//
//  ToolbarController.h
//
//  Created by Vagrod on 4/30/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ContentView.h"
#import "BottomView.h"

@interface ToolbarController : NSObject {
    IBOutlet NSToolbarItem *newFolder;
    IBOutlet NSWindow *window;
    IBOutlet NSToolbarItem *goBack;
    IBOutlet NSToolbarItem *newWatcher;
    IBOutlet NSWindow *frmWatcher;
    IBOutlet NSScrollView *scrollSheetExceptions;
    IBOutlet NSScrollView *scrollSheetTypes;
    IBOutlet NSPathControl *cmdSheetFolder;
    IBOutlet NSButton *cmdSheetNewException;
    IBOutlet NSButton *cmdSheetNewType;
    IBOutlet NSToolbarItem *cmdRestartWatchers;
    IBOutlet NSWindow *aboutWindow;
    IBOutlet NSScrollView *scrollFolders;
    IBOutlet NSScrollView *scrollWatchers;
    IBOutlet NSSearchField *txtSearch;
    IBOutlet BottomView *viewBottom;
    IBOutlet BottomView *viewTop;
    IBOutlet NSTextField *lblAboutTitle;
    IBOutlet NSTextField *lblAboutVersion;
    IBOutlet NSButton *cmdAboutWebpage;
    IBOutlet NSPathControl *pathSheet;
    IBOutlet NSPopUpButton *cboPresetsExceptions;
    IBOutlet NSPopUpButton *cboPresetsTypes;
	
	ContentView * docFolders;
	ContentView * docWatchers;
	ContentView * docExceptions;
    ContentView * docTypes;
}

- (id) _getWindow;
- (id) _getAbout;

- (void) flushShades;

- (NSImage *) resizeImage: (NSImage *) sourceImage toSize: (NSSize) size;
- (NSImage *) overlayImage: (NSImage *) sourceImage with: (NSImage *) topImage withOffset: (NSPoint)offset;
- (NSURL *) getSheetURL;
- (NSMutableArray *) getSheetTypes;
- (NSMutableArray *) getSheetExceptions;

- (void) prepareWatcherSheet: (long) ID;
- (void) startSheetForWatcher:(id)delegate withSelector: (SEL) sel;
- (void) cleanUpTypes;

- (int) getFilesMoved;
- (void) setFilesMoved: (int) count;
- (NSString *) getLastFile;
- (void) setLastFile:(NSString *)newFile;
- (BOOL) getNotifyAction;
- (void) setNotifyAction:(BOOL) state;
- (int) getBusyCount;
- (void) setUseSmartMusic: (BOOL) use;
- (BOOL) getUseSmartMusic;
- (BOOL) getUseSmartArchive;
- (void) setUseSmartArchive: (BOOL) use;
- (void) setBusyCount: (int) count;

- (NSString *) convertToURLString: (NSString *) source;
- (NSString *) convertToPathString: (NSString *) source;
//- (void) showPopUp:(NSString *)message withIcon: (NSImage *)icon;

- (IBAction)newFolder_Action:(id)sender;
- (IBAction)newWatcher_Action:(id)sender;
- (IBAction)cmdSheetCancel:(id)sender;
- (IBAction)cmdSheetOK:(id)sender;
- (IBAction)cmdSheetFolder_Click:(id)sender;
- (IBAction)cmdSheetAddExceptions_Click:(id)sender;
- (IBAction)cmdSheetAddTypes_Click:(id)sender;
- (IBAction)txtSearch_Confirm:(id)sender;
- (IBAction)cmdWebpage_Click:(id)sender;
- (id) CreateFolderControl: (NSString *)folder withWatchers: (NSMutableArray *) watchers atRect: (NSRect)rect isNew: (long) isnew;
- (void) addNewFolder:(NSString *)folder withWatchers: (NSMutableArray *) watchers isNew: (long) isnew;
- (void)awakeFromNib;

- (void) addNewExceptionWithMask: (NSString *) mask;
- (void) addNewTypeWithMask: (NSString *) mask;
- (id) CreateTypeControlWithMask: (NSString *) mask atRect: (NSRect)rect;

- (void)openPanelDidEndForFolder:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
- (void)openPanelDidEndForWatcher:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;
- (void)didEndSheetForWatcher:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

- (void) searchWatchers: (NSString *)mask;
- (void) addNewWatcherWithTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id: (long) ID Paused: (BOOL) paused ParentId: (long) parentid;
- (void) fillFolders;
- (void) backToFolders;

@end
