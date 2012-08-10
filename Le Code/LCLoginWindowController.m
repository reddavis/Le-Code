//
//  LCLoginWindowController.m
//  Le Code
//
//  Created by Red Davis on 08/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCLoginWindowController.h"
#import "LCLoginViewController.h"


@interface LCLoginWindowController ()

@property (strong, nonatomic) LCLoginViewController *loginViewController;

@end


@implementation LCLoginWindowController

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    self.loginViewController = [[LCLoginViewController alloc] initWithNibName:@"LCLoginViewController" bundle:nil];
    self.loginViewController.view.frame = self.view.frame;
    [self.view addSubview:self.loginViewController.view];
}

@end
