//
//  WatcherControl.m
//  InWatch
//
//  Created by Vagrod on 5/1/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "WatcherControl.h"
#import "WatcherItem.h"
#import "FolderItem.h"
#import "ToolbarController.h"
#import "WatcherWriter.h"

@implementation WatcherControl

@synthesize moveInd;
@synthesize cmdAction;
@synthesize mnuCopy;
@synthesize lblTypes;
@synthesize lblExceptions;
@synthesize mnuMove;
@synthesize cmdFolder;
@synthesize cmdTypes;
@synthesize cmdExceptions;
@synthesize cmdRemove;
@synthesize Id;
@synthesize ParentId;
@synthesize Bounds;
@synthesize cmdPause;
@synthesize Paused;

NSPopUpButton * cmdAction;
NSMenuItem * mnuCopy;
NSMenuItem * mnuMove;
NSPathControl * cmdFolder;
NSButton * cmdTypes;
NSButton * cmdExceptions;
NSButton * cmdRemove;
NSButton * cmdPause;
NSTextField * lblTypes;
NSTextField * lblExceptions;

NSScrollView * viewFolders;
NSScrollView * viewWatchers;

NSToolbarItem * goBack;
NSToolbarItem * newWatcher;
NSToolbarItem * newFolder;
id window;

BOOL Paused;

long Id;
long ParentId;
NSRect Bounds;

int moveInd = 0;

extern NSMutableArray * Folders;
//extern FolderItem * CurrentFolder;
extern ToolbarController * MainController;
extern BOOL SheetOK;

NSMutableArray * NSStringToArray(NSString * s){
	NSMutableArray * ret = [NSMutableArray new];
	
	if (! s){return ret;}
	if ([s length] == 0){return ret;}
	
	//s = [s substringToIndex:[s length] - 1];
	NSArray * a = [s componentsSeparatedByString:@";"];
	
	for (NSString * i in a) {
		[ret addObject:i];
	}
	
	[a release];
	
	return ret;
}

- (void) updateWatcher{
	for (FolderItem * f in Folders){
		if ([f Id] == [self ParentId]){
			for (WatcherItem * w in [f Watchers]){
				if ([w Id] == [self Id]){
					NSString * dest = [MainController convertToPathString:[[cmdFolder URL] absoluteString]];
					
					[w setDestinationFolder:dest];
					[w setExceptions:NSStringToArray([lblExceptions stringValue])];
					[w setTypes:NSStringToArray([lblTypes stringValue])];
					[w setMoveFiles:[self getMoveFilesOptionSelected:self]];
					[w setPaused:[self Paused]];
					
					break;
				}
			}
			break;
		}
	}
	
	[window setDocumentEdited:YES];
}

- (void) dispose{
	[cmdAction removeFromSuperviewWithoutNeedingDisplay];
	[cmdFolder removeFromSuperviewWithoutNeedingDisplay];
	[cmdTypes removeFromSuperviewWithoutNeedingDisplay];
	[cmdExceptions removeFromSuperviewWithoutNeedingDisplay];
	[cmdRemove removeFromSuperviewWithoutNeedingDisplay];
	[lblTypes removeFromSuperviewWithoutNeedingDisplay];
	[lblExceptions removeFromSuperviewWithoutNeedingDisplay];
	[cmdPause removeFromSuperviewWithoutNeedingDisplay];
	
	[cmdPause release];
	[lblTypes release];
	[lblExceptions release];
	[cmdAction release];
	[mnuCopy release];
	[mnuMove release];
	[cmdFolder release];
	[cmdTypes release];
	[cmdExceptions release];
	[cmdRemove release];
	[viewFolders release];
	[viewWatchers release];
	
	[goBack release];
	[newWatcher release];
	[newFolder release];
	
	[window release];
	
	[self removeFromSuperviewWithoutNeedingDisplay];
	[self release];
	self = nil;
}

