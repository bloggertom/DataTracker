//
//  DTLocationDelegate.h
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<MapKit/MapKit.h>

@interface DTLocationDelegate : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak)MKMapView *mapView;
@property (nonatomic, getter = isTracking)BOOL tracking;


-(id)initWithMapView:(MKMapView *)mapView;

@end
