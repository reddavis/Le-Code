//
//  AppDelegate.m
//  CocoaLibSpotify Test Container
//
//  Created by Daniel Kennett on 09/05/2012.
/*
 Copyright (c) 2011, Spotify AB
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

#import "AppDelegate.h"
#import "SPSessionTests.h"
#import "SPMetadataTests.h"
#import "SPSearchTests.h"
#import "SPPostTracksToInboxTests.h"
#import "SPAudioDeliveryTests.h"
#import "SPSessionTeardownTests.h"
#import "SPPlaylistTests.h"
#import "SPConcurrencyTests.h"

static NSString * const kTestStatusServerUserDefaultsKey = @"StatusColorServer";

@interface AppDelegate ()
@property (nonatomic, strong) SPTests *sessionTests;
@property (nonatomic, strong) SPTests *metadataTests;
@property (nonatomic, strong) SPTests *searchTests;
@property (nonatomic, strong) SPTests *inboxTests;
@property (nonatomic, strong) SPTests *audioTests;
@property (nonatomic, strong) SPTests *teardownTests;
@property (nonatomic, strong) SPTests *playlistTests;
@property (nonatomic, strong) SPTests *concurrencyTests;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize sessionTests;
@synthesize metadataTests;
@synthesize searchTests;
@synthesize inboxTests;
@synthesize audioTests;
@synthesize teardownTests;
@synthesize playlistTests;
@synthesize concurrencyTests;

-(void)completeTestsWithPassCount:(NSUInteger)passCount failCount:(NSUInteger)failCount {
	printf("**** Completed %lu tests with %lu passes and %lu failures ****\n", passCount + failCount, passCount, failCount);
	[self pushColorToStatusServer:failCount > 0 ? [NSColor redColor] : [NSColor greenColor]];
	exit(failCount > 0 ? EXIT_FAILURE : EXIT_SUCCESS);
}

-(void)pushColorToStatusServer:(NSColor *)color {
	
	NSString *statusServerAddress = [[NSUserDefaults standardUserDefaults] stringForKey:kTestStatusServerUserDefaultsKey];
	if (statusServerAddress.length == 0) return;
	
	NSColor *colorToSend = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
	
	NSString *requestUrlString = [NSString stringWithFormat:@"http://%@/push-color?red=%lu&green=%lu&blue=%lu",
								  statusServerAddress,
								  (NSUInteger)colorToSend.redComponent * 255,
								  (NSUInteger)colorToSend.greenComponent * 255,
								  (NSUInteger)colorToSend.blueComponent * 255];
	
	NSURL *requestUrl = [NSURL URLWithString:requestUrlString];							  
	NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl 
											 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										 timeoutInterval:1.0];
	
	[NSURLConnection sendSynchronousRequest:request
						  returningResponse:nil
									  error:nil];
	
}

#pragma mark - Running Tests

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self pushColorToStatusServer:[NSColor yellowColor]];
	
	// --- Remove old cache and settings directories for a fresh test each time
	
	// Find the application support directory for settings
	
	NSString *applicationSupportDirectory = nil;
	NSArray *potentialDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
																		NSUserDomainMask,
																		YES);
	
	if ([potentialDirectories count] > 0) {
		applicationSupportDirectory = [[potentialDirectories objectAtIndex:0] stringByAppendingPathComponent:@"com.spotify.CocoaLSUnitTests"];
	} else {
		applicationSupportDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.spotify.CocoaLSUnitTests"];
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory]) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager] removeItemAtPath:applicationSupportDirectory error:&error]) {
			NSLog(@"Could not delete application support directory: %@", error);
			[self completeTestsWithPassCount:0 failCount:1];
		}
	};
	
	// Find the caches directory for cache
	
	NSString *cacheDirectory = nil;
	
	NSArray *potentialCacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
																			 NSUserDomainMask,
																			 YES);
	
	if ([potentialCacheDirectories count] > 0) {
		cacheDirectory = [[potentialCacheDirectories objectAtIndex:0] stringByAppendingPathComponent:@"com.spotify.CocoaLSUnitTests"];
	} else {
		cacheDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.spotify.CocoaLSUnitTests"];
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager] removeItemAtPath:cacheDirectory error:&error]) {
			NSLog(@"Could not delete cache directory: %@", error);
			[self completeTestsWithPassCount:0 failCount:1];
		}
	}
	
	// ---
	
	// Insert code here to initialize your application
	self.sessionTests = [SPSessionTests new];
	
	__block NSUInteger totalPassCount = 0;
	__block NSUInteger totalFailCount = 0;
	
	[self.sessionTests runTests:^(NSUInteger sessionPassCount, NSUInteger sessionFailCount) {
		
		totalPassCount += sessionPassCount;
		totalFailCount += sessionFailCount;
		
		self.concurrencyTests = [SPConcurrencyTests new];
		[self.concurrencyTests runTests:^(NSUInteger concurrencyPassCount, NSUInteger concurrencyFailCount) {
			
			totalPassCount += concurrencyPassCount;
			totalFailCount += concurrencyFailCount;
			
			self.playlistTests = [SPPlaylistTests new];
			[self.playlistTests runTests:^(NSUInteger playlistPassCount, NSUInteger playlistFailCount) {
				
				totalPassCount += playlistPassCount;
				totalFailCount += playlistFailCount;
				
				self.audioTests = [SPAudioDeliveryTests new];
				[self.audioTests runTests:^(NSUInteger audioPassCount, NSUInteger audioFailCount) {
					
					totalPassCount += audioPassCount;
					totalFailCount += audioFailCount;
					
					self.searchTests = [SPSearchTests new];
					[self.searchTests runTests:^(NSUInteger searchPassCount, NSUInteger searchFailCount) {
						
						totalPassCount += searchPassCount;
						totalFailCount += searchFailCount;
						
						self.inboxTests = [SPPostTracksToInboxTests new];
						[self.inboxTests runTests:^(NSUInteger inboxPassCount, NSUInteger inboxFailCount) {
							
							totalPassCount += inboxPassCount;
							totalFailCount += inboxFailCount;
							
							self.metadataTests = [SPMetadataTests new];
							[self.metadataTests runTests:^(NSUInteger metadataPassCount, NSUInteger metadataFailCount) {
								
								totalPassCount += metadataPassCount;
								totalFailCount += metadataFailCount;
								
								self.teardownTests = [SPSessionTeardownTests new];
								[self.teardownTests runTests:^(NSUInteger teardownPassCount, NSUInteger teardownFailCount) {
									
									totalPassCount += teardownPassCount;
									totalFailCount += teardownFailCount;
									
									[self completeTestsWithPassCount:totalPassCount failCount:totalFailCount];
									
								}];
							}];
						}];
					}];
				}];
			}];
		}];
	}];
}

@end
