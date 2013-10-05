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
		
		[self.callback mapFinishedInicialRenderingSuccessfully:(BOOL)fullyRendered];
		_inicialRender = NO;
	}
}

-(MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
	NSLog(@"adding overlay");
	if ([overlay isKindOfClass:[MKCircle class]]) {
		MKCircleRenderer *renderer = [[MKCircleRenderer alloc]initWithOverlay:overlay];
		double speed = [self.speedTester checkSpeed];
		renderer.fillColor = [UIColor blueColor];
		renderer.alpha = (speed > 10)? 1 : speed/10;
		
		NSLog(@"Speed %f", speed);
		return renderer;
	}
	
	return nil;
}


@end