- (void) setToolbarButtonsBack: (NSToolbarItem *)goback newWatcher: (NSToolbarItem *)newwatcher newFolder: (NSToolbarItem *) newfolder{
	goBack = goback;
	newFolder = newfolder;
	newWatcher = newwatcher;
}

- (BOOL) getMoveFilesOptionSelected: (id) sender{
	return (moveInd == 1);
}

- (void) setWindow: (id) win{
	window = win;
}

- (void) setFoldersView: (NSScrollView *) view{
	viewFolders = view;
}

- (void) setWatchersView: (NSScrollView *) view{
	viewWatchers = view;
}

NSString * ArrayToNSString(NSMutableArray * a){
	NSString * ret = @"";
	
	for (NSString * s in a){
		ret = [ret stringByAppendingFormat:@"%@;", s];
	}
	
	if ([ret isEqualToString:@""]) return @"";
	
	ret = [ret substringToIndex:[ret length] - 1];
	
	return ret;
}

- (id) initWithFrame:(NSRect)frameRect andTypes: (NSMutableArray *)types Exceptions: (NSMutableArray *) exceptions Destination: (NSString *) destination MoveFiles: (BOOL) move Id: (long) ID ParentId: (long) parentid Paused: (BOOL) paused{
	self = [super initWithFrame:frameRect];
	if (self) {
		[self setBounds:frameRect];
		[self setId:ID];
		[self setParentId:parentid];
		[self setPaused:paused];
		[self setAutoresizingMask:NSViewMinYMargin];
		
		int dy = 15;
		 NSRect cmdActionRect = NSMakeRect(10,10 + dy,60,40);
		 NSImage * cmdActionImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
		 
		 cmdAction = [[NSPopUpButton alloc] initWithFrame:cmdActionRect];
		 [cmdAction setBordered:NO];
		 [cmdAction setAutoenablesItems:NO];

		 [cmdAction addItemWithTitle:@"Copy Files"];
		 [cmdAction addItemWithTitle:@"Move Files"];
		
//		[cmdAction addItemWithTitle:@"Копировать файлы"];
//		[cmdAction addItemWithTitle:@"Перемещать файлы"];
		 
		 mnuCopy = [cmdAction itemAtIndex:0];
		 mnuMove = [cmdAction itemAtIndex:1];
		 
		 [mnuCopy setEnabled:YES];
		 [mnuMove setEnabled:YES];
		 
		 NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Copy" ofType:@"png"];
		 NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];

		 [mnuCopy setImage:imageObj];
  		 [imageObj release];
		 [imageName release];
		
		 imageName = [[NSBundle mainBundle] pathForResource:@"Move" ofType:@"png"];
		 imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
		
		 [mnuMove setImage:imageObj];
		 [imageObj release];
		 [imageName release];
		 
		 [cmdAction setImage:cmdActionImage];
		 [cmdAction setImagePosition:NSImageOnly];
		 
		 [mnuCopy setTarget:self];
		 [mnuMove setTarget:self];
		 [mnuCopy setAction:@selector(mnuCopy_Click:)];
		 [mnuMove setAction:@selector(mnuMove_Click:)];
		 
		if (move == YES){
			[cmdAction selectItemAtIndex:1];
			moveInd = 1;
			[self setMoveInd:1];
		}else{
			[cmdAction selectItemAtIndex:0];
			moveInd = 0;
			[self setMoveInd:0];
		}
		
		 [self addSubview:cmdAction];
		 
		 //[cmdAction release];
		 [cmdActionImage release];
		 [mnuMove release];
		 [mnuCopy release];
		
		// Creating folder button
		cmdFolder = [[NSPathControl alloc] initWithFrame:NSMakeRect(75, 65 + dy, [window frame].size.width - 80 - 25, 20)];
		[cmdFolder setPathStyle:NSPathStyleNavigationBar];
		[cmdFolder setURL:[NSURL URLWithString:[MainController convertToURLString:destination]]];
		
		[cmdFolder setAction:@selector(cmdFolder_Click:)];
		[cmdFolder setTarget:self];
		
		[self addSubview:cmdFolder];
		
		[cmdFolder release];
		
		// Creating types button
		cmdTypes = [[NSButton alloc] initWithFrame:NSMakeRect(75, 35 + dy, 100, 25)];
		[cmdTypes setBezelStyle:NSRoundRectBezelStyle];
		[cmdTypes setAlignment:NSRightTextAlignment];
		[cmdTypes setImage:[self resizeImage:[NSImage imageNamed:@"NSActionTemplate"] toSize:NSMakeSize(10, 10)]];
		[cmdTypes setToolTip:@"Configure this Watcher"];
//		[cmdTypes setToolTip:@"Настроить монитор"];
		[cmdTypes setImagePosition:NSImageLeft];
		[cmdTypes setTitle:@"Types: "];
//		[cmdTypes setTitle:@"Типы: "];
		
		[cmdTypes setAction:@selector(cmdTypes_Click:)];
		[cmdTypes setTarget:self];
		
		[self addSubview:cmdTypes];
		
		[cmdTypes release];
		
		// Creating exceptions button
		cmdExceptions = [[NSButton alloc] initWithFrame:NSMakeRect(75, 5 + dy, 100, 25)];
		[cmdExceptions setBezelStyle:NSRoundRectBezelStyle];
		[cmdExceptions setAlignment:NSRightTextAlignment];
		[cmdExceptions setTitle:@"Exceptions: "];
//		[cmdExceptions setTitle:@"Кроме: "];
		[cmdExceptions setImage:[self resizeImage:[NSImage imageNamed:@"NSActionTemplate"] toSize:NSMakeSize(10, 10)]];
		[cmdExceptions setToolTip:@"Configure this Watcher"];
//		[cmdExceptions setToolTip:@"Настроить монитор"];
		[cmdExceptions setImagePosition:NSImageLeft];
		
		
		[cmdExceptions setAction:@selector(cmdExceptions_Click:)];
		[cmdExceptions setTarget:self];
		
		[self addSubview:cmdExceptions];
		
		[cmdExceptions release];
		
		// Creating remove button
		cmdRemove = [[NSButton alloc] initWithFrame:NSMakeRect(22, 65 + dy, 35, 16)];
		[cmdRemove setBezelStyle:NSRoundedBezelStyle];
		[cmdRemove setTitle:@""];
		[cmdRemove setBordered:NO];
		[cmdRemove setToolTip:@"Remove this Watcher"];
//		[cmdRemove setToolTip:@"Удалить монитор"];
		[cmdRemove setImage:[NSImage imageNamed:@"NSRemoveTemplate"]];
		
		[cmdRemove setAction:@selector(cmdRemove_Click:)];
		[cmdRemove setTarget:self];
		
		[self addSubview:cmdRemove];
		[cmdRemove release];
		
		// Creating pause button
		cmdPause = [[NSButton alloc] initWithFrame:NSMakeRect(22, 65 + dy - 20, 35, 16)];
		[cmdPause setBezelStyle:NSRoundedBezelStyle];
		[cmdPause setTitle:@""];
		[cmdPause setBordered:NO];
		
		if ([self Paused]){
			[cmdPause setToolTip:@"Resume this Watcher"];
//			[cmdPause setToolTip:@"Возобновить монитор"];
			[[self animator] setAlphaValue:0.5];
			
			[cmdPause setImage:[NSImage imageNamed:@"NSGoRightTemplate"]];
			
		}else{
			[cmdPause setToolTip:@"Pause this Watcher"];
//			[cmdPause setToolTip:@"Остановить монитор"];
			[[self animator] setAlphaValue:1.0];
			
			NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Pause" ofType:@"png"];
			NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
			[cmdPause setImage:imageObj];
			
			[imageObj release];
			[imageName release];
		}
		
		[cmdPause setAction:@selector(cmdPause_Click:)];
		[cmdPause setTarget:self];
		
		[self addSubview:cmdPause];
		[cmdPause release];
		
		
		// Creating Types label
		lblTypes = [[NSTextField alloc] initWithFrame:NSMakeRect(180, 39 + dy - 4, 340, 22)];
		[lblTypes setStringValue:ArrayToNSString(types)];
		[[lblTypes cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[lblTypes setBordered:NO];
		[lblTypes setSelectable:NO];
		[lblTypes setEditable:NO];
		[lblTypes setDrawsBackground:NO];
		
		[self addSubview:lblTypes];
		[lblTypes release];
		
		
		// Creating Exceptions label
		lblExceptions = [[NSTextField alloc] initWithFrame:NSMakeRect(180, 9 + dy - 4, 340, 22)];
		[lblExceptions setStringValue:ArrayToNSString(exceptions)];
		[[lblExceptions cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[lblExceptions setBordered:NO];
		[lblExceptions setSelectable:NO];
		[lblExceptions setEditable:NO];
		[lblExceptions setDrawsBackground:NO];	
		
		[self addSubview:lblExceptions];
		[lblExceptions release];
	}
	
	return self;
}

- (void)FadeViews:(NSView *)v1 to:(NSView *)v2{
	for (float i = 0; i < 1; i = i + 0.09){
		//printf("%f\n", i);
		[v1 setAlphaValue:(1 - i)];
		[v1 display];
		
		[v2 setAlphaValue:i];
		[v2 display];
		
		[self display];
	}
	[v2 setAlphaValue:1.0];
	[v1 setAlphaValue:0.0];
}

- (void) mnuCopy_Click: (id) sender{
	printf("Copy menu pressed\n");
	moveInd = 0;
	[self updateWatcher];
	//printf("Move files? %d\n", [self getMoveFilesOptionSelected:self]);
}

- (void) mnuMove_Click: (id) sender{
	printf("Move menu pressed\n");
	moveInd = 1;
	//printf("Move files? %d\n", [self getMoveFilesOptionSelected:self]);
	[self updateWatcher];
}

- (void) cmdPause_Click: (id)sender{
	printf("Pause clicked\n");
	
	[self setPaused:![self Paused]];
	
	if ([self Paused]){
		[cmdPause setToolTip:@"Resume this Watcher"];
//		[cmdPause setToolTip:@"Возобновить монитор"];
		[[self animator] setAlphaValue:0.5];
		
		[cmdPause setImage:[NSImage imageNamed:@"NSGoRightTemplate"]];
	}else{
		[cmdPause setToolTip:@"Pause this Watcher"];
//		[cmdPause setToolTip:@"Остановить монитор"];
		[[self animator] setAlphaValue:1.0];
		
		NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Pause" ofType:@"png"];
		NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
		[cmdPause setImage:imageObj];
		
		[imageObj release];
		[imageName release];
	}
	
	[self display];
	[self updateWatcher];
}

- (void) cmdRemove_Click: (id) sender{
	printf("Remove clicked\n");
	
	[(ContentView *)[self superview] ControlsRemove:self];
	
	for (FolderItem * f in Folders){
		for (WatcherItem * w in [f Watchers]){
			if ([w Id] == [self Id]){
				[[f Watchers] removeObject:w];
				break;
			}
		}
		
	}
	
	[window setDocumentEdited:YES];
}

- (void)didEndSheetForWatcher:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	if (SheetOK) {
		[cmdFolder setURL:[MainController getSheetURL]];
		[lblTypes setStringValue:ArrayToNSString([MainController getSheetTypes])];
		[lblExceptions setStringValue:ArrayToNSString([MainController getSheetExceptions])];
		[self updateWatcher];
	}
	
	[MainController cleanUpTypes];
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

- (void) cmdTypes_Click: (id) sender{
	printf("Types clicked\n");
	
	[MainController prepareWatcherSheet:[self Id]];
	[MainController startSheetForWatcher:self withSelector:@selector(didEndSheetForWatcher:returnCode:contextInfo:)];
	
//	[self updateWatcher];
}

- (void) cmdExceptions_Click: (id) sender{
	printf("Exceptions clicked\n");
	
	[MainController prepareWatcherSheet:[self Id]];
	[MainController startSheetForWatcher:self withSelector:@selector(didEndSheetForWatcher:returnCode:contextInfo:)];
	
//	[self updateWatcher];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	if (! returnCode) return;
	
	printf("Folder clicked\n");
	printf("Move files? %d\n", [self getMoveFilesOptionSelected:self]);
	
	[cmdFolder setURL:[NSURL URLWithString:[MainController convertToURLString:[panel filename]]]];
	[self updateWatcher];
}

- (void) cmdFolder_Click: (id) sender{
	printf("Folder clicked\n");
	NSString * dir = @"/";
	
	if ([[cmdFolder URL] absoluteString] > 0){dir = [MainController convertToPathString:[[cmdFolder URL] absoluteString]];}
//	dir = [dir stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
	
	NSOpenPanel * dlg = [NSOpenPanel openPanel];
	
	[dlg setCanChooseDirectories:YES];
	[dlg setCanChooseFiles:NO];
	[dlg beginSheetForDirectory:dir file:@"" modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
	[dlg release];
}

- (void) drawRect:(NSRect)dirtyRect{	
	if (! [self Paused]){
		[[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.7] set];
	}else{
		[[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.7] set];
	}
	
	NSGraphicsContext * tvarNSGraphicsContext = [NSGraphicsContext currentContext];
	CGContextRef      tvarCGContextRef     = (CGContextRef) [tvarNSGraphicsContext graphicsPort];
	CGMutablePathRef p = CGPathCreateMutable();
	
	//CGPathADd
	
	CGContextSetRGBStrokeColor(tvarCGContextRef, 0.5,0.5,0.5,0.4);
	CGContextSetLineWidth(tvarCGContextRef, 8.0 );
	
	CGPathMoveToPoint(p, nil,15,5);
	
	CGPathAddCurveToPoint(p, nil, 15, 5, 5, 5, 5, 15); //left-bottom corner
	
	CGPathAddLineToPoint(p, nil, 5,dirtyRect.size.height - 15); //left border
	
	CGPathAddCurveToPoint(p, nil, 5, dirtyRect.size.height - 15, 5, dirtyRect.size.height - 5, 15, dirtyRect.size.height - 5); //left-top corner
	
	//CGPathAddLineToPoint(p, nil, dirtyRect.size.width - 15,dirtyRect.size.height - 5); //top border
	CGPathAddCurveToPoint(p, nil, 15, dirtyRect.size.height - 5, dirtyRect.size.width / 2, dirtyRect.size.height, dirtyRect.size.width - 15, dirtyRect.size.height - 5); //top line
	
	
	CGPathAddCurveToPoint(p, nil, dirtyRect.size.width - 15, dirtyRect.size.height - 5, dirtyRect.size.width - 5, dirtyRect.size.height - 5, dirtyRect.size.width - 5, dirtyRect.size.height - 15); //top-right corner
	
	CGPathAddLineToPoint(p, nil, dirtyRect.size.width - 5, 15); //right border
	
	CGPathAddCurveToPoint(p, nil, dirtyRect.size.width - 5, 15, dirtyRect.size.width - 5, 5, dirtyRect.size.width - 15, 5); //right-bottom corner
	
	//CGPathAddLineToPoint(p, nil, 15, 5); //bottom border
	CGPathAddCurveToPoint(p, nil, dirtyRect.size.width - 15, 5, dirtyRect.size.width / 2, 15, 15, 5); //bottom line
	
		
	CGContextAddPath(tvarCGContextRef, p);
	CGContextFillPath(tvarCGContextRef);

	CGContextAddPath(tvarCGContextRef, p);
	CGContextDrawPath(tvarCGContextRef, kCGPathStroke);

	[tvarNSGraphicsContext release];
}

@end
