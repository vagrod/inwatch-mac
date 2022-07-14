//
//  TrayMenu.m
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "TrayMenu.h"
#import "ToolbarController.h"
#import "WatcherItem.h"
#import "FolderItem.h"
#import "FileWatcher.h"
#import "Messenger.h"
#import "FileWorker.h"
#import "GlobalWatcher.h"
#import "WatcherWriter.h"

@implementation TrayMenu

extern ToolbarController * MainController;
extern NSMutableArray * Monitors;
extern NSMutableArray * Folders;
extern GlobalWatcher * TotalWatcher;

BOOL StatePaused = NO;

- (void) openPreferences:(id)sender {
	[[MainController _getWindow] makeKeyAndOrderFront:self];
}

- (void) openStatistics:(id)sender {
	//[[NSWorkspace sharedWorkspace] launchApplication:@"Finder"];
	NSString * s = @"Total watchers active: ";
//	NSString * s = @"Мониторов активно: ";
	
	s = [s stringByAppendingFormat:@"%i\n", [Monitors count]];
	s = [s stringByAppendingFormat:@"Files processed: %i\n", [MainController getFilesMoved]];
//	s = [s stringByAppendingFormat:@"Файлов обработано: %i\n", [MainController getFilesMoved]];
	
	if ([MainController getLastFile]){
		if (! [[MainController getLastFile] isEqualToString:@""]) {
			s = [s stringByAppendingFormat:@"Last file: %@\n", [[MainController getLastFile] lastPathComponent]];
//			s = [s stringByAppendingFormat:@"Последний файл: %@\n", [[MainController getLastFile] lastPathComponent]];
		}
	}
	
	int w = [MainController getBusyCount];
	if (w == 0){
		s = [s stringByAppendingString:@"No watchers currently waiting for files\n"];
//		s = [s stringByAppendingString:@"Нет мониторов, ожидающих доступа к файлу\n"];
	}
	
	if (w == 1){
		s = [s stringByAppendingString:@"One watcher is currently waiting for file\n"];
//		s = [s stringByAppendingString:@"Один монитор ожидает доступа к файлу\n"];
	}
	
	if (w > 1){
		s = [s stringByAppendingFormat:@"%i watchers currently waiting for files\n", w];
//		s = [s stringByAppendingFormat:@"%i мониторов ожидают доступа к файлам\n", w];
	}
	
	
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"IconSmall" ofType:@"png"];
	NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	Messenger * m = [[Messenger alloc] init];
//	[m growlAlert:s title:@"Статистика InWatch:mac" icon:imageObj];
	[m growlAlert:s title:@"InWatch:mac Statistics" icon:imageObj];
	[m release];
	
	[imageName release];
	[imageObj release];
}

- (void) actionPause:(id)sender {
	if (StatePaused){
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
		
		[sender setTitle:@"Pause"];
//		[sender setTitle:@"Пауза"];
		
	}else{
		[TotalWatcher dispose];
		
		for (FileWatcher * w in Monitors){
			[w dispose];
			[w release];
			w = nil;
		}
		
		[Monitors removeAllObjects];
		
		[sender setTitle:@"Resume"];
//		[sender setTitle:@"Возобновить"];
	}
	
	StatePaused = !StatePaused;
}

- (void) actionAbout:(id)sender {
	[[MainController _getAbout] makeKeyAndOrderFront:self];
}

- (void) actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (void) notifyAction:(id)sender {
	[sender setState:[sender state]==0?1:0];
	[MainController setNotifyAction:[sender state]==0?NO:YES];

	WatcherWriter * wr = [[[WatcherWriter alloc] init] autorelease];
	[wr writeSettings:[sender state]==0?NO:YES useSmartMusic:[MainController getUseSmartMusic] useSmartArchive:[MainController getUseSmartArchive]];
}

- (void) smartMusic:(id)sender {
	[sender setState:[sender state]==0?1:0];
	[MainController setUseSmartMusic:[sender state]==0?NO:YES];
	
	WatcherWriter * wr = [[[WatcherWriter alloc] init] autorelease];
	[wr writeSettings:[MainController getNotifyAction] useSmartMusic:[sender state]==0?NO:YES useSmartArchive:[MainController getUseSmartArchive]];
}

- (void) smartArchive:(id)sender {
	[sender setState:[sender state]==0?1:0];
	[MainController setUseSmartArchive:[sender state]==0?NO:YES];
	
	WatcherWriter * wr = [[[WatcherWriter alloc] init] autorelease];
	[wr writeSettings:[MainController getNotifyAction] useSmartMusic:[MainController getUseSmartMusic] useSmartArchive:[sender state]==0?NO:YES];
}

