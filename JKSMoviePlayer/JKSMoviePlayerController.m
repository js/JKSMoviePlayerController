//
//  JKSMoviePlayerController.m
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/21/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import "JKSMoviePlayerController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "JKSMoviePlayerControllerView.h"

/* Partially based on the AVSimplePlayer sample from Apple */

static void *JKSMoviePlayerControllerRateContext = &JKSMoviePlayerControllerRateContext;
static void *JKSMoviePlayerControllerItemStatusContext = &JKSMoviePlayerControllerItemStatusContext;
static void *JKSMoviePlayerPlayerLayerReadyForDisplay = &JKSMoviePlayerPlayerLayerReadyForDisplay;

@interface JKSMoviePlayerController ()
@property (strong, readwrite) NSView *view;
@property (retain) id timeObserverToken;
@property (strong) AVPlayer *player;
@property (strong) AVPlayerLayer *playerLayer;
@property (strong) JKSMoviePlayerControllerView *controllerView;
@end

@implementation JKSMoviePlayerController
{
    NSProgressIndicator *_spinner;
}

- (instancetype)initWithContentURL:(NSURL *)fileURL
{
    if ((self = [super init])) {
        _contentURL = [fileURL copy];
        _view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 640, 480)];
        [_view setWantsLayer:YES];
        _spinner = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
        [_spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_spinner setStyle:NSProgressIndicatorSpinningStyle];
        [_spinner startAnimation:self];
        [_view addSubview:_spinner];
        [_view addConstraint:[NSLayoutConstraint constraintWithItem:_spinner
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
        [_view addConstraint:[NSLayoutConstraint constraintWithItem:_spinner
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0]];

        [_view layer].backgroundColor = [[NSColor blackColor] CGColor];
        _player = [[AVPlayer alloc] init];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [self addObserver:self
               forKeyPath:@"player.rate"
                  options:NSKeyValueObservingOptionNew
                  context:JKSMoviePlayerControllerRateContext];
        [self addObserver:self
               forKeyPath:@"player.currentItem.status"
                  options:NSKeyValueObservingOptionNew
                  context:JKSMoviePlayerControllerItemStatusContext];

        // Create an asset with our URL, asychronously load its tracks, its duration, and whether it's playable or protected.
        // When that loading is complete, configure a player to play the asset.
        AVURLAsset *asset = [AVAsset assetWithURL:_contentURL];
        NSArray *assetKeysToLoadAndTest = @[@"playable", @"hasProtectedContent", @"tracks", @"duration"];
        [asset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^(void) {
            // The asset invokes its completion handler on an arbitrary queue when loading is complete.
            // Because we want to access our AVPlayer in our ensuing set-up, we must dispatch our handler to the main queue.
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self setUpPlaybackOfAsset:asset withKeys:assetKeysToLoadAndTest];
            });
            
        }];
        
        _controllerView = [[JKSMoviePlayerControllerView alloc] initWithFrame:NSMakeRect(0, 0, 440, 40)];
        [_view addSubview:_controllerView];
        [_view addConstraint:[NSLayoutConstraint constraintWithItem:_controllerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
        [_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_controllerView(==440)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_controllerView)]];
        [_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_controllerView(==40)]-40-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_controllerView)]];

        [_controllerView.playPauseButton setTarget:self];
        [_controllerView.playPauseButton setAction:@selector(playPauseToggle:)];
        [_controllerView.playPauseButton setEnabled:NO];

        [_controllerView.timeSlider setTarget:self];
        [_controllerView.timeSlider setAction:@selector(scrubberChanged:)];
        [_controllerView.timeSlider setEnabled:NO];
    }
    return self;
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"player.rate"];
    [self removeObserver:self forKeyPath:@"player.currentItem.status"];
    [_player removeTimeObserver:self.timeObserverToken];
    if (_playerLayer)
		[self removeObserver:self forKeyPath:@"playerLayer.readyForDisplay"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == JKSMoviePlayerControllerItemStatusContext) {
		AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
		BOOL enable = NO;
		switch (status) {
			case AVPlayerItemStatusUnknown:
				break;
			case AVPlayerItemStatusReadyToPlay:
				enable = YES;
				break;
			case AVPlayerItemStatusFailed:
				[self stopLoadingAnimationAndHandleError:[[self.player currentItem] error]];
				break;
		}
		
        [_controllerView.playPauseButton setEnabled:enable];
        [_controllerView.timeSlider setEnabled:enable];
        if (enable) {
            [_controllerView.timeSlider setMaxValue:[self duration]];
            [self updateTimeLabel];
            
        }
	} else if (context == JKSMoviePlayerControllerRateContext) {
		float rate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
		if (rate != 1.0f) {
            [_controllerView setPlaying:NO];
		} else {
            [_controllerView setPlaying:YES];
		}
	} else if (context == JKSMoviePlayerPlayerLayerReadyForDisplay) {
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES) {
			// The AVPlayerLayer is ready for display. Hide the loading spinner and show it.
			[self stopLoadingAnimationAndHandleError:nil];
			[self.playerLayer setHidden:NO];
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


#pragma mark - Control actions


- (void)playPauseToggle:(id)sender
{
	if ([self.player rate] != 1.f) {
		if (self.currentTime == self.duration) {
            self.currentTime = 0.0f;
        }
		[self.player play];
	} else {
		[self.player pause];
	}
}


- (void)scrubberChanged:(NSSlider *)sender
{
    [self.player seekToTime:CMTimeMakeWithSeconds([sender doubleValue], NSEC_PER_SEC)];
}


#pragma mark - Private methods

- (void)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys
{
	// This method is called when the AVAsset for our URL has completing the loading of the values of the specified array of keys.
	// We set up playback of the asset here.
	
	// First test whether the values of each of the keys we need have been successfully loaded.
	for (NSString *key in keys) {
		NSError *error = nil;
		if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
			[self stopLoadingAnimationAndHandleError:error];
			return;
		}
	}
	
	if (![asset isPlayable] || [asset hasProtectedContent]) {
		// We can't play this asset. Show the "Unplayable Asset" label.
		[self stopLoadingAnimationAndHandleError:nil];
        // TODO: notify delegate
        NSLog(@"can't play this. playable=%d protected=%d", [asset isPlayable], [asset hasProtectedContent]);
		return;
	}
	
	// We can play this asset.
	// Set up an AVPlayerLayer according to whether the asset contains video.
	if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
		// Create an AVPlayerLayer and add it to the player view if there is video, but hide it until it's ready for display
		_playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
		_playerLayer.frame = [[_view layer] bounds];
		_playerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		_playerLayer.hidden = YES;
		//[[_view layer] addSublayer:_playerLayer];
        [[_view layer] insertSublayer:_playerLayer below:[_controllerView layer]];
		[self addObserver:self
               forKeyPath:@"playerLayer.readyForDisplay"
                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                  context:JKSMoviePlayerPlayerLayerReadyForDisplay];
	} else {
		// This asset has no video tracks. Show the "No Video" label.
		[self stopLoadingAnimationAndHandleError:nil];
	}
	
	// Create a new AVPlayerItem and make it our player's current item.
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
	[_player replaceCurrentItemWithPlayerItem:playerItem];
	
    __weak JKSMoviePlayerController *weakSelf = self;
	_timeObserverToken = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10)
                                                               queue:dispatch_get_main_queue()
                                                          usingBlock:^(CMTime time) {
                                                              [_controllerView.timeSlider setDoubleValue:CMTimeGetSeconds(time)];
                                                              [weakSelf updateTimeLabel];
                                                          }];
}


- (void)updateTimeLabel
{
    if (CMTIME_IS_INVALID([self.player currentTime])) {
        [self.controllerView.timeLabel setStringValue:@"--:--"];
    } else {
        Float64 seconds = CMTimeGetSeconds([self.player currentTime]);
        NSUInteger minutes = seconds / 60;
        NSUInteger secondsLeftOver = seconds - (minutes * 60);
        NSString *timeString = [NSString stringWithFormat:@"%02ld:%02ld", minutes, secondsLeftOver];
        [self.controllerView.timeLabel setStringValue:timeString];
    }
}



- (void)stopLoadingAnimationAndHandleError:(NSError *)error
{
	[_spinner stopAnimation:self];
	[_spinner setHidden:YES];
	if (error) {
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), error);
        // TODO: Notify delegate
	}
}


- (double)duration
{
	AVPlayerItem *playerItem = [self.player currentItem];
	
	if ([playerItem status] == AVPlayerItemStatusReadyToPlay) {
		return CMTimeGetSeconds([[playerItem asset] duration]);
	} else {
		return 0.f;
    }
}

- (double)currentTime
{
	return CMTimeGetSeconds([self.player currentTime]);
}

@end
