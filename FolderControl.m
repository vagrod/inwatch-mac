//
//  FolderControl.m
//  InWatch
//
//  Created by Vagrod on 5/1/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FolderControl.h"
#import "WatcherControl.h"
#import "WatcherItem.h"
#import "FolderItem.h"
#import "ToolbarController.h"
#import "WatcherWriter.h"
#import "ContentView.h"
#import "BottomView.h"

//NSPopUpButton * cmdAction;

//extern IBOutlet BottomView * viewTop;
//extern IBOutlet BottomView * viewBottom;

NSScrollView * viewFolders;
NSScrollView * viewWatchers;
ContentView * viewParent;
ContentView * viewWatchersParent;

NSToolbarItem * goBack;
NSToolbarItem * newWatcher;
NSToolbarItem * newFolder;

NSMutableArray * CtlWatchers;
NSMutableArray * Watchers;
NSString * Folder;

NSButton * cmdCopy;
NSImage * cmdCopyImage;
NSPathControl * cmdFolder;
NSButton * cmdRemove;
NSButton * cmdWatchers;
NSTextField * lblWatchers;

long Id;

id window;

int WatchersCount = 0;

extern FolderControl * CurrentFolder;
extern NSMutableArray * CtlFolders;
extern NSMutableArray * Folders;
extern int FoldersCount;
extern ToolbarController * MainController;

@implementation FolderControl

@synthesize Folder;
@synthesize Watchers;
@synthesize CtlWatchers;

@synthesize lblWatchers;
@synthesize cmdCopy;
@synthesize cmdFolder;
@synthesize cmdRemove;
@synthesize cmdWatchers;
@synthesize cmdCopyImage;
@synthesize Id;

- (void) updateFolder{
	for (FolderItem * f in Folders){
		if ([f Id] == [self Id]){
			NSString * url = [MainController convertToPathString:[[cmdFolder URL] absoluteString]]; 
			[f setFolder:url];
			break;
		}
	}
	
	[window setDocumentEdited:YES];
}


- (void) setToolbarButtonsBack: (NSToolbarItem *)goback newWatcher: (NSToolbarItem *)newwatcher newFolder: (NSToolbarItem *) newfolder{
	goBack = goback;

	[goBack setTarget:self];
	[goBack setAction:@selector(goBack_Clicked:)];
	
	newFolder = newfolder;
	newWatcher = newwatcher;
}

- (NSMutableArray *) getWatchers: (id) sender{
	return Watchers;
}

void DisposeWatchers(){
	if (CtlWatchers){
		for (id w in CtlWatchers){
			[w dispose];
			[w release];
			w = nil;
		}
		[CtlWatchers removeAllObjects];
		[CtlWatchers release];
	}
}

- (void) dispose{
	[cmdCopy removeFromSuperviewWithoutNeedingDisplay];
	[cmdFolder removeFromSuperviewWithoutNeedingDisplay];
	[cmdRemove removeFromSuperviewWithoutNeedingDisplay];
	[cmdWatchers removeFromSuperviewWithoutNeedingDisplay];
	[lblWatchers removeFromSuperviewWithoutNeedingDisplay];
	
	[lblWatchers release];
	[cmdCopy release];
	[cmdFolder release];
	[cmdRemove release];
	[cmdWatchers release];
	[cmdCopyImage release];
	[viewFolders release];
	[viewWatchers release];
	[viewParent release];
	[viewWatchersParent release];
	
	[goBack release];
	[newWatcher release];
	[newFolder release];
	
	[window release];
	
	[self removeFromSuperviewWithoutNeedingDisplay];
	[self release];
	self = nil;
}

- (void) goBack_Clicked: (id) sender{
	[[viewFolders animator] setHidden:NO];
	[[viewWatchers animator] setHidden:YES];
	
	[MainController flushShades];
	
	[goBack setEnabled:NO];
	[newWatcher setEnabled:NO];
	[newFolder setEnabled:YES];
	
	WatchersCount = 0;
	FoldersCount = 0;

	[CurrentFolder release];
	CurrentFolder = nil;
	
	DisposeWatchers();
	
	[viewWatchersParent ControlsClear];
	
	for (FolderItem * f in Folders){
		[self addNewFolder:[f Folder] withWatchers:[f Watchers] isNew:[f Id]];
		NSLog(@"Folder %d with %d watchers", [f Id], [[f Watchers] count]);
	}
}

