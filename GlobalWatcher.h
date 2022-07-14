//
//  GlobalWatcher.h
//  InWatch
//
//  Created by Vagrod on 5/6/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCEventListenerProtocol.h"
#import "SCEvents.h"
#import "SCEvent.h"

@interface GlobalWatcher : NSObject <SCEventListenerProtocol> {
	
}

@property (retain) NSMutableArray * _Watchers;
@property (retain) SCEvents * events;

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event;
- (id) initWithWatchers: (NSMutableArray *) watchers; 
- (void) dispose;

@end
