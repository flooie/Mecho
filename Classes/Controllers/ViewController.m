//
//  ViewController.m
//  PostTest
//
//  Created by William Palin on 6/5/16.
//  Copyright © 2016 William Palin. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "Converter.h"
#import "AudioSettings.h"
#import "ParsedJson.h"

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"finishedRecording"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"finishedAudio"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"mediadidfinish"
                                               object:nil];

    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerTimeChanged:) name:VLCMediaPlayerTimeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerStateChanged:) name:VLCMediaPlayerStateChanged object:nil];

    [self blah:self];

    if ([ViewController timedif] > 3600){
        NSLog(@"greater than a 30 minutes - getting new token");
        [self blah:self];
    }
}

+ (double )timedif {
    NSDate *odate = [[NSUserDefaults standardUserDefaults] objectForKey:@"datetime"];
    NSDate *now = [NSDate date];
    NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:odate];
    return distanceBetweenDates;
}


- (IBAction)sendText:(id)sender {
    if ([ViewController timedif] > 3600){
        NSLog(@"greater than a 30 minutes - getting new token");
        [self blah:self];
    }

    [self writeTextToSpeech:[_rTextField stringValue]];
}


- (IBAction)play:(id)sender {
    if ([vlcplayer isPlaying]) {
        [vlcplayer pause];
        [self storeInformation];
    }
    else {
        [vlcplayer play];
    }
}

- (void)mediaDidFinish {
    NSString *nav = [[NSUserDefaults standardUserDefaults] objectForKey:@"navtoken"];
    [self postNext:nav :^(NSData *finished) {
        if(finished){
            NSLog(@"success finished sending");
            [vlcplayer stop];
            [_audioPlayer stop];

            [self playFile:[self parseResponse:finished]];
            [self findNextLink:finished];
            
            // if a podcast it works
            
            NSString *rString = [self streamURL:_jsonResponse];
            if ([rString containsString:@"opml.radiotime.com"]){
                [vlcplayer stop];
                [_audioPlayer stop];

                [self playStream:[self identifiedStream:rString]];
            };
        };
    }];

}

- (void)writeTextToSpeech:(NSString *)stringCommand {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"recording.caf"];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];

    NSSpeechSynthesizer *speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
    [speechSynth startSpeakingString:stringCommand toURL:fileURL];
    [NSThread sleepForTimeInterval:2];
    
    NSData *datax = [Converter convertaudio:[Converter ravurlAsset:fileURL] :^(NSData *xstring){
        return xstring;
    }];

    [self postAudio:datax :^(NSData *finished) {
        if(finished){
            NSLog(@"success finished sending");
            [self playFile:[self parseResponse:finished]];
            [self findNextLink:finished];
        };
    }];
}



- (void) receiveTestNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"finishedRecording"]){
        NSURL *furl = [[NSUserDefaults standardUserDefaults] URLForKey:@"recordingURL"];
        NSData *datum = [NSData dataWithContentsOfURL:furl];
        [self postAudio:datum :^(NSData *finished) {
            if(finished){
                NSLog(@"success finished recording");
                [self playFile:[self parseResponse:finished]];
                [self findNextLink:finished];
            }
            NSLog(@"next");
        }];
    }
    
    if ([[notification name] isEqualToString:@"finishedAudio"]){
        NSString *rString = [self streamURL:_jsonResponse];
        [self playStream:[self identifiedStream:rString]];
    }
    
    if ([[notification name] isEqualToString:@"mediadidfinish"]){
        [self mediaDidFinish];
    }

//    if ([[notification name] isEqualToString:@"triggerword"]){
//        NSLog(@"trigger");
//        [self record:self];
//    }
}

- (NSURL *)identifiedStream:(NSString *)rStream {
    if ([rStream containsString:@"opml.radiotime.com"] || ([rStream containsString:@"streamtheworld"])){
        NSString *nStream = [self getDataFrom:rStream];
        NSLog(@"jj %@",[NSURL URLWithString:nStream]);
        
        if ([nStream containsString:@"streamtheworld"]){
            NSString *nxStream = [self getDataFrom:nStream];
            NSLog(@" ");
            NSLog(@"the %@",nxStream);
            NSLog(@" ");
            return [NSURL URLWithString:nxStream];
        }

        if ([nStream hasSuffix:@".m3u"]) {
            return [NSURL URLWithString:[nStream substringToIndex:[nStream length]-4]];
        }
        else {
            return [NSURL URLWithString:nStream];
        }
        return [NSURL URLWithString:nStream];
    }
    return [NSURL URLWithString:rStream];
}