- (id) CreateFolderControl: (NSString *)folder withWatchers: (NSMutableArray *) watchers atRect: (NSRect)rect isNew: (long) isnew{
	return [[FolderControl alloc] initWithFrame:rect andFolder:folder andWatchers:watchers andId:isnew];
}

- (void) addNewFolder:(NSString *)folder withWatchers: (NSMutableArray *) watchers isNew: (long) isnew{
	NSRect frame = NSMakeRect(4, 0, 545, 90); 
	FolderControl * newFolderCtl = [self CreateFolderControl:folder withWatchers:watchers atRect:frame isNew:isnew]; 
	
	[newFolderCtl setWatchersView:viewWatchers];
	[newFolderCtl setFoldersView:viewFolders];
	[newFolderCtl setParentView:viewParent];
	[newFolderCtl setParentWatchersView:viewWatchersParent];
	[newFolderCtl setWindow:window];
	[newFolderCtl setToolbarButtonsBack:goBack newWatcher:newWatcher newFolder:newFolder];
	
	[CtlFolders addObject:newFolderCtl];
	
	[viewParent ControlsAdd:newFolderCtl]; 
	[newFolderCtl release];
} 

- (void) ClearView: (id) sender{
	[viewParent ControlsClear];
}

- (id) initWithFolder: (FolderItem *) folder andFrame: (NSRect) frame{
	return [self initWithFrame:frame andFolder:[folder Folder] andWatchers:[folder Watchers] andId:[folder Id]];
}

