//
//  AppController.h
//  InWatch:mac
//
//  Created by Vagrod on 4/26/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>

@interface AppController : NSObject {
    - (void)awakeFromNib{
		/* Define variables and create a CFArray object containing
		 CFString objects containing paths to watch.
		 */
		CFStringRef mypath = CFSTR("/");
		CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);
		void *callbackInfo = NULL; // could put stream-specific data here.
		FSEventStreamRef stream;
		CFAbsoluteTime latency = 3.0; /* Latency in seconds */
		
		/* Create the stream, passing in a callback */
		stream = FSEventStreamCreate(NULL,
									 &myCallbackFunction,
									 callbackInfo,
									 pathsToWatch,
									 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
									 latency,
									 kFSEventStreamCreateFlagNone /* Flags explained in reference */
									 );
	}
	
	- (void)myCallbackFunction{
	
	} 
}

@end

