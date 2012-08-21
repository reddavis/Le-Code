//
//  LCSelectPlaylistPanel.m
//  Le Code
//
//  Created by Simon Maddox on 21/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCSelectPlaylistPanel.h"
#import "LCConstants.h"

@interface LCSelectPlaylistPanel ()
@property (strong, nonatomic) IBOutlet NSTextField *playlistField;
@end


@implementation LCSelectPlaylistPanel

- (void) awakeFromNib {
	[self.playlistField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:kPlaylistUserDefaultsKey]];
}

- (IBAction)savePlaylist:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:self.playlistField.stringValue forKey:kPlaylistUserDefaultsKey];
	[[NSApplication sharedApplication] endSheet:self.window];
}

@end
