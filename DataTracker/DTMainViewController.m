//
//  DTMainViewController.m
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTMainViewController.h"
#import "DTLocationDelegate.h"
#import "DTMapViewDelegate.h"
#import "Reachability.h"
#import "DTSpeedTester.h"
#import "DTMergableCircleOverlay.h"
#import "DTMMergableOverlay.h"
#import "DTAppDelegate.h"
#import "DTSettingsViewController.h"
#include <sys/sysctl.h>
	//White Box Test cases
#define DEBUG_OVERLAYS 0
#define FIELD_TEST 1
#define LTE_TEST 1
#define DEBUG_BACKGROUND_ACTIVITY 0

#define DefaultSpeed 10
#define HSPAPlusSpeed 20
#define FourGSpeed 50
#define OverlayRadius 500
#define DistanceFilter OverlayRadius * 1.5

#define MinSpeed 0
@interface DTMainViewController ()
@property (nonatomic, strong)DTMapViewDelegate *mapViewDelegate;
@property (nonatomic, strong)DTLocationDelegate *locationDelegate;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)DTSpeedTester *speedTester;
@property(nonatomic, strong)CLLocation *currentLocation;
@property (nonatomic)NSInteger MaxSpeed;

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
	// Do any additional setup after loading the view.
	[self correctMaxSpeed];
	
	
		//set up map view
	_mapview = [[MKMapView alloc]initWithFrame:self.view.bounds];
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
		//_locationManager.distanceFilter = DistanceFilter;
	
		//track user location. May not be needed?
		//[_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	
	
		//speedTester
	_speedTester = [[DTSpeedTester alloc]init];
	_speedTester.callback = self;
	
	[self setUpUI];
	[self.view addSubview:_mapview];
	
		//if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"] isEqualToString:DTDataStorageICloud]) {
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUi) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUi) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
		//}
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadOverlays) name:UserChoseStorageTypeNotification object:nil];
	
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
	
		//add progress label
	_progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 200, 50)];
	_progressLabel.alpha = 0;
	[self.view addSubview:_progressLabel];

		//add settings button
	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	settingsButton.frame = CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-70, 80, 80);
	[settingsButton addTarget:self action:@selector(presentSettings) forControlEvents:UIControlEventTouchUpInside];

	[self.view addSubview:settingsButton];
	
	
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
/*
-(void)dataStoreDidUpdateFromUbiquityContainer:(NSNotification *)notification{
	NSLog(@"update for container");
	DTAppDelegate *delegate = (DTAppDelegate *)[[UIApplication sharedApplication]delegate];
	[delegate.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	[self updateUi];
}
 */
-(void)updateUi{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.mapview removeOverlays:self.mapview.overlays];
		[self loadOverlays];
	});
	
}

#pragma mark - Tracking
- (void)stopTracking{
	NSLog(@"Tracking stopped");
	[self.locationManager stopMonitoringSignificantLocationChanges];
	self.tracking = NO;
}

-(void)beginTracking{
	NSLog(@"Tracking");
#if DEBUG_BACKGROUND_ACTIVITY
	[self.locationManager startUpdatingLocation];
#else
	[self.locationManager startMonitoringSignificantLocationChanges];
#endif
	self.tracking = YES;
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
	NSLog(@"Moo");
	if ([[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"] != nil) {
			[self loadOverlays];
	}
	[_mapview setRegion:MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 1500, 1500)animated:YES];
	
}

#pragma mark - Overlay addition
#pragma mark - Location Updates
-(void)locationManagerHasUpdatedToLoaction:(CLLocation *)location{
#if DEBUG_BACKGROUND_ACTIVITY
	[_locationManager allowDeferredLocationUpdatesUntilTraveled:0 timeout:5];
	return;
#endif
	_currentLocation = location;
	self.progressLabel.text = @"Testing Connection";
	[UIView animateWithDuration:0.5 animations:^{
		self.progressLabel.alpha = 1;
	} completion:^(BOOL finished) {
		
#if !FIELD_TEST
		[_speedTester checkSpeed];
#elif FIELD_TEST
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self speedTesterDidFinishSpeedTestWithResult:arc4random_uniform(_MaxSpeed)+1];
		});
#endif
	}];

}

#pragma mark - Speed Test delegate methods
-(void)speedTesterProgressDidChange:(int)perProgress{
	self.progressLabel.text = [NSString stringWithFormat:@"%d%%",perProgress];
	self.progressLabel.alpha = 1;
}
-(void)speedTesterDidFinishSpeedTestWithResult:(double)Mbs{
	NSLog(@"Finished with Mbs %f",Mbs);
		//y = 1 + (x-A)*(0.7-0)/(B-A), RANGE A-B
	double alpha = Mbs * 0.8 / _MaxSpeed;
	
	CLLocation *location = [_currentLocation copy];
	
	DTMergableCircleOverlay *circle = [DTMergableCircleOverlay circleWithCenterCoordinate:location.coordinate radius:OverlayRadius];
	circle.alpha = alpha;
	circle.title = [NSString stringWithFormat:@"%1.1f Mbs",Mbs];
	if ([[NSUserDefaults standardUserDefaults]boolForKey:kDataType4G]) {
		circle.color = [UIColor greenColor];
	}else{
		circle.color = [UIColor blueColor];
	}
	
	[self.mapViewDelegate addOverlay:circle toMapView:self.mapview];
	
	[UIView animateWithDuration:1.5 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.progressLabel.alpha = 0;
	} completion:nil];
}

#pragma mark - call back methods from map view delegate
-(void)mapViewDelegateDidAddOverlay:(id<MKOverlay>)overlay{
#if !DEBUG_OVERLAYS
		//check overlay was mergable circle
	if ([overlay isKindOfClass:[DTMergableCircleOverlay class]]) {
			//if so update model context
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
		}
	}
	
#endif
	
	
}
-(void)mapViewDelegateDidRemoveOverlay:(id<MKOverlay>)overlay{
#if	!DEBUG_OVERLAYS
		//check overlay was a Mergable circle
	if ([overlay isKindOfClass:[DTMergableCircleOverlay class]]) {
			//if so update model context
		DTAppDelegate *delegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
		NSManagedObjectContext *context = delegate.managedObjectContext;
		
		NSFetchRequest *request = [[NSFetchRequest alloc]init];
		NSNumber *longitude = [NSNumber numberWithDouble:[overlay coordinate].longitude];
		NSNumber *latitude = [NSNumber numberWithDouble:[overlay coordinate].latitude];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(longitude == %@) AND (latitude == %@)", longitude, latitude];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"MergableOverlay" inManagedObjectContext:context];
		
		[request setEntity:entity];
		[request setPredicate:predicate];
		
		NSError *error = nil;
		NSArray *array = [context executeFetchRequest:request error:&error];
		
		if (array != nil) {
			DTMMergableOverlay *deleteMe = [array firstObject];
			[context deleteObject:deleteMe];
		}else{
			NSLog(@"Failed to delete overlay: %@", [error localizedDescription]);
		}
	}
#endif
}

#pragma mark - settings cotroller handlers

-(void)switchValueDidChanged:(BOOL)on{
	[self correctMaxSpeed];
}
-(void)correctMaxSpeed{
		//NSString *model = [DTMainViewController getModel];
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
-(void)presentSettings{
	DTSettingsViewController *settingsViewController = [[DTSettingsViewController alloc]init];
	settingsViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
	settingsViewController.callBack = self;
	[self presentViewController:settingsViewController animated:YES completion:nil];
}
@end
