//
//  DTMainViewController.h
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class DTMapViewDelegate;
@class DTLocationDelegate;

@interface DTMainViewController : UIViewController

@property (nonatomic, readonly, strong)MKMapView *mapview;
@property (nonatomic, getter = isTracking)BOOL tracking;

-(void)beginTracking;
-(void)stopTracking;
-(void)mapFinishedInicialRenderingSuccessfully:(BOOL)success;

@end
