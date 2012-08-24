JKSMoviePlayerController is a little controller for easily adding user-controlled playback of videos to AppKit based applications using the AVFoundation framework. It's inspired, in spirit, by MPMovieController found in the iOS SDK.

![screenshot](https://raw.github.com/js/JKSMoviePlayerController/master/screenshot.png)

How
----

Add the files in JKSMoviePlayerController/* to your Xcode project along with the `AVFoundation`, `QuartzCore` and `CoreMedia` frameworks.

    JKSMoviePlayerController *movieController = [[JKSMoviePlayerController alloc] initWithContentURL:movieURL];
	[self.movieContainerView addSubview:movieController.view];

Where
-----

JKSMoviePlayerController requires Mac OSX 10.8+ Mountain Lion. Primarily because it uses the wonderful +[NSImage imageWithSize:flipped:drawingHandler:]. Adding support for 10.7 should be fairly straightforward though.

Why
----

QTKit and its QTMovieView is the de facto way of adding video playback to Cocoa apps. However it has two major issues on Mountain Lion

1. Its playback controller view doesn't seem to want to play at all together with Auto Layout. `<rdar://12167052>`
2. Its playback controller view looks extremely dull and, well, aged.
3. QTKit feels like one of those frameworks that will eventually be slashed (authors subjective opinion)

Things to do
----

* TODO A nicer playback controller view, with rewind/fast-forward and volume controls. Should probably look even more like the one on Quicktime X so users will recognize it quicker
* TODO JKSMoviePlayerController should expose more controller functionality (start/stop playback programmatically etc)
* TODO Hook up the controls in the controller view to the responder chain
* TODO Build it as a `.framework`
* TODO Less zealous showing and hiding of the controller view when entering/exiting the tracking area

License
-------

	Copyright (c) 2012, Johan Sørensen
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	    * Redistributions of source code must retain the above copyright
	      notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright
	      notice, this list of conditions and the following disclaimer in the
	      documentation and/or other materials provided with the distribution.
	    * Neither the name of the Author nor the
	      names of its contributors may be used to endorse or promote products
	      derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
