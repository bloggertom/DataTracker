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
#define kBitInMB 8388608
#define kMBTestSize 5
@interface DTSpeedTester()

@property(nonatomic, strong)NSMutableArray *speeds;
@property(nonatomic)NSTimeInterval start;
@property(nonatomic, strong)NSMutableData *data;
@property(nonatomic, strong)NSURLConnection *connection;
@property(nonatomic)BOOL testing;
@property(nonatomic)double expectedSizeBits;
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
	_connection = [NSURLConnection connectionWithRequest:_request delegate:self];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		//_start = [NSDate timeIntervalSinceReferenceDate];
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
	NSNumber *resultSpeed = [NSNumber numberWithDouble:((dataSize / kBitInMb) / (finish - _start))];
	[_speeds addObject:resultSpeed];
	NSLog(@"Speed %f, %f, %ui", resultSpeed.doubleValue, finish-_start, data.length);
		//_start = finish;
	[_data appendData:data];
	
	if(_testing){
		int progress = ABS(((_data.length*8)/_expectedSizeBits) * 100);
	    [self.callback speedTesterProgressDidChange:progress];
	}
	if((_data.length*8) >= _expectedSizeBits){
		[self cancelDownload];
		[self connectionDidFinishLoading:connection];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	if(!_testing){
		_testing = YES;
		
		_expectedSizeBits = response.expectedContentLength * 8;
		_expectedSizeBits = _expectedSizeBits/2;
		NSLog(@"Expected Size %f", _expectedSizeBits);
		_start = [NSDate timeIntervalSinceReferenceDate];
	}else{
			//something strange in the neighbourhood
		
			//process should restart
		_data = nil;
		_data = [[NSMutableData alloc]init];
		_start = [NSDate timeIntervalSinceReferenceDate];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
		//double total = 0.0;
	/*for (NSNumber *num in _speeds) {
		total += num.doubleValue;
	}*/
	NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
	double thing = (_data.length * 8)/kBitInMb;
	NSLog(@"total download in Mb %f", thing);
	double result =  thing / (finish - _start);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.callback speedTesterDidFinishSpeedTestWithResult:result];
}

-(void)speedtesterHasFinishedSynchronousSpeedTestWithResult:(double)result{
	_connection = nil;
	[self.callback speedTesterDidFinishSpeedTestWithResult:result];
}

-(void)cancelDownload{
	if (_connection) {
		[_connection cancel];
		_connection = nil;
	}
		

}
-(void)forceDownloadToFinish{
	[self connectionDidFinishLoading:_connection];
	[self cancelDownload];
	
}
@end
