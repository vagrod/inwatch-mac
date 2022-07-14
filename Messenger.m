//
//  Messenger.m
//  InWatch
//
//  Created by Vagrod on 5/5/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "Messenger.h"
#import "ToolbarController.h"
#import "Growl.framework/Versions/A/Headers/GrowlApplicationBridge.h"

@implementation Messenger

extern BOOL notifyAction;

/* Init method */
- (id) init { 
    if ( self = [super init] ) {
        /* Tell growl we are going to use this class to hand growl notifications */
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    return self;
}

/* Begin methods from GrowlApplicationBridgeDelegate */
- (NSDictionary *) registrationDictionaryForGrowl { /* Only implement this method if you do not plan on just placing a plist with the same data in your app bundle (see growl documentation) */
    NSArray *array = [NSArray arrayWithObjects:@"InWatch Notification", @"error", nil]; /* each string represents a notification name that will be valid for us to use in alert methods */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:1], /* growl 0.7 through growl 1.1 use ticket version 1 */
                          @"TicketVersion", /* Required key in dictionary */
                          array, /* defines which notification names our application can use, we defined example and error above */
                          @"AllNotifications", /*Required key in dictionary */
                          array, /* using the same array sets all notification names on by default */
                          @"DefaultNotifications", /* Required key in dictionary */
                          nil];
    return dict;
}

- (void) growlNotificationWasClicked:(id)clickContext{
    if (clickContext && [clickContext isEqualToString:@"popUp_Click"])
        [self popUp_Click];
    return;
}

/* These methods are not required to be implemented, so we will skip them in this example 
 - (NSString *) applicationNameForGrowl;
 - (NSData *) applicationIconDataForGrowl;
 - (void) growlNotificationTimedOut:(id)clickContext;
 */ 
/* There is no good reason not to rely on the what Growl provides for the next two methods, in otherwords, do not override these methods
 - (void) growlIsReady;
 - (void) growlIsInstalled;
 */
/* End Methods from GrowlApplicationBridgeDelegate */

/* Simple method to make an alert with growl that has no click context */
-(void) growlAlert:(NSString *)message title:(NSString *)title icon: (NSImage *) icon{
    [GrowlApplicationBridge notifyWithTitle:title /* notifyWithTitle is a required parameter */
								description:message /* description is a required parameter */
						   notificationName:@"InWatch Notification" /* notification name is a required parameter, and must exist in the dictionary we registered with growl */
								   iconData:[icon TIFFRepresentation] /* not required, growl defaults to using the application icon, only needed if you want to specify an icon. */ 
								   priority:0 /* how high of priority the alert is, 0 is default */
								   isSticky:NO /* indicates if we want the alert to stay on screen till clicked */
							   clickContext:nil]; /* click context is the method we want called when the alert is clicked, nil for none */
}

/* Simple method to make an alert with growl that has a click context */
-(void) growlAlertWithClickContext:(NSString *)message title:(NSString *)title icon: (NSImage *) icon{
    [GrowlApplicationBridge notifyWithTitle:title /* notifyWithTitle is a required parameter */
                                description:message /* description is a required parameter */
                           notificationName:@"InWatch Notification" /* notification name is a required parameter, and must exist in the dictionary we registered with growl */
                                   iconData:[icon TIFFRepresentation] /* not required, growl defaults to using the application icon, only needed if you want to specify an icon. */ 
                                   priority:0 /* how high of priority the alert is, 0 is default */
                                   isSticky:NO /* indicates if we want the alert to stay on screen till clicked */
                               clickContext:@"popUp_Click"]; /* click context is the method we want called when the alert is clicked, nil for none */
}

/* An example click context */
-(void) popUp_Click{
	if (notifyAction){
		NSWorkspace *ws = [NSWorkspace sharedWorkspace];
		NSString * fn = [[self controller] getLastFile];
		[ws openFile:fn];
		[ws release];
	}else{
		/* code to execute when alert is clicked */
		NSWorkspace *ws = [NSWorkspace sharedWorkspace];
		NSString * fn = [[self controller] getLastFile];
		[ws selectFile:fn inFileViewerRootedAtPath:[fn stringByDeletingLastPathComponent]];
		[ws release];
	}
    return;
}

/* Dealloc method */
- (void) dealloc { 
    [super dealloc]; 
}

extern ToolbarController * MainController;
- (ToolbarController *) controller{
	return MainController;
}

/*


- (void) showPopUp: (NSString *)message withIcon: (NSImage *)icon{
	[MainController showPopUp:message withIcon:icon];
}


*/

@end
