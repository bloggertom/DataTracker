//
//  DTImprovedSpeedTester.m
//  Signal Tracker
//
//  Created by Thomas Wilson on 12/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTImprovedSpeedTester.h"
#define kBitInMb 1048576
#define kBitInMB 8388608

@interface DTImprovedSpeedTester ()

@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSURLRequest *request;
@property (nonatomic, strong)NSData *data;
@property (nonatomic)NSTimeInterval start;
@property (nonatomic, strong)NSMutableArray *speeds;
@property (nonatomic, strong)NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong)NSNumber *expectedSizeBytes;

@end

@implementation DTImprovedSpeedTester

-(id)init{
	self = [super init];
	if (self) {
		_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://download.thinkbroadband.com/5MB.zip"]];
		_testing = FALSE;
		
	}
	return self;
}

-(void)checkSpeed{
	_testing = TRUE;
	_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
	_downloadTask = [_session downloadTaskWithRequest:_request];
	_speeds = [[NSMutableArray alloc]init];
	_start = [NSDate timeIntervalSinceReferenceDate];
	[_downloadTask resume];
	NSLog(@"Checking Speed with improved speed test");
	
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
		});
	}];
	_testing = FALSE;
}

#pragma - mark NSURLSessionDownload Callbacks

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
	NSLog(@"Download finished");
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
	
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
	NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval timeTaken = finish - _start;
	
	NSNumber *speed = [NSNumber numberWithDouble:(((bytesWritten*8)/timeTaken)/kBitInMb)];
	[_speeds addObject:speed];
	_start = finish;
	
	NSLog(@"iteration speed: %1.2f", speed.doubleValue);
	if (_expectedSizeBytes == nil) {
		_expectedSizeBytes = [NSNumber numberWithLongLong:(totalBytesExpectedToWrite/5)];
		NSLog(@"Setting expectedsizebytes %lld", _expectedSizeBytes.longLongValue);
	}
	NSNumber *totalBytes = [NSNumber numberWithLongLong:totalBytesWritten];
	__block double progress = (totalBytes.doubleValue/_expectedSizeBytes.doubleValue)*100;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.callback speedTesterProgressDidChange:progress];
	});
	
	
	if (totalBytesWritten > _expectedSizeBytes.longLongValue) {
		[self forceDownloadToFinish];
	}
	
}
@end
