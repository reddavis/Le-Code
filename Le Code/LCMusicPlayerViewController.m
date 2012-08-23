//
//  LCMusicPlayerViewController.m
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCMusicPlayerViewController.h"
#import "LCStyledView.h"
#import <QuartzCore/QuartzCore.h>
#import "LCConstants.h"


@interface LCMusicPlayerViewController ()

@property (assign, nonatomic) NSTrackingRectTag trackingTag;

- (CABasicAnimation *)buildFadeOutAnimationWithDelay:(CGFloat)delay;
- (CABasicAnimation *)buildFadeInAnimationWithDelay:(CGFloat)delay;

@end


static CGFloat const kTrackTimeTextFieldLeftPadding = 10.0;


@implementation LCMusicPlayerViewController

#pragma mark -

- (void)awakeFromNib {
        
    LCStyledView *view = (LCStyledView *)self.view;
    view.backgroundColor = [NSColor blackColor];
    
    self.trayView.backgroundImage = [NSImage imageNamed:@"bar"];
    
    [self.spinner startAnimation:nil];
    
    [self.trackTitleTextField setHidden:YES];
    [self.trackTimeTextField setHidden:YES];
    [self.bandNameTextField setHidden:YES];
    
    self.trackingTag = [self.view addTrackingRect:self.albumArtworkImageView.frame owner:self userData:nil assumeInside:NO];
    
    [self.pauseButton setAlphaValue:0.0];
    [self.playButton setAlphaValue:0.0];
    [self.trayView setAlphaValue:0.0];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipButtonClicked:) name:kPlayNextTrackNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPauseMediaKeyPressed) name:kPlayPauseNotification object:nil];
}

- (void)dealloc {
    
    [self.view removeTrackingRect:self.trackingTag];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)updateViewWithTrack:(SPTrack *)track {
    
    [self.trackTitleTextField setHidden:NO];
    [self.trackTimeTextField setHidden:NO];
    [self.bandNameTextField setHidden:NO];
    
    CABasicAnimation *fadeOutAnimation = [self buildFadeOutAnimationWithDelay:0.25];
    CABasicAnimation *fadeInAnimation = [self buildFadeInAnimationWithDelay:0.25];
    
    [self.albumArtworkImageView.layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    [self.trackTimeTextField.layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    [self.bandNameTextField.layer addAnimation:fadeOutAnimation forKey:@"opacity"];
    
    self.trackTitleTextField.stringValue = track.name;
    self.bandNameTextField.stringValue = track.consolidatedArtists;
    
    // Reposition track time text field
    NSSize trackNameSize = [track.name sizeWithAttributes:[NSDictionary dictionaryWithObject:self.trackTitleTextField.font forKey:NSFontAttributeName]];
    if (trackNameSize.width > self.trackTitleTextField.frame.size.width) {
        trackNameSize.width = self.trackTitleTextField.frame.size.width;
    }
    
    self.trackTimeTextField.frame = CGRectMake(floorf(trackNameSize.width+self.trackTitleTextField.frame.origin.x+kTrackTimeTextFieldLeftPadding), self.trackTimeTextField.frame.origin.y, self.trackTimeTextField.frame.size.width, self.trackTimeTextField.frame.size.height);
    
    // Fade everything back in
    [self.trackTimeTextField.layer addAnimation:fadeInAnimation forKey:@"opacity"];
    [self.bandNameTextField.layer addAnimation:fadeInAnimation forKey:@"opacity"];
    
    [SPAsyncLoading waitUntilLoaded:track.album.cover timeout:5.0 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
        
        self.albumArtworkImageView.image = track.album.cover.image;
        [self.albumArtworkImageView.layer addAnimation:fadeInAnimation forKey:@"opacity"];
    }];
}

#pragma mark - Actions

- (void)playPauseMediaKeyPressed {
    
	if ([self.playButton isHidden]) {
		[self pauseButtonClicked:nil];
	} else {
		[self playButtonClicked:nil];
	}
}

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

#pragma mark - Helpers

- (CABasicAnimation *)buildFadeInAnimationWithDelay:(CGFloat)delay {
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animation];
    fadeInAnimation.keyPath = @"opacity";
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode = kCAFillModeForwards;
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAnimation.duration = delay;
    return fadeInAnimation;
}

- (CABasicAnimation *)buildFadeOutAnimationWithDelay:(CGFloat)delay {
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animation];
    fadeOutAnimation.keyPath = @"opacity";
    fadeOutAnimation.removedOnCompletion = NO;
    fadeOutAnimation.fillMode = kCAFillModeForwards;
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeOutAnimation.duration = delay;
    return fadeOutAnimation;
}

#pragma mark - Mouse Tracking

- (void)mouseEntered:(NSEvent *)theEvent {
    
    CABasicAnimation *fadeInAnimation = [self buildFadeInAnimationWithDelay:0.5];
    [self.playButton.layer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    [self.pauseButton.layer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    [self.trayView.layer addAnimation:fadeInAnimation forKey:@"fadeIn"];
}

- (void)mouseExited:(NSEvent *)theEvent {
    
    CABasicAnimation *fadeOutAnimation = [self buildFadeOutAnimationWithDelay:0.5];
    [self.playButton.layer addAnimation:fadeOutAnimation forKey:@"fadeOut"];
    [self.pauseButton.layer addAnimation:fadeOutAnimation forKey:@"fadeOut"];
    [self.trayView.layer addAnimation:fadeOutAnimation forKey:@"fadeOut"];
}

@end