- (id) initWithFrame:(NSRect)frameRect andFolder:(NSString *)folder andWatchers: (NSMutableArray *) watchers andId: (long) ID{
	self = [super initWithFrame:frameRect];
	if (self) {
		[self setId:ID];
		[self setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin | NSViewMinYMargin];
		
		Folder = folder;
		Watchers = watchers;
		CtlWatchers = [NSMutableArray new];
		
		int dy = 15;
		int dx = 10;
		
		[self setFolder:folder];
		[self setWatchers:watchers];
		
		int width = 554; //frameRect.size.width;
		 
		// Drawing image
		cmdCopy = [[NSButton alloc] initWithFrame:NSMakeRect(7 + dx,-3 + dy,40,40)];
		NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Copy" ofType:@"png"];
		cmdCopyImage = [[NSImage alloc] initWithContentsOfFile:imageName];

//		cmdCopyImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
		
//		[cmdCopy setToolTip:@"Дублировать мониторы"];
		[cmdCopy setToolTip:@"Clone folder"];
		[cmdCopy setImage:cmdCopyImage];
		[cmdCopy setBordered:NO];

		[cmdCopy setAction:@selector(cmdCopy_Click:)];
		[cmdCopy setTarget:self];
		
		[self addSubview:cmdCopy];
		
		[imageName release];
		[cmdCopyImage release];
		[cmdCopy release];
		
		// Creating folder button
		cmdFolder = [[NSPathControl alloc] initWithFrame:NSMakeRect(50 + dx, 35 + dy, width - 60 - 0, 35)];
		[cmdFolder setPathStyle:NSPathStyleNavigationBar];
		[cmdFolder setURL:[NSURL URLWithString:[MainController convertToURLString:folder]]];		
		[cmdFolder setAction:@selector(cmdFolder_Click:)];
		[cmdFolder setTarget:self];
		
		[self addSubview:cmdFolder];
		[cmdFolder release];
		
		// Creating remove button
		cmdRemove = [[NSButton alloc] initWithFrame:NSMakeRect(10 + dx, 42 + dy, 35, 16)];
		[cmdRemove setBezelStyle:NSRoundedBezelStyle];
		[cmdRemove setToolTip:@"Remove this Item"];
//		[cmdRemove setToolTip:@"Удалить"];
		[cmdRemove setTitle:@""];
		[cmdRemove setBordered:NO];
		[cmdRemove setImage:[NSImage imageNamed:@"NSRemoveTemplate"]];
		
		[cmdRemove setAction:@selector(cmdRemove_Click:)];
		[cmdRemove setTarget:self];
		
		[self addSubview:cmdRemove];
		[cmdRemove release];
		
		// Creating watchers button
		cmdWatchers = [[NSButton alloc] initWithFrame:NSMakeRect(50 + dx, 2 + dy, 110, 25)];
		[cmdWatchers setBezelStyle:NSRoundRectBezelStyle];
		[cmdWatchers setImage:[self resizeImage:[NSImage imageNamed:@"NSActionTemplate"] toSize:NSMakeSize(10, 10)]];
		[cmdWatchers setToolTip:@"Configure Watchers for this folder"];
//		[cmdWatchers setToolTip:@"Настроить мониторы для этой папки"];
		[cmdWatchers setImagePosition:NSImageLeft];
		[cmdWatchers setTitle:@"Watchers: "];
//		[cmdWatchers setTitle:@"Мониторов: "];
		
		[cmdWatchers setAction:@selector(cmdWatchers_Click:)];
		[cmdWatchers setTarget:self];
		
		[self addSubview:cmdWatchers];
		[cmdWatchers release];
		
		
		// Creating Watchers label
		lblWatchers = [[NSTextField alloc] initWithFrame:NSMakeRect(160 + dx, 7 + dy, 120, 16)];
		int c = [watchers count];
		NSString * s = [NSString stringWithFormat:@" %d watchers", c];
		s = [s stringByReplacingOccurrencesOfString:@" 0 watchers" withString:@" no watchers"];
		s = [s stringByReplacingOccurrencesOfString:@" 1 watchers" withString:@" 1 watcher"];
		
//		NSString * s = [NSString stringWithFormat:@" %d мониторов", c];
//		s = [s stringByReplacingOccurrencesOfString:@" 0 мониторов" withString:@" нет мониторов"];
//		s = [s stringByReplacingOccurrencesOfString:@" 1 мониторов" withString:@" 1 монитор"];
		
		[lblWatchers setStringValue:s];
		[lblWatchers setBordered:NO];
		[lblWatchers setSelectable:NO];
		[lblWatchers setEditable:NO];
		[lblWatchers setDrawsBackground:NO];
		
		[self addSubview:lblWatchers];
		[lblWatchers release];
	}
	
	return self;
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

void DisposeFolders(){
	if (CtlFolders){
		for (id w in CtlFolders){
			[w dispose];
			[w release];
			w = nil;
		}
		[CtlFolders removeAllObjects];
		[CtlFolders release];
	}
}

- (void) drawRect:(NSRect)dirtyRect{
	[[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.7] set];
	
	NSGraphicsContext * tvarNSGraphicsContext = [NSGraphicsContext currentContext];
	CGContextRef      tvarCGContextRef     = (CGContextRef) [tvarNSGraphicsContext graphicsPort];
	
	//CGContextSetShadowWithColor(tvarCGContextRef, CGSizeZero, 1/2.0f, kCGColorBlack);
	
	CGMutablePathRef p = CGPathCreateMutable();
	
	//CGPathADd
	
	CGContextSetRGBStrokeColor(tvarCGContextRef, 0.5,0.5,0.5,0.4);
	CGContextSetLineWidth(tvarCGContextRef, 8.0 );

	CGPathMoveToPoint(p, nil,15,5);
	
	CGPathAddCurveToPoint(p, nil, 15, 5, 5, 5, 5, 15); //left-bottom corner
	
	CGPathAddLineToPoint(p, nil, 5,dirtyRect.size.height - 15); //left border
	
	CGPathAddCurveToPoint(p, nil, 5, dirtyRect.size.height - 15, 5, dirtyRect.size.height - 5, 15, dirtyRect.size.height - 5); //left-top corner
	
	//CGPathAddLineToPoint(p, nil, dirtyRect.size.width - 15,dirtyRect.size.height - 5); //top border
	CGPathAddCurveToPoint(p, nil, 15, dirtyRect.size.height - 5, 40, dirtyRect.size.height, dirtyRect.size.width - 15, dirtyRect.size.height - 5); //top line
	
	
	CGPathAddCurveToPoint(p, nil, dirtyRect.size.width - 15, dirtyRect.size.height - 5, dirtyRect.size.width - 5, dirtyRect.size.height - 5, dirtyRect.size.width - 5, dirtyRect.size.height - 15); //top-right corner
	
	CGPathAddLineToPoint(p, nil, dirtyRect.size.width - 5, 15); //right border
	
	CGPathAddCurveToPoint(p, nil, dirtyRect.size.width - 5, 15, dirtyRect.size.width - 5, 5, dirtyRect.size.width - 15, 5); //right-bottom corner

//	CGPathAddLineToPoint(p, nil, 120, 5); //bottom border
	CGPathAddCurveToPoint(p, nil, dirtyRect.size.width - 15, 5, dirtyRect.size.width / 2, 15, 15, 5); //bottom line

	CGContextAddPath(tvarCGContextRef, p);
	CGContextFillPath(tvarCGContextRef);
	
	CGContextAddPath(tvarCGContextRef, p);
	CGContextDrawPath(tvarCGContextRef, kCGPathStroke);
	
	[tvarNSGraphicsContext release];
}

- (void) cmdCopy_Click: (id) sender{
	printf("Clone folder clicked\n");
	
	NSString * dir = @"/";
	NSOpenPanel * dlg = [NSOpenPanel openPanel];
	
	[dlg setCanChooseDirectories:YES];
	[dlg setCanChooseFiles:NO];
	[dlg beginSheetForDirectory:dir file:@"" modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEndForClone:returnCode:contextInfo:) contextInfo:nil];
	
	[dlg release];	
}

