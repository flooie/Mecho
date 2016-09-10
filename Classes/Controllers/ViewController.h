//
//  ViewController.h
//  PostTest
//
//  Created by William Palin on 6/5/16.
//  Copyright © 2016 William Palin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VLCKit/VLCKit.h>
#import "Post.h"


@interface ViewController : NSViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, NSSpeechRecognizerDelegate, NSSpeechSynthesizerDelegate, VLCMediaPlayerDelegate, NSURLSessionDataDelegate> {
    VLCMediaPlayer *vlcplayer;
    NSMutableData *responseData;
    VLCMedia *stream;
}

@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, assign) BOOL isRecording;

@property (assign) IBOutlet NSTextField *rTextField;


- (void)storeInformation;

typedef void(^myCompletion)(BOOL);
typedef void(^postCompletion)(NSData*);
typedef void(^nextCompletion)(NSData*);

typedef void(^resetCompletion)(NSData*);

@property (nonatomic, strong) NSString *jsonResponse;
@property (nonatomic, strong) NSString *nextNavToken;

@property (nonatomic, strong) void(^completionHandler)(NSString *, NSInteger);


typedef NSData *(^todaystring)(NSData *);

@property (assign) IBOutlet NSTextField *timeleft;
@property (assign) IBOutlet NSTextField *timeElapsed;
@property (assign) IBOutlet NSTextField *jumpAround;

@end


