//
//  TypeControl.m
//  InWatch
//
//  Created by Vagrod on 5/3/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TypeControl.h"
#import "ContentView.h"

@implementation TypeControl

NSButton * cmdType;
NSTextField * txtType;
NSButton * cmdRemove;
NSString * Mask;

@synthesize cmdType;
@synthesize txtType;
@synthesize Mask;
@synthesize cmdRemove;

extern id window;

- (id) initWithFrame:(NSRect)frameRect andTypeMask: (NSString *) mask{
	self = [super initWithFrame:frameRect];
	
	if (self) {
		[self setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin | NSViewMinYMargin];
		
		[self setMask:mask];
		cmdType = [[NSButton alloc] initWithFrame:NSMakeRect(83 + 10, 0, frameRect.size.width - 77 - 25, 24)];
		[cmdType setBezelStyle:NSShadowlessSquareBezelStyle];
		[cmdType setBordered:NO];
		[cmdType setWantsLayer:YES];
		[cmdType setAction:@selector(cmdType_Click:)];
		[cmdType setTarget:self];
		[cmdType setAlignment: NSLeftTextAlignment];
		[cmdType setTitle:mask];
		
		[self addSubview:cmdType];
		
//		txtType = [[NSTextField alloc] initWithFrame:NSMakeRect(83, 0,frameRect.size.width - 77 - 25, 21)];
		txtType = [[NSTextField alloc] initWithFrame:NSMakeRect(83, 1,272, 23)];
//		[txtType setAutoresizingMask:NSViewMaxYMargin | NSViewMinXMargin | NSViewWidthSizable];
		[txtType setHidden:YES];
		[txtType setWantsLayer:YES];
		//[txtType setBordered:YES];
		//[txtType setDrawsBackground:YES];
		[txtType setBezelStyle:NSTextFieldRoundedBezel];
		[txtType setStringValue:mask];
		[[txtType cell] setSendsActionOnEndEditing:NO];
		[txtType setAction:@selector(txtType_Confirm:)];
		[txtType setTarget:self];
		
		[self addSubview:txtType];
		
		cmdRemove = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 80, 24)];
		[cmdRemove setBezelStyle:NSRecessedBezelStyle];
		[cmdRemove setBordered:YES];
		[cmdRemove setAction:@selector(cmdRemove_Click:)];
		[cmdRemove setTarget:self];
		[cmdRemove setAlignment: NSLeftTextAlignment];
		[cmdRemove setImagePosition:NSImageLeft];
		[cmdRemove setTitle:@"Remove"];
//		[cmdRemove setTitle:@"Удалить"];
		[cmdRemove setImage:[NSImage imageNamed:@"NSRemoveTemplate"]];
		
		[self addSubview:cmdRemove];
	}
	
	return self;
}

- (void) endEdit{
	[cmdType setTitle:[txtType stringValue]];
	[self setMask:[txtType stringValue]];
	
	[[txtType animator] setHidden:YES];
	[[cmdType animator] setHidden:NO];
}

- (void) enterEditMode{
	for (TypeControl * t in [[self superview] subviews]){
		[t endEdit];
	}
	
	[[txtType animator] setHidden:NO];
	[[cmdType animator] setHidden:YES];
	
	[txtType selectText:self];
	[window makeFirstResponder:txtType];
}

- (void) cmdType_Click: (id) sender{
	[self enterEditMode];
}

- (void) cmdRemove_Click: (id) sender{
	[(ContentView *)[self superview] ControlsRemove:self];
}

- (void) txtType_Confirm: (id) sender{
	[self endEdit];
}

- (void) dispose{
	[cmdType removeFromSuperviewWithoutNeedingDisplay];
	[cmdType release];
	
	[txtType removeFromSuperviewWithoutNeedingDisplay];
	[txtType release];
	
	[cmdRemove removeFromSuperviewWithoutNeedingDisplay];
	[cmdRemove release];
	
	[self removeFromSuperviewWithoutNeedingDisplay];
	[self release];
	
}

@end
