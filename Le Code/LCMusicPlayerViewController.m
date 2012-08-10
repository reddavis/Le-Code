//
//  LCMusicPlayerViewController.m
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCMusicPlayerViewController.h"
#import "LCStyledView.h"


@interface LCMusicPlayerViewController ()

@end


@implementation LCMusicPlayerViewController

- (void)awakeFromNib {
    
    LCStyledView *view = (LCStyledView *)self.view;
    view.backgroundColor = [NSColor whiteColor];
    
    [self.spinner startAnimation:nil];
    
    [self.trayView setWantsLayer:YES];
    self.trayView.backgroundColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.8];
}

#pragma mark - Actions

- (void)pauseButtonClicked:(id)sender {
    
    [self.pauseButton setHidden:YES];
    [self.playButton setHidden:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicPlayerViewControllerDidClickPauseButton:)]) {
        [self.delegate musicPlayerViewControllerDidClickPauseButton:self];
    }
}

- (void)playButtonClicked:(id)sender {
    
    [self.pauseButton setHidden:NO];
    [self.playButton setHidden:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicPlayerViewControllerDidClickPlayButton:)]) {
        [self.delegate musicPlayerViewControllerDidClickPlayButton:self];
    }
}

- (void)skipButtonClicked:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicPlayerViewControllerDidClickSkipButton:)]) {
        [self.delegate musicPlayerViewControllerDidClickSkipButton:self];
    }
}

@end
