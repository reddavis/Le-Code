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
@property (strong, nonatomic) NSArray *userPlaylists;
@property (assign, nonatomic) BOOL hasUnloadedPlaylists;

- (NSArray *)recursivlyCollectPlaylistsFromArray:(NSArray *)playlistArray;

@end


@implementation LCSelectPlaylistPanel

#pragma mark -

- (void)awakeFromNib {
	
    [self.playlistSelect setEnabled:NO];
    [self.loadingSpinner startAnimation:nil];
    
    self.hasUnloadedPlaylists = NO;
    
    NSLog(@"Is playlist container loaded? %@", [NSNumber numberWithBool:[SPSession sharedSession].userPlaylists.isLoaded]);
    
    if (![SPSession sharedSession].userPlaylists.isLoaded) {
        NSLog(@"Not loaded");
        [[SPSession sharedSession].userPlaylists addObserver:self forKeyPath:@"isLoaded" options:0 context:NULL];
    } else {
        [self setupPlaylistSelect];
    }
}

#pragma mark - Actions

- (IBAction)savePlaylist:(id)sender {
	
	SPPlaylist *selectedPlaylist = [self.userPlaylists objectAtIndex:[self.playlistSelect indexOfSelectedItem]];
    self.userPreferences.selectedPlaylist = selectedPlaylist.spotifyURL.absoluteString;
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistChangedNotification object:nil];
	[self hidePanel:nil];
}

- (IBAction)hidePanel:(id)sender {
    
//	[[NSApplication sharedApplication] endSheet:self.window];
    [self.window close];
}

#pragma mark - Helpers

- (LCUserPreferences *)userPreferences {
    
    return [LCUserPreferences sharedPreferences];
}

#pragma mark - Observers

- (void)setupPlaylistSelect {
    NSString *selectedPlaylist = self.userPreferences.selectedPlaylist;
    self.userPlaylists = [SPSession sharedSession].userPlaylists.flattenedPlaylists;
    
    NSInteger playlistNumber = 0;
    
    for (SPPlaylist *playlist in self.userPlaylists) {
        
        NSLog(@"Is playlist loaded? %@", [NSNumber numberWithBool:playlist.isLoaded]);
        
        NSString *name = nil;
        
        if (!playlist.isLoaded) {
            name = [NSString stringWithFormat: @"#%ld: Not loaded yet..", ++playlistNumber ];
            self.hasUnloadedPlaylists = YES;
        } else {
            name = playlist.name;
        }
        
        [self.playlistSelect addItemWithTitle:name];
        if ([[playlist.spotifyURL absoluteString] isEqualToString:selectedPlaylist]){
            [self.playlistSelect selectItemWithTitle:name];
        }
    }
    
    [self.playlistSelect setEnabled:YES];
    [self.loadingSpinner removeFromSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSLog(@"Observed: %@", keyPath);
    
    if ([keyPath isEqualToString:@"isLoaded"]) {
        [self setupPlaylistSelect];
    }
}

@end
