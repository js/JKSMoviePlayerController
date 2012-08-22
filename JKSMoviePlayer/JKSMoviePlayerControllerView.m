//
//  JKSMoviePlayerControllerView.m
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/22/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import "JKSMoviePlayerControllerView.h"

@implementation JKSMoviePlayerControllerView

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setWantsLayer:YES];

        _rewindButton = [self createButtonWithFrame:NSMakeRect(0, 0, 25, 18) image:[self rewindImageWithSize:NSMakeSize(25, 18)]];
        [self addSubview:_rewindButton];

        _playPauseButton = [self createButtonWithFrame:NSMakeRect(0, 0, 28, 28) image:[self playImageWithSize:NSMakeSize(28, 28)]];
        [_playPauseButton setAlternateImage:[self playImageWithSize:[_playPauseButton frame].size]];
        [self addSubview:_playPauseButton];

        _fastForwardButton = [self createButtonWithFrame:NSMakeRect(0, 0, 25, 18) image:[self fastForwardImageWithSize:NSMakeSize(25, 18)]];
        [self addSubview:_fastForwardButton];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_playPauseButton
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_rewindButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_playPauseButton
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_fastForwardButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_playPauseButton
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rewindButton]-[_playPauseButton]-[_fastForwardButton]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_rewindButton, _playPauseButton, _fastForwardButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_playPauseButton]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_playPauseButton)]];
    }

    return self;
}




- (void)drawRect:(NSRect)dirtyRect
{
    // TODO: draw rounded gradient-y box
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:8 yRadius:8];
    [path setLineWidth:1.5];
    [[NSColor grayColor] setStroke];
    [[NSColor blackColor]setFill];
    [path fill];
    [path stroke];
}


#pragma mark - Private methods

- (NSButton *)createButtonWithFrame:(NSRect)frame image:(NSImage *)image
{
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 25, 18)];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setButtonType:NSMomentaryChangeButton];
    [button setBordered:NO];
    [button setImage:image];
    return button;
}


- (NSImage *)rewindImageWithSize:(NSSize)size
{
    NSImage *image = [NSImage imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint:NSMakePoint(NSMinX(dstRect), NSMidY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMinY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMidY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMaxX(dstRect), NSMinY(dstRect))]; // tri2
        [path lineToPoint:NSMakePoint(NSMaxX(dstRect), NSMaxY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMidY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMaxY(dstRect))]; // tri1 again
        [path lineToPoint:NSMakePoint(NSMinX(dstRect), NSMidY(dstRect))];
        [path closePath];
        [[NSColor whiteColor] setFill];
        [path fill];
        return YES;
    }];
    [image setTemplate:YES];
    return image;
}


- (NSImage *)playImageWithSize:(NSSize)size
{
    return [NSImage imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint:NSZeroPoint];
        [path lineToPoint:NSMakePoint(NSMaxX(dstRect), NSMidY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMinX(dstRect), NSMaxY(dstRect))];
        [path closePath];
        [[NSColor whiteColor] setFill];
        [path fill];
        return YES;
    }];
}


- (NSImage *)pauseImageWithSize:(NSSize)size
{
    NSImage *image = [NSImage imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        [[NSColor whiteColor] setFill];
        const CGFloat spacing = 2.0f;
        NSRectFill(NSMakeRect(NSMinX(dstRect), NSMinY(dstRect), (NSWidth(dstRect)/2)-spacing, NSHeight(dstRect)));
        NSRectFill(NSMakeRect((NSWidth(dstRect)/2)+spacing, NSMinY(dstRect), NSWidth(dstRect)-spacing, NSHeight(dstRect)));
        return YES;
    }];
    [image setTemplate:YES];
    return image;
}


- (NSImage *)fastForwardImageWithSize:(NSSize)size
{
    NSImage *image = [NSImage imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint:NSMakePoint(NSMinX(dstRect), NSMinY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMinX(dstRect), NSMaxY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMidY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMaxY(dstRect))]; // tri2
        [path lineToPoint:NSMakePoint(NSMaxX(dstRect), NSMidY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMinY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMidX(dstRect), NSMidY(dstRect))];
        [path lineToPoint:NSMakePoint(NSMinX(dstRect), NSMinY(dstRect))];
        [path closePath];
        [[NSColor whiteColor] setFill];
        [path fill];
        return YES;
    }];
    [image setTemplate:YES];
    return image;
}

@end
