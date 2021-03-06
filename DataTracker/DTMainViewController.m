//
//  DTMainViewController.m
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#include <sys/sysctl.h>
#import <iAd/iAd.h>

#import "DTMainViewController.h"
#import "DTLocationDelegate.h"
#import "DTMapViewDelegate.h"
#import "Reachability.h"
#import "DTSpeedTester.h"
#import "DTMergableCircleOverlay.h"
#import "DTMMergableOverlay.h"
#import "DTAppDelegate.h"
#import "DTSettingsViewController.h"
#import "DTOverlayDetailViewController.h"
#import "DTImprovedSpeedTester.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

	//White Box Test cases
#define DEBUG_OVERLAYS 0
#define FIELD_TEST 0
#define LTE_TEST 0
#define DEBUG_BACKGROUND_ACTIVITY 0

#define DefaultSpeed 10
#define HSPAPlusSpeed 20
#define FourGSpeed 50
#define OverlayRadius 500
#define DistanceFilter 20

#define MinSpeed 0
@interface DTMainViewController ()
@property (nonatomic, strong)DTMapViewDelegate *mapViewDelegate;
@property (nonatomic, strong)DTLocationDelegate *locationDelegate;
@property (nonatomic, strong)CLLocationManager *locationManager;
	//@property (nonatomic, strong)DTSpeedTester *speedTester;
@property (nonatomic, strong)DTImprovedSpeedTester *speedTester;
@property(nonatomic, strong)CLLocation *currentLocation;
@property (nonatomic)UIBackgroundTaskIdentifier bgTask;
@property (nonatomic)NSInteger MaxSpeed;
@property (nonatomic, weak)IBOutlet UIButton *testButton;
@property (nonatomic, weak)IBOutlet UIButton *settingsButton;
@property (nonatomic, strong)id<GAITracker> tracker;
@end

@implementation DTMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_tracker = [[GAI sharedInstance] defaultTracker];
	// Do any additional setup after loading the view.
	[self correctMaxSpeed];
	self.canDisplayBannerAds = YES;
	
		//self.originalContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		//self.originalContentView.autoresizesSubviews = YES;
		//set up map view
		//_mapview = [[MKMapView alloc]initWithFrame:self.originalContentView.bounds];
	_mapViewDelegate = [[DTMapViewDelegate alloc]init];
	_mapViewDelegate.callback = self;
	_mapview.delegate = _mapViewDelegate;
	_mapview.showsUserLocation = YES;
	_mapview.mapType = [[NSUserDefaults standardUserDefaults]integerForKey:kMapType];
	
		//set up location manager
	_locationDelegate = [[DTLocationDelegate alloc]init];
	_locationManager = [[CLLocationManager alloc]init];
#if !DEBUG_OVERLAYS
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		_locationDelegate.callback = self;
	}
	
#endif
	_locationManager.delegate = _locationDelegate;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.pausesLocationUpdatesAutomatically = NO;
	
#if DEBUG_BACKGROUND_ACTIVITY
	_locationManager.distanceFilter = DistanceFilter;
#endif
		
	_speedTester = [[DTImprovedSpeedTester alloc]init];
	_speedTester.callback = self;
	
	[self setUpUI];
	
		//if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"] isEqualToString:DTDataStorageICloud]) {
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUi) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUi) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
		//}
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadOverlays) name:UserChoseStorageTypeNotification object:nil];
	
}
-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	if (self.presentingFullScreenAd && self.speedTester.isTesting) {
		[self.speedTester cancelSpeedTest];
	}
}
-(void)centerOnUser{
	NSLog(@"Center On user");
	[_mapview setRegion:MKCoordinateRegionMakeWithDistance(self.mapview.userLocation.coordinate, 1500, 1500)animated:YES];
		//[_mapview setUserTrackingMode:MKUserTrackingModeFollow];
}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
		// Dispose of any resources that can be recreated.
}
+(NSString *)getModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return deviceModel;
}

