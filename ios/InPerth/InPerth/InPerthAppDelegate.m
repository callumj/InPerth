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
@synthesize navigationController;
@synthesize documentsPath;
@synthesize offlineCacheDir;
@synthesize metaData;
@synthesize mustAnimateWeather;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.mustAnimateWeather = YES;
    self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    offlineDownloadInProgress = NO;
    
    self.metaData = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/metadata.plist", self.documentsPath]];
    if (self.metaData == nil)
        self.metaData = [[NSMutableDictionary alloc] init];
    [self runUpdateTimer:nil];
    
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.navigationController;
    [self.navigationController pushViewController:self.tabBarController animated:YES];
    [self.window makeKeyAndVisible];
    
    //create required offline cache
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    self.offlineCacheDir = [NSString stringWithFormat:@"%@/offline_cache", self.documentsPath];
    BOOL isDir;
    if(![fileManager fileExistsAtPath:self.offlineCacheDir isDirectory:&isDir])
        if(![fileManager createDirectoryAtPath:self.offlineCacheDir withIntermediateDirectories:YES attributes:nil error:NULL])
            self.offlineCacheDir = nil;
    
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
    self.mustAnimateWeather = YES;
    [self performSelectorInBackground:@selector(getLatestDataFromServer) withObject:nil];
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
    [navigationController release];
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

-(void)runUpdateTimer:(NSTimer *)timer
{
    NSLog(@"Updated timer invoked");
    [self performSelectorInBackground:@selector(getLatestDataFromServer) withObject:nil];
    [NSTimer scheduledTimerWithTimeInterval:kServerUpdateTimer target:self selector:@selector(runUpdateTimer:) userInfo:nil repeats:NO];
}

#pragma mark Remote server fetch
-(void)getLatestDataFromServer
{
    if (!fetchInProgress)
    {
        fetchInProgress = YES;
        [self getLatestWeatherDataFromServer];
        [self getLatestStubDataFromServer];
        [self getLatestPlaceDataFromServer];
        [self performSelectorInBackground:@selector(processOfflineArchives) withObject:nil];
        fetchInProgress = NO;
    }
}

