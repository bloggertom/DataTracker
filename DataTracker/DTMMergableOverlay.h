//
//  DTMMergableOverlay.h
//  DataTracker
//
//  Created by Thomas Wilson on 27/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DTMMergableOverlay : NSManagedObject

@property (nonatomic, retain) NSNumber * alpha;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * radius;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * color;

@end
