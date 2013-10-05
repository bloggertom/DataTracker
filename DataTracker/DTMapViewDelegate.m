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

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
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
	MKCircle *circle = [MKCircle circleWithCenterCoordinate:mapView.userLocation.location.coordinate radius:200];
	
	[mapView addOverlay:circle level:MKOverlayLevelAboveLabels];
	
}

-(MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
	NSLog(@"adding overlay");
	if ([overlay isKindOfClass:[MKCircle class]]) {
		MKCircleRenderer *crenderer = [[MKCircleRenderer alloc]initWithOverlay:overlay];
		MKOverlayPathRenderer *renderer = [[MKOverlayPathRenderer alloc]init];
		MKCircle *circle = (MKCircle *)overlay;
		
		
			//Kept for referance
		/*MKMapPoint a = circle.boundingMapRect.origin;
		MKMapPoint b = MKMapPointMake(circle.boundingMapRect.origin.x + circle.boundingMapRect.size.width, circle.boundingMapRect.origin.y);
		MKMapPoint c = MKMapPointMake(circle.boundingMapRect.origin.x + circle.boundingMapRect.size.width, circle.boundingMapRect.origin.y + circle.boundingMapRect.size.height);
		MKMapPoint d = MKMapPointMake(circle.boundingMapRect.origin.x, circle.boundingMapRect.origin.y + circle.boundingMapRect.size.height);
		
		MKMapPoint *points = malloc(4 * sizeof(MKMapPoint));
		
		points[0] = a;
		points[1] = b;
		points[2] = c;
		points[3] = d;
		
		MKPolygon *poly = [MKPolygon polygonWithPoints:points count:4];
		MKPolygonRenderer *prenderer = [[MKPolygonRenderer alloc]initWithPolygon:poly];*/
		CGRect rect = [crenderer rectForMapRect:circle.boundingMapRect];
		UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:circle.radius*7];
		renderer.path = [path CGPath];
		renderer.fillColor = [UIColor blueColor];
		renderer.alpha = _alpha;
		
			//free(points);
		return renderer;
	}
	
	return nil;
}


@end
