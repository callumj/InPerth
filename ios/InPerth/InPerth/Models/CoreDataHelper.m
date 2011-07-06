//
//  CoreDataHelper.m
//  InPerth
//
//  Created by Callum Jones on 6/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "CoreDataHelper.h"


@implementation CoreDataHelper

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    NSURL *storeUrl = [NSURL fileURLWithPath:[CoreDataHelper persistentStorePath]];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    NSError *error = nil;
    NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
    NSAssert3(persistentStore != nil, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    return [persistentStoreCoordinator autorelease];
}

+ (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:[CoreDataHelper persistentStoreCoordinator]];
    return [managedObjectContext autorelease];
}

+ (NSString *)persistentStorePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    NSString * persistentStorePath = [documentsDirectory stringByAppendingPathComponent:@"Model.sqlite"];
    return persistentStorePath;
}
@end
