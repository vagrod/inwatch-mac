//
//  FolderControl.h
//  InWatch
//
//  Created by Vagrod on 5/1/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FolderItem.h"
#import "ContentView.h"

@interface FolderControl : NSView {
	NSPopUpButton * cmdAction;
	NSString * Folder;
	NSMutableArray * Watchers;
	NSMutableArray * CtlWatchers;
	
	NSImageView * imgIcon;
	NSPathControl * cmdFolder;
	NSButton * cmdRemove;
	NSButton * cmdWatchers;
	NSImage * cmdCopyImage;
	NSTextField * lblWatchers;
	
	long Id;
}

@property long Id;
@property (retain) NSString * Folder;
@property (retain) NSMutableArray * Watchers;
@property (retain) NSMutableArray * CtlWatchers;

@property (retain) NSButton * cmdCopy;
@property (retain) NSPathControl * cmdFolder;
@property (retain) NSButton * cmdRemove;
@property (retain) NSButton * cmdWatchers;
@property (retain) NSImage * cmdCopyImage;
@property (retain) NSTextField * lblWatchers;

- (NSImage *) resizeImage: (NSImage *) sourceImage toSize: (NSSize) size;

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
- (id) initWithFrame:(NSRect)frameRect andFolder:(NSString *)folder andWatchers: (NSMutableArray *) watchers andId: (long) ID;
- (id) initWithFolder: (FolderItem *) folder andFrame: (NSRect) frame;
- (void) setToolbarButtonsBack: (NSToolbarItem *)goback newWatcher: (NSToolbarItem *)newwatcher newFolder: (NSToolbarItem *) newfolder;

- (void) updateFolder;

- (void) goBack_Clicked: (id) sender;
- (void) ClearView: (id) sender;;

void DisposeFolders();
void DisposeWatchers();
void SetCtlWatchers(NSMutableArray * w);

- (NSMutableArray *) getWatchers: (id) sender;
- (void) addNewFolder:(NSString *)folder withWatchers: (NSMutableArray *) watchers isNew: (long) isnew;
- (id) CreateFolderControl: (NSString *)folder withWatchers: (NSMutableArray *) watchers atRect: (NSRect)rect isNew: (long) isnew;

- (void) setParentView: (ContentView *) view;
- (void) setParentWatchersView: (NSView *) view;
- (void) setFoldersView: (NSScrollView *) view;
- (void) setWatchersView: (NSScrollView *) view;
- (void) setWindow: (id) w;
- (void) FadeViews:(NSView *)v1 to:(NSView *)v2;
- (void) addNewWatcherWithTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id: (long) ID Paused: (BOOL) paused;
- (id) CreateWatcherControlWithTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id:(long)ID Paused: (BOOL) paused atRect: (NSRect)rect;

//- (BOOL) moveFilesOption: (id) sender;
- (void) cmdFolder_Click: (id) sender;
- (void) cmdRemove_Click: (id) sender;
- (void) cmdWatchers_Click: (id) sender;

@end
