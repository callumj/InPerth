//
//  PlaceManager.h
//  InPerth
//
//  Created by Callum Jones on 16/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"
#import "BaseManager.h"
#import "StubManager.h"

@interface PlaceManager : BaseManager {
    
}

-(Place *)createPlaceWithTitle:(NSString *)title createdAt:(NSDate *)createdAt lastUpdated:(NSDate *)lastUpdated phone:(NSString *)phone address:(NSString *)address suburb:(NSString *)suburb description:(NSString *)description type:(NSString *)type serverKey:(NSString *)key;
-(void)savePlace:(Place *)stub;
-(Place *)getPlaceForKey:(NSString *)key;
-(Place *)getPlaceForStubKey:(NSString *)serverKey;
-(Place *)getMostRecentUpdatedPlace;
-(void)commitStubFromDictionary:(NSDictionary *)jsonData;

@end
