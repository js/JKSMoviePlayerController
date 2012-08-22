//
//  JKSAppDelegate.h
//  JKSMoviePlayer
//
//  Created by Johan Sørensen on 8/21/12.
//  Copyright (c) 2012 Johan Sørensen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JKSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *movieContainerView;

- (IBAction)selectMoviePressed:(id)sender;
@end
