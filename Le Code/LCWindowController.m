//
//  LCWindowController.m
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCWindowController.h"
#import "LCSelectPlaylistPanel.h"


@interface LCWindowController ()

@property (strong, nonatomic) LCMusicPlayerViewController *musicPlayerViewController;
@property (readonly, nonatomic) SPSession *spotifySession;
@property (strong, nonatomic) LCPlaybackManager *playbackManager;
@property (strong, nonatomic) LCSelectPlaylistPanel *selectPlaylistPanel;

@end


@implementation LCWindowController

- (void)windowDidLoad {
        
    [super windowDidLoad];
    [self.window setMovableByWindowBackground:YES];
    
    self.musicPlayerViewController = [[LCMusicPlayerViewController alloc] initWithNibName:@"LCMusicPlayerViewController" bundle:nil];
    self.musicPlayerViewController.view.frame = self.view.frame;
    self.musicPlayerViewController.delegate = self;
    [self.view addSubview:self.musicPlayerViewController.view];
        
    self.spotifySession.delegate = self;
    [self.spotifySession setPreferredBitrate:SP_BITRATE_320k];
    
    self.playbackManager = [[LCPlaybackManager alloc] initWithPlaybackSession:self.spotifySession];
    self.playbackManager.delegate = self;
}

#pragma mark -

- (void)logout:(void (^)(void))completionBlock {
    
    [self.spotifySession logout:^{
        completionBlock();
    }];
}

- (void)showSelectPlaylistPanel:(id)sender {
    LCSelectPlaylistPanel *selectPlaylistPanel = [[LCSelectPlaylistPanel alloc] initWithWindowNibName:@"LCSelectPlaylistPanel"];
	
	[[NSApplication sharedApplication] beginSheet:selectPlaylistPanel.window
								   modalForWindow:self.window
									modalDelegate:self
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
									  contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:nil];
}

#pragma mark - Helpers

- (SPSession *)spotifySession {
    
    return [SPSession sharedSession];
}

#pragma mark - LCMusicPlayerViewControllerDelegate

- (void)musicPlayerViewControllerDidClickPauseButton:(LCMusicPlayerViewController *)musicPlayerViewController {
    
    [self.playbackManager pause];
}

- (void)musicPlayerViewControllerDidClickPlayButton:(LCMusicPlayerViewController *)musicPlayerViewController {
    
    [self.playbackManager unPause];
}

- (void)musicPlayerViewControllerDidClickSkipButton:(LCMusicPlayerViewController *)musicPlayerViewController {
    
    [self.playbackManager skipTrack];
}

#pragma mark - LCPlaybackManagerDelegate

- (void)playbackManagerHasLoadedTracks:(LCPlaybackManager *)playbackManager {
    
    [self.musicPlayerViewController.pauseButton setHidden:NO];
    [self.musicPlayerViewController.playButton setHidden:YES];
    [self.musicPlayerViewController.skipButton setHidden:NO];
    [self.playbackManager unPause];
}

- (void)playbackManager:(LCPlaybackManager *)playbackManager didChangeTrack:(SPTrack *)track {
    
    [self.musicPlayerViewController.spinner startAnimation:nil];
    
    [self.musicPlayerViewController updateViewWithTrack:track];
    [self.musicPlayerViewController.spinner stopAnimation:nil];
    [self.musicPlayerViewController.pauseButton setHidden:NO];
    [self.musicPlayerViewController.playButton setHidden:YES];
	
	if (NSClassFromString(@"NSUserNotificationCenter") != nil) {	
		NSUserNotification *notification = [[NSUserNotification alloc] init];
		[notification setHasActionButton:NO];
		[notification setTitle:track.name];
		[notification setSubtitle:track.consolidatedArtists];
		
		[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
	}
}

- (void)playbackManager:(LCPlaybackManager *)playbackManager didChangeTrackPosition:(NSTimeInterval)timeInterval {
    
    CGFloat minutes = timeInterval/60.0;
    NSString *minuteString = [NSString stringWithFormat:@"%.2f", minutes];
    self.musicPlayerViewController.trackTimeTextField.stringValue = minuteString;
}

- (void)playbackManagerWillStartPlayingAudio:(SPPlaybackManager *)aPlaybackManager {
    
}

@end
