//
//  DTMapViewDelegate.m
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTMapViewDelegate.h"
#import "DTSpeedTester.h"
#import "DTMainViewController.h"
@interface DTMapViewDelegate ()
@property (nonatomic, strong)DTSpeedTester *speedTester;
@property (nonatomic)BOOL inicialRender;
@property (nonatomic)CGFloat alpha;
@end

@implementation DTMapViewDelegate

-(id)init{
	self = [super init];
	if (self) {
		_speedTester = [[DTSpeedTester alloc]init];
		_inicialRender = YES;
	}
	return self;
}
-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
	if (_inicialRender) {//required for first overlay.
		
		[self.callback mapFinishedInitialRenderingSuccessfully:(BOOL)fullyRendered];
		_inicialRender = NO;
	}
}

-(void)addOverlayWithAlpha:(CGFloat)alpha atLocation:(CLLocation*)location toMapView:(MKMapView *)mapView{
	NSLog(@"Adding overlay with alpha %f",alpha);
	NSAssert([mapView.delegate isKindOfClass:[self class]], [NSString stringWithFormat:@"Unable to add overlay to map view with invalid delegate"]);
	_alpha = alpha;
	MKCircle *circle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:200];
	[mapView addOverlay:circle level:MKOverlayLevelAboveLabels];
}

-(MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
	NSLog(@"adding overlay");
	if ([overlay isKindOfClass:[MKCircle class]]) {
		MKCircleRenderer *renderer = [[MKCircleRenderer alloc]initWithOverlay:overlay];
		renderer.fillColor = [UIColor blueColor];
		renderer.alpha = _alpha;
		return renderer;
	}
	
	return nil;
}


@end
