//
//  DTMapViewDelegate.h
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class Reachability;
@class DTMainViewController;
@interface DTMapViewDelegate : NSObject <MKMapViewDelegate>

@property (nonatomic, weak)DTMainViewController *callback;


@end
