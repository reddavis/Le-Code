//
//  SPClientUpsellViewController.m
//  CocoaLibSpotify iOS Library
//
//  Created by Daniel Kennett on 26/03/2012.
/*
 Copyright (c) 2012, Spotify AB
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Spotify AB nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPClientUpsellViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SPURLExtensions.h"
#import "SPSession.h"

#if DEBUG
static NSString * const kClientUpsellPageURL = @"http://libspotify.spotify.s3.amazonaws.com/client-upsell/client-upsell.html";
#else
static NSString * const kClientUpsellPageURL = @"http://ls.scdn.co/client-upsell/client-upsell.html";
#endif

@interface SPClientUpsellViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) SPSession *session;

@end

@implementation SPClientUpsellViewController

-(id)initWithSession:(SPSession *)aSession {
	self = [super init];
	if (self) {
		self.session = aSession;
		self.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	return self;
}

@synthesize spinner;
@synthesize completionBlock;
@synthesize session;

-(void)done {
	if (self.completionBlock) self.completionBlock();
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(UIWebView *)webView {
	return (UIWebView *)self.view;
}

-(void)loadView {
	
	self.title = @"Get Spotify!";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
																			  style:UIBarButtonItemStyleDone
																			 target:self
																			 action:@selector(done)];
	
	self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.spinner.hidesWhenStopped = YES;
	
	CGRect bounds = CGRectMake(0, 0, 320, 460);
	UIWebView *web = [[UIWebView alloc] initWithFrame:bounds];
	web.delegate = self;
	
	NSString *params = [NSString stringWithFormat:@"?userAgent=%@&platform=%@&locale=%@",
						[NSURL urlEncodedStringForString:self.session.userAgent],
						[NSURL urlEncodedStringForString:[[UIDevice currentDevice] model]],
						[NSURL urlEncodedStringForString:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]]];
	
	NSURL *url = [NSURL URLWithString:[kClientUpsellPageURL stringByAppendingString:params]];
	[web loadRequest:[NSURLRequest requestWithURL:url]];
	
	for(id maybeScroll in web.subviews) {
		if ([maybeScroll respondsToSelector:@selector(setBounces:)])
			((UIScrollView *)maybeScroll).bounces = NO;
	}
	
	self.view = web;
	[self.view addSubview:self.spinner];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.spinner.layer.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
	[self.spinner startAnimating];
}

-(void)viewDidUnload {
	self.spinner = nil;
	[super viewDidUnload];
}

#pragma mark - WebView

-(void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
	if ([error.domain isEqual:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        // Just ignore, this is just an async call being cancelled
        return;
    }
	
	// Doh. This page isn't important enough to destroy the login flow, so just finish.
	[self done];
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
	[self.spinner startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.spinner stopAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		
		if ([request.URL.absoluteString hasPrefix:@"spotify:"]) {
			[self done];
			return NO;
		}
		
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	return YES;
}

@end
