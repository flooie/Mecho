//
//  Converter.m
//  Alexa
//
//  Created by William Palin on 6/8/16.
//
//

#import "Converter.h"

@implementation Converter


+ (NSData *)convertaudio :(AVURLAsset *)URLAsset :(todaystring)completionblock {
    NSError *error = nil ;
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:URLAsset error:&error];
    AVAssetReaderAudioMixOutput *audioMixOutput = [AVAssetReaderAudioMixOutput
                                                   assetReaderAudioMixOutputWithAudioTracks:[URLAsset tracksWithMediaType:AVMediaTypeAudio]
                                                   audioSettings:[Converter audioSettings]];
    
    if (![assetReader canAddOutput:audioMixOutput]) return NO ;
    [assetReader addOutput :audioMixOutput];
    
    if (![assetReader startReading]) {
        NSLog(@"NO");
        return NO;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"recx.wav"];
    NSURL *recxURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];

    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:recxURL
                                                          fileType:AVFileTypeWAVE
                                                             error:&error];
    
    AVAssetWriterInput *assetWriterInput = [ AVAssetWriterInput assetWriterInputWithMediaType :AVMediaTypeAudio
                                                                                outputSettings:[Converter audioSettings]];
	
	assetWriterInput. expectsMediaDataInRealTime = NO;
	if (![assetWriter canAddInput:assetWriterInput]) return NO ;
    [assetWriter addInput :assetWriterInput];
    if (![assetWriter startWriting]) return NO;
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    dispatch_queue_t queue = dispatch_queue_create( "assetWriterQueue", NULL );
    [assetWriterInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        while (TRUE)
        {
            if ([assetWriterInput isReadyForMoreMediaData] && (assetReader.status == AVAssetReaderStatusReading)) {
                CMSampleBufferRef sampleBuffer = [audioMixOutput copyNextSampleBuffer];
                if (sampleBuffer) {
                    [assetWriterInput appendSampleBuffer :sampleBuffer];
                    CFRelease(sampleBuffer);
                } else {
                    [assetWriterInput markAsFinished];
                    break;
                }
            }
        }
        [assetWriter finishWritingWithCompletionHandler:^{

        }];
        
    }];
    [NSThread sleepForTimeInterval:2];
    
    
    NSData *datum = [NSData dataWithContentsOfURL:recxURL];
    return completionblock(datum);

}


+ (AVURLAsset *)ravurlAsset:(NSURL *)fileURL {
    return [[AVURLAsset alloc] initWithURL:fileURL options:nil];
}

+ (NSDictionary * )audioSettings {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithFloat:16000.0], AVSampleRateKey,
            [ NSNumber numberWithInt:1], AVNumberOfChannelsKey,
            [ NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
            [ NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
            [ NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
            [ NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
            [ NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
            [ NSData data], AVChannelLayoutKey, nil ];
}

@end





//+ (BOOL)convertaudiofile:(AVURLAsset *)URLAsset :(myConversion) compblock{
//    NSError *error = nil ;
//
//    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:URLAsset error:&error];
//    AVAssetReaderAudioMixOutput *audioMixOutput = [AVAssetReaderAudioMixOutput
//                                                   assetReaderAudioMixOutputWithAudioTracks:[URLAsset tracksWithMediaType:AVMediaTypeAudio]
//                                                   audioSettings:[Converter audioSettings]];
//
//    if (![assetReader canAddOutput:audioMixOutput]) return NO ;
//    [assetReader addOutput :audioMixOutput];
//
//    if (![assetReader startReading]) {
//        NSLog(@"NO");
//        return NO;
//    }
//
//    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:@"/Users/Palin/Desktop/recx.wav"]
//                                                          fileType:AVFileTypeWAVE
//                                                             error:&error];
//
//    AVAssetWriterInput *assetWriterInput = [ AVAssetWriterInput assetWriterInputWithMediaType :AVMediaTypeAudio
//                                                                                outputSettings:[Converter audioSettings]];
//    assetWriterInput. expectsMediaDataInRealTime = NO;
//    if (![assetWriter canAddInput:assetWriterInput]) return NO ;
//    [assetWriter addInput :assetWriterInput];
//    if (![assetWriter startWriting]) return NO;
//    [assetWriter startSessionAtSourceTime:kCMTimeZero];
//    dispatch_queue_t queue = dispatch_queue_create( "assetWriterQueue", NULL );
//    [assetWriterInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
//        while (TRUE)
//        {
//            if ([assetWriterInput isReadyForMoreMediaData] && (assetReader.status == AVAssetReaderStatusReading)) {
//                CMSampleBufferRef sampleBuffer = [audioMixOutput copyNextSampleBuffer];
//                if (sampleBuffer) {
//                    [assetWriterInput appendSampleBuffer :sampleBuffer];
//                    CFRelease(sampleBuffer);
//                } else {
//                    [assetWriterInput markAsFinished];
//                    break;
//                }
//            }
//        }
//        [assetWriter finishWritingWithCompletionHandler:^{
//            NSLog(@"done?");
//            compblock(YES);
//        }];
//    }];
//
//    return YES;
//}
//

//    NSLog(@"stuff");
//    NSString *filepath = @"/Users/Palin/Desktop/recx.wav";
//    NSString *fp = @"/Users/Palin/Desktop/recording.caf";
//
//    NSData *datum = [NSData dataWithContentsOfFile:filepath];

//    [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
//    [[NSFileManager defaultManager] removeItemAtPath:fp error:&error];
