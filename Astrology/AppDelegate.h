//
//  AppDelegate.h
//  Astrology
//
//  Created by coneits on 9/1/16.
//  Copyright © 2016 zaltan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MFSideMenuContainerViewController.h"
#import "SideMenuVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MFSideMenuContainerViewController *container;   //MainRootVC( = leftSideMenuVC + TabBarController)
    SideMenuVC *leftMenuViewController; //leftSideMenuVC
}

@property (strong, nonatomic) UIWindow *window;

extern NSString *asShortCutType;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) openHome;
- (void) openCreateChart;
- (void) openSavedChart;
- (void) openTransit;
- (void) openSettings;
- (void) openHelp;
- (void) openShop;
- (void) openContact;

@property(nonatomic,retain) SideMenuVC *sideMenu;

@end