- (NSString *)streamURL:(NSString *)jsonString {
    if ([jsonString containsString:@"listen"]) {

        return nil;
    }
    return [[[jsonString componentsSeparatedByString: @"\"streamUrl\":\""] lastObject] componentsSeparatedByString:@"\""][0];
}

//- (NSURL *)parseForStream:(NSString *)jsonString {
//    
//    NSArray *chunks = [jsonString componentsSeparatedByString: @"\"streamUrl\":\""];
//    NSURL *url;
//    if (chunks.count > 1){
//        NSString *link_url = [chunks lastObject];
//        NSString *stream = [link_url componentsSeparatedByString:@"\""][0];
////        NSString *lookslike = [ViewController newRequest:[link_url componentsSeparatedByString:@"\""][0]];
//        NSString *lookslike = [self getDataFrom:[link_url componentsSeparatedByString:@"\""][0]];
//        lookslike = [lookslike stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//        NSURL *urlx = [NSURL URLWithString:lookslike];
//        NSLog(@"looks %@",lookslike);
//        NSLog(@"stream %@",stream);
//        if ([link_url containsString:@"cloudfront"]){
//            return [NSURL URLWithString:stream];
//        }
//        return urlx;
//    }
//    return url;
//}

- (IBAction)stop:(id)sender {
    [self storeInformation];
    [vlcplayer stop];
    [_audioPlayer stop];

}

- (IBAction)jumpjump:(id)sender {
    float position = [_jumpAround floatValue];
	
    [vlcplayer setPosition:position];
}

- (void)playStream:(NSURL *)url {
    NSLog(@"**** %@",url);
    if (url != NULL){
        NSLog(@"the url is ---> %@",url);
        [vlcplayer setDelegate:self];
        vlcplayer = [[VLCMediaPlayer alloc] init];
        stream = [VLCMedia mediaWithURL:url];
        [vlcplayer setMedia:stream];
        [vlcplayer play];
    }
}


- (void)playFile:(NSURL *)file {
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}


//

- (NSString *)findNextLink:(NSData *)response {
    NSString *requestReply = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
    _jsonResponse = requestReply;
    NSLog(@"json resposne %@",_jsonResponse);
    NSString *navtoken = [[[_jsonResponse componentsSeparatedByString: @"\"navigationToken\":\""] lastObject] componentsSeparatedByString:@"\""][0];
    
    [[NSUserDefaults standardUserDefaults] setObject:navtoken forKey:@"navtoken"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    return _jsonResponse;
}
//

- (NSURL *)parseResponse:(NSData *)response {
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"response.mp3"]];
    [response writeToURL:fileURL atomically:YES];
    return fileURL;
}

- (IBAction)stopPlaying:(id)sender {
    [self storeInformation];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"stop"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [vlcplayer stop];
    [_audioPlayer stop];
}

- (void)storeInformation {
    VLCTime *currentTime = vlcplayer.time;
    _timeElapsed.stringValue = [currentTime stringValue];
    float a = currentTime.intValue;
    float b = vlcplayer.media.length.intValue;
    float percent = (a/b);
    [[NSUserDefaults standardUserDefaults] setURL:vlcplayer.media.url forKey:@"stream"];
    [[NSUserDefaults standardUserDefaults] setFloat:percent forKey:@"position"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}


- (IBAction)record:(id)sender {
    NSLog(@"start recording");
    [self prepareAV];
    [self recordAudio:^(BOOL finished) {
        if(finished){
            NSLog(@"success finshed from record");
        }
    }];
}

- (IBAction)blah:(id)sender {
    
    [self resetSystem:@"string" :^(NSData *finished){
        NSString *data = [[NSString alloc] initWithData:finished encoding:NSASCIIStringEncoding];
        NSArray *chunks = [data componentsSeparatedByString: @"\""];
        [[NSUserDefaults standardUserDefaults] setObject:chunks[3] forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"datetime"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }];
}

- (IBAction)mark:(id)sender {
    float position = [[NSUserDefaults standardUserDefaults] floatForKey:@"position"];
    NSURL *url = [[NSUserDefaults standardUserDefaults] URLForKey:@"stream"];
    
    vlcplayer = [[VLCMediaPlayer alloc] init];
    [vlcplayer setDelegate:self];
    stream = [VLCMedia mediaWithURL:url];
    [vlcplayer setMedia:stream];
    [vlcplayer play];
    [vlcplayer setPosition:position];
}

- (void)prepareAV {
    NSError *error = nil;
    NSString *cp = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"recording.wav"];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:cp]];

    _audioRecorder = [[AVAudioRecorder alloc]initWithURL:
                                        fileURL
                                        settings:[AudioSettings recordSettings]
                                        error:&error];
    
    [[NSUserDefaults standardUserDefaults] setURL:fileURL forKey:@"recordingURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [_audioRecorder prepareToRecord];
}