+(BOOL)FourGEnabledModel{
#if LTE_TEST
	return TRUE;
#else
	NSString *model = [DTMainViewController getModel];
	return ([model rangeOfString:@"iPhone5"].location != NSNotFound || [model rangeOfString:@"iPhone6"].location != NSNotFound);
#endif
}

#pragma mark - set up methods
-(void)setUpUI{
	_progressLabel.alpha = 0;

	[_testButton setTitle:@"Test Now" forState:UIControlStateNormal];
	[_testButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[_testButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
	[_testButton setBackgroundColor:[UIColor whiteColor]];
	[_testButton setAlpha:0.6];
	_testButton.layer.cornerRadius = 15;
	_testButton.layer.borderColor = [UIColor grayColor].CGColor;
	_testButton.layer.borderWidth = 1;
}

-(void)loadOverlays{
		//get all saved overlays
	DTAppDelegate *delegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
	NSManagedObjectContext *context = delegate.managedObjectContext;
	NSEntityDescription *overlayDescritptions = [NSEntityDescription entityForName:@"MergableOverlay" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc]init];
	[request setEntity:overlayDescritptions];
	NSError *error = nil;
	NSArray *overlays = [context executeFetchRequest:request error:&error];
		//convert them to MKOverlays and added them to mapview
	if (overlays != nil && overlays.count > 0) {
		for (DTMMergableOverlay *mOverlay in overlays) {
			DTMergableCircleOverlay *circle = [DTMergableCircleOverlay circleWithCenterCoordinate:CLLocationCoordinate2DMake(mOverlay.latitude.doubleValue, mOverlay.longitude.doubleValue) radius:mOverlay.radius.doubleValue];
			circle.alpha = mOverlay.alpha.doubleValue;
			circle.title = mOverlay.title;
			circle.color = [NSKeyedUnarchiver unarchiveObjectWithData:mOverlay.color];
			[_mapview addOverlay:circle level:MKOverlayLevelAboveRoads];
			[_mapview addAnnotation:circle];
		}
		NSLog(@"%lu Overlays loaded", (unsigned long)overlays.count);
	}else if(error != nil){
		NSLog(@"Failed to load saved overlays: %@", [error localizedDescription]);
	}else{
		NSLog(@"No overlays loaded");
	}

}

#pragma mark - iCloud
-(void)updateUi{
		//reload on main thread for concurrency
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.mapview removeOverlays:self.mapview.overlays];
		NSMutableArray *annotations = [self.mapview.annotations mutableCopy];
		[annotations removeObject:self.mapview.userLocation];
		[self.mapview removeAnnotations:self.mapview.annotations];
		[self loadOverlays];
	});
	
}

#pragma mark - Tracking
- (void)stopTracking{
	NSLog(@"Tracking stopped");
	
	[_tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Tracking" action:@"Stop" label:@"stop" value:nil]build]];
	
	[self.locationManager stopMonitoringSignificantLocationChanges];
	self.tracking = NO;
	[self trackingStatusHasChanged];
}

-(void)beginTracking{
	NSLog(@"Tracking");
	
	[_tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Tracking" action:@"Start Tracking" label:@"Start" value:nil]build]];
	
#if DEBUG_BACKGROUND_ACTIVITY
	[self.locationManager startUpdatingLocation];
#else
	[self.locationManager startMonitoringSignificantLocationChanges];
#endif
	self.tracking = YES;
	[self trackingStatusHasChanged];
	
#if DEBUG_OVERLAYS
	_currentLocation = self.locationManager.location;
	double delayInSeconds = 4.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self speedTesterDidFinishSpeedTestWithResult:10];
	});
	
	delayInSeconds = 4.0;
	popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		MKMapPoint point = MKMapPointForCoordinate(_currentLocation.coordinate);
		CLLocationDistance distancePerPoint = MKMetersPerMapPointAtLatitude(_currentLocation.coordinate.latitude);
		double deltaPoint = 300/distancePerPoint;
		point.x +=deltaPoint;
		CLLocationCoordinate2D new = MKCoordinateForMapPoint(point);
		CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:new.latitude longitude: new.longitude];
		_currentLocation = newLocation;
		[self speedTesterDidFinishSpeedTestWithResult:10];
	});
	
