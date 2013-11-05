//
//  DTViewPersistanceDelegate.h
//  DataTracker
//
//  Created by Thomas Wilson on 04/11/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTViewPersistanceDelegate <NSObject>

-(void)mapFinishedInitialRenderingSuccessfully:(BOOL)success;

@end
