//
//  LCWindowContentView.m
//  Le Code
//
//  Created by Red Davis on 17/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCWindowContentView.h"


@implementation LCWindowContentView

- (void)awakeFromNib {
    
    [self setWantsLayer:YES];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0;
}

@end
