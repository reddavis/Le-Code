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

@property (strong, nonatomic) IBOutlet NSPopUpButton *playlistSelect;
@property (readonly, nonatomic) LCUserPreferences *userPreferences;

@end


@implementation LCSelectPlaylistPanel

#pragma mark -

- (void)awakeFromNib {
	
	NSString *selectedPlaylist = self.userPreferences.selectedPlaylist;
	
	for (SPPlaylist *playlist in [[[SPSession sharedSession] userPlaylists] playlists]) {
        
        NSLog(@"%@", playlist);
		[self.playlistSelect addItemWithTitle:playlist.name];
		if ([[playlist.spotifyURL absoluteString] isEqualToString:selectedPlaylist]){
			[self.playlistSelect selectItemWithTitle:playlist.name];
		}
	}
}

#pragma mark - Actions

- (IBAction)savePlaylist:(id)sender {
	
	SPPlaylist *selectedPlaylist = [[[[SPSession sharedSession] userPlaylists] playlists] objectAtIndex:[self.playlistSelect indexOfSelectedItem]];
    self.userPreferences.selectedPlaylist = selectedPlaylist.spotifyURL.absoluteString;
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistChangedNotification object:nil];
	[self hidePanel];
}

- (void)hidePanel {
    
	[[NSApplication sharedApplication] endSheet:self.window];
}

#pragma mark - Helpers

- (LCUserPreferences *)userPreferences {
    
    return [LCUserPreferences sharedPreferences];
}

@end
