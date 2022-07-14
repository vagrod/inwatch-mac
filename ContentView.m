//
//  ContentView.m
//  InWatch
//
//  Created by Vagrod on 5/7/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "ContentView.h"
#import <Quartz/Quartz.h>

@implementation ContentView

@synthesize ItemHeight;
@synthesize TopMargin;
@synthesize RightMargin;
@synthesize LeftMargin;
@synthesize Spacing;
@synthesize BottomMargin;
@synthesize Textured;
@synthesize Texture;
@synthesize BackColor;

- (BOOL)isFlipped{
	// Telling parent that we have NORMAL coordinates but not cocoa's, (i.e. top is at 0,0)
	return YES;
}

- (void) ControlsAdd: (NSView *) control withIndependentHeight: (BOOL) selfh{
	if (! self) return;
	
	[control setWantsLayer:YES];
	[control setCanDrawConcurrently:selfh];
	if (selfh){
//		[control setFrameSize:[control frame].size.width, [self ItemHeight]];
	}else{
		[control setFrameSize:NSMakeSize([control frame].size.width, [self ItemHeight])];
	}

	[[NSAnimationContext currentContext] setDuration:0.3];
	[control setAlphaValue:0];
	[control setAutoresizingMask:NSViewMaxYMargin | NSViewMinXMargin | NSViewWidthSizable];
	[self addSubview:control];
	[self calculateWidths];
	[self display];
	[control display];
	
	[[control animator] setAlphaValue:1];
	
}

- (void) ControlsAdd: (NSView *) control{
	if (! self) return;
	
	[control setWantsLayer:YES];
	[control setCanDrawConcurrently:NO];
	[control setFrameSize:NSMakeSize([control frame].size.width, [self ItemHeight])];
	[[NSAnimationContext currentContext] setDuration:0.3];
	[control setAlphaValue:0];
	[control setAutoresizingMask:NSViewMaxYMargin | NSViewMinXMargin | NSViewWidthSizable];
	[self addSubview:control];
	[self calculateWidths];
	[self display];
	[control display];
	
	[[control animator] setAlphaValue:1];
}

- (void) calculateWidths{
	if (! self) return;
	
	NSView * v = self;
	//int w = [self ItemHeight];
	int i=0;
	int cnt = [[v subviews] count];
	int docH = [v frame].size.height;
	int docW = [[v superview] frame].size.width;
	BOOL isLastControlIndependent = NO;
	int indControlH = 0;
	NSPoint p;
	int lastH = [self TopMargin];
	int fullH = [self TopMargin] + [self BottomMargin] + (cnt - 1) * [self Spacing];
	
	for (NSView * f in [v subviews]){
		fullH += [f frame].size.height;
	}
	
	if (fullH < [[v superview] frame].size.height) fullH = [[v superview] frame].size.height;
	
	[v setFrameSize:NSMakeSize(docW, fullH)];
	
	docH = [v frame].size.height;
	
	[v setBoundsOrigin:NSMakePoint(0, 0)];
	BOOL fFirst = YES;
	
	for (NSView * f in [v subviews]){
		if (fFirst){
			p = NSMakePoint([self LeftMargin], [self TopMargin]);
			fFirst = NO;
		}else{
			if (! isLastControlIndependent){
				p = NSMakePoint([self LeftMargin], lastH);
			}else{
				p = NSMakePoint([self LeftMargin], lastH);	
			}
		}
		
		if ((BOOL) [f canDrawConcurrently] == NO){
			[[f animator] setFrame:NSMakeRect(p.x, p.y, docW - [self RightMargin] - [self LeftMargin], [self ItemHeight])];
		}else{
			[[f animator] setFrame:NSMakeRect(p.x, p.y, docW - [self RightMargin] - [self LeftMargin], [f frame].size.height)];
			isLastControlIndependent = YES;
			indControlH = [f frame].size.height;
		}
		
		lastH += [f frame].size.height + [self Spacing];
		
		i++;
	}
}

- (void) calculateWidths: (id)ignoringControl{
	if (! self) return;
	
	NSView * v = self;
	//int w = [self ItemHeight];
	int i=0;
	int cnt = [[v subviews] count];
	int docH = [v frame].size.height;
	int docW = [[v superview] frame].size.width;
	int indControlH = 0;
	NSPoint p;
	int lastH = [self TopMargin];
	int fullH = [self TopMargin] + [self BottomMargin] + (cnt - 1 - 1) * [self Spacing];
	
	for (NSView * f in [v subviews]){
		fullH += [f frame].size.height;
	}
	
	if (fullH < [[v superview] frame].size.height) fullH = [[v superview] frame].size.height;
	
	[v setFrameSize:NSMakeSize(docW, fullH)];
	
	docH = [v frame].size.height;
	
	[v setBoundsOrigin:NSMakePoint(0, 0)];
	BOOL fFirst = YES;
	
	for (NSView * f in [v subviews]){
		if (f != ignoringControl){
			if (fFirst){
				p = NSMakePoint([self LeftMargin], [self TopMargin]);
				fFirst = NO;
			}else{
				p = NSMakePoint([self LeftMargin], lastH);
			}
		
			if ((BOOL) [f canDrawConcurrently] == NO){
				[[f animator] setFrame:NSMakeRect(p.x, p.y, docW - [self RightMargin] - [self LeftMargin], [self ItemHeight])];
			}else{
				[[f animator] setFrame:NSMakeRect(p.x, p.y, docW - [self RightMargin] - [self LeftMargin], [f frame].size.height)];
				indControlH = [f frame].size.height;
			}
		
			lastH += [f frame].size.height + [self Spacing];
		}
		i++;
	}
}

- (void) ControlsClear{
	while ([[self subviews] count]){
		[[[self subviews]objectAtIndex:0] removeFromSuperview];
	}
	
	[self calculateWidths];
}

NSView * removingControl;
CAAnimation * an;

- (void) ControlsRemove: (NSView *) control{	
	//[self calculateWidths:control];
	
	removingControl = control;
	if (an) [an release];
	
	an = [[[control animator] animationForKey:@"hidden"] autorelease];
	[an setDuration:0.3];
	
	[an setDelegate:self];
	[[control animator] setHidden:YES];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
	if (removingControl){
		[removingControl removeFromSuperview];
		[removingControl release];
		[self calculateWidths];
	}
	
	removingControl = nil;
}

- (id)initWithParent: (NSScrollView *) parent{
    self = [super initWithFrame:NSMakeRect(0, 0, [parent frame].size.width, [parent frame].size.height)];
    if (self) {	
		[self setWantsLayer:YES];
        // Initialization code here.
		[parent addSubview:self];
		[self setAutoresizingMask:NSViewMaxYMargin | NSViewMinXMargin | NSViewWidthSizable];
		[parent setDocumentView:self];
		[self calculateWidths];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	float xOffset = NSMinX([self convertRect:[self frame] toView:nil]); 
	float yOffset = NSMinY([self convertRect:[self frame] toView:nil]); 
	[[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(xOffset, yOffset)]; 
	
	// Draw background
	if ([self BackColor]){
		[[self BackColor] set];
		[NSBezierPath fillRect: [self visibleRect]];
	}
	
	// Draw Rect with pattern image
	if ([self Textured]){
		[[NSColor colorWithPatternImage:[self Texture]] set];
		[NSBezierPath fillRect: dirtyRect];
	}
}

@end
