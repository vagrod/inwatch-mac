//
//  FolderItem.m
//  InWatch
//
//  Created by Vagrod on 5/2/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FolderItem.h"


@implementation FolderItem

NSMutableArray * Watchers;
NSString * Folder;
long Id;

@synthesize Watchers;
@synthesize Folder;
@synthesize Id;

-(id) init{
	self = [super init];
	if (self){
		[self setId:rand()];
	}
	
	return self;
}

@end