- (void)openPanelDidEndForClone:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	if (! returnCode) return;
	
	FolderItem * f = [[FolderItem alloc] init];
	NSMutableArray * w = [NSMutableArray new];
	for (WatcherItem * wt in Watchers){
		WatcherItem * c = [[WatcherItem alloc] init];
		[c setTypes:[NSMutableArray arrayWithArray:[wt Types]]];
		[c setExceptions:[NSMutableArray arrayWithArray:[wt Exceptions]]];
		[c setMoveFiles:[wt MoveFiles]==YES?YES:NO];
		[c setDestinationFolder:[NSString stringWithFormat:@"%@", [wt DestinationFolder]]];
		[c setPaused:[wt Paused]==YES?YES:NO];
		[c setParentId:[f Id]];
		[c setSourceFolder:[NSString stringWithFormat:@"%@", [panel filename]]];
		
		[w addObject:c];
	}
	
	[f setWatchers:w];
	[Folders addObject:f];
	
	[self addNewFolder:[panel filename] withWatchers:w isNew:[f Id]];
	[f setFolder:[panel filename]];
	
	[f release];
	[w release];
	
	[window setDocumentEdited:YES];
}

- (void) cmdWatchers_Click: (id) sender{
	printf("Watchers clicked\n");

	[[viewFolders animator] setHidden:YES];
	[[viewWatchers animator] setHidden:NO];
	
	[MainController flushShades];
	
	DisposeFolders();
	
	[viewParent ControlsClear];
	
	CurrentFolder = self;
	
	[goBack setEnabled:YES];
	[newWatcher setEnabled:YES];
	[newFolder setEnabled:NO];
	
	FolderItem * f;
	
	for (FolderItem * fl in Folders){
		if ([self Id] == [fl Id]){
			f = fl;
			break;
		}
	}
	
	NSButton * txtGroup = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
	[txtGroup setTitle:[f Folder]];
	[txtGroup setEnabled:NO];
	[txtGroup setBezelStyle:NSRecessedBezelStyle];
	
	[viewWatchersParent ControlsAdd:txtGroup withIndependentHeight:YES];
	
	[txtGroup release];
	
	NSMutableArray * wtc = [f Watchers];
	
	for (WatcherItem * w in wtc){
		[self addNewWatcherWithTypes:[w Types] Exceptions:[w Exceptions] Destination:[w DestinationFolder] MoveFiles:[w MoveFiles] Id:[w Id] Paused:[w Paused]];
	}
	
	[f release];
	[wtc release];
}

