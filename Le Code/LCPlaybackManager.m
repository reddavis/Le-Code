//
//  LCPlaybackManager.m
//  Le Code
//
//  Created by Red Davis on 07/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import "LCPlaybackManager.h"
#import "NSMutableArray+Shuffle.h"
#import "LCConstants.h"
#import "LCUserPreferences.h"


@interface LCPlaybackManager ()

@property (strong, nonatomic) SPTrack *currentTrack;
@property (strong, nonatomic) SPPlaylist *playlist;
@property (strong, nonatomic) NSArray *tracks;
@property (readonly, nonatomic) LCUserPreferences *userPreferences;

- (NSArray *)tracksFromPlaylist;
- (void)loadPlaylist;
- (void)loadTracks;
- (SPTrack *)nextTrack;
- (void)playTrack:(SPTrack *)track;

@end


@implementation LCPlaybackManager

@dynamic delegate;

#pragma mark - Initialization

- (id)initWithPlaybackSession:(SPSession *)aSession {
    
    self = [super initWithPlaybackSession:aSession];
    if (self) {
        
        self.playbackSession.playbackDelegate = self;
        [self addObserver:self forKeyPath:@"playlist.loaded" options:0 context:nil];
        [self addObserver:self forKeyPath:@"trackPosition" options:0 context:nil];
        [self loadPlaylist];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistChanged) name:kPlaylistChangedNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    
    [self removeObserver:self forKeyPath:@"playlist.loaded"];
    [self removeObserver:self forKeyPath:@"trackPosition"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)loadPlaylist {
    
    [SPPlaylist playlistWithPlaylistURL:[NSURL URLWithString:self.userPreferences.selectedPlaylist] inSession:self.playbackSession callback:^(SPPlaylist *playlist) {
        self.playlist = playlist;
    }];
}

- (void)playlistChanged {
    
	if (![self.playlist.spotifyURL.absoluteString isEqualToString:self.userPreferences.selectedPlaylist]) {
		[self pause];
		self.playlist = nil;
		self.tracks = nil;
		self.currentTrack = nil;
		[self loadPlaylist];
	}
}

- (void)loadTracks {
    
    [SPAsyncLoading waitUntilLoaded:[self tracksFromPlaylist] timeout:10.0 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
        
        NSMutableArray *randomizedTracks = [NSMutableArray arrayWithArray:loadedItems];
        [randomizedTracks lc_shuffle];
        self.tracks = [NSArray arrayWithArray:randomizedTracks];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playbackManagerHasLoadedTracks:)]) {
            [self.delegate playbackManagerHasLoadedTracks:self];
        }
    }];
}

- (void)playTrack:(SPTrack *)track {
    
    [self playTrack:track callback:^(NSError *error) {
        
        if (!error) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(playbackManager:didChangeTrack:)]) {
                [self.delegate playbackManager:self didChangeTrack:self.currentTrack];
            }
        }
        else {
            
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - Actions

- (void)unPause {
        
    if (!self.currentTrack) {
        
        self.currentTrack = [self nextTrack];
        [self playTrack:self.currentTrack];
    }
        
    [self setIsPlaying:YES];
}

- (void)pause {
    
    [self setIsPlaying:NO];
}

- (void)skipTrack {
    
    self.currentTrack = [self nextTrack];
    [self playTrack:self.currentTrack];
}

#pragma mark -

- (NSArray *)tracksFromPlaylist {
    
    NSMutableArray *tracksArray = [NSMutableArray array];
    for (SPPlaylistItem *playlistItem in self.playlist.items) {
        
        if (playlistItem.itemClass == [SPTrack class]) {
            [tracksArray addObject:playlistItem.item];
        }
    }
    
    return [NSArray arrayWithArray:tracksArray];
}

- (SPTrack *)nextTrack {
    
    SPTrack *nextTrack = nil;
    if (self.currentTrack) {
        
        NSInteger currentTrackIndex = [self.tracks indexOfObject:self.currentTrack];
        if (self.tracks.count == currentTrackIndex+1) {
            nextTrack = [self.tracks objectAtIndex:0];
        }
        else {
            nextTrack = [self.tracks objectAtIndex:currentTrackIndex+1];
        }
    } else {
        nextTrack = [self.tracks objectAtIndex:0];
    }
    
    return nextTrack;
}

#pragma mark - Helpers

- (LCUserPreferences *)userPreferences {
    
    return [LCUserPreferences sharedPreferences];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"playlist.loaded"]) {
        
        if (self.playlist.loaded) {
            [self loadTracks];
        }
    }
    else if ([keyPath isEqualToString:@"trackPosition"]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playbackManager:didChangeTrackPosition:)]) {
            [self.delegate playbackManager:self didChangeTrackPosition:self.trackPosition];
        }
    }
}

#pragma mark - SPSessionPlaybackDelegate

- (void)sessionDidEndPlayback:(id<SPSessionPlaybackProvider>)aSession {
    
    self.currentTrack = [self nextTrack];
    [self playTrack:self.currentTrack];
}

@end
