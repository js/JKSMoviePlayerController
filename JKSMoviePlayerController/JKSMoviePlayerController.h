//
//  JKSMoviePlayerController.h
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/21/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JKSMoviePlayerScalingMode) {
    JKSMoviePlayerScalingResizeAspect,     // Preserve aspect ratio; fit within layer bounds.
    JKSMoviePlayerScalingResizeAspectFill, // Preserve aspect ratio; fill layer bounds.
    JKSMoviePlayerScalingResize,           // Stretch to fill layer bounds.
};

@interface JKSMoviePlayerController : NSObject
@property (copy, readonly) NSURL *contentURL;
@property (strong, readonly) NSView *view;
@property (nonatomic, assign) JKSMoviePlayerScalingMode scalingMode;
@property (nonatomic, readonly) Float64 duration;
@property (nonatomic, assign) Float64 currentTime;
@property (assign, readonly, getter=isPlayable) BOOL playable;
@property (nonatomic, strong) NSTextField *unplayableLabel;

- (instancetype)initWithContentURL:(NSURL *)fileURL;

- (void)play;
- (void)pause;
@end