- (void)recordAudio:(myCompletion) compblock{
    if (!_audioRecorder.recording) {
        _audioRecorder.delegate = self;
        [_audioRecorder recordForDuration:4];//Here i took record duration as 4 secs
    }
    compblock(YES);
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"recording did finish");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"finishedRecording"
     object:self];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Encode Error occurred");
}


- (void)postAudio:(NSData *)datum :(postCompletion)compblock {
    NSString *stringurl = @"https://access-alexa-na.amazon.com/v1/avs/speechrecognizer/recognize";
    NSMutableURLRequest *request = [ViewController request:[ViewController headerDictionary]:[Post postData:datum]:stringurl];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"the response is %@",response);
            compblock(data);
        }
    }];
    [dataTask resume];
}

- (void)postNext:(NSString *)navToken :(nextCompletion)compblock {
    NSString *stringurl = @"https://access-alexa-na.amazon.com/v1/avs/audioplayer/getNextItem";
    NSMutableURLRequest *request = [ViewController request:[ViewController nextDictionary]:[Post postNextData:navToken]:stringurl];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"the response is %@",response);
            compblock(data);
        }
    }];
    [dataTask resume];
}

//- (void)postNext:(NSString *)navToken {
//    NSString *stringurl = @"https://access-alexa-na.amazon.com/v1/avs/audioplayer/getNextItem";
//    NSMutableURLRequest *request = [ViewController request:[ViewController nextDictionary]:[Post postNextData:navToken]:stringurl];
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"%@", error);
//        } else {
//            NSLog(@"the response is %@",response);
//            
//        }
//    }];
//    [dataTask resume];
//}


+ (NSDictionary *)headerDictionary {
    return @{ @"Authorization": [NSString stringWithFormat:@"Bearer %@", [ViewController currentWorkingAuthCode]], @"Transfer-Encoding": @"chunked", @"Content-Type": @"multipart/form-data; boundary=someboundary" };
}

+ (NSDictionary *)nextDictionary {
    return @{ @"Authorization": [NSString stringWithFormat:@"Bearer %@", [ViewController currentWorkingAuthCode]], @"content-type": @"application/json; charset=UTF-8" };
}


+ (NSMutableURLRequest *)request:(NSDictionary *)headers :(NSMutableData *)postData :(NSString *)stringURL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:stringURL]
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    return request;
}

- (NSString *) getDataFrom:(NSString *)url{
    NSLog(@"$$$ %@",url);
    NSMutableURLRequest *requester = [[NSMutableURLRequest alloc] init];
    [requester setHTTPMethod:@"GET"];
    [requester setURL:[NSURL URLWithString:url]];
    NSError *error;
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:requester returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return nil;
    }
    
    NSString *receivedDataString = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"^^ %@",receivedDataString);
    NSArray *brokenByLines=[receivedDataString componentsSeparatedByString:@"\n"];
    NSLog(@"the response of the new request %@",brokenByLines);
    
        NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray* matches = [detector matchesInString:receivedDataString options:0 range:NSMakeRange(0, [receivedDataString length])];
        NSLog(@"matches are %@",matches);
        NSTextCheckingResult *match = matches[0];
        NSLog(@"%@ <-----",[match URL]);
        return [NSString stringWithFormat:@"%@",[match URL]];

}


- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}


+ (NSString *)currentWorkingAuthCode {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
}

+ (NSURL *)currentURL {
    return [NSURL URLWithString:@"https://access-alexa-na.amazon.com/v1/avs/speechrecognizer/recognize"];
}


- (void)resetSystem:(NSString *)file_path :(resetCompletion)compblock {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[AudioSettings contentDictionary] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonRequest = [[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:@"https://api.amazon.com/auth/o2/token"];
    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:jsonRequest forHTTPHeaderField:@"data"];
    [request setHTTPBody: requestData];

    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"the response is %@",response);
            compblock(data);
        }
    }];
    [dataTask resume];

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"finished playing ");
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"finishedAudio"
     object:self];
}

//- (void)URLSession:(NSURLSession *)session
//            dataTask:(NSURLSessionDataTask *)dataTask
//            didReceiveResponse:(NSURLResponse *)response
//            completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
//    
//    NSLog(@"blah");
//    completionHandler(NSURLSessionResponseAllow);
//    
//    //    receivedData=nil; receivedData=[[NSMutableData alloc] init];
//    //    [receivedData setLength:0];
//    
//    completionHandler(NSURLSessionResponseAllow);
//}
//
//
//
//-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
//    NSLog(@"data");
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    
//    [responseData setLength:0];
//    
//    NSLog(@"the repsonse is %@",response);
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//    if ([response respondsToSelector:@selector(allHeaderFields)]) {
//        NSDictionary *dictionary = [httpResponse allHeaderFields];
//        NSLog([dictionary description]);
//    }
//}
//
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    NSLog(@"asdfasdfasd %@",data);
//    [responseData appendData:data];
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
//{
//    NSLog(@"Connection failed! Error - %@ %@",
//          [error localizedDescription],
//          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    NSLog(@"BLAHH");
//}
//
//
//
//
- (void)speechtalklisten {
    NSSpeechRecognizer *listen;
    NSArray *cmds = [NSArray arrayWithObjects:@"alexa" ,nil];
    listen = [[NSSpeechRecognizer alloc] init];
    [listen setCommands:cmds];
    [listen setDelegate:self];
    [listen setListensInForegroundOnly:NO];
    [listen startListening];
    [listen setBlocksOtherRecognizers:YES];
}
//

- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd {
    NSLog(@"%@",aCmd);
    NSLog(@"called again and again");
    if ([(NSString *)aCmd isEqualToString:@"alexa"]) {
        NSLog(@"trigger word detected");
//        [[NSNotificationCenter defaultCenter]
//         postNotificationName:@"triggerword"
//         object:self];
//        [self record:self];

//        [self performSelector:@selector(record:)];
    }
    //    if ([(NSString *)aCmd isEqualToString:@"okay"]) {
    //        NSLog(@"stop");
    //        [self performSelector:@selector(stopPlaying:)];
    //    }

}









