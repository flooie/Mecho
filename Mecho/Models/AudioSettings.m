//
//  Settings.m
//  Alexa
//
//  Created by William Palin on 6/9/16.
//
//

#import "AudioSettings.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioSettings


+ (NSDictionary *)recordSettings {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: 1],
            AVNumberOfChannelsKey,
            [NSNumber numberWithFloat:16000.0],
            AVSampleRateKey, nil];
}

+ (NSString *)clientid {
    return @"amzn1.application-oa2-.....7";
}

+ (NSString *)client_secret {
    return @"8d....";
}

+ (NSString *)refresh {
    return @"Atzr|....";
}

+ (NSDictionary *)contentDictionary {
    NSMutableDictionary *contentDictionary = [[NSMutableDictionary alloc]init];
    [contentDictionary setValue:[AudioSettings clientid] forKey:@"client_id"];
    [contentDictionary setValue:[AudioSettings client_secret] forKey:@"client_secret"];
    [contentDictionary setValue:[AudioSettings refresh] forKey:@"refresh_token"];
    [contentDictionary setValue:@"refresh_token" forKey:@"grant_type"];
    return contentDictionary;
}


@end
