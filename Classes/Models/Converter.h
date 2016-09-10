//
//  Converter.h
//  Alexa
//
//  Created by William Palin on 6/8/16.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Converter : NSObject

//typedef void(^myConversion)(BOOL);

//+ (BOOL)convertaudiofile:(AVURLAsset *)URLAsset :(myConversion) compblock;

+ (AVURLAsset *)ravurlAsset:(NSURL *)fileURL;

typedef NSData *(^todaystring)(NSData *);
+ (NSData *)convertaudio :(AVURLAsset *)URLAsset :(todaystring)completionblock;


@end
