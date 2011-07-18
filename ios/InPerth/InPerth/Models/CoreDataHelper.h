//
//  CoreDataHelper.h
//  InPerth
//
//  Created by Callum Jones on 6/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InPerthAppDelegate;

@interface CoreDataHelper : NSObject {
    
}
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSString *)persistentStorePath;
@end
