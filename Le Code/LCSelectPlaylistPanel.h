//
//  LCSelectPlaylistPanel.h
//  Le Code
//
//  Created by Simon Maddox on 21/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCSelectPlaylistPanel : NSWindowController

@property (weak, nonatomic) IBOutlet NSProgressIndicator *loadingSpinner;

- (IBAction)savePlaylist:(id)sender;
- (IBAction)hidePanel:(id)sender;

@end