#endif
}


-(void)mapFinishedInitialRenderingSuccessfully:(BOOL)success{
	[self.reach startNotifier];
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"] != nil) {
			[self loadOverlays];
	}
}

#pragma mark - Overlay addition
#pragma mark - Location Updates
-(void)locationManagerHasUpdatedToLoaction:(CLLocation *)location{
	if(_speedTester.isTesting){
		NSLog(@"Speed tester busy, returning");
		return;
	}
	_currentLocation = location;
	if([[UIApplication sharedApplication]applicationState] != UIApplicationStateBackground){
		[self.testButton setTitle:@"Stop Test" forState:UIControlStateNormal];
		self.progressLabel.text = @"Testing Connection";
		[UIView animateWithDuration:0.3 animations:^{
			self.progressLabel.alpha = 1;
		} completion:^(BOOL finished) {
			
#if !FIELD_TEST//debuging stuff
			[_speedTester checkSpeed];
#elif FIELD_TEST
			double delayInSeconds = 2.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self speedTesterDidFinishSpeedTestWithResult:arc4random_uniform((int)_MaxSpeed)+1];
			});
#endif
		}];
	}else if([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground){
		NSLog(@"Running background task");
		_bgTask = [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication]endBackgroundTask:_bgTask];
			_bgTask = UIBackgroundTaskInvalid;
			NSLog(@"Ran out of time!");
		}];
		[_speedTester checkSpeed];
	}
}

