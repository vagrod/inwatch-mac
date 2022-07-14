//
//  GlobalWatcher.m
//  InWatch
//
//  Created by Vagrod on 5/6/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "GlobalWatcher.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "WatcherItem.h"
#import "FileWatcher.h"

@implementation GlobalWatcher

@synthesize _Watchers;
@synthesize events;
//@synthesize _Events;

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event{
//	[event eventPath]
	for (FileWatcher * w in [self _Watchers]){
		NSString * p = [event eventPath];
		NSString * wp = [w Path];
		
		if ([wp isEqualToString:p]){
			//Watcher found for this path
			[w CheckForFile];
			//[w CheckForFile];
		}
		[p release];
		[wp release];
	}
}

- (void) dispose{
	[[self events] stopWatchingPaths];
	[[self events] release];
}

- (id) initWithWatchers: (NSMutableArray *) watchers{
	self = [super init];

	NSMutableArray * paths = [NSMutableArray new];
	events = [SCEvents sharedPathWatcher];
	[self set_Watchers:[NSMutableArray new]];
	
	[events setDelegate:self];
	
	for (FileWatcher * w in watchers){
		[[self _Watchers] addObject:w];

		int ind = [paths indexOfObject:[w Path]];

		if (ind == -1){
			NSString * p = [w Path];
	
			[paths addObject:p];
			[p release];
		}
	}

	[events startWatchingPaths:paths];
	[paths release];
	
	return self;
}


@end
