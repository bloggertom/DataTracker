//
//  DTMergableRenderer.m
//  DataTracker
//
//  Created by Thomas Wilson on 19/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTMergableRenderer.h"
#import "DTMergableCircleOverlay.h"
@implementation DTMergableRenderer

-(id)initWithOverlay:(id<MKOverlay>)overlay{
	NSArray *array = [NSArray arrayWithObject:overlay];
	return [self initWithOverlays:array];
}

-(id)initWithOverlays:(NSArray*)overlays{
	if (overlays.count == 1) {
		self = [super initWithOverlay:[overlays firstObject]];
	}else if(overlays.count > 1){
		MKMapRect rect = MKMapRectNull;
		for (id<MKOverlay> o in overlays) {
			rect = MKMapRectUnion(rect, [o boundingMapRect]);
		}
		MKMapPoint mPoint = MKMapPointMake(MKMapRectGetMidX(rect), MKMapRectGetMidY(rect));
		CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mPoint);
		CLLocationDistance distance = MKMetersBetweenMapPoints(mPoint, MKMapPointMake(MKMapRectGetMaxX(rect),MKMapRectGetMidY(rect)));
		MKCircle *cirle = [MKCircle circleWithCenterCoordinate:coord radius:distance];
		self = [super initWithOverlay:cirle];
	}else{
		return nil;
	}
	if (self) {
			_overlays = overlays;
		[self invalidatePath];
		[self createPath];
	}
	return self;
}

-(void)fillPath:(CGPathRef)path inContext:(CGContextRef)context{
		//DTMergableCircleOverlay *tOverlay = (DTMergableCircleOverlay *)self.overlay;
	CGGradientRef gradient;
		//CGRect rect = CGPathGetBoundingBox(path);
	CGContextSaveGState(context);
	CGContextAddPath(context, path);
		//CGContextClip(context);
	
	CGFloat location[2] = {0.5, 1.0};
	
	for (DTMergableCircleOverlay *o in self.overlays) {
		
		
		CGRect rect = [self rectForMapRect:o.boundingMapRect];
		
		NSArray *array = [NSArray arrayWithObjects:(id)[o.color colorWithAlphaComponent:o.alpha].CGColor,[o.color colorWithAlphaComponent:0.0].CGColor, nil];
		
		CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
		CGFloat radius = rect.size.width * 0.5;
		gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)array, location);
		CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
		
		CGGradientRelease(gradient);
		
	}
		//NSArray *array = [NSArray arrayWithObjects:(id)[self.fillColor colorWithAlphaComponent:tOverlay.alpha].CGColor,[UIColor clearColor].CGColor, nil];
	
	
	
	
		//CFRelease(colorsArr);
	
}


-(void)createPath{
	UIBezierPath *path = [[UIBezierPath alloc]init];
	for (id<MKOverlay> o in _overlays) {
		if ([o isKindOfClass:[DTMergableCircleOverlay class]]) {
			DTMergableCircleOverlay *overlay = (DTMergableCircleOverlay *)o;
			CGRect rect = [self rectForMapRect:overlay.boundingMapRect];
			UIBezierPath *path2 = [UIBezierPath bezierPathWithOvalInRect:rect];
			[path appendPath:path2];
		}
	}
	self.path = path.CGPath;
}

@end
