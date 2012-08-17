//
//  LCMusicPlayerViewController.h
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCImageView.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>


@class LCStyledView;
@protocol LCMusicPlayerViewControllerDelegate;


@interface LCMusicPlayerViewController : NSViewController

@property (assign, nonatomic) id <LCMusicPlayerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet LCImageView *albumArtworkImageView;
@property (weak, nonatomic) IBOutlet NSProgressIndicator *spinner;
@property (weak, nonatomic) IBOutlet NSButton *pauseButton;
@property (weak, nonatomic) IBOutlet NSButton *playButton;
@property (weak, nonatomic) IBOutlet NSButton *skipButton;
@property (weak, nonatomic) IBOutlet NSTextField *trackTitleTextField;
@property (weak, nonatomic) IBOutlet NSTextField *bandNameTextField;
@property (weak, nonatomic) IBOutlet NSTextField *trackTimeTextField;

- (IBAction)pauseButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)skipButtonClicked:(id)sender;

- (void)updateViewWithTrack:(SPTrack *)track;

@end


@protocol LCMusicPlayerViewControllerDelegate <NSObject>
@optional
- (void)musicPlayerViewControllerDidClickPauseButton:(LCMusicPlayerViewController *)musicPlayerViewController;
- (void)musicPlayerViewControllerDidClickPlayButton:(LCMusicPlayerViewController *)musicPlayerViewController;
- (void)musicPlayerViewControllerDidClickSkipButton:(LCMusicPlayerViewController *)musicPlayerViewController;
@end
