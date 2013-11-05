//
//  DTiPadViewController.m
//  DataTracker
//
//  Created by Thomas Wilson on 04/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTiPadViewController.h"
#import "DTAppDelegate.h"
#import "DTMergableCircleOverlay.h"
#import "DTMMergableOverlay.h"
#import "DTMapViewDelegate.h"
@interface DTiPadViewController ()
@property (nonatomic, strong)DTMapViewDelegate *mapDelegate;
@end

@implementation DTiPadViewController

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
	_mapview = [[MKMapView alloc]initWithFrame:self.view.frame];
	_mapview.showsUserLocation = YES;
	_mapDelegate = [[DTMapViewDelegate alloc]init];
		//mapDelegate.callback = self;
	_mapview.delegate = _mapDelegate;
	[_mapview setCenterCoordinate:_mapview.userLocation.coordinate animated:YES];
	self.view = _mapview;
	
		//if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"] isEqualToString:DTDataStorageICloud]) {
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUi) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateUi) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
		//}
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadOverlays) name:UserChoseStorageTypeNotification	object:nil];
	NSLog(@"View did load");
	if([[NSUserDefaults standardUserDefaults]objectForKey:@"com.apple.DataTracker.StorageType"] != nil){
		[self loadOverlays];
	}

}

-(void)dealloc{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadOverlays{
	DTAppDelegate *delegate = (DTAppDelegate*)[UIApplication sharedApplication].delegate;
	@try {
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
	@catch (NSException *exception) {
		
	}
	@finally {
		
	}
	
	
}
/*
-(void)dataStoreDidUpdateFromUbiquityContainer:(NSNotification *)notification{
	NSLog(@"update for container");
	DTAppDelegate *delegate = (DTAppDelegate *)[[UIApplication sharedApplication]delegate];
	[delegate.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	[self updateUi];
}
-(void)persistantStoreDidChange:(NSNotification *)notification{
	
	
}
 */
-(void)updateUi{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.mapview removeOverlays:_mapview.overlays];
		[self loadOverlays];
	});
	
}
@end
