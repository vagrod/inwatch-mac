//
//  ToolbarController.m
//
//  Created by Vagrod on 4/30/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "ToolbarController.h"
#import "FolderControl.h"
#import "WatcherControl.h"
#import "WatcherReader.h"
#import "FolderItem.h"
#import "WatcherItem.h"
#import "TypeControl.h"
#import "GlobalWatcher.h"
#import "BottomView.h"

@implementation ToolbarController

extern NSMutableArray * Folders;
extern id window;

ToolbarController * MainController;
FolderControl * CurrentFolder;
NSMutableArray * CtlFolders;
NSMutableArray * CtlTypes;

int FoldersCount = 0;
BOOL SheetOK = NO;
int FilesMoved = 0;
NSString * LastFile;
int BusyWatchers = 0;
BOOL notifyAction = NO;
BOOL useSmartMusic = NO;
BOOL useSmartArchive = NO;

BOOL fSearchMode = NO;

- (id) _getWindow{
	return window;
}

- (id) _getAbout{
	return aboutWindow;
}

- (int) getFilesMoved{
	return FilesMoved;
}

- (BOOL) getUseSmartArchive{
	return useSmartArchive;
}

- (void) setUseSmartArchive: (BOOL) use{
	useSmartArchive = use;
}

- (BOOL) getUseSmartMusic{
	return useSmartMusic;
}

- (void) setUseSmartMusic: (BOOL) use{
	useSmartMusic = use;
}

- (void) setFilesMoved: (int) count{
	FilesMoved = count;
}

- (NSString *) getLastFile{
	return LastFile;
}

- (void) setLastFile:(NSString *)newFile{
	LastFile = newFile;
}

- (int) getBusyCount{
	return BusyWatchers;
}

- (void) setBusyCount: (int) count{
	BusyWatchers = count;
}

- (void) setNotifyAction:(BOOL) state{
	notifyAction = state;
}

- (BOOL) getNotifyAction{
	return notifyAction;
}

- (id) CreateFolderControl: (NSString *)folder withWatchers: (NSMutableArray *) watchers atRect: (NSRect)rect isNew: (long) isnew{
	return [[FolderControl alloc] initWithFrame:rect andFolder:folder andWatchers:watchers andId:isnew];
}

- (void) addNewFolder:(NSString *)folder withWatchers: (NSMutableArray *) watchers isNew: (long) isnew{
	NSRect frame = NSMakeRect(4, 0, 555, 120); 
	FolderControl * newFolderCtl = [self CreateFolderControl:folder withWatchers:watchers atRect:frame isNew:isnew]; 
	
	[newFolderCtl setWatchersView:scrollWatchers];
	[newFolderCtl setFoldersView:scrollFolders];
	[newFolderCtl setParentView:docFolders];
	[newFolderCtl setParentWatchersView:docWatchers];
	[newFolderCtl setWindow:window];
	[newFolderCtl setToolbarButtonsBack:goBack newWatcher:newWatcher newFolder:newFolder];
	
	[CtlFolders addObject:newFolderCtl];
	[docFolders ControlsAdd:newFolderCtl];
 	
	[newFolderCtl release];
} 

- (void) flushShades{	
	return;
	
	BOOL hF = [scrollFolders isHidden];
	BOOL hW = [scrollWatchers isHidden];
	
	[scrollFolders setHidden:YES];
	[scrollFolders setHidden:hF];
	
	[scrollWatchers setHidden:YES];
	[scrollWatchers setHidden:hW];
	
	[viewTop setHidden:YES];
	[viewTop setHidden:NO];
	
	[viewBottom setHidden:YES];
	[viewBottom setHidden:NO];
	
    if (! hF) [scrollFolders display];
	if (! hW) [scrollWatchers display];
	
	[viewTop display];
	[viewBottom display];
}

- (void)openPanelDidEndForFolder:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	if (! returnCode) return;
	
	NSMutableArray * w = [NSMutableArray new];
	
	FolderItem * f = [[FolderItem alloc] init];
	
	[Folders addObject:f];
	
	[self addNewFolder:[panel filename] withWatchers:w isNew:[f Id]];
	[f setFolder:[panel filename]];
	
	[f release];
	[w release];
	
	[window setDocumentEdited:YES];
}

- (NSURL *) getSheetURL{
	return [cmdSheetFolder URL];
}

- (NSMutableArray *) getSheetTypes{
	NSMutableArray * ret = [NSMutableArray new];
	
	for (TypeControl * t in CtlTypes){
		if ([[t superview] isEqual:docTypes]){
			[t endEdit];
			[ret addObject:[t Mask]];
		}
	}
	
	return ret;//[NSMutableArray arrayWithArray:ret];
}

- (NSMutableArray *) getSheetExceptions{
	NSMutableArray * ret = [NSMutableArray new];
	
	for (TypeControl * t in CtlTypes){
		if ([[t superview] isEqual:docExceptions]){
			[t endEdit];
			[ret addObject:[t Mask]];
		}
	}
	
	return ret;//[NSMutableArray arrayWithArray:ret];
}

