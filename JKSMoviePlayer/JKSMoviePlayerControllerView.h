//
//  JKSMoviePlayerControllerView.h
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/22/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKSMoviePlayerControllerView : NSView
@property (strong, readonly) NSButton *rewindButton;
@property (strong, readonly) NSButton *playPauseButton;
@property (strong, readonly) NSButton *fastForwardButton;
@property (strong, readonly) NSSlider *timeSlider;
//@property (strong, readonly) NSSlider *volumeSlider;
@end
