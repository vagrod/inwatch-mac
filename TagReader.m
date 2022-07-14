//
//  TagReader.m
//  InWatch
//
//  Created by Vagrod on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TagReader.h"


@implementation TagReader

+ (NSString *) readMP3artist: (NSString *) _filename{
	if (! _filename) return @"";
	if ([_filename isEqualToString:@""]) return @"";
	
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:_filename];
	NSDictionary*  dictionary  = [[NSFileManager defaultManager] attributesOfItemAtPath:_filename error:nil];
	uint64 filelen = [dictionary fileSize];
	
	if (filelen < 128) return @"";
	
	[fh seekToFileOffset:filelen-128];
	
	NSData *filePiece = [fh readDataOfLength: 128];
	Byte *byteData = (Byte*)malloc(128);
	
	memcpy(byteData, [filePiece bytes], 128);	
	
	char *chars =(char*)malloc(3);
	
	chars[0] = byteData[0];
	chars[1] = byteData[1];
	chars[2] = byteData[2];
	
	NSString * tag = [NSString stringWithCString:chars encoding:NSUTF8StringEncoding];
	NSString * artist = @"";
	
	int n=0;
	
	if ([tag isEqualToString:@"TAG"]){
		// Has tag
		for (int i = 33; i<62; i++){
			if (byteData[i] == 0) break;
			
			artist = [artist stringByAppendingString:[self getCyrillicChar:byteData[i]]];
			
			n++;
		}
		printf("\n");
		
		if (n == 0) {[fh closeFile]; return @"";}
	}
	
	[fh closeFile];
	
	return [NSString stringWithString:artist];
}

+ (NSString *) getCyrillicChar: (int) byte{
	switch (byte) {
		case 192:
			return @"А";
			break;
		case 193:
			return @"Б";
			break;
		case 194:
			return @"В";
			break;
		case 195:
			return @"Г";
			break;
		case 196:
			return @"Д";
			break;
		case 197:
			return @"Е";
			break;
		case 198:
			return @"Ж";
			break;
		case 199:
			return @"З";
			break;
		case 200:
			return @"И";
			break;
		case 201:
			return @"Й";
			break;
		case 202:
			return @"К";
			break;
		case 203:
			return @"Л";
			break;
		case 204:
			return @"М";
			break;
		case 205:
			return @"Н";
			break;
		case 206:
			return @"О";
			break;
		case 207:
			return @"П";
			break;
		case 208:
			return @"Р";
			break;
		case 209:
			return @"С";
			break;
		case 210:
			return @"Т";
			break;
		case 211:
			return @"У";
			break;
		case 212:
			return @"Ф";
			break;
		case 213:
			return @"Х";
			break;
		case 214:
			return @"Ц";
			break;
		case 215:
			return @"Ч";
			break;
		case 216:
			return @"Ш";
			break;
		case 217:
			return @"Щ";
			break;
		case 218:
			return @"Ъ";
			break;
		case 219:
			return @"Ы";
			break;
		case 220:
			return @"Ь";
			break;
		case 221:
			return @"Э";
			break;
		case 222:
			return @"Ю";
			break;
		case 223:
			return @"Я";
			break;
		case 224:
			return @"а";
			break;
		case 225:
			return @"б";
			break;
		case 226:
			return @"в";
			break;
		case 227:
			return @"г";
			break;
		case 228:
			return @"д";
			break;
		case 229:
			return @"е";
			break;
		case 230:
			return @"ж";
			break;
		case 231:
			return @"з";
			break;
		case 232:
			return @"и";
			break;
		case 233:
			return @"й";
			break;
		case 234:
			return @"к";
			break;
		case 235:
			return @"л";
			break;
		case 236:
			return @"м";
			break;
		case 237:
			return @"н";
			break;
		case 238:
			return @"о";
			break;
		case 239:
			return @"п";
			break;
		case 240:
			return @"р";
			break;
		case 241:
			return @"с";
			break;
		case 242:
			return @"т";
			break;
		case 243:
			return @"у";
			break;
		case 244:
			return @"ф";
			break;
		case 245:
			return @"х";
			break;
		case 246:
			return @"ц";
			break;
		case 247:
			return @"ч";
			break;
		case 248:
			return @"ш";
			break;
		case 249:
			return @"щ";
			break;
		case 250:
			return @"ъ";
			break;
		case 251:
			return @"ы";
			break;
		case 252:
			return @"ь";
			break;
		case 253:
			return @"э";
			break;
		case 254:
			return @"ю";
			break;
		case 255:
			return @"я";
			break;
	}
	
	char * c = (char *)malloc(1);
	c[0] = byte;
	
	return [NSString stringWithUTF8String:c];
}

@end
