//
//  StubManager.h
//  InPerth
//
//  Created by Callum Jones on 6/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Stub.h"
#import "Provider.h"
#import "ProviderManager.h"
#import "BaseManager.h"

@class ProviderManager;
@class BaseManager;

@interface StubManager :BaseManager {
}

@property (nonatomic, retain) ProviderManager *existingProviderManager;

-(Stub *)createStubWithTitle:(NSString *)title serverKey:(NSString *)key uri:(NSString *)uri description:(NSString *)description tags:(NSString *)tags classifier:(NSString *)classifier date:(NSDate *)date contentProvider:(Provider *)provider;
-(void)saveStub:(Stub *)stub;

-(void)commitStubFromDictionary:(NSDictionary *)jsonData;

-(Stub *)getStubForKey:(NSString *)key;
-(Stub *)getMostRecentStub;

-(NSArray *)getStubsForClassifier:(NSString *)classifier;
-(NSArray *)getStubsForClassifier:(NSString *)classifier withLimit:(int)limit;
-(NSArray *)getStubsForClassifier:(NSString *)classifier withLimit:(int)limit olderThanDate:(NSDate *)date;
-(NSArray *)getStubsForClassifier:(NSString *)classifier sinceDate:(NSDate *)date;
-(NSArray *)getStubsWithLimit:(int)limit;
-(NSArray *)getStubsWithLimit:(int)limit olderThanDate:(NSDate *)date;
-(NSArray *)getStubsPendingOfflineDownloadWithLimit:(int)limit;

+(NSString *)getOfflineLocationForStub:(NSString *)stubServerKey;
@end
