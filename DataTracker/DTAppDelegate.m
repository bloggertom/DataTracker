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
#define DEBUG_ALERTVIEW 0


@interface DTAppDelegate ()
@property (nonatomic, strong)NSURL *ubiquityContainerURL;
@end

@implementation DTAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	//[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
#if USE_ICLOUD
		//Check iCloud availability
	id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
	if (currentiCloudToken) {
		NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject:currentiCloudToken];
		[[NSUserDefaults standardUserDefaults]setObject:newTokenData forKey:@"com.apple.DataTracker.UbiquityIdentityToken"];
		
	}else{
		[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"com.apple.DataTracker.UbiquityIdentityToken"];
	}
	
		//Invite user to use iCloud on initial launch
	if (currentiCloudToken && ![[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"]){
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Choose Data Storage" message:@"Would you like to use iCloud for data Storage?" delegate:self cancelButtonTitle:@"Local Only" otherButtonTitles:@"Use iCloud Only", nil];
		[alert show];
	}else{
		[self userHasMadeStorageChoice];
	}
		//[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(iCloudAvailabilityChange) name:NSUbiquityIdentityDidChangeNotification object:nil];
#endif
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		_mainIPadController = [[DTiPadViewController alloc]init];
		self.window.rootViewController = _mainIPadController;
	}else{
		//check reachability
		_reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
		_reachability.reachableOnWWAN = YES;
		_mainIPhoneController = [[DTMainViewController alloc]init];
		_mainIPhoneController.reach = _reachability;
		self.window.rootViewController = _mainIPhoneController;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reachabilityChanged:)
													 name:kReachabilityChangedNotification
												   object:nil];
		
		[self reachabilityChanged:nil];
	}
    [self.window makeKeyAndVisible];

	
	
	
	
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
	if (_mainIPhoneController) {
		[_mainIPhoneController beginTracking];
	}
	
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	//[self reachabilityChanged:nil];
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
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
		
		if([[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"]isEqualToString: DTDataStorageICloud]){
			
			
			[options setObject:@"DataTracker_iCloud_Store" forKey:NSPersistentStoreUbiquitousContentNameKey];
			[options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
			
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
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
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
@end