- (NSMenu *) createMenu {
	NSZone *menuZone = [NSMenu menuZone];
	NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
	NSMenu *menuAdvanced = [[NSMenu allocWithZone:menuZone] init];
	NSMenuItem *menuItem;
	
	// Add to advanced
	
//	menuItem = [menuAdvanced addItemWithTitle:@"Настроить мониторы..."
	menuItem = [menuAdvanced addItemWithTitle:@"Configure Watchers..."
							   action:@selector(openPreferences:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	[menuItem release];
	
//	menuItem = [menuAdvanced addItemWithTitle:@"Создавать подпапку исполнителя для музыки"
	menuItem = [menuAdvanced addItemWithTitle:@"Create artist subfolder for music"
									   action:@selector(smartMusic:)
								keyEquivalent:@""];
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"Music_menu" ofType:@"png"];
	NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	[menuItem setImage:imageObj];
	[menuItem setState:[MainController getUseSmartMusic]==YES?1:0];
	[menuItem setTarget:self];
	[menuItem release];
	
	[imageObj release];
	[imageName release];
	
//	menuItem = [menuAdvanced addItemWithTitle:@"Использовать опцию SmartArchive"
	menuItem = [menuAdvanced addItemWithTitle:@"Use SmartArchive Option"
									   action:@selector(smartArchive:)
								keyEquivalent:@""];
	imageName = [[NSBundle mainBundle] pathForResource:@"Archive_menu" ofType:@"png"];
	imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	[menuItem setImage:imageObj];
	[menuItem setState:[MainController getUseSmartArchive]==YES?1:0];
	[menuItem setTarget:self];
	[menuItem release];
	
	[imageObj release];
	[imageName release];
	
//	menuItem = [menuAdvanced addItemWithTitle:@"Клик на уведомлении открывает файл"
	menuItem = [menuAdvanced addItemWithTitle:@"Notification click opens file"
									   action:@selector(notifyAction:)
								keyEquivalent:@""];
	[menuItem setState:[MainController getNotifyAction]==YES?1:0];
	[menuItem setTarget:self];
	[menuItem release];
	
	
	
	// Add To Items
	
//	menuItem = [menu addItemWithTitle:@"Пауза"
	menuItem = [menu addItemWithTitle:@"Pause"
							   action:@selector(actionPause:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	[menuItem release];
	
	// Add Separator
	[menu addItem:[NSMenuItem separatorItem]];
		
//	menuItem = [menu addItemWithTitle:@"Об InWatch"
	menuItem = [menu addItemWithTitle:@"About InWatch"
							   action:@selector(actionAbout:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	[menuItem release];
		
//	menuItem = [menu addItemWithTitle:@"Настройки"
	menuItem = [menu addItemWithTitle:@"Preferences"
							   action:@selector(openPreferences:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	
	[menu setSubmenu:menuAdvanced forItem:menuItem];
	
	[menuItem release];
	
//	menuItem = [menu addItemWithTitle:@"Статистика"
	menuItem = [menu addItemWithTitle:@"Statistics"
							   action:@selector(openStatistics:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
	[menuItem release];
	
	
	// Add Separator
	[menu addItem:[NSMenuItem separatorItem]];
	
	// Add Quit Action

//	menuItem = [menu addItemWithTitle:@"Выход"
	menuItem = [menu addItemWithTitle:@"Quit"
							   action:@selector(actionQuit:)
						keyEquivalent:@""];
	[menuItem setToolTip:@"Click to Quit InWatch"];
//	[menuItem setToolTip:@"Нажмите для выхода из InWatch"];
	[menuItem setTarget:self];
	[menuItem release];
	
	return menu;
}

- (void) initMenu:(id)sender {
	NSMenu *menu = [self createMenu];
	
	_statusItem = [[[NSStatusBar systemStatusBar]
					statusItemWithLength:NSSquareStatusItemLength] retain];
	
	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"MenuBar" ofType:@"png"];
	NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[_statusItem setImage:imageObj];
	[_statusItem setAlternateImage:imageObj];
	[_statusItem setMenu:menu];
	[_statusItem setHighlightMode:YES];
	[_statusItem setToolTip:@"InWatch:mac"];
	
	[menu release];
	[imageObj release];
	[imageName release];
}

@end
