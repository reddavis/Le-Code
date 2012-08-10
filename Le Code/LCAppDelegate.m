//
//  LCAppDelegate.m
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCAppDelegate.h"
#import "LCWindowController.h"
#import "LCLoginWindowController.h"
#import "LCConstants.h"
#import "LCUserPreferences.h"


@interface LCAppDelegate ()

@property (strong, nonatomic) LCWindowController *windowController;
@property (strong, nonatomic) LCLoginWindowController *loginWindowController;

- (void)loggedInSuccessfulyNotification:(NSNotification *)notification;

@end


static NSString *const kWindowControllerNibName = @"LCWindowController";
static NSString *const kLoginWindowControllerNibName = @"LCLoginWindowController";


@implementation LCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    #import "appkey.c"
    
    NSError *spotifyInitializeError = nil;
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:g_appkey length:g_appkey_size] userAgent:@"LeCode" loadingPolicy:SPAsyncLoadingImmediate error:&spotifyInitializeError];
    
    if (spotifyInitializeError) {
        NSLog(@"Error initializing Spotify %@", spotifyInitializeError);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInSuccessfulyNotification:) name:kLoggedInSuccessfulyNotification object:nil];

    self.loginWindowController = [[LCLoginWindowController alloc] initWithWindowNibName:kLoginWindowControllerNibName];
    [self.loginWindowController showWindow:nil];
}

#pragma mark - Actions

- (void)logoutMenuItemClicked:(id)sender {
    
    LCUserPreferences *userPreferences = [LCUserPreferences sharedPreferences];
    userPreferences.username = nil;
    userPreferences.credential = nil;
    
    [self.windowController logout:^{
        
        [self.windowController close];
        
        self.loginWindowController = [[LCLoginWindowController alloc] initWithWindowNibName:kLoginWindowControllerNibName];
        [self.loginWindowController showWindow:nil];
    }];
}

#pragma mark - Notification

- (void)loggedInSuccessfulyNotification:(NSNotification *)notification {
    
    [self.loginWindowController close];
    
    self.windowController = [[LCWindowController alloc] initWithWindowNibName:kWindowControllerNibName];
    [self.windowController showWindow:nil];
}

@end
