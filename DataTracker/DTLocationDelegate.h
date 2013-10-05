//
//  DTLocationDelegate.h
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	<MapKit/MapKit.h>
@class DTMainViewController;
@interface DTLocationDelegate : NSObject <CLLocationManagerDelegate>



@property (nonatomic, weak)DTMainViewController *callback;

@end
