//
//  DTLocationDelegate.m
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTLocationDelegate.h"
#import "Reachability.h"


@interface DTLocationDelegate()

@property(nonatomic, strong)Reachability *reachability;

@end
@implementation DTLocationDelegate

-(id)initWithMapView:(MKMapView *)mapView{
	self = [super init];
	if(self){
		_mapView = mapView;
		_reachability = [[Reachability alloc]init];
		[_reachability setReachableOnWWAN:YES];
		
	}
	return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	NSLog(@"Updating location");
	CLLocation *location = (CLLocation *)[locations firstObject];
	NSLog(@"%@", location.debugDescription);
	MKCircle *circle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:200];
	/*
	for(id<MKOverlay> overlay in [self.mapView overlaysInLevel:MKOverlayLevelAboveLabels]){
		if ([overlay intersectsMapRect:circle.boundingMapRect] && [overlay isKindOfClass:[MKCircle class]]) {
			NSLog(@"Returning");
			return;
		}
	}
	*/
	NSLog(@"%@", _mapView.delegate.debugDescription);
	[self.mapView addOverlay:circle level:MKOverlayLevelAboveLabels];
	
}


@end
