//
//  FileWorker.h
//  InWatch
//
//  Created by Vagrod on 4/29/10.
//  Copyright 2010 Vagrod Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FileWorker : NSObject {
	NSString *File;
	NSString *Destination;
	BOOL Busy;
	NSOperationQueue * theQueue;
	NSInvocationOperation * theOp;
}

@property(nonatomic, copy) NSString *File;
@property(nonatomic, copy) NSString *Destination;
@property BOOL MoveFiles;
@property BOOL Busy;
@property int ParentId;

- (void) ProcessFile: (id) sender;
void SetFileAndDestination(NSString * file, NSString * destination, BOOL move);
//- (BOOL) isBusy;
- (void) initWithFile: (NSString *) file andDestination: (NSString *)destination andMoveFiles: (BOOL) move andParent: (int) parentid ;
- (void) ProcessFileInvoke:(id)param;
-(NSInteger) MessageBoxQuestion:(NSString *)_message withInformativeText:(NSString *)_inf withYesText: (NSString *) _yes withNoText: (NSString *) _no;

@end
