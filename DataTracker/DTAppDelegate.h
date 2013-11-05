//
//  DTAppDelegate.h
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define USE_ICLOUD 1

@class DTMainViewController;
@class Reachability;
@class DTiPadViewController;

static NSString * const DTDataStorageICloud = @"iCloud";
static NSString * const DTDataStorageLocal = @"Local";
static NSString *const UserChoseStorageTypeNotification = @"StoryTypeChosen";

@interface DTAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) DTMainViewController *mainIPhoneController;
@property (readonly, strong, nonatomic) DTiPadViewController *mainIPadController;

@property (nonatomic, strong)Reachability *reachability;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
