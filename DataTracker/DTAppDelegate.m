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
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(iCloudAvailabilityChange) name:NSUbiquityIdentityDidChangeNotification object:nil];
#endif
	
		//check reachability
	_reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
	_reachability.reachableOnWWAN = YES;
	
	
	
    _mainController = [[DTMainViewController alloc]init];
	_mainController.reach = _reachability;
	self.window.rootViewController = _mainController;
	
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
	[self reachabilityChanged:nil];
	
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
	[_reachability stopNotifier];
}

-(void)reachabilityChanged:(NSNotification *)notification{
	NSLog(@"Reachability Changed");
	if (_reachability.isReachableViaWWAN) {
		[_mainController beginTracking];
	}else{
		[_mainController stopTracking];
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
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataTracker.sqlite"];
	
	NSDictionary *options = nil;
	
	if([[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"]isEqualToString: DTDataStorageICloud]){
		options = [[NSDictionary alloc]initWithObjectsAndKeys:@"DataTracker_iCloud_Store",NSPersistentStoreUbiquitousContentNameKey, nil];
		NSLog(@"Set up options for ubiquity container");
	}
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
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
		
		[[NSNotificationCenter defaultCenter]addObserver:_mainController selector:@selector(dataStoreDidUpdateFromUbiquityContainer) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
		/*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self setUpUbiquityContainer];
			
		});*/
		
	}else{
		NSLog(@"Unknown Storage Option chosen");
	}
	[self userHasMadeStorageChoice];
}

-(void)userHasMadeStorageChoice{
	[[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"com.apple.DataTracker.FirstLaunchWithiCloud"];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name:kReachabilityChangedNotification
											   object:nil];
	if (_reachability.reachableOnWWAN) {
		[_mainController beginTracking];
	}
}
@end
