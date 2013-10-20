//
//  DTMergableRenderer.h
//  DataTracker
//
//  Created by Thomas Wilson on 19/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <MapKit/MapKit.h>
@class DTMergableCircleOverlay;
@interface DTMergableRenderer : MKOverlayPathRenderer

@property (nonatomic, readonly)NSArray *overlays;
@property (nonatomic, readonly)id<MKOverlay> overlay;

-(id)initWithOverlays:(NSArray*)overlays;

@end
