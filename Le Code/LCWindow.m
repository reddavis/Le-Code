//
//  LCWindow.m
//  Le Code
//
//  Created by Red Davis on 17/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCWindow.h"


@implementation LCWindow

#pragma mark - Initialization

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self) {
        
        [self setOpaque:NO];
        self.backgroundColor = [NSColor clearColor];
    }
    
    return self;
}

@end