- (void) prepareWatcherSheet: (long) ID{
	[docTypes setFrameSize:NSMakeSize(367, 111)];
	[docExceptions setFrameSize:NSMakeSize(367, 111)];
	
	if (ID == 0){
		//New sheet
		for (FolderItem * f in Folders){
			if ([f Id] == [CurrentFolder Id]){
				[pathSheet setURL:[NSURL URLWithString:[self convertToURLString:[f Folder]]]];
//				[pathSheet setURL:[NSURL fileURLWithPath:[f Folder]]];
				break;
			}
		}
		
		[cmdSheetFolder setURL:
		 [NSURL URLWithString:
		  [self convertToURLString:
		   @"/Applications"
		   ]
		  ]
		 ];
	}else{
		for (FolderItem * f in Folders){
//			if ([f Id] == [CurrentFolder Id]){
				for (WatcherItem * w in [f Watchers]){
					if ([w Id] == ID){
						[cmdSheetFolder setURL:[NSURL URLWithString:[self convertToURLString:[w DestinationFolder]]]];
						
						for (NSString * t in [w Types]){
							[self addNewTypeWithMask:t];
						}
				
						for (NSString * e in [w Exceptions]){
							[self addNewExceptionWithMask:e];
						}
						
						[pathSheet setURL:[NSURL URLWithString:[self convertToURLString:[f Folder]]]];
				
						break;
					}
				}
			//}
		}
	}
	
	[docTypes display];
	[docExceptions display];
}

- (void)openPanelDidEndForWatcher:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	if (! returnCode) return;
	
	[cmdSheetFolder setURL:[NSURL URLWithString:[self convertToURLString:[panel filename]]]];
}

- (void)didEndSheetForWatcher:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	if (SheetOK) {
		WatcherItem * newW = [[WatcherItem alloc] init];
		
		for (FolderItem * f in Folders){
			if ([f Id] == [CurrentFolder Id]){
				NSString * dest = [self convertToPathString:[[cmdSheetFolder URL] absoluteString]];
				
				[newW setTypes:[self getSheetTypes]];
				[newW setDestinationFolder:dest];
				[newW setExceptions:[self getSheetExceptions]];
				[newW setMoveFiles:YES];
				[newW setSourceFolder:[f Folder]];
				[newW setPaused:NO];
				
				[dest release];
		
				if (! [f Watchers]){[f setWatchers:[NSMutableArray new]];}
			
				[[f Watchers] addObject:newW];
				if ([[CurrentFolder Watchers] count] == 0) [[CurrentFolder Watchers] addObject:newW];
				
				[CurrentFolder addNewWatcherWithTypes:[newW Types] Exceptions:[newW Exceptions] Destination:[newW DestinationFolder] MoveFiles:[newW MoveFiles] Id:[newW Id] Paused:[newW Paused]];
				
				break;
			}
		}
		[newW release];
		
		[window setDocumentEdited:YES];
	}
	
	[self cleanUpTypes];
}

- (void) cleanUpTypes{
	for (TypeControl *t in CtlTypes){
		[t dispose];
		[t removeFromSuperviewWithoutNeedingDisplay];
		[t release];
	}
	
	[CtlTypes removeAllObjects];
	CtlTypes = nil;
}

- (IBAction)newFolder_Action:(id)sender {
    printf("New folder clicked\n");
	
	NSString * dir = @"/";
	NSOpenPanel * dlg = [NSOpenPanel openPanel];
	
	[dlg setCanChooseDirectories:YES];
	[dlg setCanChooseFiles:NO];
	[dlg beginSheetForDirectory:dir file:@"" modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEndForFolder:returnCode:contextInfo:) contextInfo:nil];
	
	[dlg release];
}

- (NSImage *) resizeImage: (NSImage *) sourceImage toSize: (NSSize) size{
	NSImage *resizedImage = [[NSImage alloc] initWithSize: NSMakeSize(size.width, size.height)];
	
	NSSize originalSize = [sourceImage size];
	
	[resizedImage lockFocus];
	[sourceImage drawInRect: NSMakeRect(0, 0, size.width, size.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
	[resizedImage unlockFocus];
	[sourceImage release];
	return resizedImage;
}

- (NSImage *) overlayImage: (NSImage *) sourceImage with: (NSImage *) topImage withOffset: (NSPoint)offset{
	NSImage *resizedImage = [[NSImage alloc] initWithSize: NSMakeSize([sourceImage size].width, [sourceImage size].height)];
	
	[resizedImage lockFocus];
	[sourceImage drawInRect: NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height) fromRect: NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height) operation: NSCompositeSourceOver fraction: 1.0];
	[topImage drawInRect: NSMakeRect(offset.x, offset.y, [sourceImage size].width, [sourceImage size].height) fromRect: NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height) operation: NSCompositeSourceOver fraction: 1.0];
	[resizedImage unlockFocus];
	[sourceImage release];
	
	return resizedImage;
}

