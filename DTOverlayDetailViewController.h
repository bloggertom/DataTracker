//
//  DTOverlayDetailViewController.h
//  DataTracker
//
//  Created by Thomas Wilson on 08/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	<MapKit/MapKit.h>
#import "DTMergableCircleOverlay.h"
#define DisabledAlpha 0.5
#define EnabledAlpha 1.0

@class DTMainViewController;

@interface DTOverlayDetailViewController : UIViewController <MKMapViewDelegate>


@property (nonatomic, weak)DTMergableCircleOverlay *overlay;
@property (nonatomic, weak)DTMainViewController *callback;

@end
