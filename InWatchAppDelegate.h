//
//  InWatchAppDelegate.h
//  InWatch:mac
//
//  Created by Vagrod on 4/26/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GlobalWatcher.h"

@interface InWatchAppDelegate : NSObject {
    IBOutlet NSWindow *window;
    IBOutlet NSToolbarItem *goBack;
    IBOutlet NSToolbarItem *newWatcher;
    IBOutlet NSToolbarItem *newFolder;
    IBOutlet NSToolbarItem *refreshWatchers;
    IBOutlet NSImageView *imageApp;
}
- (IBAction)refreshWatchers_Click:(id)sender;
//- (NSMutableArray *) Monitors;

@property (assign) IBOutlet NSWindow *window;
//@property (retain) GlobalWatcher * TotalWatcher;

@end
