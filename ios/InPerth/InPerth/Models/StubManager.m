//
//  StubManager.m
//  InPerth
//
//  Created by Callum Jones on 6/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "StubManager.h"

@implementation StubManager

@synthesize existingProviderManager;

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        self.existingProviderManager = nil;
    }
    
    return self;
}

-(id)initWithExistingContext:(NSManagedObjectContext *)context
{
    self = [super initWithExistingContext:context];
    if (self != nil)
    {
        self.existingProviderManager = nil;
    }
    
    return self;
}

-(id)initWithNewContext
{
    self = [super initWithNewContext];
    if (self != nil)
    {
        self.existingProviderManager = nil;
    }
    
    return self; 
}

#pragma mark object management operations
-(Stub *)createStubWithTitle:(NSString *)title serverKey:(NSString *)key uri:(NSString *)uri description:(NSString *)description tags:(NSString *)tags classifier:(NSString *)classifier date:(NSDate *)date contentProvider:(Provider *)provider
{
    //perform a sanity check
    Stub *newStub = [self getStubForKey:key];
    if (newStub == nil)
        newStub = (Stub *)[NSEntityDescription insertNewObjectForEntityForName:@"Stub" inManagedObjectContext:dataContext];
    
    [newStub setTitle:title];
    [newStub setServerKey:key];
    [newStub setURI:uri];
    [newStub setDescription:description];
    [newStub setTags:tags];
    [newStub setClassifier:classifier];
    if ([newStub Date] == nil)
        [newStub setDate:date];
    [newStub setContentProvider:provider];
    
    return newStub;
}

-(void)saveStub:(Stub *)stub
{
    NSError *err = nil;
    [dataContext save:&err];
    if (err != nil)
        NSLog(@"Err: %@", [err description]);
}

#pragma mark JSON helper operations
-(void)commitStubFromDictionary:(NSDictionary *)jsonData
{
    NSString *key = [jsonData objectForKey:@"key"];
    if ([self getStubForKey:key] != nil)
        return;
    
    if (self.existingProviderManager == nil)
    {
        ProviderManager *man = [[ProviderManager alloc] initWithExistingContext:dataContext];
        [self setExistingProviderManager:man];
        [man release];
    }
    
    NSDictionary *provInfo = [jsonData objectForKey:@"provider"];
    if (provInfo == nil)
        return;
    
    NSString *timeString = [jsonData objectForKey:@"time"];
   
    NSDate *date = [dateFormatter dateFromString:timeString];    
    NSArray *tags = [jsonData objectForKey:@"tags"];
    NSString *tag_join = [tags componentsJoinedByString:@", "];
    NSArray *classifiers = [jsonData objectForKey:@"classifiers"];
    
    NSString *classifier = nil;
    if ([classifiers count] > 0)
        classifier = [classifiers objectAtIndex:0];
    else
        classifier = @"none";
    
    Provider *prov = [self.existingProviderManager fetchOrCreateProviderWithKey:[provInfo objectForKey:@"id"] title:[provInfo objectForKey:@"title"]];
    
    Stub *obj = [self createStubWithTitle:[jsonData objectForKey:@"title"] serverKey:[jsonData objectForKey:@"key"] uri:[jsonData objectForKey:@"uri"] description:[jsonData objectForKey:@"desc"] tags:tag_join classifier:classifier date:date contentProvider:prov];
    
    if (![[jsonData objectForKey:@"offline_archive"] isKindOfClass:[NSNull class]])
    {
        [obj setOfflineDownloaded:[NSNumber numberWithBool:NO]];
        [obj setOfflineArchive:[jsonData objectForKey:@"offline_archive"]];
    }
    
    if (![[jsonData objectForKey:@"updated_at"] isKindOfClass:[NSNull class]])
    {
        NSString *updateString = [jsonData objectForKey:@"updated_at"];
        NSDate *updateDate = [dateFormatter dateFromString:updateString];
        [obj setLastUpdated:updateDate];
    }
        
    
    [self saveStub:obj];
}

#pragma mark Query

-(Stub *)getStubForKey:(NSString *)key
{
    Stub *cacheLookup = [instanceCache objectForKey:key];
    if (cacheLookup != nil)
        return cacheLookup;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"ServerKey == %@", key];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:query];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    Stub *returnObj = nil;
    if ([results count] >= 1)
        returnObj = [results objectAtIndex:0];
    
    //clear up memory
    [results release];
    [request release];
    
    if (returnObj != nil)
        [instanceCache setObject:returnObj forKey:key];
    
    return returnObj;
}

-(Stub *)getMostRecentStub
{    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setFetchLimit:1];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    Stub *returnObj = nil;
    if ([results count] >= 1)
        returnObj = [results objectAtIndex:0];
    
    //clear up memory
    [dateSort release];
    [results release];
    [request release];
    
    if (returnObj != nil)
        [instanceCache setObject:returnObj forKey:[returnObj ServerKey]];
    
    return returnObj; 
}

-(NSArray *)getStubsWithLimit:(int)limit
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setFetchLimit:limit];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    [dateSort release];
    [request release];
    
    return [results autorelease];
}

-(NSArray *)getStubsPendingOfflineDownloadWithLimit:(int)limit
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"OfflineArchive != nil AND (OfflineDownloaded == NO || OfflineDownloaded == nil)"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setFetchLimit:limit];
    [request setPredicate:query];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    [dateSort release];
    [request release];
    
    return [results autorelease];
}

-(NSArray *)getStubsWithLimit:(int)limit olderThanDate:(NSDate *)date
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Date < %@", date];
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setFetchLimit:limit];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    [dateSort release];
    [request release];
    
    return [results autorelease];  
}

-(NSArray *)getStubsForClassifier:(NSString *)classifier withLimit:(int)limit
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Classifier == %@", classifier];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setFetchLimit:limit];
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    [dateSort release];
    [request release];
    
    return [results autorelease]; 
}

-(NSArray *)getStubsForClassifier:(NSString *)classifier withLimit:(int)limit olderThanDate:(NSDate *)date
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Classifier == %@ AND Date < %@", classifier, date];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setFetchLimit:limit];
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    [dateSort release];
    [request release];
    
    return [results autorelease];   
}

-(void)dealloc
{
    [super dealloc];
    [existingProviderManager release];
}
@end
