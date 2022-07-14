//
//  FileWatcher.h
//  InWatch
//
//  Created by Vagrod on 4/28/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>

@interface FileWatcher : NSObject {

}

@property(retain) NSString *Path;
@property(retain) NSMutableArray *LastFolderContents;
@property(retain) NSMutableArray *Exceptions;
@property(retain) NSMutableArray *Types;
@property BOOL MoveFiles;
@property (retain) NSString * Destination;
@property int Id;
@property int ParentId;
//@property FSEventStreamRef WatcherStream;

- (void) dispose;

//void FileEventHandler(ConstFSEventStreamRef streamRef,
//					  void *clientCallBackInfo,
//					  size_t numEvents,
//					  void *eventPaths,
//					  const FSEventStreamEventFlags eventFlags[],
//					  const FSEventStreamEventId eventIds[]);

- (void) CheckForFile;

void SetPathAndFolders(NSString *p, NSMutableArray *f, NSString *d, NSMutableArray * t, NSMutableArray * e, BOOL move, int ID);
NSMutableArray * GetFilesInDirectory(NSString * path);
- (NSMutableArray *) GetNewFilesInDirectory: (NSMutableArray *) current withLastCollection:(NSMutableArray *) inCollection;
//- (void) InitFS;
- (void)initWithPath: (NSString *) path andDestination: (NSString *) dest andTypes: (NSMutableArray *) t andExceptions: (NSMutableArray *) e andMoveFiles: (BOOL) move andParent: (int) parentid;
BOOL HasFile(NSString *file, NSMutableArray *inCollection);

@end
