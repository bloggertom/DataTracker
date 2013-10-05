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

#define DEBUG_OVERLAYS 0
#define MaxSpeed 10
#define MinSpeed 0
@interface DTMainViewController ()
@property (nonatomic, strong)DTMapViewDelegate *mapViewDelegate;
@property (nonatomic, strong)DTLocationDelegate *locationDelegate;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)DTSpeedTester *speedTester;
@property(nonatomic, strong)CLLocation *currentLocation;

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
		
		//set up map view
	_mapview = [[MKMapView alloc]initWithFrame:self.view.bounds];
	_mapViewDelegate = [[DTMapViewDelegate alloc]init];
	_mapViewDelegate.callback = self;
	_mapview.delegate = _mapViewDelegate;
	
	
	
		//set up location manager
	_locationDelegate = [[DTLocationDelegate alloc]init];
	_locationManager = [[CLLocationManager alloc]init];
#if !DEBUG_OVERLAYS
	_locationDelegate.callback = self;
#endif
	_locationManager.delegate = _locationDelegate;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.pausesLocationUpdatesAutomatically = YES;
	
		//centering map view
	[_mapview setRegion:MKCoordinateRegionMakeWithDistance(_mapview.userLocation.coordinate, 500, 500)];
	
		//track user location. May not be needed?
	[_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	
	
		//speedTester
	_speedTester = [[DTSpeedTester alloc]init];
	_speedTester.callback = self;
	
	[self.view addSubview:_mapview];
	[self setUpUI];
}

-(void)setUpUI{
	_progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 200, 50)];
	_progressLabel.alpha = 0;
	[self.view addSubview:_progressLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Tracking
- (void)stopTracking{
	NSLog(@"Tracking stopped");
	[self.locationManager stopMonitoringSignificantLocationChanges];
	self.tracking = NO;
}

-(void)beginTracking{
	NSLog(@"Tracking");
	[self.locationManager startMonitoringSignificantLocationChanges];
	self.tracking = YES;
	
#if DEBUG_OVERLAYS
	double delayInSeconds = 4.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self speedTesterDidFinishSpeedTestWithResult:10];
	});
	
#endif
}


-(void)mapFinishedInitialRenderingSuccessfully:(BOOL)success{
	[self.reach startNotifier];
	
	if(self.reach.isReachableViaWWAN){
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self beginTracking];
		});
		
	}
}

#pragma mark - Overlay addition
#pragma mark - Location Updates
-(void)locationManagerHasUpdatedToLoaction:(CLLocation *)location{
	NSLog(@"new location update");
	self.progressLabel.text = @"Testing Connection";
	[UIView animateWithDuration:0.5 animations:^{
		self.progressLabel.alpha = 1;
	} completion:^(BOOL finished) {
		_currentLocation = location;
		[_speedTester checkSpeed];
	}];
}

#pragma mark - Speed Test delegate methods
-(void)speedTesterProgressDidChange:(int)perProgress{
	self.progressLabel.text = [NSString stringWithFormat:@"%d%%",perProgress];
}
-(void)speedTesterDidFinishSpeedTestWithResult:(double)Mbs{
	NSLog(@"Finished with Mbs %f",Mbs);
		//y = 1 + (x-A)*(0.7-0)/(B-A), RANGE A-B
	
	double alpha = Mbs * 0.7 / MaxSpeed;
	[self.mapViewDelegate addOverlayWithAlpha:alpha atLocation:_locationManager.location toMapView:_mapview];
}
@end
