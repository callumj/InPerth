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
#import "PlaceManager.h"

#define kStubDataRefreshCompleteNotification @"StubDataRefreshCompleteNotification"
#define kWeatherDataRefreshCompleteNotification @"WeatherDataRefreshCompleteNotification"
#define kPlaceDataRefreshCompleteNotification @"PlaceDataRefreshCompleteNotification"

#define kServerUpdateTimer 5 * 60

@interface InPerthAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString *persistentStorePath;
    NSManagedObjectContext *managedObjectContext;
    UINavigationController *navigationController;
    BOOL fetchInProgress;
    
    BOOL offlineDownloadInProgress;
}

@property (nonatomic, retain) NSMutableDictionary *metaData;
@property (nonatomic, retain) NSString *documentsPath;
@property (nonatomic, retain) NSString *offlineCacheDir;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic) BOOL mustAnimateWeather;

#pragma mark Remote server fetch
-(void)runUpdateTimer:(NSTimer *)timer;
-(void)getLatestDataFromServer;
-(void)getLatestStubDataFromServer;
-(void)getLatestPlaceDataFromServer;
-(void)getLatestWeatherDataFromServer;
-(NSData *)getDataFromServer:(NSString *) path;
-(void)processOfflineArchives;

#pragma mark Core Data
-(NSManagedObjectContext *)managedObjectContext;
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;
-(NSString *)persistentStorePath;
@end