//- (void)testitup {
//    responseData = [[NSMutableData alloc] init];
//
//    NSString *client_id = @"amzn1.application-oa2-client.77374bfcb33148cf92b6703429dc6ab7";
//    NSString *client_secret = @"84e6f9b2ce1a35afc46fd777eee18355fb3e217d14e87b2ed105a25455ed8883";
//    NSString *refresh = @"Atzr|IQEBLjAsAhQeMqLGYx9tYTijVTAMThlBUl1pkQIUKzJr4k6zMKmA1OWZr_cvlHIVxMFU6zWMMWcQgG_BLFNJZ6nF6vZexU4VGL0Y7kJsXu2H6ho3z1TnHOlSXudhBr4V3b2LIKQs6qdIvm3hJXhIdkawqtSckCr_61m-kl7KPe3JCwm18yCKZzfPzd64Enz969JKosxwEggqRyZZVzPNeS6RyGFgJCHte2sx6XZhbacQ0_qMGbiQyK58R5rbME9D50kgcEdODaFiiRuUJoFDkN6YDmDP5P8OWshmyEf-mroHgIocqBWJiTVgk2RKyyj4mKO9T_kAImB2_RtEopx_MjN7fE62CFqUv_SStSsYo5H1_Hza8zMhECsD_-6jLl_vGrHaVHJI-g7EKPUsLgCs3SUdDkc6BaWZLWJiwdssoMbTAZ9dL-HVdQeHnTnIZ5WDjQeBoV3f2YaLAd9kgz4FkpmfsqRiennapulUSGFcM7kADacsduxSqPfPDTYPwsG1QLEM2I5sDHkxf54JzS8aD7X40_-hTtrqTjRWWD2RYUHuglc";
//
//    NSMutableDictionary *contentDictionary = [[NSMutableDictionary alloc]init];
//    [contentDictionary setValue:client_id forKey:@"client_id"];
//    [contentDictionary setValue:client_secret forKey:@"client_secret"];
//    [contentDictionary setValue:refresh forKey:@"refresh_token"];
//    [contentDictionary setValue:@"refresh_token" forKey:@"grant_type"];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:contentDictionary options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonRequest = [[NSString alloc] initWithData:data
//                                                  encoding:NSUTF8StringEncoding];
//
//    NSURL *url = [NSURL URLWithString:@"https://api.amazon.com/auth/o2/token"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
//                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
//
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:jsonRequest forHTTPHeaderField:@"data"];
//    [request setHTTPBody: requestData];
//
//    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//    [connection start];
//
//}

//    [Converter convertaudiofile:[Converter ravurlAsset:fp] :^(BOOL yesNo){
//        NSLog(@"yesNo");
//    }];
//
//    [Converter convertaudiofile:[Converter ravurlAsset:fp]: ^(BOOL yesNo) {
//        NSLog(@"yes no");
//        NSString *filepath = @"/Users/Palin/Desktop/recx.wav";
//
//        [self postAudio:(NSString *)filepath :^(NSData *finished) {
//            if(finished){
//                NSLog(@"success finished sending");
//
//                [self playFile:[self parseResponse:finished]];
//                [self findNextLink:finished];
//
//                NSError *error;
//                [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
//                [[NSFileManager defaultManager] removeItemAtPath:fp error:&error];
////                if (error.code != NSFileNoSuchFileError) {
////                    NSLog(@"%@", error);
////                }
//            };
//        }];
//    }];
//
//    NSLog(@"dataum is %@",datum);


//    NSData *teststring = [self returnthisdarnstring :@"anotherstring" :^(NSData *xstring) {
//        NSData *datum;
//        return datum;
//    }];
//
//    NSLog(@"%@",teststring);
//
//    NSString *fp = [@"~/Desktop/recording.caf" stringByExpandingTildeInPath];
//
//    NSData *datax = [Converter convertaudio:[Converter ravurlAsset:fp] :^(NSData *xstring){
//
//        return xstring;
//    }];

//typedef void(^myCompletion)(BOOL);

//- (NSData *)convertaudio :(AVURLAsset *)ravurlasset :(todaystring)completionblock {
//    //    (myConversion) compblock
//    //    NSString *retStr = [NSString stringWithFormat:@"--->%@<----",anotherstring];
//    NSData *datum;
//    return completionblock(datum);
//}

//
//- (NSData *)returnthisdarnstring :(NSString *)anotherstring :(todaystring)completionblock {
////    (myConversion) compblock
//    NSString *retStr = [NSString stringWithFormat:@"--->%@<----",anotherstring];
//    NSData *datum;
//    return completionblock(datum);
//}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    VLCMediaPlayer *player = [aNotification object];
    VLCTime *currentTime = player.time;
    _timeElapsed.stringValue = [currentTime stringValue];
    float a = currentTime.intValue;
    float b = player.media.length.intValue;
    float percent = (a/b) *100;
    
    NSString* formattedNumber = [NSString stringWithFormat:@"%.02f %@", percent, @"%"];
    _timeleft.stringValue = formattedNumber;
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    
    BOOL stop = [[NSUserDefaults standardUserDefaults] boolForKey:@"stop"];
    
    VLCMediaPlayer *player = [aNotification object];
    NSLog(@"player state is %ld",(long)player.state);
    if ((player.state == 0)){
        if (stop == YES) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"mediadidfinish"
         object:self];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"stop"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    if (player.state == 6){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"mediadidfinish"
         object:self];
    }
}





@end
