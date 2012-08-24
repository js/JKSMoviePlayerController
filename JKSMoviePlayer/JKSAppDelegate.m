//
//  JKSAppDelegate.m
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/21/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import "JKSAppDelegate.h"
#import "JKSMoviePlayerController.h"

@interface JKSAppDelegate ()
@property (strong) JKSMoviePlayerController *movieController;
@end

@implementation JKSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadMovieFromURL:[NSURL fileURLWithPath:@"/Users/johan/Desktop/skylapse.mp4"]];
}


- (IBAction)selectMoviePressed:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:@[@"mov",@"mp4"]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];

    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [self loadMovieFromURL:[panel URL]];
        }
    }];
}


#pragma mark - 

- (void)loadMovieFromURL:(NSURL *)url
{
    // Remove previous movie controller (if any)
    [self.movieController.view removeFromSuperview];

    self.movieController = [[JKSMoviePlayerController alloc] initWithContentURL:url];
    self.movieController.scalingMode = JKSMoviePlayerScalingResizeAspectFill;
    NSView *movieView = self.movieController.view;
    [self.movieContainerView addSubview:movieView];
    [self.movieContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[movieView(>=440)]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(movieView)]];
    [self.movieContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[movieView(>=60)]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(movieView)]];
}
@end
