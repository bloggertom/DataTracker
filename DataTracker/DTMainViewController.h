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
@class Reachability;
@class DTMergableCircleOverlay;
@interface DTMainViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, readonly, strong)MKMapView *mapview;
@property (nonatomic, getter = isTracking)BOOL tracking;
@property (nonatomic, weak)Reachability *reach;
@property (nonatomic, strong)UILabel *progressLabel;
@property (nonatomic, weak)NSManagedObjectContext *objectContext;

-(void)beginTracking;
-(void)stopTracking;
-(void)mapFinishedInitialRenderingSuccessfully:(BOOL)success;
-(void)locationManagerHasUpdatedToLoaction:(CLLocation *)location;
-(void)speedTesterDidFinishSpeedTestWithResult:(double)Mbs;
-(void)speedTesterProgressDidChange:(int)perProgress;

-(void)mapViewDelegateDidAddOverlay:(id<MKOverlay>)overlay;
-(void)mapViewDelegateDidRemoveOverlay:(id<MKOverlay>)overlay;

@end
