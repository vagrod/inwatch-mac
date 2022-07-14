//
//  WatcherReader.m
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "WatcherReader.h"
#import "FolderItem.h"
#import "WatcherItem.h"

@implementation WatcherReader

NSMutableArray * _NSStringToArray(NSString * s){
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

- (IWSettings) readSettings{
	BOOL notifyAct;
	BOOL smartMusic;
	BOOL smartArchive;
	
	NSXMLDocument *xmlDoc;
	NSError *err=nil;
	NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Monitor" ofType:@"xml"]];
	
	xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:file options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
	if (xmlDoc == nil) {
		xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:file options:NSXMLDocumentTidyXML error:&err];
	}
	
	NSXMLElement *root = (NSXMLElement *)[xmlDoc rootElement];
	
	for (int i=0; i<[root childCount]; i++){
		NSXMLElement * e = (NSXMLElement *)[root childAtIndex:i];
		
		if ([[e name] isEqualToString:@"NotifyAction"]){
			notifyAct = [[e stringValue] isEqualToString:@"YES"]==YES?YES:NO;
		}
		
		if ([[e name] isEqualToString:@"SmartMusic"]){
			smartMusic = [[e stringValue] isEqualToString:@"YES"]==YES?YES:NO;
		}
		
		if ([[e name] isEqualToString:@"SmartArchive"]){
			smartArchive = [[e stringValue] isEqualToString:@"YES"]==YES?YES:NO;
		}
		
		[e release];
	}
	
	IWSettings ret;
	ret.SmartMusic = smartMusic;
	ret.NotifyAction = notifyAct;
	ret.SmartArchive = smartArchive;
	
	return ret;
}

- (NSMutableArray *) initWatchers{
	NSMutableArray * Folders;
	Folders = [NSMutableArray new];
	
	NSXMLDocument *xmlDoc;
	NSError *err=nil;
	NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"xml"]];

	xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:file options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
	if (xmlDoc == nil) {
		xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:file options:NSXMLDocumentTidyXML error:&err];
	}
	
	NSXMLElement *root = (NSXMLElement *)[xmlDoc rootElement];
	FolderItem * f = nil;
	
	for (int i=0; i<[root childCount]; i++){
		NSXMLElement * e = (NSXMLElement *)[root childAtIndex:i];
		
		if ([[e name] isEqualToString:@"Folder"]){
			if (f) [f release];
			
			f = [[FolderItem alloc] init];
			[f setWatchers:[NSMutableArray new]];
			[f setFolder:[[e childAtIndex:0] stringValue]];
			int wcnt = (int)[e childCount];
			
			for (int j=1;j<[e childCount];j++){
				if ([[[e childAtIndex:j] name] isEqualToString:@"Watcher"]){
					NSXMLElement * e2 ;
				
					NSString * dest;
					NSMutableArray * t;
					NSMutableArray * ex;
					BOOL move;
					BOOL paused;
					//int cn = [e2 childCount];
				
					e2 = (NSXMLElement *)[[e childAtIndex:j] childAtIndex:0];
					dest = [e2 stringValue];
				
					e2 = (NSXMLElement *)[[e childAtIndex:j] childAtIndex:1];
					NSString * st = [e2 stringValue];
				
					e2 = (NSXMLElement *)[[e childAtIndex:j] childAtIndex:2];
					NSString * se = [e2 stringValue];
				
					t = _NSStringToArray(st);
					ex = _NSStringToArray(se);
				
					e2 = (NSXMLElement *)[[e childAtIndex:j] childAtIndex:3];
					move = [[e2 stringValue] isEqualToString:@"YES"]==YES?YES:NO;
					
					e2 = (NSXMLElement *)[[e childAtIndex:j] childAtIndex:4];
					paused = [[e2 stringValue] isEqualToString:@"YES"]==YES?YES:NO;
				
					WatcherItem * w = [[WatcherItem alloc] init];
					[w setTypes:t];
					[w setExceptions:ex];
					[w setDestinationFolder:dest];
					[w setSourceFolder:[f Folder]];
					[w setMoveFiles:move];
					[w setPaused:paused];
					[w setParentId:[f Id]];
				
					[[f Watchers] addObject:w];
				
					[w release];
					[dest release];
					[t release];
					[ex release];
				}
			}
			
			[Folders addObject:f];
		}
		
		[e release];
	}
	
	[f release];
	
	return Folders;
}

@end
