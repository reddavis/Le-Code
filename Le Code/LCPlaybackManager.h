//
//  LCPlaybackManager.h
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>


@protocol LCPlaybackManagerDelegate;


@interface LCPlaybackManager : SPPlaybackManager <SPSessionPlaybackDelegate>

@property (assign, nonatomic) __unsafe_unretained id <LCPlaybackManagerDelegate, SPPlaybackManagerDelegate> delegate;

- (void)unPause;
- (void)pause;
- (void)skipTrack;

@end


@protocol LCPlaybackManagerDelegate <SPPlaybackManagerDelegate>
@optional
- (void)playbackManagerHasLoadedTracks:(LCPlaybackManager *)playbackManager;
- (void)playbackManager:(LCPlaybackManager *)playbackManager didChangeTrack:(SPTrack *)track;
@end
