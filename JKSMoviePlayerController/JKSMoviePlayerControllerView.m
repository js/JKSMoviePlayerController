//
//  JKSMoviePlayerControllerView.m
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/22/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import "JKSMoviePlayerControllerView.h"

@interface JKSMoviePlayerSliderCell : NSSliderCell
@end

@implementation JKSMoviePlayerSliderCell
- (void)drawKnob:(NSRect)knobRect
{
    knobRect.origin.x += 6;
    knobRect.origin.y += 8;
    knobRect.size.height = 7;
    knobRect.size.width = 7;

    NSBezierPath *knobPath = [NSBezierPath bezierPathWithOvalInRect:knobRect];
    [[NSColor whiteColor] set];
    [knobPath fill];
}


- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    NSRect sliderRect = aRect;
    sliderRect.origin.y += (NSMaxY(sliderRect) / 2) - 4;
    sliderRect.origin.x += 4;
    sliderRect.size.width -= 10;
    sliderRect.size.height = 11;

    NSBezierPath *barPath = [NSBezierPath bezierPathWithRoundedRect:sliderRect xRadius:4 yRadius:4];
    [barPath setLineWidth:1.5f];

    [[NSGraphicsContext currentContext] saveGraphicsState];
    [[NSColor blackColor] set];
    NSRectFill(aRect);
    [barPath fill];
    [[NSGraphicsContext currentContext] restoreGraphicsState];

    [[NSColor whiteColor] setStroke];
    [[NSColor colorWithDeviceWhite:0.5f alpha:1.0f] set];
    [barPath stroke];
}
@end


@interface JKSMoviePlayerSlider : NSSlider
@end

@implementation JKSMoviePlayerSlider
+ (Class)cellClass { return [JKSMoviePlayerSliderCell class]; }
@end


@implementation JKSMoviePlayerControllerView

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setWantsLayer:YES];
        [self layer].backgroundColor = [[NSColor blackColor] CGColor];
        [self layer].cornerRadius = 8;

        NSRect playPauseRect = NSMakeRect(0, 0, 18, 18);
        _playPauseButton = [self createButtonWithFrame:playPauseRect image:[self playImageWithSize:playPauseRect.size]];
        [self addSubview:_playPauseButton];

        _timeSlider = [[JKSMoviePlayerSlider alloc] initWithFrame:NSMakeRect(0, 0, 235, 20)];
        [_timeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_timeSlider];

        _timeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 35, 15)];
        [_timeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_timeLabel setBezeled:NO];
        [_timeLabel setDrawsBackground:NO];
        [_timeLabel setEditable:NO];
        [_timeLabel setSelectable:NO];
        [_timeLabel setTextColor:[NSColor whiteColor]];
        [_timeLabel setStringValue:@"--:--"];
        [self addSubview:_timeLabel];

        [self addConstraintWithItem:_timeSlider toItem:self attribute:NSLayoutAttributeCenterX];
        [self addConstraintWithItem:_timeSlider toItem:self attribute:NSLayoutAttributeCenterY];
        [self addConstraintWithItem:_playPauseButton toItem:_timeSlider attribute:NSLayoutAttributeCenterY];
        [self addConstraintWithItem:_timeLabel toItem:_timeSlider attribute:NSLayoutAttributeCenterY];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_playPauseButton(==18)]-[_timeSlider]-5-[_timeLabel]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_playPauseButton, _timeSlider, _timeLabel)]];
    }

    return self;
}


- (void)setPlaying:(BOOL)flag
{
    if (flag) {
        [self.playPauseButton setToolTip:@"Pause"];
        [self.playPauseButton setImage:[self pauseImageWithSize:[self.playPauseButton frame].size]];
    } else {
        [self.playPauseButton setToolTip:@"Play"];
        [self.playPauseButton setImage:[self playImageWithSize:[self.playPauseButton frame].size]];
    }
}


#pragma mark - Private methods

- (void)addConstraintWithItem:(id)view toItem:(id)otherView attribute:(NSLayoutAttribute)attribute
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:otherView
                                                     attribute:attribute
                                                    multiplier:1.0
                                                      constant:0]];
}


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
