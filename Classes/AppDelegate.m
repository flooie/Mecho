//
//  AppDelegate.m
//  PostTest
//
//  Created by William Palin on 6/5/16.
//  Copyright © 2016 William Palin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface AppDelegate ()
@property (strong) IBOutlet NSWindow *window;

@end

@implementation AppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application


}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"the ending just happended");
}



@end
