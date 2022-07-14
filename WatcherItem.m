//
//  WatcherItem.m
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "WatcherItem.h"


@implementation WatcherItem

NSString * SourceFolder;
NSString * DestinationFolder;
NSMutableArray * Exceptions;
NSMutableArray * Types;
BOOL MoveFiles;
BOOL Paused;
long Id;
long ParentId;

@synthesize SourceFolder;
@synthesize DestinationFolder;
@synthesize Exceptions;
@synthesize Types;
@synthesize MoveFiles;
@synthesize Id;
@synthesize Paused;
@synthesize ParentId;

-(id) init{
	self = [super init];
	if (self){
		[self setId:rand()];
	}
	
	return self;
}

@end
