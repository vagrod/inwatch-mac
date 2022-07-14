//
//  InWatchAppDelegate.m
//  InWatch:mac
//
//  Created by Vagrod on 4/26/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import "InWatchAppDelegate.h"
#import "FileWatcher.h"
#import "TrayMenu.h"
#import "FolderItem.h"
#import "WatcherItem.h"
#import "WatcherReader.h"
#import "LoginItems.h"
#import "WatcherWriter.h"
#import "GlobalWatcher.h"

@implementation InWatchAppDelegate

extern BOOL notifyAction;
extern BOOL useSmartMusic;
extern BOOL useSmartArchive;

BOOL _messageclosed = YES;
BOOL _shouldclose = NO;

TrayMenu * menu;
NSMutableArray * Folders;
NSMutableArray * Monitors;
GlobalWatcher * TotalWatcher;

@synthesize window;

-(void) MessageBoxSheet:(NSString *)_message withInformativeText:(NSString *)_inf{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	_messageclosed=NO;
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:_message];
	[alert setInformativeText:_inf];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd: returnCode: contextInfo:) contextInfo:nil];
	
	//[alert beginSheetModalForWindow:[searchField window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

-(void) MessageBox:(NSString *)_message withInformativeText:(NSString *)_inf{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:_message];
	[alert setInformativeText:_inf];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert runModal];
	
	//[alert beginSheetModalForWindow:[searchField window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

