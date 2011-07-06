//
//  ProviderManager.h
//  InPerth
//
//  Created by Callum Jones on 6/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "InPerthAppDelegate.h"
#import "CoreDataHelper.h"
#import "Provider.h"

@interface ProviderManager : NSObject {
    NSMutableDictionary *instanceCache;
    NSManagedObjectContext *dataContext;
}

-(id)initWithExistingContext:(NSManagedObjectContext *)context;
-(id)initWithNewContext;

-(Provider *)createProviderWithTitle:(NSString *)title serverKey:(NSString *)key;
-(Provider *)fetchOrCreateProviderWithKey:(NSString *)key title:(NSString *)title;
-(void)saveProvider:(Provider *)provider;

-(Provider *)getProviderForKey:(NSString *)key;
-(NSArray *)getAllProviders;
@end
