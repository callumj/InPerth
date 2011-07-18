//
//  BaseManager.h
//  InPerth
//
//  Created by Callum Jones on 16/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"

@class InPerthAppDelegate;
@class CoreDataHelper;

@interface BaseManager : NSObject {
    NSMutableDictionary *instanceCache;
    NSManagedObjectContext *dataContext;
    NSDateFormatter *dateFormatter;
}

-(id)initWithExistingContext:(NSManagedObjectContext *)context;
-(id)initWithNewContext;

@end
