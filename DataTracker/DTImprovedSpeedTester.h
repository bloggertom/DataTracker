//
//  DTImprovedSpeedTester.h
//  Signal Tracker
//
//  Created by Thomas Wilson on 12/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTMainViewController.h"
@interface DTImprovedSpeedTester : NSObject <NSURLSessionDownloadDelegate, NSURLSessionDelegate>

@property(nonatomic, readonly, getter = isTesting)BOOL testing;
@property(nonatomic, weak)DTMainViewController *callback;

-(void)checkSpeed;
-(void)forceDownloadToFinish;


@end
