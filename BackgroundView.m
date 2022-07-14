//
//  BackgroundView.m
//
//  Created by Vagrod on 5/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView

- (void) drawRect:(NSRect)dirtyRect{
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"viewPattern" ofType:@"png"];
	NSImage* NoiseBGMainView = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	// Black background
	[[NSColor blackColor] set];
	[NSBezierPath fillRect: [self visibleRect]];
	
	// Draw Rect with pattern image
	[[NSColor colorWithPatternImage:NoiseBGMainView] set];
	[NSBezierPath fillRect: dirtyRect];
	[[NSColor greenColor] set];
	[NSBezierPath strokeRect: dirtyRect];
}

@end