void SetCtlWatchers(NSMutableArray * w){
	CtlWatchers = w;
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	if (! returnCode) return;
//	NSString * p = [[panel filename] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	[cmdFolder setURL:[NSURL URLWithString:[MainController convertToURLString:[panel filename]]]];		
	[self updateFolder];
}

- (void) cmdFolder_Click: (id) sender{
	printf("Folder clicked\n");
	NSString * dir = @"/";
	
	if ([[[cmdFolder URL] absoluteString] length] > 0){dir = [MainController convertToPathString:[[cmdFolder URL] absoluteString]];}
//	dir = [dir stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
	
	NSOpenPanel * dlg = [NSOpenPanel openPanel];
	
	[dlg setCanChooseDirectories:YES];
	[dlg setCanChooseFiles:NO];
	[dlg beginSheetForDirectory:dir file:@"" modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
	[dlg release];
}

- (void) cmdRemove_Click: (id) sender{
	printf("Remove clicked\n");
	
	[(ContentView *)[self superview] ControlsRemove:self];
	
	for (FolderItem * f in Folders){
		if ([f Id] == [self Id]){
			[Folders removeObject:f];
			break;
		}
	}

	[window setDocumentEdited:YES];
}

- (void)FadeViews:(NSView *)v1 to:(NSView *)v2{
	[v2 setAlphaValue:1.0];
	[v1 setAlphaValue:0.0];
	
	return;
	
	[v2 setAlphaValue:0];
	[v2 setHidden:NO];
	
	[v1 setHidden:NO];
	[v1 setAlphaValue:1];
	
	for (float i = 0; i < 0.9; i=i+0.08){
		//printf("%f\n", i);
		[v1 setAlphaValue:(1 - i)];
		[v1 display];
		
		[v2 setAlphaValue:i];
		[v2 display];
		
		[self display];
		//usleep(10);
	}
	[v2 setAlphaValue:1.0];
	[v1 setAlphaValue:0.0];
}

- (void) setFoldersView: (NSScrollView *) view{
	viewFolders = view;
}

- (void) setWatchersView: (NSScrollView *) view{
	viewWatchers = view;
}

- (void) setParentView: (ContentView *) view{
	viewParent = view;
}

- (void) setParentWatchersView: (ContentView *) view{
	viewWatchersParent = view;
}

- (void) setWindow: (id) w{
	window = w;
}

- (id) CreateWatcherControlWithTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id:(long)ID Paused: (BOOL) paused atRect: (NSRect)rect{
	return [[WatcherControl alloc] initWithFrame:rect andTypes:types Exceptions:exceptions Destination:destination MoveFiles:move Id:ID ParentId:[self Id] Paused:paused];
}

- (void) addNewWatcherWithTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id: (long) ID Paused: (BOOL) paused{
	[viewWatchers setNeedsDisplay:NO];
	
	[viewWatchersParent setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
	[viewWatchersParent setNeedsDisplay:NO];
	
	NSRect frame = NSMakeRect(4, 0, 545, 120);
	
	WatcherControl * newWatcherCtl = [self CreateWatcherControlWithTypes:types Exceptions:exceptions Destination:destination MoveFiles:move Id:ID Paused:paused atRect:frame]; 
	
	[newWatcherCtl setWatchersView:viewWatchers];
	[newWatcherCtl setFoldersView:viewFolders];
	[newWatcherCtl setToolbarButtonsBack:goBack newWatcher:newWatcher newFolder:newFolder];
	[newWatcherCtl setWindow:window];
	
	[viewWatchersParent ControlsAdd:newWatcherCtl]; 
	[[self CtlWatchers] addObject:newWatcherCtl];
	SetCtlWatchers([self CtlWatchers]);
	
	[newWatcherCtl release];
	
	[viewWatchersParent setNeedsDisplay:YES];
	[viewWatchers setNeedsDisplay:YES];
	
	[viewWatchersParent display];
	[viewWatchers display];
}

@end
