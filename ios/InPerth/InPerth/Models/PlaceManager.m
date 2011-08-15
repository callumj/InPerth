//
//  PlaceManager.m
//  InPerth
//
//  Created by Callum Jones on 16/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "PlaceManager.h"


@implementation PlaceManager

-(void)savePlace:(Place *)stub
{
    NSError *err = nil;
    [dataContext save:&err];
    if (err != nil)
        NSLog(@"Err: %@", [err description]);
}

-(void)commitStubFromDictionary:(NSDictionary *)jsonData
{
    NSString *key = [jsonData objectForKey:@"key"];
    
    NSString *createdString = [jsonData objectForKey:@"created_at"];
    NSDate *createdAt = [dateFormatter dateFromString:createdString];
    if (createdAt == nil)
        createdAt = [NSDate date];
    
    NSString *updatedString = [jsonData objectForKey:@"updated_at"];
    NSDate *updatedAt = [dateFormatter dateFromString:updatedString];
    if (updatedAt == nil)
        updatedAt = [NSDate date];
    
    NSString *tag_join = @"";
    if (![[jsonData objectForKey:@"tags"] isKindOfClass:[NSNull class]])
    {
        NSArray *tags = [jsonData objectForKey:@"tags"];
        tag_join = [tags componentsJoinedByString:@", "];
    }
    
    NSArray *classifiers = [jsonData objectForKey:@"classifiers"];
    NSString *classifier = nil;
    if (![classifier isKindOfClass:[NSNull class]] && [classifiers count] > 0)
        classifier = [classifiers objectAtIndex:0];
    else
        classifier = @"none";
    
    Place *obj = [self createPlaceWithTitle:[jsonData objectForKey:@"title"] createdAt:createdAt lastUpdated:updatedAt phone:[jsonData objectForKey:@"phone"] address:[jsonData objectForKey:@"address"] suburb:[jsonData objectForKey:@"suburb"] description:[jsonData objectForKey:@"description"] type:[jsonData objectForKey:@"type"] serverKey:[jsonData objectForKey:@"_id"]];
    
    if (![[jsonData objectForKey:@"urbanspoon_uri"] isKindOfClass:[NSNull class]])
        [obj setUrbanspoonURI:[jsonData objectForKey:@"urbanspoon_uri"]];
    
    if (![[jsonData objectForKey:@"foursquare_uri"] isKindOfClass:[NSNull class]])
        [obj setFoursquareURI:[jsonData objectForKey:@"foursquare_uri"]];
    
    if (![[jsonData objectForKey:@"google_uri"] isKindOfClass:[NSNull class]])
        [obj setGoogleURI:[jsonData objectForKey:@"google_uri"]];
    
    if (![[jsonData objectForKey:@"site_uri"] isKindOfClass:[NSNull class]])
        [obj setSiteURI:[jsonData objectForKey:@"site_uri"]];
    
    if (![[jsonData objectForKey:@"lat"] isKindOfClass:[NSNull class]])
    {
        CGFloat floatVal = [(NSString *)[jsonData objectForKey:@"lat"] floatValue];
        [obj setLatitude:[NSNumber numberWithFloat:floatVal]];
    }
    
    if (![[jsonData objectForKey:@"long"] isKindOfClass:[NSNull class]])
    {
        CGFloat floatVal = [(NSString *)[jsonData objectForKey:@"long"] floatValue];
        [obj setLongitude:[NSNumber numberWithFloat:floatVal]];
    }
    
    [obj setTags:tag_join];
    
    //form relationships
    if (![[jsonData objectForKey:@"stubs"] isKindOfClass:[NSNull class]])
    {
        StubManager *sManager = [[StubManager alloc] initWithExistingContext:dataContext];
        NSArray *stubs = [jsonData objectForKey:@"stubs"];
        NSMutableSet *allStubs = [obj mutableSetValueForKey:@"Stubs"];
        for (NSString *stubServerKey in stubs)
        {
            Stub *related = [sManager getStubForKey:stubServerKey];
            if (related != nil)
                [allStubs addObject:related];
        }
    }
    [self savePlace:obj];
}

-(Place *)createPlaceWithTitle:(NSString *)title createdAt:(NSDate *)createdAt lastUpdated:(NSDate *)lastUpdated phone:(NSString *)phone address:(NSString *)address suburb:(NSString *)suburb description:(NSString *)description type:(NSString *)type serverKey:(NSString *)key
{
        //perform a sanity check
        Place *existingPlace = [self getPlaceForKey:key];
        if (existingPlace != nil)
            return existingPlace;
        
        Place *newPlace = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:dataContext];
        
    if (![title isKindOfClass:[NSNull class]])
        [newPlace setTitle:title];
    
    if (![createdAt isKindOfClass:[NSNull class]])
        [newPlace setCreatedAt:createdAt];
    
    if (![lastUpdated isKindOfClass:[NSNull class]])
        [newPlace setLastUpdated:lastUpdated];
    
    if (![phone isKindOfClass:[NSNull class]])
        [newPlace setPhone:phone];
    
    if (![address isKindOfClass:[NSNull class]])
        [newPlace setAddress:address];
    
    if (![suburb isKindOfClass:[NSNull class]])
        [newPlace setSuburb:suburb];
    
    if (![description isKindOfClass:[NSNull class]])
        [newPlace setDescription:description];
    
    if (![type isKindOfClass:[NSNull class]])
        [newPlace setType:type];
    
    
    [newPlace setServerKey:key];
    
    return newPlace;
}

-(Place *)getPlaceForKey:(NSString *)key
{    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:dataContext]; 
    
    NSPredicate *query = [NSPredicate predicateWithFormat:@"ServerKey == %@", key];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:query];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    Place *returnObj = nil;
    if ([results count] >= 1)
        returnObj = [results objectAtIndex:0];
    
    //clear up memory
    [results release];
    [request release];
    
    return returnObj;
}

-(Place *)getPlaceForStubKey:(NSString *)serverKey
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:dataContext]; 
        
    NSPredicate *search = [NSPredicate predicateWithFormat:@"ANY Stubs.ServerKey LIKE %@", serverKey]; 
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];
    [request setPredicate:search];
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    Place *returnObj = nil;
    if ([results count] >= 1)
        returnObj = [results objectAtIndex:0];
    
    //clear up memory
    [results release];
    [request release];
    
    return returnObj; 
}

-(Place *)getMostRecentUpdatedPlace
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:dataContext]; 
    
    NSSortDescriptor *sorting = [NSSortDescriptor sortDescriptorWithKey:@"LastUpdated" ascending:NO];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];
    [request setSortDescriptors:[NSArray arrayWithObject:sorting]];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    Place *returnObj = nil;
    if ([results count] >= 1)
        returnObj = [results objectAtIndex:0];
    
    //clear up memory
    [results release];
    [request release];
    
    return returnObj; 
}

-(NSArray *)getStubsForPlace:(NSString *)key
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stub" inManagedObjectContext:dataContext]; 
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Place.ServerKey == %@", key];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *results = [[dataContext executeFetchRequest:request error:&error] copy]; 
    
    [dateSort release];
    [request release];
    
    return [results autorelease]; 
}
@end
