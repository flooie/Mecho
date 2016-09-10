//
//  BackgroundView.m
//  Alexa
//
//  Created by William Palin on 6/9/16.
//
//

#import "BackgroundView.h"

@implementation BackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSLog(@"view called");
    if (self.backgroundColor) {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    [self willChangeValueForKey:@"backgroundColor"];
    _backgroundColor = [backgroundColor copy];
    [self didChangeValueForKey:@"backgroundColor"];
    
    [self setNeedsDisplay:YES];
}

@end
