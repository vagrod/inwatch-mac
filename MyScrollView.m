//
//  MyScrollView.m
//
//  Created by Vagrod on 5/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyScrollView.h"

@implementation MyScrollView

- (void) drawRect:(NSRect)dirtyRect{
	[[self documentView] display];
}

@end
