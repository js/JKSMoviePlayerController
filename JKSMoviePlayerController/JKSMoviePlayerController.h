//
//  JKSMoviePlayerController.h
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/21/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKSMoviePlayerController : NSObject
@property (copy, readonly) NSURL *contentURL;
@property (strong, readonly) NSView *view;

@property (nonatomic, readonly) Float64 duration;
@property (nonatomic, assign) Float64 currentTime;

- (instancetype)initWithContentURL:(NSURL *)fileURL;

- (void)play;
- (void)pause;
@end
