//
//  InPerthAppDelegate.m
//  InPerth
//
//  Created by Callum Jones on 4/07/11.
//  Copyright 2011 mullac.org. All rights reserved.
//

#import "InPerthAppDelegate.h"

@implementation InPerthAppDelegate


@synthesize window=_window;
@synthesize tabBarController=_tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //init CD store
    NSManagedObjectContext *con = [self managedObjectContext];
    
    [self performSelectorInBackground:@selector(getLatestDataFromServer) withObject:nil];
    
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

#pragma mark Remote server fetch
-(void)getLatestDataFromServer
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //check if we have already have a complete set, and just want the server to give us new data
    StubManager *manager = [[StubManager alloc] initWithNewContext];
    
    Stub *mostRecent = [manager getMostRecentStub];
    
    //fetch from URL
    NSURL *url = nil;
    if (mostRecent == nil)
        url = [NSURL URLWithString:@"http://perth.mullac.org/stub/all.json"];
    else
    {
        NSTimeInterval time = [[mostRecent Date] timeIntervalSince1970];
        time = time - [[NSTimeZone localTimeZone] secondsFromGMT];
        NSString *paramsString = [NSString stringWithFormat:@"http://perth.mullac.org/stub/all.json?since=%d", time];
        url = [NSURL URLWithString:paramsString];
    }
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data != nil)
    {
        
        
        JSONDecoder *decoder = [JSONDecoder decoder];
        NSDictionary *jsonData = [decoder objectWithData:data];
        NSArray *databaseContents = [jsonData objectForKey:@"data"];
        if (databaseContents != nil && [databaseContents count] > 0)
        {
            for (NSDictionary *stubData in databaseContents)
            {
                [manager commitStubFromDictionary:stubData];
            }
        }
    }
    
    [pool release];
}


#pragma mark Core Data
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator == nil) {
        NSURL *storeUrl = [NSURL fileURLWithPath:persistentStorePath];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        NSError *error = nil;
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
        NSAssert3(persistentStore != nil, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (managedObjectContext == nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
    return managedObjectContext;
}

- (NSString *)persistentStorePath {
    if (persistentStorePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths lastObject];
        persistentStorePath = [[documentsDirectory stringByAppendingPathComponent:@"Model.sqlite"] retain];
    }
    return persistentStorePath;
}

@end
