//
//  DTSpeedTester.h
//  DataTracker
//
//  Created by Thomas Wilson on 05/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTSpeedTester : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong)NSURLRequest *request;

-(double)checkSpeed;

@end
