//
//  DTMergableCircleOverlay.m
//  DataTracker
//
//  Created by Thomas Wilson on 19/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTMergableCircleOverlay.h"

@interface DTMergableCircleOverlay ()
	//@property (nonatomic)CLLocationDistance radius;
	//@property (nonatomic)CLLocationCoordinate2D coordinate;

@end

@implementation DTMergableCircleOverlay


-(id)initWithLocation:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)radius{
	self = [super init];
	if (self) {
		_radius = radius;
		_coordinate = coord;
		MKCircle *temp = [MKCircle circleWithCenterCoordinate:coord radius:radius];
		_boundingMapRect = temp.boundingMapRect;
		temp = nil;
		
	}
	return self;
}

+(DTMergableCircleOverlay*)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)radius{
	DTMergableCircleOverlay *overlay = [[DTMergableCircleOverlay alloc]initWithLocation:coord radius:radius];
	return overlay;
}
-(BOOL)canReplaceMapContent{
	return NO;
}
-(BOOL)intersectsMapRect:(MKMapRect)mapRect{
	return MKMapRectIntersectsRect(_boundingMapRect, mapRect);
}


@end
