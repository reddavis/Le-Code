//
//  LCSelectPlaylistPanel.m
//  Le Code
//
//  Created by Simon Maddox on 21/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCSelectPlaylistPanel.h"
#import "LCConstants.h"

@interface LCSelectPlaylistPanel () <NSTextFieldDelegate>
@property (strong, nonatomic) IBOutlet NSTextField *playlistField;
@end


@implementation LCSelectPlaylistPanel

- (void) awakeFromNib {
	[self.playlistField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:kPlaylistUserDefaultsKey]];
}

- (IBAction)savePlaylist:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:self.playlistField.stringValue forKey:kPlaylistUserDefaultsKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:kPlaylistChangedNotification object:nil];
	[self hidePanel];
}

- (void) hidePanel {
	[[NSApplication sharedApplication] endSheet:self.window];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
	if ([NSStringFromSelector(commandSelector) isEqualToString:@"cancel:"]){
		[self hidePanel];
		return YES;
	} else if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertNewline:"]){
		[self savePlaylist:control];
		return YES;
	}
	return NO;
}

@end
