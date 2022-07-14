//
//  BottomView.m
//
//  Created by Vagrod on 5/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "BottomView.h"

@implementation BottomView

@synthesize startingColor;
@synthesize endingColor;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame;
{
	if (self = [super initWithFrame:frame]) {
		NSColor * clrFrom = [NSColor windowFrameColor];
		
		double r = [[clrFrom
					 colorUsingColorSpaceName:@"NSDeviceRGBColorSpace"] redComponent];
		double g = [[clrFrom
					 colorUsingColorSpaceName:@"NSDeviceRGBColorSpace"] greenComponent];
		double b = [[clrFrom
					 colorUsingColorSpaceName:@"NSDeviceRGBColorSpace"] blueComponent];
		
		[self setStartingColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0]];
		[self setEndingColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:0.0]];
		[self setAngle:270];
	}
	return self;
}

- (BOOL) isFlipped{
	return YES;
}

- (void)drawRect:(NSRect)rect;
{
	if (endingColor == nil || [startingColor isEqual:endingColor]) {
		// Fill view with a standard background color
		[startingColor set];
		NSRectFill(rect);
	}
	else {
		// Fill view with a top-down gradient
		// from startingColor to endingColor
		NSGradient* aGradient = [[[NSGradient alloc]
								  initWithStartingColor:startingColor
								  endingColor:endingColor] autorelease];
		
		[aGradient drawInRect:[self bounds] angle:angle];
	}
}

- (void)setStartingColor:(NSColor *)newColor;
{
	[startingColor autorelease];
	startingColor = [newColor retain];
	
	[self setNeedsDisplay:YES];
}

- (void)setEndingColor:(NSColor *)newColor;
{
	[endingColor autorelease];
	endingColor = [newColor retain];
	
	[self setNeedsDisplay:YES];
}

- (void)dealloc;
{
	[self setStartingColor:nil];
	[self setEndingColor:nil];
	[super dealloc];
}

@end
