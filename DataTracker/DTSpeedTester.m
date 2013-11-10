//
//  DTSpeedTester.m
//  DataTracker
//
//  Created by Thomas Wilson on 05/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTSpeedTester.h"
#import "DTMainViewController.h"
#define kBitInMb 1048576
#define kMbTestSize 2.5
@interface DTSpeedTester()

@property(nonatomic, strong)NSMutableArray *speeds;
@property(nonatomic)NSTimeInterval start;
@property(nonatomic, strong)NSMutableData *data;
@property(nonatomic)BOOL testing;
@property(nonatomic)double expectedSize;
@end

@implementation DTSpeedTester

-(id)init{
	self = [super init];
	if(self){
		_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://download.thinkbroadband.com/5MB.zip"]];
		_speeds = [[NSMutableArray alloc]init];
		_data = [[NSMutableData alloc]init];
	}
	return self;
	
}


#pragma mark - Progress and speed test
/*!
 @method checkSpeed.
 @abstract Returns speed of connection in Mb/s.
 */
-(void)checkSpeed{
	[NSURLConnection connectionWithRequest:_request delegate:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	_start = [NSDate timeIntervalSinceReferenceDate];
}

-(void)performSynchronousSpeedTest{
	NSLog(@"perfoming synchronous speed test");
	double result = [DTSpeedTester performSynchronousSpeedTest];
	[self speedtesterHasFinishedSynchronousSpeedTestWithResult:result];
}

+(double)performSynchronousSpeedTest{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://download.thinkbroadband.com/5MB.zip"]];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
	double dataSize = data.length;
	
	double result = (dataSize /kBitInMb) / (finish / start);
	return result;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	double dataSize = data.length * 8;
	NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
	NSNumber *resultSpeed = [NSNumber numberWithDouble:(dataSize / kBitInMb) / (finish - _start)];
	[_speeds addObject:resultSpeed];
	_start = finish;
	[_data appendData:data];
	
	if(_testing){
		int progress = ABS(_data.length/_expectedSize * 100);
	    [self.callback speedTesterProgressDidChange:progress];
	}
	if((_data.length) >= _expectedSize){
		[connection cancel];
		[self connectionDidFinishLoading:connection];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	if(!_testing){
		_testing = YES;
		_expectedSize = kMbTestSize * (kBitInMb/8);
		NSLog(@"Expected Size %f", _expectedSize);
	}else{
			//something strange in the neighbourhood
		
			//process should restart
		_data = nil;
		_data = [[NSMutableData alloc]init];
		_start = [NSDate timeIntervalSinceReferenceDate];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	double total = 0.0;
	for (NSNumber *num in _speeds) {
		total += num.doubleValue;
	}
	
	double result = total / [_speeds count];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.callback speedTesterDidFinishSpeedTestWithResult:result];
}

-(void)speedtesterHasFinishedSynchronousSpeedTestWithResult:(double)result{
	[self.callback speedTesterDidFinishSpeedTestWithResult:result];
}

@end
