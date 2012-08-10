//
//  LCWindowController.h
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "LCPlaybackManager.h"
#import "LCMusicPlayerViewController.h"


@interface LCWindowController : NSWindowController <SPSessionDelegate, LCPlaybackManagerDelegate, LCMusicPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSView *view;

- (void)logout:(void (^)(void))completionBlock;

@end
