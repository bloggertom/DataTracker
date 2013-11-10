//
//  DTLocationDelegate.m
//  DataTracker
//
//  Created by Thomas Wilson on 04/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTLocationDelegate.h"
#import "Reachability.h"
#import "DTMainViewController.h"

@interface DTLocationDelegate()

@property(nonatomic, strong)Reachability *reachability;


@end
@implementation DTLocationDelegate

-(id)init{
	self = [super init];
	if(self){
		_reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
		[_reachability setReachableOnWWAN:YES];
		
	}
	return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	if (!_reachability.isReachableViaWWAN) {
		NSLog(@"Connected on WIFI");
		return;
	}
	NSLog(@"Location update, Reachable Via WWAN");
	[_callback locationManagerHasUpdatedToLoaction:manager.location];
	
	
	
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			[self.callback centerOnUser];
			break;
		default:
			break;
	}
}
@end
