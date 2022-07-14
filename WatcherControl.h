//
//  WatcherControl.h
//  InWatch
//
//  Created by Vagrod on 5/1/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WatcherItem.h"

@interface WatcherControl : NSView {
	NSScrollView * viewFolders;
	NSScrollView * viewWatchers;
	
	NSPopUpButton * cmdAction;
	NSMenuItem * mnuCopy;
	NSMenuItem * mnuMove;
	NSPathControl * cmdFolder;
	NSButton * cmdTypes;
	NSButton * cmdExceptions;
	NSButton * cmdRemove;
	NSTextField * lblTypes;
	NSTextField * lblExceptions;
	
	long Id;
	long ParentId;
	int moveInd;
}

@property int moveInd;
@property long Id;
@property long ParentId;
@property BOOL Paused;
@property (retain) NSPopUpButton * cmdAction;
@property (retain) NSMenuItem * mnuCopy;
@property (retain) NSMenuItem * mnuMove;
@property (retain) NSPathControl * cmdFolder;
@property (retain) NSButton * cmdTypes;
@property (retain) NSButton * cmdExceptions;
@property (retain) NSButton * cmdRemove;
@property (retain) NSTextField * lblTypes;
@property (retain) NSTextField * lblExceptions;
@property (retain) NSButton * cmdPause;
@property NSRect Bounds;

- (void) updateWatcher;
- (id) initWithFrame:(NSRect)frameRect andTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id: (long) ID ParentId: (long) parentid Paused: (BOOL) paused;
//- (id) initWithWatcher:(WatcherItem *)watcher andFrame: (NSRect) frame;
- (void) setToolbarButtonsBack: (NSToolbarItem *)goback newWatcher: (NSToolbarItem *)newwatcher newFolder: (NSToolbarItem *) newfolder;

- (void)didEndSheetForWatcher:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

NSString * ArrayToNSString(NSMutableArray * a);
NSMutableArray * NSStringToArray(NSString * s);

- (NSImage *) resizeImage: (NSImage *) sourceImage toSize: (NSSize) size;
- (void) FadeViews:(NSView *)v1 to:(NSView *)v2;
- (BOOL) getMoveFilesOptionSelected: (id) sender;
- (void) setFoldersView: (NSScrollView *) view;
- (void) setWatchersView: (NSScrollView *) view;
- (void) setWindow: (id) win;

- (void) mnuCopy_Click: (id) sender;
- (void) mnuMove_Click: (id) sender;
- (void) cmdRemove_Click: (id) sender;
- (void) cmdTypes_Click: (id) sender;
- (void) cmdExceptions_Click: (id) sender;
- (void) cmdFolder_Click: (id) sender;

- (void) dispose;

@end
