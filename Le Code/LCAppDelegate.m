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
#import "SPMediaKeyTap.h"

@interface LCAppDelegate ()

@property (strong, nonatomic) LCWindowController *windowController;
@property (strong, nonatomic) LCLoginWindowController *loginWindowController;
@property (strong, nonatomic) SPMediaKeyTap *keyTap;

- (void)loggedInSuccessfulyNotification:(NSNotification *)notification;

@end


static NSString *const kWindowControllerNibName = @"LCWindowController";
static NSString *const kLoginWindowControllerNibName = @"LCLoginWindowController";


@implementation MediaKeyApplication

- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
	
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}
@end


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
	[self registerMediaKeys];
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

- (void)choosePlaylistMenuItemClicked:(id)sender {
	[self.windowController showSelectPlaylistPanel:sender];
}

#pragma mark - Notification

- (void)loggedInSuccessfulyNotification:(NSNotification *)notification {
    
    [self.loginWindowController close];
    
    self.windowController = [[LCWindowController alloc] initWithWindowNibName:kWindowControllerNibName];
    [self.windowController showWindow:nil];
}

- (void) registerMediaKeys {
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
															 [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
															 nil]];
	
	self.keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap]){
		[self.keyTap startWatchingMediaKeys];
	}
}

- (void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event {
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	
	if (keyIsPressed) {
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				[[NSNotificationCenter defaultCenter] postNotificationName:kPlayPauseNotification object:nil];
				break;
				
			case NX_KEYTYPE_FAST:
				[[NSNotificationCenter defaultCenter] postNotificationName:kPlayNextTrackNotification object:nil];
				break;
				
			case NX_KEYTYPE_REWIND:
				[[NSNotificationCenter defaultCenter] postNotificationName:kPlayPreviousTrackNotification object:nil];
				break;
			default:
				break;
		}
	}
}

@end
