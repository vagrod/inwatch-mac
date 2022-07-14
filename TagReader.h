//
//  TagReader.h
//  InWatch
//
//  Created by Vagrod on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TagReader : NSObject {

}

+ (NSString *) readMP3artist: (NSString *) _filename;
+ (NSString *) getCyrillicChar: (int) byte;

@end
