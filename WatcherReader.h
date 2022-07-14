//
//  WatcherReader.h
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WatcherReader : NSObject {

}

typedef struct _IWSettings {
	BOOL SmartMusic;
	BOOL NotifyAction;
	BOOL SmartArchive;
} IWSettings;

NSMutableArray * _NSStringToArray(NSString * s);
- (NSMutableArray *) initWatchers;
- (IWSettings) readSettings;

@end
