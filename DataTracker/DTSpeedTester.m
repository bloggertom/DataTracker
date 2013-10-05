//
//  DTSpeedTester.m
//  DataTracker
//
//  Created by Thomas Wilson on 05/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTSpeedTester.h"

@interface DTSpeedTester()



@end

@implementation DTSpeedTester

-(id)init{
	self = [super init];
	if(self){
		_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.co.uk"]];
	}
	return self;
	
}

/*!
 @method checkSpeed.
 @abstract Returns speed of connection in Mb/s.
 */
-(double)checkSpeed{
	double speed = 0.0;
	NSURLResponse *repsonse;
	NSError *error;
	
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	NSData *data = [NSURLConnection sendSynchronousRequest:self.request returningResponse:&repsonse error:&error];
	NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
	if (error == nil) {
		
		NSTimeInterval timeTake = finish - start;
		NSLog(@"Time taken %f", timeTake);
		NSLog(@"Data Length %d",(data.length*8));
		speed = (data.length*8) /timeTake;
		
		
		speed /= 1048576; //bits in a megabit
	}
	
	
	return speed;
}

@end
