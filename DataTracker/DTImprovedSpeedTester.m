//
//  DTImprovedSpeedTester.m
//  Signal Tracker
//
//  Created by Thomas Wilson on 12/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTImprovedSpeedTester.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#define kBitInMb 1048576
#define kBitInMB 8388608
#define speedTestCat
@interface DTImprovedSpeedTester ()

@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSURLRequest *request;
@property (nonatomic, strong)NSData *data;
@property (nonatomic)NSTimeInterval start;
@property (nonatomic, strong)NSMutableArray *speeds;
@property (nonatomic, strong)NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong)NSNumber *expectedSizeBytes;
@property (nonatomic, strong)id<GAITracker> tracker;
@property (nonatomic)BOOL forceFinish;
@end

@implementation DTImprovedSpeedTester

-(id)init{
	self = [super init];
	if (self) {
		_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://download.thinkbroadband.com/5MB.zip"]];
		_testing = FALSE;
		_tracker = [[GAI sharedInstance]defaultTracker];
		
	}
	return self;
}

-(void)checkSpeed{
	_forceFinish = YES;
	_testing = TRUE;
	_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
	_downloadTask = [_session downloadTaskWithRequest:_request];
	_speeds = [[NSMutableArray alloc]init];
	_start = [NSDate timeIntervalSinceReferenceDate];
	
	[_tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SpeedTester" action:@"Start Speed Test" label:@"start" value:nil]build]];
	
	
	[_downloadTask resume];
	
}

-(void)forceDownloadToFinish{
	[_downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
		double total = 0.0;
		for (NSNumber *speed in _speeds) {
			total += speed.doubleValue;
		}
		NSLog(@"Download force Finished");
		double result = total/_speeds.count;
		NSLog(@"Speed test finished with result %1.2f",result);
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.callback speedTesterDidFinishSpeedTestWithResult:result];
			_downloadTask = nil;
			_session = nil;
			_speeds = nil;
			_testing = FALSE;
		});
		
	}];
	if (_forceFinish) {
		[_tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SpeedTester" action:@"End Speed Test" label:@"Force Finish" value:nil]build]];
	}else{
		[_tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SpeedTester" action:@"End Speed Test" label:@"Finished" value:nil]build]];
	}
	
	
}

-(void)cancelSpeedTest{
	NSLog(@"Canceling Speedtest");
	[_downloadTask cancel];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.callback speedTestDidCancel];
		_downloadTask = nil;
		_session = nil;
		_speeds = nil;
		_testing = FALSE;
	});
	[_tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SpeedTester" action:@"End Speed Test" label:@"Cancel" value:nil]build]];
}

#pragma - mark NSURLSessionDownload Callbacks

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
	NSLog(@"Download finished");
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
	
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
	totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
	if (downloadTask.state == NSURLSessionTaskStateCanceling) {
		return;
	}
	NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval timeTaken = finish - _start;
	
	NSNumber *speed = [NSNumber numberWithDouble:(((bytesWritten*8)/timeTaken)/kBitInMb)];
	[_speeds addObject:speed];
	_start = finish;
	
	if (_expectedSizeBytes == nil) {
		_expectedSizeBytes = [NSNumber numberWithLongLong:(totalBytesExpectedToWrite/2)];
		NSLog(@"Setting expectedsizebytes %lld", _expectedSizeBytes.longLongValue);
	}
	NSNumber *totalBytes = [NSNumber numberWithLongLong:totalBytesWritten];
	__block double progress = (totalBytes.doubleValue/_expectedSizeBytes.doubleValue)*100;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.callback speedTesterProgressDidChange:progress];
	});
	
	
	if (totalBytesWritten > _expectedSizeBytes.longLongValue) {
		
		_forceFinish = NO;
		[self forceDownloadToFinish];
	}
	
}
@end
