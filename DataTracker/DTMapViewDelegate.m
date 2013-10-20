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
#import "DTMergableCircleOverlay.h"
#import "DTMergableRenderer.h"

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
@interface DTMapViewDelegate ()
@property (nonatomic, strong)DTSpeedTester *speedTester;
@property (nonatomic)BOOL inicialRender;
	//@property (nonatomic)CGFloat alpha;
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
	mapView.delegate = self;
		//MKCircle *circle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:200];
	DTMergableCircleOverlay *circle = (DTMergableCircleOverlay *)[DTMergableCircleOverlay circleWithCenterCoordinate:location.coordinate radius:200];
	
	circle.alpha = alpha;
	[mapView addOverlay:circle level:MKOverlayLevelAboveRoads];
}

-(MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
	NSLog(@"adding overlay");
		//MKOverlayPathRenderer *renderer;
	DTMergableRenderer *renderer;
	
	if ([overlay isKindOfClass:[DTMergableCircleOverlay class]]) {
		DTMergableCircleOverlay *circle = (DTMergableCircleOverlay *)overlay;
		
		
		NSArray *overlays = [mapView overlaysInLevel:MKOverlayLevelAboveRoads];
		NSMutableArray *array = [[NSMutableArray alloc]init];
		[array addObject:circle];
		for (id<MKOverlay> o in overlays) {
			if (![o isEqual:overlay] && [o intersectsMapRect:circle.boundingMapRect]) {
				CLLocation *location = [[CLLocation alloc]initWithLatitude:[o coordinate].latitude longitude:[o coordinate].longitude];
				CLLocation *location2 = [[CLLocation alloc]initWithLatitude:[circle coordinate].latitude longitude:[circle coordinate].longitude];
				if ([location distanceFromLocation:location2] > 100) {
					[array addObject:o];
					[mapView removeOverlay:o];
				}
			}
		}
		NSLog(@"Overlays %d", array.count);
		renderer = [[DTMergableRenderer alloc]initWithOverlays:array];
		renderer.fillColor = [UIColor blueColor];
		renderer.alpha = circle.alpha;
		
	}
	
	return renderer;
}



@end
