//
//  WatcherWriter.m
//  InWatch
//
//  Created by Vagrod on 5/4/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "WatcherWriter.h"
#import "WatcherItem.h"
#import "FolderItem.h"

@implementation WatcherWriter

extern id window;

NSString * _ArrayToNSString(NSMutableArray * a){
	NSString * ret = @"";
	
	for (NSString * s in a){
		ret = [ret stringByAppendingFormat:@"%@;", s];
	}
	
	if ([ret isEqualToString:@""]) return @"";
	
	ret = [ret substringToIndex:[ret length] - 1];
	
	return ret;
}

- (void) writeWatchers: (NSMutableArray *) watchers{
	NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"Folders"];
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
	
//	[xmlDoc op]
	
	[xmlDoc setVersion:@"1.0"];
	[xmlDoc setCharacterEncoding:@"UTF-8"];
	
	int i;
	for (i = 0; i < [watchers count]; i++){
		FolderItem *folder = [watchers objectAtIndex:i];
		NSXMLElement *folderElement = [NSXMLNode elementWithName:@"Folder"];
		[root addChild:folderElement];
		
		NSXMLElement *pathElement = [NSXMLNode elementWithName:@"Path"];
		[pathElement setStringValue:[folder Folder]];
		[folderElement addChild:pathElement];
		
		for (WatcherItem * w in [folder Watchers]){
			NSXMLElement *watcherElement = [NSXMLNode elementWithName:@"Watcher"];
			[folderElement addChild:watcherElement];
			
			NSXMLElement *watcherFolderElement = [NSXMLNode elementWithName:@"Destination"];
			[watcherFolderElement setStringValue:[w DestinationFolder]];
			[watcherElement addChild:watcherFolderElement];
			
			NSXMLElement *watcherTypesElement = [NSXMLNode elementWithName:@"Types"];
			[watcherTypesElement setStringValue:_ArrayToNSString([w Types])];
			[watcherElement addChild:watcherTypesElement];
			
			NSXMLElement *watcherExceptionsElement = [NSXMLNode elementWithName:@"Exceptions"];
			[watcherExceptionsElement setStringValue:_ArrayToNSString([w Exceptions])];
			[watcherElement addChild:watcherExceptionsElement];
			
			NSXMLElement *watcherMoveElement = [NSXMLNode elementWithName:@"MoveFiles"];
			[watcherMoveElement setStringValue:[w MoveFiles] == YES?@"YES":@"NO"];
			[watcherElement addChild:watcherMoveElement];
			
			NSXMLElement *watcherPausedElement = [NSXMLNode elementWithName:@"Paused"];
			[watcherPausedElement setStringValue:[w Paused] == YES?@"YES":@"NO"];
			[watcherElement addChild:watcherPausedElement];
		}
	}

	NSData * dt = [xmlDoc XMLData];
	
	[dt writeToURL: [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"xml"]] atomically:YES];
	
	[root release];
	[xmlDoc release];
	[dt release];
	
	[window setDocumentEdited:NO];
}

- (void) writeSettings: (BOOL) notifyAct useSmartMusic:(BOOL) smartmusic useSmartArchive: (BOOL) smartarchive{
	NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"MonitorSettings"];
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
	
	//	[xmlDoc op]
	
	[xmlDoc setVersion:@"1.0"];
	[xmlDoc setCharacterEncoding:@"UTF-8"];
	
	NSXMLElement *notifyElement = [NSXMLNode elementWithName:@"NotifyAction"];
	[notifyElement setStringValue:notifyAct==YES?@"YES":@"NO"];
	[root addChild:notifyElement];
	
	NSXMLElement *smartMusic = [NSXMLNode elementWithName:@"SmartMusic"];
	[smartMusic setStringValue:smartmusic==YES?@"YES":@"NO"];
	[root addChild:smartMusic];
	
	NSXMLElement *smartArchive = [NSXMLNode elementWithName:@"SmartArchive"];
	[smartArchive setStringValue:smartarchive==YES?@"YES":@"NO"];
	[root addChild:smartArchive];
	
	NSData * dt = [xmlDoc XMLData];
	
	[dt writeToURL: [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Monitor" ofType:@"xml"]] atomically:YES];
	
	[root release];
	[xmlDoc release];
	[dt release];
	
	[window setDocumentEdited:NO];
}

@end
