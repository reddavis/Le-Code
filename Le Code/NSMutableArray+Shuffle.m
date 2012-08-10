//
//  NSMutableArray+Shuffle.m
//  Le Code
//
//  Created by Red Davis on 08/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"


@implementation NSMutableArray (Shuffle)

- (void)lc_shuffle {
    
    for (NSInteger i = 0; i < self.count; i++) {
        
        NSInteger indexOfObjectToSwapWith = (arc4random() % (self.count-1));
        [self exchangeObjectAtIndex:i withObjectAtIndex:indexOfObjectToSwapWith];
    }
}

@end
