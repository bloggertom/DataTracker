//
//  DTMergableCircleOverlay.h
//  DataTracker
//
//  Created by Thomas Wilson on 19/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DTMergableCircleOverlay : NSObject <MKOverlay>

@property (nonatomic)CGFloat alpha;
@property (nonatomic, readonly)CLLocationDistance radius;
@property (nonatomic, readonly)CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly)MKMapRect boundingMapRect;


+(DTMergableCircleOverlay*)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)radius;

@end
