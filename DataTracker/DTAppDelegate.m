//
//  DTAppDelegate.m
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTAppDelegate.h"
#import "DTMainViewController.h"
#import "Reachability.h"
#import "DTiPadViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#define DEBUG_ALERTVIEW 0
#define DEBUG_GOOGLE 1

@interface DTAppDelegate ()
@property (nonatomic, strong)NSURL *ubiquityContainerURL;
@end

@implementation DTAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
		//self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	//[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

		//Check iCloud availability
	id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
	if (currentiCloudToken) {
		NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject:currentiCloudToken];
		[[NSUserDefaults standardUserDefaults]setObject:newTokenData forKey:@"com.apple.DataTracker.UbiquityIdentityToken"];
		
	}else{
		NSLog(@"removing icloud token");
		[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"com.apple.DataTracker.UbiquityIdentityToken"];
	}
	
		//Invite user to use iCloud on initial launch
	if (currentiCloudToken && ![[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"]){
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Choose Data Storage" message:@"Would you like to use iCloud for data Storage?" delegate:self cancelButtonTitle:@"Local Only" otherButtonTitles:@"Use iCloud Only", nil];
		[alert show];
	}else{
		[self userHasMadeStorageChoice];
	}

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		_mainIPadController = [[DTiPadViewController alloc]init];
		self.window.rootViewController = _mainIPadController;
	}else{
		//check reachability
		_reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
		_reachability.reachableOnWWAN = YES;
		_mainIPhoneController = (DTMainViewController *)self.window.rootViewController;
		_mainIPhoneController.reach = _reachability;
		/*_mainIPhoneController = [[DTMainViewController alloc]init];
		
		self.window.rootViewController = _mainIPhoneController;*/
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reachabilityChanged:)
													 name:kReachabilityChangedNotification
												   object:nil];
		
		[self reachabilityChanged:nil];
	}
	
	[GAI sharedInstance].trackUncaughtExceptions = YES;
#if DEBUG_GOOGLE
	id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-49282504-3"];
#else
	id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-49282504-1"];
#endif
	[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                           action:@"appstart"
                                                            label:nil
                                                            value:nil] set:@"start" forKey:kGAISessionControl] build]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	NSLog(@"App entering background");
		//[self reachabilityChanged:nil];
	if (_mainIPhoneController && _reachability.isReachableViaWWAN) {
		[_mainIPhoneController beginTracking];
	}
	
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[self reachabilityChanged:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	NSLog(@"Did become active");
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[_reachability stopNotifier];
	if (_mainIPhoneController) {
		[_mainIPhoneController stopTracking];
	}
	id <GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                           action:@"appfinish"
                                                            label:nil
                                                            value:nil] set:@"end" forKey:kGAISessionControl] build]];
	[self saveContext];
}

-(void)reachabilityChanged:(NSNotification *)notification{
	NSLog(@"Reachability Changed");
	if (_reachability.isReachableViaWWAN && [[NSUserDefaults standardUserDefaults] objectForKey:@"com.apple.DataTracker.StorageType"] != nil) {
		[_mainIPhoneController beginTracking];
	}else{
		[_mainIPhoneController stopTracking];
	}
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSFileManager *fileManager = [NSFileManager defaultManager];
            NSLog(@"Signal Tracker unable to save managerObjectContext.\nError: %@, %@", error, [error userInfo]);
			NSString *message = nil;
			if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"] isEqualToString:DTDataStorageICloud]) {
				id currentiCloudToken = [fileManager ubiquityIdentityToken];
				NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject:currentiCloudToken];
				if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.UbiquityIdentityToken"]isEqualToData:newTokenData]) {
					message = @"Unable to save data to iCloud due to unknow iCloud account";
				}else{
					message = @"Unable to save data to iCloud. Please check settings.";
				}
			}else{
				message = @"Signal Tracker was unable to save your data";
			}
			
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed to save!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			
			[managedObjectContext rollback];
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
        
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataTracker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	NSLog(@"Getting persistent store coordinator");
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	

		NSError *error = nil;
		NSString *storeName = @"DataTracker.sqlite";

		NSURL *localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeName];
		NSMutableDictionary *options = [[NSMutableDictionary alloc]init];
		[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
		[options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
		
	if([[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"]isEqualToString: DTDataStorageICloud]){
			
			
			[options setObject:@"DataTracker_iCloud_Store" forKey:NSPersistentStoreUbiquitousContentNameKey];
			[_persistentStoreCoordinator lock];
			[_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:localStoreURL options:options error:&error];
			[_persistentStoreCoordinator unlock];
			
		}else{
			[_persistentStoreCoordinator lock];
			[_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:localStoreURL options:nil error:&error];
			[_persistentStoreCoordinator unlock];
		}
		if (error != nil) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			 
			 Typical reasons for an error here include:
			 * The persistent store is not accessible;
			 * The schema for the persistent store is incompatible with current managed object model.
			 Check the error message to determine what the actual problem was.
			 
			 
			 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
			 
			 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
			 * Simply deleting the existing store:
			 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
			 
			 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
			 @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
			 
			 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
			 */
			NSString *message = nil;
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				//abort();
			NSFileManager *fileManager = [NSFileManager defaultManager];
			if (![fileManager isWritableFileAtPath:localStoreURL.path]) {
				NSLog(@"Directiony at path: %@, is not readable", localStoreURL.path);
				message = @"Application is unable to create persistance store, and your data will not save";
			}else{
				message = @"Application data format has changed and older data has had to be removed";
				[self resetLocalStorage];
				UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Scheme" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
				return [self persistentStoreCoordinator];
			}
			
		}
	   
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - iCloud

-(void)iCloudAvailabilityChange{
	NSLog(@"Availability changed");
	
		//Need to find out what i should do if anything here
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSString * choise = [alertView buttonTitleAtIndex:buttonIndex];
	NSLog(@"button clicked");
	if ([choise isEqualToString:@"Local Only"]) {
		
		NSLog(@"User Chose to use Local Storage");
		[[NSUserDefaults standardUserDefaults]setObject:DTDataStorageLocal forKey:@"com.apple.DataTracker.StorageType"];
		
	}else if ([choise isEqualToString:@"Use iCloud Only"]){
		
		NSLog(@"User Chose to use iCloud Storage");
		[[NSUserDefaults standardUserDefaults]setObject:DTDataStorageICloud forKey:@"com.apple.DataTracker.StorageType"];
		
		
	}else{
		NSLog(@"Unknown Storage Option chosen");
	}
	[self userHasMadeStorageChoice];
}

-(void)userHasMadeStorageChoice{
	NSNotification *notification = [NSNotification notificationWithName:UserChoseStorageTypeNotification object:nil];
	[[NSNotificationCenter defaultCenter]postNotification:notification];
}

#pragma mark - RESET!
-(BOOL)resetLocalStorage{
	
	_managedObjectContext = nil;
	_managedObjectModel = nil;
	_persistentStoreCoordinator = nil;
	
	NSFileManager *filemanager = [NSFileManager defaultManager];
	NSString *storeName = @"DataTracker.sqlite";
	NSURL *localStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeName];
	
	NSError *error = nil;
	
	if ([filemanager fileExistsAtPath:localStoreURL.path]) {
		[filemanager removeItemAtURL:localStoreURL error:&error];
	}
	if (error) {
		NSLog(@"Failed to delete local store.\n %@", error);
		return NO;
	}
	return YES;
}
@end
