//
//  Growl.h
//  InWatch
//
//  Created by Vagrod on 4/29/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import <Growl.framework/Headers/GrowlApplicationBridge.h>

@interface Growl :NSObject <GrowlApplicationBridgeDelegate> {} 
-(void) growlAlert:(NSString *)message title:(NSString *)title;
-(void) growlAlertWithClickContext:(NSString *)message title:(NSString *)title;
-(void) exampleClickContext;
@end
