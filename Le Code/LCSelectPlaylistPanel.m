//
//  LCSelectPlaylistPanel.m
//  Le Code
//
//  Created by Simon Maddox on 21/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCSelectPlaylistPanel.h"
#import "LCConstants.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "LCUserPreferences.h"


@interface LCSelectPlaylistPanel () <NSTextFieldDelegate>

@property (readonly, nonatomic) SPSession *spotifySession;
@property (strong, nonatomic) IBOutlet NSPopUpButton *playlistSelect;
@property (readonly, nonatomic) LCUserPreferences *userPreferences;

- (void)windowDidBecomeKey:(NSNotification *)notification;

@end


@implementation LCSelectPlaylistPanel

#pragma mark -

- (void)awakeFromNib {
	    
    [self.playlistSelect setEnabled:NO];
    [self.loadingSpinner startAnimation:nil];
    
    [SPAsyncLoading waitUntilLoaded:self.spotifySession.userPlaylists timeout:5.0 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
        
        [self setupPlaylistSelect];
        [self.playlistSelect setEnabled:YES];
        [self.loadingSpinner removeFromSuperview];
    }];    
}

#pragma mark - Actions

- (IBAction)savePlaylist:(id)sender {
	
	SPPlaylist *selectedPlaylist = [self.spotifySession.userPlaylists.flattenedPlaylists objectAtIndex:[self.playlistSelect indexOfSelectedItem]];
    self.userPreferences.selectedPlaylist = selectedPlaylist.spotifyURL.absoluteString;
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistChangedNotification object:nil];
	[self hidePanel:nil];
}

- (IBAction)hidePanel:(id)sender {
    
	[[NSApplication sharedApplication] endSheet:self.window];
}

#pragma mark - Helpers

- (LCUserPreferences *)userPreferences {
    
    return [LCUserPreferences sharedPreferences];
}

- (SPSession *)spotifySession {
    
    return [SPSession sharedSession];
}

#pragma mark - Notifications

- (void)windowDidBecomeKey:(NSNotification *)notification {
    
    [self setupPlaylistSelect];
}

#pragma mark - Observers

- (void)setupPlaylistSelect {
    
    NSString *selectedPlaylist = self.userPreferences.selectedPlaylist;
    
    NSInteger notLoadedPlaylistNumber = 0;
    for (SPPlaylist *playlist in self.spotifySession.userPlaylists.flattenedPlaylists) {
                
        NSString *name = nil;
        if (!playlist.isLoaded) {    
            name = [NSString stringWithFormat: @"#%ld: Not loaded yet..", ++notLoadedPlaylistNumber ];
        }
        else {
            name = playlist.name;
        }
        
        [self.playlistSelect addItemWithTitle:name];
        
        if ([[playlist.spotifyURL absoluteString] isEqualToString:selectedPlaylist]) {
            [self.playlistSelect selectItemWithTitle:name];
        }
    }
}

@end
