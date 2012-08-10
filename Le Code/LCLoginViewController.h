//
//  LCLoginViewController.h
//  Le Code
//
//  Created by Red Davis on 08/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "LCConstants.h"


@interface LCLoginViewController : NSViewController <SPSessionDelegate>

@property (weak, nonatomic) IBOutlet NSTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet NSTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSButton *loginButton;
@property (weak, nonatomic) IBOutlet NSProgressIndicator *largeSpinner;

- (IBAction)loginButtonClicked:(id)sender;

@end
