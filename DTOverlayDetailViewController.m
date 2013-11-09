//
//  DTOverlayDetailViewController.m
//  DataTracker
//
//  Created by Thomas Wilson on 08/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTOverlayDetailViewController.h"
#import "DTMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#define VLABLE_SPACING 10
@interface DTOverlayDetailViewController ()
@property (nonatomic, strong)MKMapView *mapview;
@property (nonatomic, strong)UIButton *removeButton;
@end

@implementation DTOverlayDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - UI Preparation
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self setUpUi];
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[_mapview setZoomEnabled:NO];
	[_mapview setScrollEnabled:NO];
	[_mapview setUserInteractionEnabled:NO];
	[_mapview setRegion:MKCoordinateRegionMakeWithDistance(self.overlay.coordinate, 700, 700) animated:YES];
	[_mapview addAnnotation:self.overlay];
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
	self.navigationItem.rightBarButtonItem = button;
	
	
}

-(void)setUpUi{
	self.view.backgroundColor = [UIColor whiteColor];
		//set up map view
	CGRect frame = self.view.bounds;
	frame.size.height = self.view.center.y;
	frame.origin.y += 20;
	_mapview = [[MKMapView alloc]initWithFrame:frame];
	_mapview.delegate = self;
	_mapview.layer.borderColor = [UIColor lightGrayColor].CGColor;
	_mapview.layer.borderWidth = 1;
	_mapview.clipsToBounds = NO;
	_mapview.layer.shadowColor = [UIColor grayColor].CGColor;
	_mapview.layer.shadowOpacity = 0.5;
	_mapview.layer.shadowOffset = CGSizeMake(0, 1);
	
	
		//Text attributes
	UIFont *font = [UIFont systemFontOfSize:18];
	UIColor *textColor = [UIColor lightGrayColor];
	
		//Create Labels
	UILabel *speedLable = [[UILabel alloc]init];
	speedLable.text = @"Speed:";
	speedLable.font = font;
	[speedLable sizeToFit];
	speedLable.frame = CGRectMake(55, (CGRectGetMaxY(_mapview.frame)+30), CGRectGetWidth(speedLable.frame), CGRectGetHeight(speedLable.frame));
	
	UILabel *speed = [[UILabel alloc]init];
	speed.text = self.overlay.title;
	speed.font = font;
	[speed sizeToFit];
	
	frame = speed.frame;
	frame.origin.x = CGRectGetMaxX(speedLable.frame) + 20;
	frame.origin.y = speedLable.frame.origin.y;
	speed.frame = frame;
	
	UILabel *latitudeLabel = [[UILabel alloc]init];
	latitudeLabel.text = @"Latitude:";
	latitudeLabel.font = font;
	[latitudeLabel sizeToFit];
	latitudeLabel.frame = CGRectMake(CGRectGetMinX(speedLable.frame), CGRectGetMaxY(speedLable.frame) + VLABLE_SPACING, CGRectGetWidth(latitudeLabel.frame), CGRectGetHeight(latitudeLabel.frame));
	
	UILabel *latitude = [[UILabel alloc]init];
	latitude.text = [NSString stringWithFormat:@"%1.8f", self.overlay.coordinate.latitude];
	latitude.font = font;
	[latitude sizeToFit];
	
	frame = latitude.frame;
	frame.origin.x = (CGRectGetMinX(latitudeLabel.frame) + CGRectGetWidth(latitudeLabel.frame) + 20);
	frame.origin.y = latitudeLabel.frame.origin.y;
	latitude.frame = frame;
	
	UILabel *longitudeLabel = [[UILabel alloc]init];
	longitudeLabel.text = @"Logitude:";
	longitudeLabel.font = font;
	[longitudeLabel sizeToFit];
	
	longitudeLabel.frame = CGRectMake(CGRectGetMinX(latitudeLabel.frame), CGRectGetMaxY(latitudeLabel.frame) + VLABLE_SPACING, CGRectGetWidth(longitudeLabel.frame), CGRectGetHeight(longitudeLabel.frame));
	
	
	UILabel *longitude = [[UILabel alloc]init];
	longitude.text = [NSString stringWithFormat:@"%1.8f", self.overlay.coordinate.longitude];
	longitude.font = font;
	[longitude sizeToFit];
	
	frame = longitude.frame;
	frame.origin.x = (CGRectGetMinX(longitudeLabel.frame)+CGRectGetWidth(longitudeLabel.frame) + 20);
	frame.origin.y = CGRectGetMinY(longitudeLabel.frame);
	longitude.frame = frame;
	
	
	speedLable.textColor = textColor;
	longitudeLabel.textColor = textColor;
	latitudeLabel.textColor = textColor;
	speed.textColor = textColor;
	longitude.textColor = textColor;
	latitude.textColor = textColor;
	
	
		//add labels and map
	[self.view addSubview:_mapview];
	[self.view addSubview:speedLable];
	[self.view addSubview:speed];
	[self.view addSubview:latitude];
	[self.view addSubview:latitudeLabel];
	[self.view addSubview:longitudeLabel];
	[self.view addSubview:longitude];
	
		//switch and removal button - This could be put into a UIView subclass as it's been used twice
	_removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_removeButton setTitle:@"Remove Result" forState:UIControlStateNormal];
	_removeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	[_removeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[_removeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	_removeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
	_removeButton.layer.borderWidth = 1;
	[_removeButton sizeToFit];
	
		//possition button
	CGRect bounds= _removeButton.frame;
	bounds.size.height += 20;
	bounds.size.width += 30;
	_removeButton.bounds = bounds;
	_removeButton.frame = CGRectMake((CGRectGetWidth(self.view.frame)-CGRectGetWidth(_removeButton.frame)) - 20, (CGRectGetHeight(self.view.frame) - CGRectGetHeight(_removeButton.frame)) - 20, CGRectGetWidth(_removeButton.frame), CGRectGetHeight(_removeButton.frame));
	
		//disabled by default
	_removeButton.enabled = NO;
	[_removeButton addTarget:self action:@selector(userRequestedOverlayRemoval:) forControlEvents:UIControlEventTouchUpInside];
	
	UISwitch *enableSwitch = [[UISwitch alloc]init];
	frame = enableSwitch.frame;
	frame.origin = CGPointMake(20, CGRectGetMidY(_removeButton.frame)-(CGRectGetHeight(enableSwitch.frame)/2));
	[enableSwitch addTarget:self action:@selector(enableSwitchValueHasChanged:) forControlEvents:UIControlEventValueChanged];
	enableSwitch.frame = frame;
	
	[self.view addSubview:_removeButton];
	[self.view addSubview:enableSwitch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	_mapview = nil;
	
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	MKPinAnnotationView *anitationview = nil;
	if (![annotation isKindOfClass:[MKUserLocation class]]) {
		anitationview = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"This"];
	}

	return anitationview;
}

-(void)enableSwitchValueHasChanged:(id)sender{
	if ([sender isKindOfClass:[UISwitch class]]) {
		UISwitch *conSwitch = (UISwitch *)sender;
		if (conSwitch.on) {
			_removeButton.alpha = EnabledAlpha;
			_removeButton.enabled = YES;
			_removeButton.layer.borderColor = [UIColor redColor].CGColor;
		}else{
			_removeButton.alpha = DisabledAlpha;
			_removeButton.enabled = NO;
			_removeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
		}
	}
}

-(void)userRequestedOverlayRemoval:(id)sender{
	NSLog(@"Removing Overlay");
	[self.callback userDidRequestRemovalOfOverlay:self.overlay];
	[self dismissViewControllerAnimated:YES
							 completion:nil];
}
-(void)back{
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
