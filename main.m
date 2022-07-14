//
//  main.m
//  InWatch
//
//  Created by Vagrod on 4/15/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrayMenu.h"
#include <CoreServices/CoreServices.h> 

int main(int argc, char *argv[])
{
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];
	
    TrayMenu *menu = [[TrayMenu alloc] init];
    [NSApp setDelegate:menu];
    //[NSApp run];
	
    //return EXIT_SUCCESS;
	
    return NSApplicationMain(argc,  (const char **) argv);
	//[pool release];
}
