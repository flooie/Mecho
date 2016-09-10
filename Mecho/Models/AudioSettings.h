//
//  Settings.h
//  Alexa
//
//  Created by William Palin on 6/9/16.
//
//

#import <Foundation/Foundation.h>

@interface AudioSettings : NSObject


+ (NSDictionary *)recordSettings;
+ (NSString *)clientid;
+ (NSString *)client_secret;
+ (NSString *)refresh;
+ (NSDictionary *)contentDictionary;


@end
