//
//  ZipFile.h
//  ZippedImagesEtcetera
//
//  Created by Kenji Nishishiro  on 10/05/08.
//  Copyright 2010 Kenji Nishishiro. All rights reserved.
//

#import "minizip/unzip.h"

@interface ZipFile : NSObject {
	NSString *path_;
	unzFile unzipFile_;
}

- (id)initWithFileAtPath:(NSString *)path;
- (BOOL)open;
- (void)close;
- (NSData *)readWithFileName:(NSString *)fileName maxLength:(NSUInteger)maxLength;
- (NSArray *)fileNames;
@end