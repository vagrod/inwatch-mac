//
//  Messenger.h
//  InWatch
//
//  Created by Vagrod on 5/5/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolbarController.h"
#import "Growl.framework/Versions/A/Headers/GrowlApplicationBridge.h"

@interface Messenger :NSObject <GrowlApplicationBridgeDelegate> {

}

-(void) growlAlert:(NSString *)message title:(NSString *)title icon: (NSImage *) icon;
-(void) growlAlertWithClickContext:(NSString *)message title:(NSString *)title icon: (NSImage *) icon;
-(void) popUp_Click;

- (ToolbarController *) controller;
//- (void) showPopUp: (NSString *)message withIcon: (NSImage *) icon;

@end
