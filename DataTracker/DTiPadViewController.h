//
//  DTiPadViewController.h
//  DataTracker
//
//  Created by Thomas Wilson on 04/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DTiPadViewController : UIViewController <MKMapViewDelegate>


@property (nonatomic, strong)MKMapView *mapview;


@end
