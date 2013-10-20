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
		_reachability = [[Reachability alloc]init];
		[_reachability setReachableOnWWAN:YES];
		
	}
	return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	
	[_callback locationManagerHasUpdatedToLoaction:manager.location];
	
	
}

@end
