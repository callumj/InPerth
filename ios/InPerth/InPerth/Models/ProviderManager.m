//
//  ProviderManager.m
//  InPerth
//
//  Created by Callum Jones on 6/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "ProviderManager.h"


@implementation ProviderManager
-(id)init
{
    self = [super init];
    if (self != nil)
    {
        InPerthAppDelegate *delegate = (InPerthAppDelegate *)[[UIApplication sharedApplication] delegate]; 
        dataContext = [[delegate managedObjectContext] retain];
        instanceCache = [[[NSMutableDictionary alloc] init] retain];
    }
    
    return self;
}

-(id)initWithExistingContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self != nil)
    {
        dataContext = [context retain];
        instanceCache = [[[NSMutableDictionary alloc] init] retain];
    }
    return self;
}

-(id)initWithNewContext
{
    self = [super init];
    if (self != nil)
    {
        dataContext = [[CoreDataHelper managedObjectContext] retain];
        instanceCache = [[[NSMutableDictionary alloc] init] retain];
    }
    return self;
}

#pragma mark object management operations
-(Provider *)createProviderWithTitle:(NSString *)title serverKey:(NSString *)key
{
    Provider *newProvider = (Provider *)[NSEntityDescription insertNewObjectForEntityForName:@"Provider" inManagedObjectContext:dataContext];
    
    [newProvider setTitle:title];
    [newProvider setServerKey:key];
    
    return newProvider;
}

-(void)saveProvider:(Provider *)provider
{
    NSError *err = nil;
    [dataContext save:&err];
    if (err != nil)
        NSLog(@"Err: %@", [err description]); 
}

-(Provider *)getProviderForKey:(NSString *)key
{
    Provider *cacheLookup = [instanceCache objectForKey:key];
    if (cacheLookup != nil)
        return cacheLookup;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Provider" inManagedObjectContext:dataContext]; 
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"ServerKey == %@", key];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:query];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    Provider *returnObj = nil;
    if ([results count] >= 1)
        returnObj = [results objectAtIndex:0];
    
    //clear up memory
    [results release];
    [request release];
    
    if (returnObj != nil)
        [instanceCache setObject:returnObj forKey:key];
    
    return returnObj;
}

-(Provider *)fetchOrCreateProviderWithKey:(NSString *)key title:(NSString *)title
{
    Provider *prov = [self getProviderForKey:key];
    if (prov == nil)
    {
        prov = [self createProviderWithTitle:title serverKey:key];
        [self saveProvider:prov];
    }
    
    return prov;
}

-(void)dealloc
{
    [dataContext release];
    [instanceCache release];
    [super dealloc];
}
@end