#pragma mark - Speed Test callbacks
-(void)speedTesterProgressDidChange:(int)perProgress{
	if (perProgress > 100) {
		perProgress = 100;
	}
	self.progressLabel.text = [NSString stringWithFormat:@"%d%%",perProgress];
	
	if (_bgTask != UIBackgroundTaskInvalid) {
		if ([[UIApplication sharedApplication]backgroundTimeRemaining] < 10) {
			NSLog(@"Download takening too long");
			[self.speedTester forceDownloadToFinish];
			NSLog(@"Download ended prematurely");
		}
	}
}
-(void)speedTesterDidFinishSpeedTestWithResult:(double)Mbs{
		//NSLog(@"Spped Test finished with Mbs %f", Mbs);
	[_tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SpeedTester" action:@"End Speed Test" label:@"Call Back" value:nil]build]];
	
	double result = Mbs;
	if (Mbs > _MaxSpeed) {
		result = _MaxSpeed;
	}
	double alpha = result * 0.8 / _MaxSpeed;
	if (alpha < 0.1) {
		alpha = 0.1;
	}
	CLLocation *location = [_currentLocation copy];
		//build new mergable overlay using speed test result
	DTMergableCircleOverlay *circle = [DTMergableCircleOverlay circleWithCenterCoordinate:location.coordinate radius:OverlayRadius];
	circle.alpha = alpha;
	circle.title = [NSString stringWithFormat:@"%1.1f Mbs",Mbs];
		//green overlays for true 4G otherwise blue
	if ([[NSUserDefaults standardUserDefaults]boolForKey:kDataType4G]) {
		circle.color = [UIColor greenColor];
	}else{
		circle.color = [UIColor blueColor];
	}
		//add new overlay to mapview.
	[self.mapViewDelegate addOverlay:circle toMapView: self.mapview];
	NSLog(@"overlay added");
	if (_bgTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:_bgTask];
		_bgTask = UIBackgroundTaskInvalid;
		NSLog(@"Ended background task");
	}
	
	[UIView animateWithDuration:1.5 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.progressLabel.alpha = 0;
	} completion:nil];
	[self.testButton setTitle:@"Test Now" forState:UIControlStateNormal];
}
-(void)speedTestDidCancel{
	
	[self.testButton setTitle:@"Test Now" forState:UIControlStateNormal];
	[UIView animateWithDuration:0.3 animations:^{
		self.progressLabel.alpha = 0;
	}];
	
}
#pragma mark - Mapview Delegate Callbacks
-(void)mapViewDelegateDidAddOverlay:(id<MKOverlay>)overlay{
#if !DEBUG_OVERLAYS
		//check overlay was mergable circle
	if ([overlay isKindOfClass:[DTMergableCircleOverlay class]]) {
			//if so update model context
		NSLog(@"adding overlay to context");
		DTMergableCircleOverlay *circle = (DTMergableCircleOverlay *)overlay;
		DTAppDelegate *delegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
		NSManagedObjectContext *context = delegate.managedObjectContext;
		
		DTMMergableOverlay *overlayM = [NSEntityDescription insertNewObjectForEntityForName:@"MergableOverlay" inManagedObjectContext:context];
		overlayM.longitude = [NSNumber numberWithDouble:[circle coordinate].longitude];
		overlayM.latitude = [NSNumber numberWithDouble:[circle coordinate].latitude];
		overlayM.radius = [NSNumber numberWithDouble:circle.radius];
		overlayM.alpha = [NSNumber numberWithDouble:circle.alpha];
		overlayM.title = circle.title;
		overlayM.color = [NSKeyedArchiver archivedDataWithRootObject:circle.color];
		NSError *error;
		if(![context save:&error]){
			NSLog(@"Failed to save context: %@", [error localizedDescription]);
			NSLog(@"%@", [overlayM debugDescription]);
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Holy Shoot!" message:@"The application was unable to save the new overlay" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[_mapview removeOverlay:overlay];
			[_mapview removeAnnotation:overlay];
			[context rollback];
		}
	}
	
#endif
	
	
}
-(void)mapViewDelegateDidRemoveOverlay:(id<MKOverlay>)overlay{
#if	!DEBUG_OVERLAYS
		//check overlay was a Mergable circle
	if ([overlay isKindOfClass:[DTMergableCircleOverlay class]]) {
			//if so update model context
		NSLog(@"removing Overlay from context");
		DTAppDelegate *delegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
		NSManagedObjectContext *context = delegate.managedObjectContext;
			//build request using location coordinates
		NSFetchRequest *request = [[NSFetchRequest alloc]init];
		NSNumber *longitude = [NSNumber numberWithDouble:[overlay coordinate].longitude];
		NSNumber *latitude = [NSNumber numberWithDouble:[overlay coordinate].latitude];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(longitude == %@) AND (latitude == %@)", longitude, latitude];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"MergableOverlay" inManagedObjectContext:context];
		
		[request setEntity:entity];
		[request setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *array = [context executeFetchRequest:request error:&error];
			//delete overlay (assumes only a single overlay in array)
		if (array != nil && error == nil) {
			DTMMergableOverlay *deleteMe = [array firstObject];
			[context deleteObject:deleteMe];
			if (![context save:&error]) {
				
				UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh Oh!" message:@"The application was unable to remove the overlay" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
				[_mapview addOverlay:overlay];
				[_mapview addAnnotation:overlay];
				[context rollback];
			}
		}
		if (error) {
			NSLog(@"Failed to delete overlay: %@", error);
		}
	}
#endif
}

-(void)userDidTapAccessoryButton:(UIButton *)button forAnnotation:(id <MKAnnotation>)annotation{
		//check if it's a relavent overlay
	if ([annotation isKindOfClass:[DTMergableCircleOverlay class]]) {
			//if so build detail view controller and display.
		DTMergableCircleOverlay *overlay = (DTMergableCircleOverlay *)annotation;
		DTOverlayDetailViewController *controller = [[DTOverlayDetailViewController alloc]init];
		controller.callback = self;
		controller.overlay = overlay;
		UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:controller];
		[self presentViewController:navController animated:YES completion:nil];
	}
}

