//
//  WatcherWriter.h
//  InWatch
//
//  Created by Vagrod on 5/4/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WatcherWriter : NSObject {

}

NSString * _ArrayToNSString(NSMutableArray * a);
- (void) writeWatchers: (NSMutableArray *) watchers;
- (void) writeSettings: (BOOL) notifyAct useSmartMusic:(BOOL) smartmusic useSmartArchive: (BOOL) smartarchive;

@end
