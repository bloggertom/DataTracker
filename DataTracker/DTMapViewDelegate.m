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
#define kMIN_DISTANCE 250
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

-(void)addOverlay:(id<MKOverlay>)overlay toMapView:(MKMapView *)mapView{
	if ([overlay isKindOfClass:[DTMergableCircleOverlay class]]) {
		DTMergableCircleOverlay *circle = (DTMergableCircleOverlay *)overlay;
		NSArray *array = [mapView overlaysInLevel:MKOverlayLevelAboveRoads];
		
		for (id<MKOverlay> o in array) {
			if ([o isKindOfClass:[DTMergableCircleOverlay class]]) {
				DTMergableCircleOverlay *overlay = (DTMergableCircleOverlay*)o;
				CLLocation *location = [[CLLocation alloc]initWithLatitude:overlay.coordinate.latitude longitude:overlay.coordinate.longitude];
				CLLocation *location2 = [[CLLocation alloc]initWithLatitude:circle.coordinate.latitude longitude:circle.coordinate.longitude];
				if ([location distanceFromLocation:location2] < kMIN_DISTANCE) {
					[mapView removeOverlay:o];
					[mapView removeAnnotation:o];
					[self.callback mapViewDelegateDidRemoveOverlay:o];
				}
			}
		}
		[mapView addOverlay:circle level:MKOverlayLevelAboveRoads];
		[mapView addAnnotation:circle];
		[self.callback mapViewDelegateDidAddOverlay:circle];
	}
}
/*
-(void)addOverlayWithAlpha:(CGFloat)alpha atLocation:(CLLocation*)location toMapView:(MKMapView *)mapView{
	NSLog(@"Adding overlay with alpha %f",alpha);
	NSAssert([mapView.delegate isKindOfClass:[self class]], [NSString stringWithFormat:@"Unable to add overlay to map view with invalid delegate"]);
	mapView.delegate = self;
		//MKCircle *circle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:200];
	DTMergableCircleOverlay *circle = (DTMergableCircleOverlay *)[DTMergableCircleOverlay circleWithCenterCoordinate:location.coordinate radius:200];
	NSArray *array = [mapView overlaysInLevel:MKOverlayLevelAboveRoads];
	
	for (id<MKOverlay> o in array) {
		if ([o isKindOfClass:[DTMergableCircleOverlay class]]) {
			DTMergableCircleOverlay *overlay = (DTMergableCircleOverlay*)o;
			CLLocation *location = [[CLLocation alloc]initWithLatitude:overlay.coordinate.latitude longitude:overlay.coordinate.longitude];
			CLLocation *location2 = [[CLLocation alloc]initWithLatitude:circle.coordinate.latitude longitude:circle.coordinate.longitude];
			if ([location distanceFromLocation:location2] < kMIN_DISTANCE) {
				[mapView removeOverlay:o];
				[mapView removeAnnotation:o];
				[self.callback mapViewDelegateDidRemoveOverlay:o];
			}
		}
	}
	
	
	circle.alpha = alpha;
	[mapView addOverlay:circle level:MKOverlayLevelAboveRoads];
	[self.callback mapViewDelegateDidAddOverlay:circle];
}
*/
-(MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
	NSLog(@"adding overlay");
		
	DTMergableRenderer *renderer;
	
	if ([overlay isKindOfClass:[DTMergableCircleOverlay class]]) {
		DTMergableCircleOverlay *circle = (DTMergableCircleOverlay *)overlay;
		renderer = [[DTMergableRenderer alloc]initWithOverlay:circle];
		if ([[NSUserDefaults standardUserDefaults]boolForKey:kDataType4G]) {
			renderer.fillColor = [UIColor greenColor];
		}else{
			renderer.fillColor = [UIColor blueColor];
		}
		
			
		
	}
	
	return renderer;
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	MKAnnotationView *view = nil;
	
	if ([annotation isKindOfClass:[DTMergableCircleOverlay class]]) {
			//view = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Bobs"];
		view = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Bobs"];
		view.bounds = CGRectMake(0, 0, 64, 64);
		view.canShowCallout = YES;
		view.image = nil;
		view.calloutOffset = CGPointMake(0, 32);
	}
	
	
	return view;

}
@end
