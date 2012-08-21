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

@interface LCSelectPlaylistPanel () <NSTextFieldDelegate>
@property (strong, nonatomic) IBOutlet NSPopUpButton *playlistSelect;
@end


@implementation LCSelectPlaylistPanel

- (void) awakeFromNib {
	
	NSString *selectedPlaylist = [[NSUserDefaults standardUserDefaults] stringForKey:kPlaylistUserDefaultsKey];
	
	for (SPPlaylist *playlist in [[[SPSession sharedSession] userPlaylists] playlists]){
		[self.playlistSelect addItemWithTitle:playlist.name];
		if ([[playlist.spotifyURL absoluteString] isEqualToString:selectedPlaylist]){
			[self.playlistSelect selectItemWithTitle:playlist.name];
		}
	}
}

- (IBAction)savePlaylist:(id)sender {
	
	SPPlaylist *selectedPlaylist = [[[[SPSession sharedSession] userPlaylists] playlists] objectAtIndex:[self.playlistSelect indexOfSelectedItem]];
		
	[[NSUserDefaults standardUserDefaults] setObject:[[selectedPlaylist spotifyURL] absoluteString] forKey:kPlaylistUserDefaultsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistChangedNotification object:nil];
	[self hidePanel];
}

- (void) hidePanel {
	[[NSApplication sharedApplication] endSheet:self.window];
}

@end
