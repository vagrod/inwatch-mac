//
//  TypeControl.h
//  InWatch
//
//  Created by Vagrod on 5/3/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TypeControl : NSView {

}

@property (retain) NSButton * cmdType;
@property (retain) NSTextField * txtType;
@property (retain) NSString * Mask;
@property (retain) NSButton * cmdRemove;

- (id) initWithFrame:(NSRect)frameRect andTypeMask: (NSString *) mask;
- (void) enterEditMode;
- (void) endEdit;
- (void) dispose;

- (void) txtType_Confirm: (id) sender;
- (void) cmdType_Click: (id) sender;
- (void) cmdRemove_Click: (id) sender;

@end
