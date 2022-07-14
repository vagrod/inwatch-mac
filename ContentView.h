//
//  ContentView.h
//  InWatch
//
//  Created by Vagrod on 5/7/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ContentView : NSView {
	
}

@property int ItemHeight;
@property int TopMargin;
@property int RightMargin;
@property int BottomMargin;
@property int LeftMargin;
@property int Spacing;
@property BOOL Textured;
@property (retain) NSImage * Texture;
@property (retain) NSColor * BackColor;

- (id)initWithParent: (NSScrollView *) parent;

- (void) ControlsAdd: (NSView *) control;
- (void) ControlsAdd: (NSView *) control withIndependentHeight: (BOOL) selfh;
- (void) calculateWidths;
- (void) ControlsClear;
- (void) ControlsRemove: (NSView *) control;

@end
