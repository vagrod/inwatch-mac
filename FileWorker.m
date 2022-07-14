//
//  FileWorker.m
//  InWatch:mac
//
//  Created by Vagrod on 4/29/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import "FileWorker.h"
#import "Messenger.h"
#import "TagReader.h"
#import "ZipFile.h"
#import "FolderItem.h"
#import "WatcherItem.h"

@implementation FileWorker

@synthesize File;
@synthesize Destination;
@synthesize MoveFiles;
@synthesize Busy;
@synthesize ParentId;

NSString * File;
NSString * Destination;
BOOL MoveFiles;
BOOL Busy;

extern NSMutableArray * Folders;

-(unsigned int) InStr:(NSString *) s chr: (char) searchChar {
	NSRange searchRange;
	searchRange.location=(unsigned int)searchChar;
	searchRange.length=1;
	NSRange foundRange = [s rangeOfCharacterFromSet:[NSCharacterSet characterSetWithRange:searchRange]];
	return foundRange.location;
}

- (int) IndexOf: (NSMutableArray *)arr ofString:(NSString *)s{
	int ret = -1;
	
	for (NSString * i in arr){
		ret++;
		if ([i isEqualToString:s])return ret;
	}
	
	return -1;
}

- (void)ProcessFileInvoke:(id)param{
	printf("ProcessFile: started routine for file\n");
	Messenger * m = [[Messenger alloc] init];
	NSFileManager * man = [NSFileManager defaultManager];
	NSString * FileName = [self.File lastPathComponent];
	NSString * toPath = [self.Destination stringByAppendingPathComponent:FileName];
	BOOL moved;
	NSNumber * size = [NSNumber numberWithUnsignedLongLong:1];
	NSNumber * lastSize = [NSNumber numberWithUnsignedLongLong:0];
	int c = 0;
	Busy = YES;
	[self setBusy:YES];
	[[m controller] setBusyCount:[[m controller] getBusyCount] + 1];
	
	printf("	ProcessFile: waiting for file to lock off\n");
	
	NSDictionary * attr = [man attributesOfItemAtPath:self.File error:nil];
	
	while ([size unsignedLongLongValue] != [lastSize unsignedLongLongValue]) {
		[attr release];
		[lastSize release];
		lastSize = [NSNumber numberWithUnsignedLongLong:[size unsignedLongLongValue]];
		[NSThread sleepForTimeInterval:3];
		
		attr = [man attributesOfItemAtPath:self.File error:nil];
		
		[size release];
		size = (NSNumber *)[attr objectForKey:NSFileSize];
		c++;
	}
	
	
	if ([self.File isLike:@"*.mp3"]){
		if([[m controller] getUseSmartMusic]){
			@try {
				NSString * art = [TagReader readMP3artist:self.File];
				
				NSLog(@"%@", art);
				
				if (![art isEqualToString:@""]){
					// Has artist
					art = [art stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					art = [art stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
					art = [art stringByReplacingOccurrencesOfString:@"~" withString:@"_"];
					
					NSString * fn = [toPath lastPathComponent];
					
					toPath = [toPath stringByDeletingLastPathComponent];
					toPath = [toPath stringByAppendingPathComponent:art];
					
					[[NSFileManager defaultManager] createDirectoryAtPath:toPath attributes:nil];
					
					toPath = [toPath stringByAppendingPathComponent:fn];
				}
			}
			@catch (NSException * e) {
				// Do Nothing
			}
		}
	}
	if ([self.File isLike:@"*.zip"]){
		if([[m controller] getUseSmartArchive]){
			@try {
				int c = 0;
				NSArray * fn;
				ZipFile * z = [[ZipFile alloc] initWithFileAtPath:self.File];
				
				[z open];
				
				fn = [z fileNames];
				
				NSMutableArray * exts = [NSMutableArray new];
				
				for (NSString * f in fn){
					NSLog(@"File in archive: %@", f);
					
					c ++;
					NSString * ext = [f pathExtension];
					
					if (![ext isEqualToString:@""]){
						//Not a folder
						[exts addObject:ext];
					}
					if (c > 100) break;
				}
				
				NSMutableArray * counts = [NSMutableArray new];
				NSMutableArray * cl = [NSMutableArray new];
				
				for (NSString * l in exts){
					int n = [self IndexOf:cl ofString:l];
					
					if (n > -1){
					}else{
						[counts addObject:[NSNumber numberWithInteger:0]];
						[cl addObject:l];
						n = [cl count] - 1;
						NSLog(@"Ext added: %@", l);
					}
					NSNumber * cur = (NSNumber *)[counts objectAtIndex:n];
					NSNumber * nw = [NSNumber numberWithInteger:[cur intValue] + 1];
					
					[counts replaceObjectAtIndex:n withObject:nw];
					
					[cur release];
					[nw release];
				}
				
				NSString * myExt;
				int max = 0;
				int myInd = -1;
				int ind = -1;
				
				for (NSNumber * cnt in counts){
					ind++;
					if ([cnt intValue] > max){
						max = [cnt intValue];
						myInd = ind;
					}
				}
				
				myExt = (NSString *)[cl objectAtIndex:myInd];
				BOOL found = NO;
				
				myExt = [@"any." stringByAppendingString:myExt];
				
				for (FolderItem * fld in Folders){
					if ([fld Id] == [self ParentId]){
						for (WatcherItem * wt in [fld Watchers]){
							for (NSString * ex in [wt Types]){
								if ([myExt isLike:ex]){
									if (![ex isEqualToString:@"*.*"]){
										found = YES;
										NSInteger res;
										
										NSString * msg = [NSString stringWithFormat:@"The archive %@ contains mostly .%@ files, for whitch was found associated watcher. Move this archive to a folder for .%@?", [self.File lastPathComponent], [myExt stringByReplacingOccurrencesOfString:@"any." withString:@""], [myExt stringByReplacingOccurrencesOfString:@"any." withString:@""]];
										res = [self MessageBoxQuestion:@"InWatch: Smart Archive" withInformativeText:msg withYesText:@"Yes" withNoText:@"No, move to archives location"];
										
//										NSString * msg = [NSString stringWithFormat:@"Архив %@ содержит в основном файлы .%@, для которых назначен монитор. Переместить архив в папку для файлов .%@?", [self.File lastPathComponent], [myExt stringByReplacingOccurrencesOfString:@"any." withString:@""], [myExt stringByReplacingOccurrencesOfString:@"any." withString:@""]];
//										res = [self MessageBoxQuestion:@"InWatch: Анализ архива" withInformativeText:msg withYesText:@"Да" withNoText:@"Нет, переместить в папку для архивов"];
										
										if (res == NSAlertDefaultReturn){
											NSString * file = [toPath lastPathComponent];
									
											toPath = [wt DestinationFolder];
											toPath = [toPath stringByAppendingPathComponent:file];
										}
										break;
									}
								}
							}
							if (found) break;
						}
					}
					if (found) break;
				}
				
				[myExt release];
				[exts release];
				[cl release];
				[counts release];
				[z close];
				[z release];
				
			}
			@catch (NSException * e) {
				// Do Nothing
				NSLog(@"Exception when analysing archive: %@", [e reason]);
			}
		}
	}
	
	printf("	ProcessFile: waiting completed atfer %d seconds\n", c * 2);
	
	if ([man fileExistsAtPath:toPath] == YES) {
		printf("	ProcessFile: removing existing file\n");
		[man removeItemAtPath:toPath error:nil];
	}
	
	NSString * shortName = [self.File lastPathComponent];
	
	if (! self.MoveFiles) {
		printf("	ProcessFile: copying source file\n");
		moved = [man copyItemAtPath:self.File toPath:toPath error:nil];
		
		NSImage * ico = [[NSWorkspace sharedWorkspace] iconForFileType:[shortName pathExtension]];
		NSString* imageName = [[NSBundle mainBundle] pathForResource:@"IconSmall" ofType:@"png"];
		NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
		ico = [[m controller] resizeImage:ico toSize:NSMakeSize(24, 24)];
		[[m controller] setFilesMoved:[[m controller] getFilesMoved] + 1];
		[[m controller] setLastFile:toPath];
		
//		[m growlAlertWithClickContext:@"Файл был скопирован" title:shortName icon:[[m controller] overlayImage:imageObj with:ico withOffset:NSMakePoint(4, 0)]];
		[m growlAlertWithClickContext:@"File was copied" title:shortName icon:[[m controller] overlayImage:imageObj with:ico withOffset:NSMakePoint(4, 0)]];
		[ico release];
		[imageName release];
		[imageObj release];
	}else{
		printf("	ProcessFile: moving source file\n");
		moved = [man moveItemAtPath:self.File toPath:toPath error:nil];
		
		if (moved){
			NSImage * ico = [[NSWorkspace sharedWorkspace] iconForFileType:[shortName pathExtension]];
			NSString* imageName = [[NSBundle mainBundle] pathForResource:@"IconSmall" ofType:@"png"];
			NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
			ico = [[m controller] resizeImage:ico toSize:NSMakeSize(24, 24)];
			[[m controller] setFilesMoved:[[m controller] getFilesMoved] + 1];
			[[m controller] setLastFile:toPath];
			
//			[m growlAlertWithClickContext:@"Файл был перемещен" title:shortName icon:[[m controller] overlayImage:imageObj with:ico withOffset:NSMakePoint(4, 0)]];
			[m growlAlertWithClickContext:@"File was moved" title:shortName icon:[[m controller] overlayImage:imageObj with:ico withOffset:NSMakePoint(4, 0)]];
			[ico release];
			[imageName release];
			[imageObj release];
		}
	}
	
	Busy = NO;
	[self setBusy:NO];
	[[m controller] setBusyCount:[[m controller] getBusyCount] - 1];
	
	[man release];
	[attr release];
	[FileName release];
	[toPath release];
	[size release];
	[lastSize release];
	[m release];
	
	printf("ProcessFile: done.\n");
}

-(NSInteger) MessageBoxQuestion:(NSString *)_message withInformativeText:(NSString *)_inf withYesText: (NSString *) _yes withNoText: (NSString *) _no{
	NSAlert * alert = [NSAlert alertWithMessageText:_message defaultButton:_yes alternateButton:_no otherButton:nil informativeTextWithFormat:_inf];
	
	return [alert runModal];
	
	//[alert beginSheetModalForWindow:[searchField window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

NSOperationQueue * theQueue;
NSInvocationOperation * theOp;

/*
 Starting watcher process in a separate thread
 
 Created at 04/30/2010 Vagrod
 */
- (void) ProcessFile: (id) sender{
	theQueue = [[[NSOperationQueue alloc] init] autorelease];
	
	theOp = [[[NSInvocationOperation alloc] initWithTarget:self
												  selector:@selector(ProcessFileInvoke:)
													object:nil] autorelease];
	[theQueue addOperation:theOp];
}

void SetFileAndDestination(NSString * file, NSString * destination, BOOL move){
	File = [NSString stringWithString:file];
	Destination = [NSString stringWithString:destination];
	MoveFiles = move;
}

- (void) initWithFile: (NSString *) file andDestination: (NSString *)destination andMoveFiles: (BOOL) move andParent: (int) parentid {
	self.File = [NSString stringWithString:file];
	self.MoveFiles = move;
	self.Destination = [NSString stringWithString:destination];
	[self setParentId:parentid];
	SetFileAndDestination(file, destination, move);
    [self ProcessFile:self];
}

@end
