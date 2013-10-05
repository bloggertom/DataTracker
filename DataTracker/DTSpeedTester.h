//
//  DTSpeedTester.h
//  DataTracker
//
//  Created by Thomas Wilson on 05/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DTMainViewController;
@interface DTSpeedTester : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong)NSURLRequest *request;
@property (nonatomic, weak, setter=delegate:)DTMainViewController *callback;

-(void)checkSpeed;

@end
