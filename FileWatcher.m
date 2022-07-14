//
//  FileWatcher.m
//  InWatch
//
//  Created by Vagrod on 4/28/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import "FileWatcher.h"
#import "FileWorker.h"


@implementation FileWatcher

@synthesize Path;
@synthesize LastFolderContents;
@synthesize Exceptions;
@synthesize Types;
@synthesize MoveFiles;
@synthesize Destination;
@synthesize Id;
@synthesize ParentId;

//FSEventStreamRef WatcherStream;
NSString *Path;
NSMutableArray * LastFolderContents;
NSMutableArray *Exceptions;
NSMutableArray *Types;
NSString * Destination;
int Id;

BOOL MoveFiles;

- (void) dispose{
	//FSEventStreamStop([self WatcherStream]);
}

/* 
 Initializes Watcher instance. 
	path: Path to watch
 
 Created at 04/28/2010 Vagrod
 */
- (void)initWithPath: (NSString *) path andDestination: (NSString *) dest andTypes: (NSMutableArray *) t andExceptions: (NSMutableArray *) e andMoveFiles: (BOOL) move andParent: (int) parentid {
	[self setPath:[NSString stringWithString:path]];
	Path = [NSString new];
	Path = [[NSString stringWithString:path] retain];
	[self setParentId:parentid];
	Id = rand();
	self.Id = Id;
	self.Path = [NSString stringWithString:path];
	self.Destination = [NSString stringWithString:dest];
	self.Types = t;
	self.Exceptions = e;
	self.MoveFiles = move;
	self.LastFolderContents = GetFilesInDirectory(self.Path);
	SetPathAndFolders(self.Path, self.LastFolderContents, self.Destination, self.Types, self.Exceptions, self.MoveFiles, self.Id);
	[self setLastFolderContents:self.LastFolderContents];
	//[self InitFS]; 
}

void SetPathAndFolders(NSString *p, NSMutableArray *f, NSString *d, NSMutableArray * t, NSMutableArray * e, BOOL move, int ID){
	Path = p;
	LastFolderContents = f;
	Destination = d;
	Types = t;
	Exceptions = e;
	MoveFiles = move;
	Id = ID;
}

/* 
 Returns YES if given file already exists in a given collection. 
	file: file to check (full path) 
	inCollection: files to look at
 
 Created at 04/28/2010 Vagrod
 */
BOOL HasFile(NSString *file, NSMutableArray *inCollection){
	int count = [inCollection count];
	
	for (int i = 0; i < count; i++){
		if ([(NSString *)[inCollection objectAtIndex:i] isEqualToString:file]) {
			return YES;
		}
	}
	
	return NO;
}

/* 
 Gets list of files in a given directory (not in subfolders) 
	path: path to look at
 
 Created at 04/28/2010 Vagrod
 */
NSMutableArray * GetFilesInDirectory(NSString * path){
	//int count = 0;
	NSMutableArray * ret = [NSMutableArray new];
	//NSString * file;
	//NSString * FullPath;
	
	NSArray * a = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
	
	for (NSString * s in a){
		[ret addObject:s];
	}
	
	[a release];
	return ret;
}

- (NSMutableArray *) GetNewFilesInDirectory: (NSMutableArray *) current withLastCollection:(NSMutableArray *) inCollection{
	int count = [current count];
	NSMutableArray *ret = [NSMutableArray new];
	
	for (int i = 0; i < count; i++){
		if (! HasFile([current objectAtIndex:i], inCollection)){
			//New file found, addind to result
			[ret addObject:[current objectAtIndex:i]];
		}
	}
	
	return ret;
}

- (void) CheckForFile{
	int i; 
	
	//Need to check for new files
	NSMutableArray *curFiles = GetFilesInDirectory(Path);
	//NSMutableArray *newFiles;
		
	//Need to compare files with lastest collection
	//newFiles = [self GetNewFilesInDirectory:[NSMutableArray arrayWithArray:curFiles] withLastCollection:[NSMutableArray arrayWithArray:LastFolderContents]];
	
	int count = [curFiles count];
	NSMutableArray *newFiles = [NSMutableArray new];
	
	for (int i = 0; i < count; i++){
		if (! HasFile([curFiles objectAtIndex:i], LastFolderContents)){
			//New file found, addind to result
			[newFiles addObject:[curFiles objectAtIndex:i]];
		}
	}
	
	//Remember current file states
	SetPathAndFolders(Path, [NSMutableArray arrayWithArray:curFiles], Destination, Types, Exceptions, MoveFiles, Id);
	
	NSLog(@"Path changed for Id %i: %@", Id, Path);
	
	//No new files, ignore event
	if ([newFiles count] == 0) return;
		
	count = [newFiles count];
	
	for (i = 0; i < count; i++){
		NSString *file = [NSString stringWithString:[newFiles objectAtIndex:i]];
		BOOL fFound = NO;
		
		for (NSString * ext in Types){
			if ([file isLike:ext]){
				fFound = YES;
			}
		}
		
		for (NSString * ext in Exceptions){
			if ([file isLike:ext]){
				fFound = NO;
			}
		}
		
		if (! fFound) {
			[file release];
			continue;
		}
		
		printf("FileEventHandler: new file found\n");
		
		//TODO: start FileWorker for file
		printf("	FileEventHandler: starting worker for file\n");
		FileWorker *w = [[[FileWorker alloc] init] autorelease];
		
//		[file isLike:]
		NSString * fullpath = [Path stringByAppendingPathComponent:file];
		
		[w initWithFile:fullpath andDestination:Destination andMoveFiles:MoveFiles andParent:[self ParentId]];
		
		printf("FileEventHandler: done.\n");
		
		//Add new file to last files collection
		[LastFolderContents addObject:[NSString stringWithString:[newFiles objectAtIndex:i]]];
		
		[fullpath release];
		[curFiles release];
		[file release];
	}
	
	[newFiles release];
}
	
@end
