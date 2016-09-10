//
//  Post.h
//  Alexa
//
//  Created by William Palin on 6/9/16.
//
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

+ (NSMutableData *)postData:(NSData *)audioData;
+ (NSMutableData *)postNextData:(NSString *)navtoken;

@end
