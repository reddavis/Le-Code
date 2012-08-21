//
//  LCAppDelegate.h
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MediaKeyApplication : NSApplication
@end

@interface LCAppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)logoutMenuItemClicked:(id)sender;
- (IBAction)choosePlaylistMenuItemClicked:(id)sender;

@end
