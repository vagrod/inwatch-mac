//
//  WatcherItem.h
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WatcherItem : NSObject {
	
}

@property (retain) NSString * SourceFolder;
@property (retain) NSString * DestinationFolder;
@property (retain) NSMutableArray * Exceptions;
@property (retain) NSMutableArray * Types;
@property BOOL MoveFiles;
@property long Id;
@property BOOL Paused;
@property long ParentId;

- (id) init;

@end
