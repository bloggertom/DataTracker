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
#import "DTAppDelegate.h"
@interface DTMainViewController ()
@property (nonatomic, strong)DTMapViewDelegate *mapViewDelegate;
@property (nonatomic, strong)DTLocationDelegate *locationDelegate;
@property (nonatomic, strong)CLLocationManager *locationManager;
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
	_locationDelegate = [[DTLocationDelegate alloc]initWithMapView:_mapview];
	_locationManager = [[CLLocationManager alloc]init];
	_locationManager.delegate = _locationDelegate;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	_locationManager.pausesLocationUpdatesAutomatically = YES;
	
		//centering map view
	[_mapview setRegion:MKCoordinateRegionMakeWithDistance(_mapview.userLocation.coordinate, 500, 500)];
	
		//track user location. May not be needed?
	[_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	
	
	self.view = _mapview;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stopTracking{
	NSLog(@"Tracking stopped");
	[self.locationManager stopMonitoringSignificantLocationChanges];
	self.tracking = NO;
}

-(void)beginTracking{
	NSLog(@"Tracking");
	[self.locationManager startMonitoringSignificantLocationChanges];
	self.tracking = YES;
}

-(void)mapFinishedInicialRenderingSuccessfully:(BOOL)success{
	DTAppDelegate *del = (DTAppDelegate *)[[UIApplication sharedApplication]delegate];
	[del.reachability startNotifier];
	
	if(del.reachability.isReachableViaWWAN){
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self beginTracking];
		});
		
	}
}

@end
