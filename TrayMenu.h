//
//  TrayMenu.h
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TrayMenu : NSObject {
@private
	NSStatusItem *_statusItem;
}

- (void) initMenu:(id)sender;

@end
