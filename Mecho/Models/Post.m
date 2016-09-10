//
//  Post.m
//  Alexa
//
//  Created by William Palin on 6/9/16.
//
//

#import "Post.h"

@implementation Post

+ (NSMutableData *)postData:(NSData *)audioData {
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[@"\r\n--someboundary\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Disposition: form-data; name=\"request\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Type: application/json; charset=UTF-8\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"{\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"messageHeader\": {\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"deviceContext\": [\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"{\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"name\": \"playbackState\",\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"namespace\": \"AudioPlayer\",\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"payload\": {\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"streamId\": \"\",\r\n" dataUsingEncoding:NSUTF8StringEncoding]]; // what is the streamid supposed to be?
    [postData appendData:[@"\"offsetInMilliseconds\": \"\",\r\n" dataUsingEncoding:NSUTF8StringEncoding]];//Is this correct?
    [postData appendData:[@"\"playerActivity\": \"IDLE\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"}\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"}\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"]\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"},\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"messageBody\": {\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"profile\": \"alexa-close-talk\",\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"locale\": \"en-us\",\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"\"format\": \"audio/L16; rate=16000; channels=1\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"}\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"}\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"--someboundary\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Disposition: form-data; name=\"audio\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Type: audio/L16; rate=16000; channels=1\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[NSData dataWithData:audioData]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--someboundry--"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postData;
}

+ (NSMutableData *)postNextData:(NSString *)navtoken {
    NSString *navtokenString = [NSString stringWithFormat:@"\"navigationToken\": %@ \r\n",navtoken];
    
    NSString *json = [NSString stringWithFormat:@"{\r\n \"messageHeader\": {},\r\n \"messageBody\": {\r\n \"navigationToken\": \"%@\" \r\n }\r\n }\r\n\r\n \r\n--someboundry--", navtoken];
    
    NSLog(@"the json is %@",json);
    
//    NSMutableData *postData = [[NSMutableData alloc] initWithData:[@"\r\n--someboundary\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"Content-Disposition: form-data; name=\"request\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"Content-Type: application/json; charset=UTF-8\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"{\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"\"messageHeader\": {\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"},\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"\"messageBody\": {\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[navtokenString dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"}\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[@"}\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postData appendData:[[NSString stringWithFormat:@"\r\n--someboundry--"] dataUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"post data is %@",postData);
    NSMutableData *postData = [[NSMutableData alloc]initWithData:[json dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postData;
}


//def alexa_getnextitem(nav_token):
//# https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/rest/audioplayer-getnextitem-request
//time.sleep(0.5)
//# if audioplaying == False:
//if debug: print("{}Sending GetNextItem Request...{}".format(bcolors.OKBLUE, bcolors.ENDC))
//# GPIO.output(plb_light, GPIO.HIGH)
//url = 'https://access-alexa-na.amazon.com/v1/avs/audioplayer/getNextItem'
//headers = {'Authorization' : 'Bearer %s' % gettoken(), 'content-type' : 'application/json; charset=UTF-8'}
//d = {
//    "messageHeader": {},
//    "messageBody": {
//        "navigationToken": nav_token
//    }
//}
//r = requests.post(url, headers=headers, data=json.dumps(d))
//return r

@end
