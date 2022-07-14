//
//  FolderItem.h
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WatcherItem.h"

@interface FolderItem : NSObject {
	
}

@property (retain) NSMutableArray * Watchers;
@property (retain) NSString * Folder;
@property long Id;

-(id) init;

@end
