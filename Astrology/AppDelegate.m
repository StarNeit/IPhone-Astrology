//
//  AppDelegate.m
//  Astrology
//
//  Created by coneits on 9/1/16.
//  Copyright © 2016 zaltan. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeVC.h"
#import "CreateChartVC.h"
#import "SavedChartVC.h"
#import "TransitVC.h"
#import "SettingsVC.h"
#import "HelpVC.h"
#import "ContactVC.h"
#import "ShopVC.h"

@import GooglePlaces;

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString *asShortcutType;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    HomeVC *vc = [[HomeVC alloc] init];
    
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:[NSString stringWithFormat:@"SideMenuVC%@", IS_IPAD?@"_iPad":@""] bundle:nil];
    
    
    
    //---SETTING MAIN ROOTVC AS CONTAINER(TABBAR + LEFTMENUVC)---
    container = [MFSideMenuContainerViewController
                 containerWithCenterViewController:[[UINavigationController alloc] initWithRootViewController:vc]
                 leftMenuViewController:leftMenuViewController
                 rightMenuViewController:nil];
    
    
    
    //---SETTING ROOTVC---
    self.window.rootViewController = container;
    
    [GMSPlacesClient provideAPIKey:@"AIzaSyAKpQ3qcYbjIWmZFR22t3z1Nw7wjeJmrB0"];
    
   
    
    
    //---Count 5 Settings---//
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ( ![userDefaults valueForKey:@"version"] )
    {
        [USER_DEFAULT setValue:@"5" forKey:@"remain_count"];
        
        // Adding version number to NSUserDefaults for first version:
        [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] forKey:@"version"];
    }
    if ([[NSUserDefaults standardUserDefaults] floatForKey:@"version"] == [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] )
    {
        /// Same Version so dont run the function
    }
    else
    {
        [USER_DEFAULT setValue:@"5" forKey:@"remain_count"];
        
        // Update version number to NSUserDefaults for other versions:
        [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] forKey:@"version"];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ah.iosapp.Astrology" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Astrology" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Astrology.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



-(void) openHome{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    HomeVC *vc =[[HomeVC alloc] initWithNibName:@"HomeVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                        containerWithCenterViewController:naviSetting
                        leftMenuViewController:leftMenuViewController
                        rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}

-(void) openCreateChart{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    CreateChartVC *vc =[[CreateChartVC alloc] initWithNibName:@"CreateChartVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                                                           containerWithCenterViewController:naviSetting
                                                           leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}

-(void) openSavedChart{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    SavedChartVC *vc =[[SavedChartVC alloc] initWithNibName:@"SavedChartVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                                                           containerWithCenterViewController:naviSetting
                                                           leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}


-(void) openTransit{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    TransitVC *vc =[[TransitVC alloc] initWithNibName:@"TransitVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                                                           containerWithCenterViewController:naviSetting
                                                           leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}

-(void) openSettings{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    SettingsVC *vc =[[SettingsVC alloc] initWithNibName:@"SettingsVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                                                           containerWithCenterViewController:naviSetting
                                                           leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}


-(void) openHelp{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    HelpVC *vc =[[HelpVC alloc] initWithNibName:@"HelpVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                                                           containerWithCenterViewController:naviSetting
                                                           leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}


-(void) openContact{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    ContactVC *vc =[[ContactVC alloc] initWithNibName:@"ContactVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                                                           containerWithCenterViewController:naviSetting
                                                           leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}


-(void) openShop{
    leftMenuViewController  = [[SideMenuVC alloc] initWithNibName:IS_IPAD?@"SideMenuVC_iPad":@"SideMenuVC" bundle:[NSBundle mainBundle]];
    ShopVC *vc =[[ShopVC alloc] initWithNibName:@"ShopVC" bundle:[NSBundle mainBundle]];
    UINavigationController* naviSetting = [[UINavigationController alloc] initWithRootViewController:vc];
    MFSideMenuContainerViewController* containerSetting = [MFSideMenuContainerViewController
                                                           containerWithCenterViewController:naviSetting
                                                           leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:nil];
    self.window.rootViewController = containerSetting;
}


-(void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    BOOL bSucceeded = NO;
    
    if ([shortcutItem.type isEqual: @"com.ah.Astrology.CreateChart"])
    {
        asShortcutType = @"CreateChart";
        bSucceeded = YES;
    }
}


@end
