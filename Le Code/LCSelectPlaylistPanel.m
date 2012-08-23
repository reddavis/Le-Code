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

- (NSArray *)recursivlyCollectPlaylistsFromArray:(NSArray *)playlistArray;

@end


@implementation LCSelectPlaylistPanel

#pragma mark -

- (void)awakeFromNib {
	
	NSString *selectedPlaylist = self.userPreferences.selectedPlaylist;
	NSArray *userPlaylists = [self recursivlyCollectPlaylistsFromArray:[SPSession sharedSession].userPlaylists.playlists];
    
	for (SPPlaylist *playlist in userPlaylists) {
        
		[self.playlistSelect addItemWithTitle:playlist.name];
		if ([[playlist.spotifyURL absoluteString] isEqualToString:selectedPlaylist]){
			[self.playlistSelect selectItemWithTitle:playlist.name];
		}
	}
}

#pragma mark -

- (NSArray *)recursivlyCollectPlaylistsFromArray:(NSArray *)playlistArray {
    
    NSMutableArray *mutablePlaylistArray = [NSMutableArray array];
    for (id playlistObject in playlistArray) {
        
        if ([playlistObject isKindOfClass:[SPPlaylistFolder class]]) {
            
            SPPlaylistFolder *playlistFolder = (SPPlaylistFolder *)playlistObject;
            [mutablePlaylistArray addObjectsFromArray:[self recursivlyCollectPlaylistsFromArray:playlistFolder.playlists]];
        }
        else if ([playlistObject isKindOfClass:[SPPlaylist class]]) {
            [mutablePlaylistArray addObject:playlistObject];
        }
    }
    
    return [NSArray arrayWithArray:mutablePlaylistArray];
}

#pragma mark - Actions

- (IBAction)savePlaylist:(id)sender {
	
	SPPlaylist *selectedPlaylist = [[[[SPSession sharedSession] userPlaylists] playlists] objectAtIndex:[self.playlistSelect indexOfSelectedItem]];
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

@end
