//
//  LCLoginViewController.m
//  Le Code
//
//  Created by Red Davis on 08/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCLoginViewController.h"
#import "LCUserPreferences.h"


@interface LCLoginViewController ()

@property (readonly, nonatomic) SPSession *spotifySession;
@property (readonly, nonatomic) LCUserPreferences *userPreferences;

- (void)showLoginForm;
- (void)hideLoginForm;

@end


@implementation LCLoginViewController

- (void)awakeFromNib {
        
    self.spotifySession.delegate = self;
    
    if (self.userPreferences.username && self.userPreferences.credential) {
                
        [self hideLoginForm];
        [self.spotifySession attemptLoginWithUserName:self.userPreferences.username existingCredential:self.userPreferences.credential rememberCredentials:YES];
    }
}

#pragma mark -

- (void)showLoginForm {
    
    [self.largeSpinner stopAnimation:nil];
    [self.usernameTextField setHidden:NO];
    [self.passwordTextField setHidden:NO];
    [self.loginButton setHidden:NO];
}

- (void)hideLoginForm {
    
    [self.usernameTextField setHidden:YES];
    [self.passwordTextField setHidden:YES];
    [self.loginButton setHidden:YES];
    [self.largeSpinner startAnimation:nil];
}

#pragma mark - Actions

- (void)loginButtonClicked:(id)sender {
    
    [self.loginButton setEnabled:NO];
    [self.largeSpinner startAnimation:nil];
    
    NSString *username = self.usernameTextField.stringValue;
    NSString *password = self.passwordTextField.stringValue;
    [self.spotifySession attemptLoginWithUserName:username password:password rememberCredentials:YES];
}

#pragma mark - Helpers

- (SPSession *)spotifySession {
    
    return [SPSession sharedSession];
}

- (LCUserPreferences *)userPreferences {
    
    return [LCUserPreferences sharedPreferences];
}

#pragma mark - SPSessionDelegate

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert beginSheetModalForWindow:self.view.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    
    [self.largeSpinner stopAnimation:nil];
    [self.loginButton setEnabled:YES];
}

- (void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error {
    
    //..Show error label
    [self showLoginForm];
}

- (void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    
    self.userPreferences.username = userName;
    self.userPreferences.credential = credential;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInSuccessfulyNotification object:nil];
}

- (void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    
    if (self.userPreferences.username && self.userPreferences.credential) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInSuccessfulyNotification object:nil];
    }
}

@end
