//
//  SPAsyncLoadingObserver.m
//  CocoaLibSpotify Mac Framework
//
//  Created by Daniel Kennett on 12/04/2012.
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

#import "SPAsyncLoading.h"

static void * const kSPAsyncLoadingObserverKVOContext = @"SPAsyncLoadingObserverKVO";
static NSMutableArray *observerCache;

@interface SPAsyncLoading ()

-(id)initWithItems:(NSArray *)items loadedBlock:(void (^)(NSArray *))block;
-(id)initWithItems:(NSArray *)items timeout:(NSTimeInterval)timeout loadedBlock:(void (^)(NSArray *loadedItems, NSArray *notLoadedItems))block;

@property (nonatomic, readwrite, copy) NSArray *observedItems;
@property (nonatomic, readwrite, copy) void (^loadedHandler) (NSArray *);
@property (nonatomic, readwrite, copy) void (^loadedWithTimeoutHandler) (NSArray *, NSArray *);
@end

@implementation SPAsyncLoading

+(void)waitUntilLoaded:(id)itemOrItems timeout:(NSTimeInterval)timeout then:(void (^)(NSArray *, NSArray *))block {
	
	NSArray *itemArray = [itemOrItems isKindOfClass:[NSArray class]] ? itemOrItems : [NSArray arrayWithObject:itemOrItems];
	
	SPAsyncLoading *observer = [[SPAsyncLoading alloc] initWithItems:itemArray
															 timeout:timeout
														 loadedBlock:block];
	
	if (observer) {
		if (observerCache == nil) observerCache = [[NSMutableArray alloc] init];
		
		@synchronized(observerCache) {
			[observerCache addObject:observer];
		}
	}
	
}

-(id)initWithItems:(NSArray *)items loadedBlock:(void (^)(NSArray *))block {
	
	BOOL allLoaded = YES;
	for (id <SPAsyncLoading> item in items)
		allLoaded &= item.isLoaded;
	
	if (allLoaded) {
		if (block) dispatch_async(dispatch_get_main_queue(), ^() { block(items); });
		return nil;
	}
	
	self = [super init];
	
	if (self) {
		self.observedItems = items;
		self.loadedHandler = block;
		for (id <SPAsyncLoading> item in self.observedItems) {
			[(id)item addObserver:self
					   forKeyPath:@"loaded"
						  options:0
						  context:kSPAsyncLoadingObserverKVOContext];
			
			if ([item conformsToProtocol:@protocol(SPDelayableAsyncLoading)])
				[(id <SPDelayableAsyncLoading>)item startLoading];
		}
		
		// Since the items async load, an item may have loaded in the meantime.
		[self observeValueForKeyPath:@"loaded"
							ofObject:self.observedItems.lastObject
							  change:nil
							 context:kSPAsyncLoadingObserverKVOContext];
	}
	
	return self;
}

-(id)initWithItems:(NSArray *)items timeout:(NSTimeInterval)timeout loadedBlock:(void (^)(NSArray *, NSArray *))block {
	
	self = [self initWithItems:items loadedBlock:nil];
	
	if (self == nil) {
		// All were loaded already.
		if (block) block(items, nil);
		return nil;
	}
	
	if (self) {
		self.loadedWithTimeoutHandler = block;
		[self performSelector:@selector(triggerTimeout)
				   withObject:nil
				   afterDelay:timeout];
	}
	
	return self;
}

-(void)dealloc {
	
	// Cancel previous delayed calls to this 
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(triggerTimeout)
                                               object:nil];
	
	for (id <SPAsyncLoading> item in self.observedItems)
		[(id)item removeObserver:self forKeyPath:@"loaded"];
}

@synthesize observedItems;
@synthesize loadedHandler;
@synthesize loadedWithTimeoutHandler;

-(void)triggerTimeout {
	
	NSMutableArray *loadedItems = [NSMutableArray arrayWithCapacity:self.observedItems.count];
	NSMutableArray *notLoadedItems = [NSMutableArray arrayWithCapacity:self.observedItems.count];
	
	for (id <SPAsyncLoading> item in self.observedItems) {
		if (item.isLoaded)
			[loadedItems addObject:item];
		else {
			[notLoadedItems addObject:item];
		}
	}
	
	if (self.loadedWithTimeoutHandler) dispatch_async(dispatch_get_main_queue(), ^() {
		self.loadedWithTimeoutHandler([NSArray arrayWithArray:loadedItems], [NSArray arrayWithArray:notLoadedItems]);
		self.loadedHandler = nil;
		self.loadedWithTimeoutHandler = nil;
		@synchronized(observerCache) {
			[observerCache removeObject:self];
		}
	});
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kSPAsyncLoadingObserverKVOContext) {
        
		BOOL allLoaded = YES;
		for (id <SPAsyncLoading> item in self.observedItems)
			allLoaded &= item.isLoaded;
		
		if (allLoaded) {
			
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(triggerTimeout)
													   object:nil];
			
			if (self.loadedHandler || self.loadedWithTimeoutHandler) dispatch_async(dispatch_get_main_queue(), ^() {
				if (self.loadedHandler)
					self.loadedHandler(self.observedItems);
				else if (self.loadedWithTimeoutHandler)
					self.loadedWithTimeoutHandler(self.observedItems, nil);
				
				self.loadedHandler = nil;
				self.loadedWithTimeoutHandler = nil;
				@synchronized(observerCache) {
					[observerCache removeObject:self];
				}
			});
		}
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