- (void)awakeFromNib{	
	MainController = self;
	
	[lblAboutTitle setFont:[NSFont boldSystemFontOfSize:13]];
	[lblAboutVersion setFont:[NSFont systemFontOfSize:9]];
	
	viewTop = [[BottomView alloc] initWithFrame:NSMakeRect(1, 467, 559, 23)];
	[viewTop setAngle:90];
	[[window contentView] addSubview:viewTop];
	
	viewBottom = [[BottomView alloc] initWithFrame:NSMakeRect(1, 21, 559, 23)];
	[viewBottom setAngle:270];
	[[window contentView] addSubview:viewBottom];
	
	docFolders = [[ContentView alloc] initWithParent:scrollFolders];
	[docFolders setTextured:YES];
	[docFolders setTexture:
		[[NSImage alloc] initWithContentsOfFile:
			 [[NSBundle mainBundle] pathForResource:@"leather" ofType:@"png"]
		 ]
	];
	[docFolders setItemHeight:100];
	[docFolders setTopMargin:10];
	[docFolders setBottomMargin:10];
	[docFolders setRightMargin:10];
	[docFolders setLeftMargin:10];
	[docFolders setSpacing:5];
	
	docWatchers = [[ContentView alloc] initWithParent:scrollWatchers];
	[docWatchers setTextured:YES];
	[docWatchers setTexture:
	 [[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"leather" ofType:@"png"]
	  ]
	 ];
	[docWatchers setItemHeight:120];
	[docWatchers setTopMargin:10];
	[docWatchers setBottomMargin:10];
	[docWatchers setRightMargin:10];
	[docWatchers setLeftMargin:10];
	[docWatchers setSpacing:5];
	
	docTypes = [[ContentView alloc] initWithParent:scrollSheetTypes];
	[docTypes setItemHeight:24];
	[docTypes setTopMargin:5];
	[docTypes setBottomMargin:5];
	[docTypes setRightMargin:5];
	[docTypes setLeftMargin:5];
	[docTypes setSpacing:1];
	
	docExceptions = [[ContentView alloc] initWithParent:scrollSheetExceptions];
	[docExceptions setItemHeight:24];
	[docExceptions setTopMargin:5];
	[docExceptions setBottomMargin:5];
	[docExceptions setRightMargin:5];
	[docExceptions setLeftMargin:5];
	[docExceptions setSpacing:1];
	
	
	//**** Setting up presets
	[cboPresetsTypes removeAllItems];
	
	[cboPresetsTypes addItemWithTitle:@"dummy"];
	
	[cboPresetsTypes addItemWithTitle:@"Applications"];
//	[cboPresetsTypes addItemWithTitle:@"Программы"];
	[[cboPresetsTypes itemAtIndex:1] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Application" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:1] setTarget:self];
	[[cboPresetsTypes itemAtIndex:1] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Archives"];
//	[cboPresetsTypes addItemWithTitle:@"Архивы"];
	[[cboPresetsTypes itemAtIndex:2] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Archive" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:2] setTarget:self];
	[[cboPresetsTypes itemAtIndex:2] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Books"];
//	[cboPresetsTypes addItemWithTitle:@"Книги"];
	[[cboPresetsTypes itemAtIndex:3] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Book" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:3] setTarget:self];
	[[cboPresetsTypes itemAtIndex:3] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Cursors, Icons"];
//	[cboPresetsTypes addItemWithTitle:@"Курсоры, иконки"];
	[[cboPresetsTypes itemAtIndex:4] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Cursor" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:4] setTarget:self];
	[[cboPresetsTypes itemAtIndex:4] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Documents"];
//	[cboPresetsTypes addItemWithTitle:@"Документы"];
	[[cboPresetsTypes itemAtIndex:5] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Documents" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:5] setTarget:self];
	[[cboPresetsTypes itemAtIndex:5] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Disk Images"];
//	[cboPresetsTypes addItemWithTitle:@"Образы"];
	[[cboPresetsTypes itemAtIndex:6] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_ISO" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:6] setTarget:self];
	[[cboPresetsTypes itemAtIndex:6] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Music"];
//	[cboPresetsTypes addItemWithTitle:@"Музыка"];
	[[cboPresetsTypes itemAtIndex:7] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Music" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:7] setTarget:self];
	[[cboPresetsTypes itemAtIndex:7] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Torrents"];
//	[cboPresetsTypes addItemWithTitle:@"Торренты"];
	[[cboPresetsTypes itemAtIndex:8] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Torrent" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:8] setTarget:self];
	[[cboPresetsTypes itemAtIndex:8] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Videos"];
//	[cboPresetsTypes addItemWithTitle:@"Видео"];
	[[cboPresetsTypes itemAtIndex:9] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Video" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:9] setTarget:self];
	[[cboPresetsTypes itemAtIndex:9] setAction:@selector(presetType_Click:)];
	
	[cboPresetsTypes addItemWithTitle:@"Pictures"];
//	[cboPresetsTypes addItemWithTitle:@"Рисунки"];
	[[cboPresetsTypes itemAtIndex:10] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle mainBundle] pathForResource:@"Preset_Photo" ofType:@"png"]
	  ] autorelease]
	 ];
	[[cboPresetsTypes itemAtIndex:10] setTarget:self];
	[[cboPresetsTypes itemAtIndex:10] setAction:@selector(presetType_Click:)];
	
	
	
	[cboPresetsExceptions removeAllItems];
	
	[cboPresetsExceptions addItemWithTitle:@"dummy"];
	
	[cboPresetsExceptions addItemWithTitle:@"Applications"];
//	[cboPresetsExceptions addItemWithTitle:@"Программы"];
	[[cboPresetsExceptions itemAtIndex:1] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Application" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:1] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:1] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Archives"];
//	[cboPresetsExceptions addItemWithTitle:@"Архивы"];
	[[cboPresetsExceptions itemAtIndex:2] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Archive" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:2] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:2] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Books"];
//	[cboPresetsExceptions addItemWithTitle:@"Книги"];
	[[cboPresetsExceptions itemAtIndex:3] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Book" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:3] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:3] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Cursors, Icons"];
//	[cboPresetsExceptions addItemWithTitle:@"Курсоры, иконки"];
	[[cboPresetsExceptions itemAtIndex:4] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Cursor" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:4] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:4] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Documents"];
//	[cboPresetsExceptions addItemWithTitle:@"Документы"];
	[[cboPresetsExceptions itemAtIndex:5] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Documents" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:5] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:5] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Disk Images"];
//	[cboPresetsExceptions addItemWithTitle:@"Образы"];
	[[cboPresetsExceptions itemAtIndex:6] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_ISO" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:6] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:6] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Music"];
//	[cboPresetsExceptions addItemWithTitle:@"Музыка"];
	[[cboPresetsExceptions itemAtIndex:7] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Music" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:7] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:7] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Torrents"];
//	[cboPresetsExceptions addItemWithTitle:@"Торренты"];
	[[cboPresetsExceptions itemAtIndex:8] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Torrent" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:8] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:8] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Videos"];
//	[cboPresetsExceptions addItemWithTitle:@"Видео"];
	[[cboPresetsExceptions itemAtIndex:9] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Video" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:9] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:9] setAction:@selector(presetException_Click:)];
	
	[cboPresetsExceptions addItemWithTitle:@"Pictures"];
//	[cboPresetsExceptions addItemWithTitle:@"Рисунки"];
	[[cboPresetsExceptions itemAtIndex:10] setImage:
	 [[[NSImage alloc] initWithContentsOfFile:
	   [[NSBundle mainBundle] pathForResource:@"Preset_Photo" ofType:@"png"]
	   ] autorelease]
	 ];
	[[cboPresetsExceptions itemAtIndex:10] setTarget:self];
	[[cboPresetsExceptions itemAtIndex:10] setAction:@selector(presetException_Click:)];
	
	
	//**** Reading folders if needed and filling settings
	if (! Folders) {
		WatcherReader * reader = [[WatcherReader alloc] init];
		Folders = [reader initWatchers];
		[reader release];
	}
	
	[self fillFolders];
}

- (BOOL) hasType:(NSString *) t{
	for (TypeControl * c in [docTypes subviews]){
		if ([[c Mask] isEqualToString:t]) return YES;
	}
	
	return NO;
}

- (void) presetType_Click: (id)sender {
	int ind = [cboPresetsTypes indexOfItem:sender];
	switch (ind) {
		case 1:
			if (! [self hasType:@"*.app"]) [self addNewTypeWithMask:@"*.app"];
			if (! [self hasType:@"*.pkg"]) [self addNewTypeWithMask:@"*.pkg"];
			break;
			
		case 2:
			if (! [self hasType:@"*.rar"]) [self addNewTypeWithMask:@"*.rar"];
			if (! [self hasType:@"*.zip"]) [self addNewTypeWithMask:@"*.zip"];
			if (! [self hasType:@"*.tar"]) [self addNewTypeWithMask:@"*.tar"];
			if (! [self hasType:@"*.tgz"]) [self addNewTypeWithMask:@"*.tgz"];
			if (! [self hasType:@"*.gz"]) [self addNewTypeWithMask:@"*.gz"];
			if (! [self hasType:@"*.jar"]) [self addNewTypeWithMask:@"*.jar"];
			if (! [self hasType:@"*.sit"]) [self addNewTypeWithMask:@"*.sit"];
			if (! [self hasType:@"*.sitx"]) [self addNewTypeWithMask:@"*.sitx"];
			break;
			
		case 3:
			if (! [self hasType:@"*.fb2"]) [self addNewTypeWithMask:@"*.fb2"];
			break;
			
		case 4:
			if (! [self hasType:@"*.ico"]) [self addNewTypeWithMask:@"*.ico"];
			if (! [self hasType:@"*.icns"]) [self addNewTypeWithMask:@"*.icns"];
			if (! [self hasType:@"*.cur"]) [self addNewTypeWithMask:@"*.cur"];
			break;
			
		case 5:
			if (! [self hasType:@"*.doc"]) [self addNewTypeWithMask:@"*.doc"];
			if (! [self hasType:@"*.docx"]) [self addNewTypeWithMask:@"*.docx"];
			if (! [self hasType:@"*.xls"]) [self addNewTypeWithMask:@"*.xls"];
			if (! [self hasType:@"*.xlsx"]) [self addNewTypeWithMask:@"*.xlsx"];
			if (! [self hasType:@"*.accdb"]) [self addNewTypeWithMask:@"*.accdb"];
			if (! [self hasType:@"*.odt"]) [self addNewTypeWithMask:@"*.odt"];
			if (! [self hasType:@"*.odf"]) [self addNewTypeWithMask:@"*.odf"];
			if (! [self hasType:@"*.pdf"]) [self addNewTypeWithMask:@"*.pdf"];
			if (! [self hasType:@"*.sxd"]) [self addNewTypeWithMask:@"*.sxd"];
			if (! [self hasType:@"*.std"]) [self addNewTypeWithMask:@"*.std"];
			if (! [self hasType:@"*.docm"]) [self addNewTypeWithMask:@"*.docm"];
			if (! [self hasType:@"*.ppt"]) [self addNewTypeWithMask:@"*.ppt"];
			if (! [self hasType:@"*.pptx"]) [self addNewTypeWithMask:@"*.pptx"];
			if (! [self hasType:@"*.pps"]) [self addNewTypeWithMask:@"*.pps"];
			if (! [self hasType:@"*.ppsx"]) [self addNewTypeWithMask:@"*.ppsx"];
			break;
			
		case 6:
			if (! [self hasType:@"*.iso"]) [self addNewTypeWithMask:@"*.iso"];
			if (! [self hasType:@"*.nrg"]) [self addNewTypeWithMask:@"*.nrg"];
			if (! [self hasType:@"*.dmg"]) [self addNewTypeWithMask:@"*.dmg"];
			break;
			
		case 7:
			if (! [self hasType:@"*.mp3"]) [self addNewTypeWithMask:@"*.mp3"];
			if (! [self hasType:@"*.wav"]) [self addNewTypeWithMask:@"*.wav"];
			if (! [self hasType:@"*.ogg"]) [self addNewTypeWithMask:@"*.ogg"];
			if (! [self hasType:@"*.flac"]) [self addNewTypeWithMask:@"*.flac"];
			if (! [self hasType:@"*.aac"]) [self addNewTypeWithMask:@"*.aac"];
			if (! [self hasType:@"*.wma"]) [self addNewTypeWithMask:@"*.wma"];
			break;
			
		case 8:
			if (! [self hasType:@"*.torrent"]) [self addNewTypeWithMask:@"*.torrent"];
			break;
			
		case 9:
			if (! [self hasType:@"*.mpe"]) [self addNewTypeWithMask:@"*.mpe"];
			if (! [self hasType:@"*.mpeg"]) [self addNewTypeWithMask:@"*.mpeg"];
			if (! [self hasType:@"*.mp4"]) [self addNewTypeWithMask:@"*.mp4"];
			if (! [self hasType:@"*.mkv"]) [self addNewTypeWithMask:@"*.mkv"];
			if (! [self hasType:@"*.avi"]) [self addNewTypeWithMask:@"*.avi"];
			if (! [self hasType:@"*.3gp"]) [self addNewTypeWithMask:@"*.3gp"];
			if (! [self hasType:@"*.vob"]) [self addNewTypeWithMask:@"*.vob"];
			if (! [self hasType:@"*.wmv"]) [self addNewTypeWithMask:@"*.wmv"];
			if (! [self hasType:@"*.qt"]) [self addNewTypeWithMask:@"*.qt"];
			if (! [self hasType:@"*.flv"]) [self addNewTypeWithMask:@"*.flv"];
			if (! [self hasType:@"*.asx"]) [self addNewTypeWithMask:@"*.asx"];
			if (! [self hasType:@"*.mov"]) [self addNewTypeWithMask:@"*.mov"];
			break;
			
		case 10:
			if (! [self hasType:@"*.png"]) [self addNewTypeWithMask:@"*.png"];
			if (! [self hasType:@"*.jpe"]) [self addNewTypeWithMask:@"*.jpe"];
			if (! [self hasType:@"*.jpg"]) [self addNewTypeWithMask:@"*.jpg"];
			if (! [self hasType:@"*.jpeg"]) [self addNewTypeWithMask:@"*.jpeg"];
			if (! [self hasType:@"*.bmp"]) [self addNewTypeWithMask:@"*.bmp"];
			if (! [self hasType:@"*.tif"]) [self addNewTypeWithMask:@"*.tif"];
			if (! [self hasType:@"*.tiff"]) [self addNewTypeWithMask:@"*.tiff"];
			if (! [self hasType:@"*.gif"]) [self addNewTypeWithMask:@"*.gif"];
			if (! [self hasType:@"*.jfif"]) [self addNewTypeWithMask:@"*.jfif"];
			if (! [self hasType:@"*.wmf"]) [self addNewTypeWithMask:@"*.wmf"];
			if (! [self hasType:@"*.psd"]) [self addNewTypeWithMask:@"*.psd"];
			break;
	}
}

- (BOOL) hasException:(NSString *) t{
	for (TypeControl * c in [docExceptions subviews]){
		if ([[c Mask] isEqualToString:t]) return YES;
	}
	
	return NO;
}

- (void) presetException_Click: (id)sender {
	int ind = [cboPresetsExceptions indexOfItem:sender];
	switch (ind) {
		case 1:
			if (! [self hasException:@"*.app"]) [self addNewExceptionWithMask:@"*.app"];
			if (! [self hasException:@"*.pkg"]) [self addNewExceptionWithMask:@"*.pkg"];
			break;
			
		case 2:
			if (! [self hasException:@"*.rar"]) [self addNewExceptionWithMask:@"*.rar"];
			if (! [self hasException:@"*.zip"]) [self addNewExceptionWithMask:@"*.zip"];
			if (! [self hasException:@"*.tar"]) [self addNewExceptionWithMask:@"*.tar"];
			if (! [self hasException:@"*.tgz"]) [self addNewExceptionWithMask:@"*.tgz"];
			if (! [self hasException:@"*.gz"]) [self addNewExceptionWithMask:@"*.gz"];
			if (! [self hasException:@"*.jar"]) [self addNewExceptionWithMask:@"*.jar"];
			if (! [self hasException:@"*.sit"]) [self addNewExceptionWithMask:@"*.sit"];
			if (! [self hasException:@"*.sitx"]) [self addNewExceptionWithMask:@"*.sitx"];
			break;
			
		case 3:
			if (! [self hasException:@"*.fb2"]) [self addNewExceptionWithMask:@"*.fb2"];
			break;
			
		case 4:
			if (! [self hasException:@"*.ico"]) [self addNewExceptionWithMask:@"*.ico"];
			if (! [self hasException:@"*.icns"]) [self addNewExceptionWithMask:@"*.icns"];
			if (! [self hasException:@"*.cur"]) [self addNewExceptionWithMask:@"*.cur"];
			break;
			
		case 5:
			if (! [self hasException:@"*.doc"]) [self addNewExceptionWithMask:@"*.doc"];
			if (! [self hasException:@"*.docx"]) [self addNewExceptionWithMask:@"*.docx"];
			if (! [self hasException:@"*.xls"]) [self addNewExceptionWithMask:@"*.xls"];
			if (! [self hasException:@"*.xlsx"]) [self addNewExceptionWithMask:@"*.xlsx"];
			if (! [self hasException:@"*.accdb"]) [self addNewExceptionWithMask:@"*.accdb"];
			if (! [self hasException:@"*.odt"]) [self addNewExceptionWithMask:@"*.odt"];
			if (! [self hasException:@"*.odf"]) [self addNewExceptionWithMask:@"*.odf"];
			if (! [self hasException:@"*.pdf"]) [self addNewExceptionWithMask:@"*.pdf"];
			if (! [self hasException:@"*.sxd"]) [self addNewExceptionWithMask:@"*.sxd"];
			if (! [self hasException:@"*.std"]) [self addNewExceptionWithMask:@"*.std"];
			if (! [self hasException:@"*.docm"]) [self addNewExceptionWithMask:@"*.docm"];
			if (! [self hasException:@"*.ppt"]) [self addNewExceptionWithMask:@"*.ppt"];
			if (! [self hasException:@"*.pptx"]) [self addNewExceptionWithMask:@"*.pptx"];
			if (! [self hasException:@"*.pps"]) [self addNewExceptionWithMask:@"*.pps"];
			if (! [self hasException:@"*.ppsx"]) [self addNewExceptionWithMask:@"*.ppsx"];
			break;
			
		case 6:
			if (! [self hasException:@"*.iso"]) [self addNewExceptionWithMask:@"*.iso"];
			if (! [self hasException:@"*.nrg"]) [self addNewExceptionWithMask:@"*.nrg"];
			if (! [self hasException:@"*.dmg"]) [self addNewExceptionWithMask:@"*.dmg"];
			break;
			
		case 7:
			if (! [self hasException:@"*.mp3"]) [self addNewExceptionWithMask:@"*.mp3"];
			if (! [self hasException:@"*.wav"]) [self addNewExceptionWithMask:@"*.wav"];
			if (! [self hasException:@"*.ogg"]) [self addNewExceptionWithMask:@"*.ogg"];
			if (! [self hasException:@"*.flac"]) [self addNewExceptionWithMask:@"*.flac"];
			if (! [self hasException:@"*.aac"]) [self addNewExceptionWithMask:@"*.aac"];
			if (! [self hasException:@"*.wma"]) [self addNewExceptionWithMask:@"*.wma"];
			break;
			
		case 8:
			if (! [self hasException:@"*.torrent"]) [self addNewExceptionWithMask:@"*.torrent"];
			break;
			
		case 9:
			if (! [self hasException:@"*.mpe"]) [self addNewExceptionWithMask:@"*.mpe"];
			if (! [self hasException:@"*.mpeg"]) [self addNewExceptionWithMask:@"*.mpeg"];
			if (! [self hasException:@"*.mp4"]) [self addNewExceptionWithMask:@"*.mp4"];
			if (! [self hasException:@"*.mkv"]) [self addNewExceptionWithMask:@"*.mkv"];
			if (! [self hasException:@"*.avi"]) [self addNewExceptionWithMask:@"*.avi"];
			if (! [self hasException:@"*.3gp"]) [self addNewExceptionWithMask:@"*.3gp"];
			if (! [self hasException:@"*.vob"]) [self addNewExceptionWithMask:@"*.vob"];
			if (! [self hasException:@"*.wmv"]) [self addNewExceptionWithMask:@"*.wmv"];
			if (! [self hasException:@"*.qt"]) [self addNewExceptionWithMask:@"*.qt"];
			if (! [self hasException:@"*.flv"]) [self addNewExceptionWithMask:@"*.flv"];
			if (! [self hasException:@"*.asx"]) [self addNewExceptionWithMask:@"*.asx"];
			if (! [self hasException:@"*.mov"]) [self addNewExceptionWithMask:@"*.mov"];
			break;
			
		case 10:
			if (! [self hasException:@"*.png"]) [self addNewExceptionWithMask:@"*.png"];
			if (! [self hasException:@"*.jpe"]) [self addNewExceptionWithMask:@"*.jpe"];
			if (! [self hasException:@"*.jpg"]) [self addNewExceptionWithMask:@"*.jpg"];
			if (! [self hasException:@"*.jpeg"]) [self addNewExceptionWithMask:@"*.jpeg"];
			if (! [self hasException:@"*.bmp"]) [self addNewExceptionWithMask:@"*.bmp"];
			if (! [self hasException:@"*.tif"]) [self addNewExceptionWithMask:@"*.tif"];
			if (! [self hasException:@"*.tiff"]) [self addNewExceptionWithMask:@"*.tiff"];
			if (! [self hasException:@"*.gif"]) [self addNewExceptionWithMask:@"*.gif"];
			if (! [self hasException:@"*.jfif"]) [self addNewExceptionWithMask:@"*.jfif"];
			if (! [self hasException:@"*.wmf"]) [self addNewExceptionWithMask:@"*.wmf"];
			if (! [self hasException:@"*.psd"]) [self addNewExceptionWithMask:@"*.psd"];
			break;
	}
}

- (void) fillFolders{
	for (FolderItem * f in Folders){
		[self addNewFolder:[f Folder] withWatchers:[f Watchers] isNew:[f Id]];
	}
}

- (IBAction)newWatcher_Action:(id)sender {
	[self prepareWatcherSheet:0];
	[self startSheetForWatcher:self withSelector:@selector(didEndSheetForWatcher:returnCode:contextInfo:)];
}

- (void) startSheetForWatcher:(id)delegate withSelector: (SEL) sel {
	[NSApp beginSheet: frmWatcher
	   modalForWindow: window
		modalDelegate: delegate
	   didEndSelector: sel
		  contextInfo: nil];
}

- (IBAction)cmdSheetCancel:(id)sender {
	SheetOK = NO;
	[frmWatcher orderOut:nil];
    [NSApp endSheet:frmWatcher];
}

- (IBAction)cmdSheetOK:(id)sender {
	SheetOK = YES;
    [frmWatcher orderOut:nil];
    [NSApp endSheet:frmWatcher];
}

- (IBAction)cmdSheetFolder_Click:(id)sender {
    NSString * dir = @"/";
	NSOpenPanel * dlg = [NSOpenPanel openPanel];
	
	[dlg setCanChooseDirectories:YES];
	[dlg setCanChooseFiles:NO];
	[dlg beginSheetForDirectory:dir file:@"" modalForWindow:frmWatcher modalDelegate:self didEndSelector:@selector(openPanelDidEndForWatcher:returnCode:contextInfo:) contextInfo:nil];
	
	[dlg release];
}

- (IBAction)cmdSheetAddExceptions_Click:(id)sender {
    [self addNewExceptionWithMask:@"*.*"];
	[[CtlTypes objectAtIndex:[CtlTypes count] - 1] enterEditMode];
}

- (IBAction)cmdSheetAddTypes_Click:(id)sender {
    [self addNewTypeWithMask:@"*.*"];
	[[CtlTypes objectAtIndex:[CtlTypes count] - 1] enterEditMode];
}

- (id) CreateTypeControlWithMask: (NSString *) mask atRect: (NSRect)rect{
	return [[TypeControl alloc] initWithFrame:rect andTypeMask:mask];
}

- (IBAction)txtSearch_Confirm:(id)sender {
    [self searchWatchers:[txtSearch stringValue]];
}

- (void) searchWatchers: (NSString *)mask{
	[[scrollFolders animator] setHidden:YES];
	[[scrollWatchers animator] setHidden:NO];
	
	[docFolders ControlsClear];
	[docWatchers ControlsClear];
	
	[goBack setEnabled:YES];
	[newWatcher setEnabled:NO];
	[newFolder setEnabled:NO];
	
	fSearchMode = YES;
	
	BOOL fAdded = NO;
	
	if ([mask isEqualToString:@""]){
		[self backToFolders];
		return;
	}
	
	mask = [@"*" stringByAppendingString:mask];
	mask = [mask stringByAppendingString:@"*"];
	
	mask = [mask stringByReplacingOccurrencesOfString:@"**" withString:@"*.*"];
	NSString * lastFolder = @"";
	
	for (FolderItem * f in Folders){
		for (WatcherItem * w in [f Watchers]){
			for (NSString * t in [w Types]){
				NSString * ext = [NSString stringWithFormat:@"%@", t];
				ext = [ext stringByReplacingOccurrencesOfString:@"*" withString:@""];
				
				if ([ext isLike:mask] == YES){
					if (! fAdded){
						if (![lastFolder isEqualToString:[f Folder]]){
							NSButton * txtGroup = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
							[txtGroup setTitle:[f Folder]];
							[txtGroup setEnabled:NO];
							[txtGroup setBezelStyle:NSRecessedBezelStyle];
							
							[docWatchers ControlsAdd:txtGroup withIndependentHeight:YES];
							[txtGroup release];
							
							lastFolder = [f Folder];
						} 
						[self addNewWatcherWithTypes:[w Types] Exceptions:[w Exceptions] Destination:[w DestinationFolder] MoveFiles:[w MoveFiles] Id:[w Id] Paused:[w Paused] ParentId:[f Id]];
						fAdded = YES;
					}
				}
				
				[ext release];
			}
			fAdded = NO;
		}
	}
	
	[self flushShades];
}

- (NSString *) convertToURLString: (NSString *) source{
	NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
			(CFStringRef)source,
			NULL,
			(CFStringRef)@"!*'\"();:@&=+$,?%#[]% ",
			kCFStringEncodingUTF8 );
	
	return [@"file://localhost" stringByAppendingString:encodedString];
}

- (NSString *) convertToPathString: (NSString *) source{
	NSString * encodedString = (NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL,
			(CFStringRef)source,
			(CFStringRef)@"");
	
	return [encodedString stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
}

- (void) backToFolders{
	[[scrollFolders animator] setHidden:NO];
	[[scrollWatchers animator] setHidden:YES];
	
	[docFolders ControlsClear];
	[docWatchers ControlsClear];
	
	[goBack setEnabled:NO];
	[newWatcher setEnabled:NO];
	[newFolder setEnabled:YES];
	
	fSearchMode = NO;
	
	[self fillFolders];
}

- (id) CreateWatcherControlWithTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id:(long)ID Paused: (BOOL) paused ParentId: (long) parentid atRect: (NSRect)rect{
	return [[WatcherControl alloc] initWithFrame:rect andTypes:types Exceptions:exceptions Destination:destination MoveFiles:move Id:ID ParentId:parentid Paused:paused];
}

- (void) addNewWatcherWithTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id: (long) ID Paused: (BOOL) paused ParentId: (long) parentid{	
	NSRect frame = NSMakeRect(4, 0, 545, 120);
	
	WatcherControl * newWatcherCtl = [self CreateWatcherControlWithTypes:types Exceptions:exceptions Destination:destination MoveFiles:move Id:ID Paused:paused ParentId:parentid atRect:frame]; 
	
	[newWatcherCtl setToolbarButtonsBack:goBack newWatcher:newWatcher newFolder:newFolder];
	[newWatcherCtl setWindow:window];
	
	[docWatchers ControlsAdd:newWatcherCtl]; 
	
	[newWatcherCtl release];
}

- (IBAction)cmdWebpage_Click:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://fileimg.ru/en/inwatch.html"];
	[[NSWorkspace sharedWorkspace] openURL:url];
	[url release];
}

- (void) addNewTypeWithMask: (NSString *) mask{
	if (!CtlTypes) CtlTypes = [NSMutableArray new];
	
	NSRect frame = NSMakeRect(0, 0, 384, 20); 
	TypeControl * newTypeCtl = [self CreateTypeControlWithMask:mask atRect:frame]; 
	
	[CtlTypes addObject:newTypeCtl];
	
	[docTypes ControlsAdd:newTypeCtl]; 
	[newTypeCtl release];
} 

- (void) addNewExceptionWithMask: (NSString *) mask{
	if (!CtlTypes) CtlTypes = [NSMutableArray new];
	
	NSRect frame = NSMakeRect(0,0, 384, 20); 
	TypeControl * newTypeCtl = [self CreateTypeControlWithMask:mask atRect:frame]; 
	
	[CtlTypes addObject:newTypeCtl];
	
	[docExceptions ControlsAdd:newTypeCtl]; 
	[newTypeCtl release];
} 

@end