#pragma mark - settings controller handlers
-(void)switchValueDidChanged:(BOOL)on{
		//4G switch changed
	[self correctMaxSpeed];
}
-(void)correctMaxSpeed{
		//Usually checking models isn't acceptable but there is no why to check for a
		// Phones available data types so this will have to do.
	if ([DTMainViewController FourGEnabledModel]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults boolForKey:kDataType4G]) {
			_MaxSpeed = FourGSpeed;
		}else{
			_MaxSpeed = HSPAPlusSpeed;
		}
	}else{
		_MaxSpeed = DefaultSpeed;
	}
	NSLog(@"Max Speed %ld", (long)_MaxSpeed);
}

-(void)segmentControlValueDidChange:(NSInteger)index{
		//Callback from settings controller to update current map type
	switch (index) {
		case 0:
			self.mapview.mapType = MKMapTypeStandard;
			[[NSUserDefaults standardUserDefaults]setInteger:MKMapTypeStandard forKey:kMapType];
			break;
		case 1:
			self.mapview.mapType = MKMapTypeHybrid;
			[[NSUserDefaults standardUserDefaults]setInteger:MKMapTypeHybrid forKey:kMapType];
			break;
		case 2:
			self.mapview.mapType = MKMapTypeSatellite;
			[[NSUserDefaults standardUserDefaults]setInteger:MKMapTypeSatellite forKey:kMapType];
			break;
		default:
			break;
	}
}
-(IBAction)presentSettings{
		//Build and present settings controller
	DTSettingsViewController *settingsViewController = [[DTSettingsViewController alloc]init];
	settingsViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
	settingsViewController.callBack = self;
	[self presentViewController:settingsViewController animated:YES completion:nil];
}

-(void)userDidRequestDataWhipe{
		//retrive managed context
	DTAppDelegate *delegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
	NSManagedObjectContext *context = delegate.managedObjectContext;
		//get all current overlays
	NSEntityDescription *overlayDescritptions = [NSEntityDescription entityForName:@"MergableOverlay" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc]init];
	[request setEntity:overlayDescritptions];
	
		//remove them all from the current context
	NSError *error = nil;
	NSArray *overlays = [context executeFetchRequest:request error:&error];
	if (!error) {
		for (DTMMergableOverlay *overlay in overlays) {
			[context deleteObject:overlay];
		}
		[context save:&error];
	}
		//if error let the user know about it
	if (error) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Something went wrong!\n Unable to delete user data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		NSLog(@"Failed to delete user data with error:\n%@", error);
	}else{
			//otherwise update ui
		[self updateUi];
	}
}

#pragma mark - Overlay Description Callback
-(void)userDidRequestRemovalOfOverlay:(DTMergableCircleOverlay *)overlay{
		//remove overlay from map
	[_mapview removeOverlay:overlay];
	[_mapview removeAnnotation:overlay];
		//remove from context by calling this callback back method for the map delegate
	[self mapViewDelegateDidRemoveOverlay:overlay];
}

#pragma mark - Test Button Handlers

-(void)trackingStatusHasChanged{
	if (_testButton != nil) {
		if (self.isTracking) {
			_testButton.layer.borderColor = [UIColor redColor].CGColor;
			[_testButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		}else{
			_testButton.layer.borderColor = [UIColor grayColor].CGColor;
			[_testButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		}
	}
}

-(IBAction)forceSpeedTest{
	if (self.speedTester.testing) {
		[self.speedTester cancelSpeedTest];
		
	}else{
		if (self.isTracking) {
			[self locationManagerHasUpdatedToLoaction:_locationManager.location];
		}else{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"You must not be connected to Wifi in order to test the speed of your data connection." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}
	}
}

@end