-(void)getLatestStubDataFromServer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //check if we have already have a complete set, and just want the server to give us new data
    StubManager *manager = [[StubManager alloc] initWithNewContext];
    
    Stub *mostRecent = [manager getMostRecentStub];
    
    //fetch from URL
    NSString *path = nil;
    if (mostRecent == nil)
        path = @"/stub/all.json";
    else
    {
        NSTimeInterval time;
        if ([mostRecent LastUpdated] != nil)
           time = [[mostRecent LastUpdated] timeIntervalSince1970];
        else
           time = [[mostRecent Date] timeIntervalSince1970];
        time -= [[NSTimeZone localTimeZone] secondsFromGMT];
        NSNumber *objNumber = [NSNumber numberWithDouble:time];
        path = [NSString stringWithFormat:@"/stub/all.json?since=%@", objNumber];
    }
    
    NSData *data = [self getDataFromServer:path];
    
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
    
    Stub *mostRecentAfterRun = [manager getMostRecentStub];
    
    //perform compare
    BOOL isDiff = NO;
    if (mostRecent != nil && mostRecentAfterRun != nil)
    {
        NSTimeInterval diff = [[mostRecentAfterRun Date] timeIntervalSinceDate:[mostRecent Date]];
        if (diff != 0)
            isDiff = YES;
    }
    else
    {
        isDiff = YES;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kStubDataRefreshCompleteNotification object:[NSNumber numberWithBool:isDiff]];
    
    [manager release];
    [pool release];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)getLatestPlaceDataFromServer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //check if we have already have a complete set, and just want the server to give us new data
    PlaceManager *manager = [[PlaceManager alloc] initWithNewContext];
    
    Place *mostRecent = [manager getMostRecentUpdatedPlace];
    
    //fetch from URL
    NSURL *url = nil;
    NSString *path;
    if (mostRecent == nil)
        path = @"/place/all.json";
    else
    {
        NSTimeInterval time = [[mostRecent LastUpdated] timeIntervalSince1970];
        time -= [[NSTimeZone localTimeZone] secondsFromGMT];
        NSNumber *objNumber = [NSNumber numberWithDouble:time];
        path = [NSString stringWithFormat:@"/place/all.json?since=%@", objNumber];
    }
    
    NSData *data = [self getDataFromServer:path];
    
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
    
    Place *mostRecentAfterRun = [manager getMostRecentUpdatedPlace];
    
    //perform compare
    BOOL isDiff = NO;
    if (mostRecent != nil && mostRecentAfterRun != nil)
    {
        NSTimeInterval diff = [[mostRecentAfterRun LastUpdated] timeIntervalSinceDate:[mostRecent LastUpdated]];
        if (diff != 0)
            isDiff = YES;
    }
    else
    {
        isDiff = YES;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlaceDataRefreshCompleteNotification object:[NSNumber numberWithBool:isDiff]];
    
    [manager release];
    [pool release];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)getLatestWeatherDataFromServer
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData *data = [self getDataFromServer:@"meta/weather.json"];
    
    if (data != nil)
    {
        JSONDecoder *decoder = [JSONDecoder decoder];
        NSDictionary *jsonData = [decoder objectWithData:data];
        NSDictionary *innerData = [jsonData objectForKey:@"data"];
        if (innerData != nil)
        {
            NSDictionary *weatherData = [innerData objectForKey:@"meta"];
            if (weatherData != nil)
            {
                [self.metaData addEntriesFromDictionary:[NSDictionary dictionaryWithObject:weatherData forKey:@"weather"]];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWeatherDataRefreshCompleteNotification object:nil];
    [self.metaData writeToFile:[NSString stringWithFormat:@"%@/metadata.plist", self.documentsPath] atomically:YES];
    [pool release];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


#pragma mark Core Data
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator == nil) {
        NSURL *storeUrl = [NSURL fileURLWithPath:[self persistentStorePath]];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        NSError *error = nil;
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
        if (persistentStore == nil)
        {
            [persistentStoreCoordinator release];
            persistentStoreCoordinator = nil;
            [[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error];
            return [self persistentStoreCoordinator];
        }
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

-(void)processOfflineArchives
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (!offlineDownloadInProgress)
    {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        ZipArchive *archiveHelper = [[ZipArchive alloc] init];
        NSFileManager *fileHelper = [NSFileManager defaultManager];
        
        offlineDownloadInProgress = YES;
        StubManager *manager = [[StubManager alloc] initWithNewContext];
        NSArray *pendingDownload = [manager getStubsPendingOfflineDownloadWithLimit:50];
        
        NSString *tmpDir = NSTemporaryDirectory();
        
        if (self.offlineCacheDir != nil)
        {
            for (Stub *stub in pendingDownload)
            {
                NSString *offlineURI = [stub OfflineArchive];
                if ([offlineURI length] > 0)
                {
                    NSURL *url = [NSURL URLWithString:offlineURI];
                    NSData *contents = [NSData dataWithContentsOfURL:url];
                    if (contents != nil)
                    {
                        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@.zip", tmpDir, [stub ServerKey]];
                        if ([contents writeToFile:tmpPath atomically:NO])
                        {
                            if ([archiveHelper UnzipOpenFile:tmpPath])
                            {
                                NSString *cache_path = [NSString stringWithFormat:@"%@/%@", self.offlineCacheDir, [stub ServerKey]];
                                if ([archiveHelper UnzipFileTo:cache_path overWrite:YES])
                                {
                                    NSError *error = nil;
                                    NSArray *allFiles = [fileHelper contentsOfDirectoryAtPath:cache_path error:&error];
                                    NSString *webPage = nil;
                                    for (NSString *file in allFiles)
                                    {
                                        if ([[file pathExtension] isEqualToString:@"html"])
                                            webPage = file;
                                    }
                                    
                                    if (webPage == nil)
                                    {
                                        NSLog(@"Could not locate page");
                                    }
                                    
                                    [stub setOfflineArchive:webPage];
                                    [stub setOfflineDownloaded:[NSNumber numberWithBool:YES]];
                                    [manager saveStub:stub];
                                    [fileHelper removeItemAtPath:tmpPath error:&error];
                                }
                            }
                        }
                    }
                }
            }
        }
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        offlineDownloadInProgress = NO;
    }
    [pool release];
}

-(NSData *)getDataFromServer:(NSString *) path
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://perth-proxy.mullac.org/%@", path]];
    NSLog(@"Making request to %@", [url absoluteString]);
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data == nil)
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://perth.mullac.org/%@", path]];
        NSLog(@"Primary server unavailable, making request to %@", [url absoluteString]);
        data = [NSData dataWithContentsOfURL:url];
    }
    
    return data;
}

-(void)presentMailControlWithSubject:(NSString *)subject andMessageBody:(NSString *)body
{
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:subject];
        [mailViewController setMessageBody:body isHTML:NO];
        
        [self.navigationController presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
        
    }
}

- (void)presentTweetControlerWithText:(NSString *)text andURL:(NSString *)url
{
    TweetViewController *shareController = [[TweetViewController alloc] init];
    [shareController setMessageText:[NSString stringWithFormat:text]];
    [shareController setLocationURI:url];
    
    [self.navigationController presentModalViewController:shareController animated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

@end
