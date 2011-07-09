//
//  InPerthAppDelegate.h
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSONKit.h"

#import "StubManager.h"

#define kDataRefreshCompleteNotification @"DataRefreshCompleteNotification"

@interface InPerthAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString *persistentStorePath;
    NSManagedObjectContext *managedObjectContext;
    UINavigationController *navigationController;
    
    BOOL fetchInProgress;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

#pragma mark Remote server fetch
-(void)getLatestDataFromServer;

#pragma mark Core Data
-(NSManagedObjectContext *)managedObjectContext;
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;
-(NSString *)persistentStorePath;
@end