-(NSInteger) MessageBoxQuestion:(NSString *)_message withInformativeText:(NSString *)_inf withYesText: (NSString *) _yes withNoText: (NSString *) _no{
	NSAlert * alert = [NSAlert alertWithMessageText:_message defaultButton:_yes alternateButton:_no otherButton:nil informativeTextWithFormat:_inf];
	
	return [alert runModal];
	
	//[alert beginSheetModalForWindow:[searchField window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

-(void) SheetQuestion:(NSString *)_message withInformativeText:(NSString *)_inf withYesText: (NSString *) _yes withNoText: (NSString *) _no{
	NSAlert * alert = [NSAlert alertWithMessageText:_message defaultButton:_yes alternateButton:_no otherButton:nil informativeTextWithFormat:_inf];
	
	//return [alert runModal];
	
	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(questionDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo{
	_messageclosed=YES; 
	
	if (_shouldclose) {[[alert window] close]; [window close];};
}

- (void)questionDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo{
	if (returnCode == NSAlertDefaultReturn){
		[[alert window] close];
		[self refreshWatchers_Click:self];
	}else{
		_messageclosed = YES;
		[[alert window] close];
		[[self window] close];
	}
}

- (IBAction)refreshWatchers_Click:(id)sender {
	WatcherWriter * wr = [[WatcherWriter alloc] init];
	[wr writeWatchers:Folders];
	[wr writeSettings:notifyAction useSmartMusic:useSmartMusic useSmartArchive:useSmartArchive];
	[wr release];
	
	[TotalWatcher dispose];
	
    for (FileWatcher * w in Monitors){
		[w dispose];
		[w release];
		w = nil;
	}
	
	[Monitors removeAllObjects];
	
	Monitors = [NSMutableArray new];
	for (FolderItem * f in Folders){
		for (WatcherItem * wt in [f Watchers]){
			if (! [wt Paused]) {
				FileWatcher *w = [[[FileWatcher alloc] init] autorelease];
				
				[w initWithPath:[f Folder] andDestination:[wt DestinationFolder] andTypes:[wt Types] andExceptions:[wt Exceptions] andMoveFiles:[wt MoveFiles] andParent:[f Id]];
				[w setTypes:[wt Types]];
				[w setExceptions:[wt Exceptions]];
				[w setMoveFiles:[wt MoveFiles]];
				[w setDestination:[wt DestinationFolder]];
				
				[Monitors addObject:w];
				[w release];
			}
		}
	}
	
	TotalWatcher = [[GlobalWatcher alloc] initWithWatchers:Monitors];

	[self MessageBoxSheet:@"Watchers has been relaunched" withInformativeText:[@"All active watchers has been relaunched to match preferences.\n" stringByAppendingFormat:@"Currently watchers online: %i", [Monitors count]]];
//	[self MessageBoxSheet:@"Мониторы были перезапущены" withInformativeText:[@"Все активные мониторы были перезапущены с указанными настройками.\n" stringByAppendingFormat:@"Мониторов активно: %i", [Monitors count]]];
}

- (BOOL) windowShouldClose:(NSNotification *)notification{
	if ([window isDocumentEdited] == YES){
		_shouldclose = YES;
		_messageclosed = NO;
//		[self SheetQuestion:@"Применение настроек" withInformativeText:@"Настройки были изменены. Применить изменения сейчас?" withYesText:@"Перезапустить мониторы" withNoText:@"Не сейчас"];
		[self SheetQuestion:@"Applying Changes" withInformativeText:@"Preferences has been changed. Apply this modifications now?" withYesText:@"Restart watchers" withNoText:@"Not now"];
	}

	if (_messageclosed) [window setDocumentEdited:NO];
	return _messageclosed;
}

- (void)windowWillClose:(NSNotification *)notification{

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	printf("InWatch:mac started\n");
	
	if (! [LoginItems willStartAtLogin:[[NSBundle mainBundle] bundleURL]] == YES){
		if([self MessageBoxQuestion:@"InWatch Autostart" withInformativeText:@"InWatch is not set to start automatically at login. Add InWatch to startup Loging Items now?" withYesText:@"Add to startup" withNoText:@"Not now"] == NSAlertDefaultReturn){
//		if([self MessageBoxQuestion:@"Автозапуск InWatch" withInformativeText:@"InWatch не прописан в автозагрузку. Нажмите Добавить..., чтобы программа автоматически запускалась при старте компьютера." withYesText:@"Добавить в автозагрузку" withNoText:@"Не сейчас"] == NSAlertDefaultReturn){
			[LoginItems setStartAtLogin:[[NSBundle mainBundle] bundleURL] enabled:YES];
		}
	}
		
	WatcherReader * reader = [[WatcherReader alloc] init];
	if (! Folders) Folders = [reader initWatchers];
	
	IWSettings set;
	set = [reader readSettings];
	
	notifyAction = set.NotifyAction;
	useSmartMusic = set.SmartMusic;
	useSmartArchive = set.SmartArchive;
	
	[reader release];
	
	menu = [[TrayMenu alloc] init];
	
	[menu initMenu:self];
	
	[goBack setEnabled:NO];
	[newWatcher setEnabled:NO];
	
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Back" ofType:@"png"];
	NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[goBack setImage:imageObj];
	
	[imageName release];
	[imageObj release];
	
	imageName = [[NSBundle mainBundle] pathForResource:@"Add" ofType:@"png"];
	imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[newWatcher setImage:imageObj];
	
	[imageName release];
	[imageObj release];
	
	imageName = [[NSBundle mainBundle] pathForResource:@"NewFolder" ofType:@"png"];
	imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[newFolder setImage:imageObj];
	
	[imageName release];
	[imageObj release];
	
	imageName = [[NSBundle mainBundle] pathForResource:@"Restart" ofType:@"png"];
	imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[refreshWatchers setImage:imageObj];
	
	[imageName release];
	[imageObj release];	
	
	imageName = [[NSBundle mainBundle] pathForResource:@"Icon" ofType:@"icns"];
	imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[imageApp setImage:imageObj];
	
	[imageName release];
	[imageObj release];	
	
	// Insert code here to initialize your application 

	printf("Starting file system event handler\n");
	
	Monitors = [NSMutableArray new];
	for (FolderItem * f in Folders){
		for (WatcherItem * wt in [f Watchers]){
			if (! [wt Paused]) {
				FileWatcher *w = [[[FileWatcher alloc] init] autorelease];
				NSLog(@"%@ id %i", [f Folder], [f Id]);
				[w initWithPath:[f Folder] andDestination:[wt DestinationFolder] andTypes:[wt Types] andExceptions:[wt Exceptions] andMoveFiles:[wt MoveFiles] andParent:[f Id]];
				[w setTypes:[wt Types]];
				[w setExceptions:[wt Exceptions]];
				[w setMoveFiles:[wt MoveFiles]];
				[w setDestination:[wt DestinationFolder]];
		
				[Monitors addObject:w];
				[w release];
			}
		}
	}
	
	TotalWatcher = [[GlobalWatcher alloc] initWithWatchers:Monitors];
}

@end
