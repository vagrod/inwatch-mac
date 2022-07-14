//
//  BottomView.h
//
//  Created by Vagrod on 5/8/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BottomView : NSView {
		NSColor *startingColor;
		NSColor *endingColor;
		int angle;
	}
	
	// Define the variables as properties
	@property(nonatomic, retain) NSColor *startingColor;
	@property(nonatomic, retain) NSColor *endingColor;
	@property(assign) int angle;
	
@end
