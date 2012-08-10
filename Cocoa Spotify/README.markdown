# CocoaLibSpotify #

CocoaLibSpotify is an Objective-C wrapper around our libspotify library. It provides easy access to libspotify's features in a friendly, KVC/O compliant Objective-C wrapper.

CocoaLibSpotify requires libspotify.framework, which isn't included in the repository. The Mac Framework and iOS Library  Xcode projects include a build step to download and unpack it from developer.spotify.com automatically. If this fails for some reason, download it manually from developer.spotify.com and unpack it into the project folder.

## Release Notes ##

You can find the latest release notes in the [CHANGELOG.markdown](https://github.com/spotify/cocoalibspotify/blob/master/CHANGELOG.markdown) file.

## Threading ##

As of CocoaLibSpotify 2.0, the framework uses an internal threading model to run the libSpotify library on a background thread, allowing your application to remain responsive when libSpotify is experiencing heavy load.

However, libSpotify is **not** thread-safe, and all methods in CocoaLibSpotify that provide access to libSpotify types are guarded to prevent access from the wrong thread. If you must access libSpotify types directly, first file an issue so we can make a thread-aware API in CocoaLibSpotify for your use case, then make sure you use libDispatch to call the relevant API on the correct queue, which `SPSession` provides an accessor for.

Bad: 

```
sp_artist *artist = …; // An artist.
SPArtist *artistObj = [SPArtist artistWithArtistStruct:artist inSession:session];
// ^ The above line will throw an assertion for being called on the wrong queue.
```

Instead, you should create the object on the correct queue and safely pass it back to the target queue (the main queue if you're doing UI work) for further use:

```
dispatch_async([SPSession libSpotifyQueue], ^{
	sp_artist *artist = …; // An artist.
	SPArtist *artistObj = [SPArtist artistWithArtistStruct:artist inSession:session];
	dispatch_async(dispatch_get_main_queue(), ^{ self.artist = artistObj; }); 
});
```

## A Note On "Loading" ##

CocoaLibSpotify does a lot of asynchronous loading — tracks, playlists, artists, albums, etc can all finish loading their metadata after you get an object. In the case of user playlists and searching, this can be a number of seconds.

Do *not* poll these properties - when you do a polling loop you can, in many cases, stop CocoaLibSpotify's ability to do any work, causing the metadata to never load.

Instead, most objects in the CocoaLibSpotify object model (including metadata classes like `SPArtist`, `SPTrack`, `SPAlbum`, etc and "action" classes like `SPSearch` etc) conform to the `SPAsyncLoading` protocol, and you can use the `SPAsyncLoading` helper class to get a block callback when the given item(s) are loaded. For example:

```
	NSArray *someTracks = …; // Some tracks.

	[SPAsyncLoading waitUntilLoaded:someTracks timeout:10.0 then:^(NSArray *loadedTracks, NSArray *notLoadedTracks) {

		NSLog(@"The following tracks are loaded: %@", loadedTracks);
	}];
```

Additionally, CocoaLibSpotify's properties are Key-Value Observing compliant, and the best practice is to add an observer to the properties you're interested in to receive a notification callback when the metadata is loaded.

For example, if you want to know when search results come back, add an observer like this:

    [self addObserver:self forKeyPath:@"search.tracks" options:0 context:nil];
    self.search = [SPSearch searchWithSearchQuery:@"Hello" inSession:[SPSession sharedSession]];

When the tracks in the search are updated, you'll get a callback:


    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    	if ([keyPath isEqualToString:@"search.tracks"])
    		NSLog(@"Search found tracks: %@", self.search.tracks);
    }

Key-Value Observing is a core technology in the Mac and iOS SDKs, and extensive documentation and examples can be found in Apple's [developer documentation](http://developer.apple.com/library/ios/#documentation/General/Conceptual/DevPedia-CocoaCore/KVO.html).

## Building -  Mac OS X ##

The Xcode project requires Xcode 4.3 and Mac OS X 10.7 to build since it uses ARC. However, the built binary can be deployed on 64-bit systems running Mac OS X 10.6 or higher.

The built CocoaLibSpotify.framework contains libspotify.framework as a child framework. Sometimes, Xcode gives build errors complaining it can't find <libspotify/api.h>. If you get this, manually add the directory libspotify.framework is in to your project's "Framework Search Paths" build setting. For example, if you're building the CocoaLibSpotify project alongside your application as an embedded Xcode project then copying it into your bundle, you'd have this:

`$CONFIGURATION_BUILD_DIR/CocoaLibSpotify.framework/Versions/Frameworks`

Otherwise, you'd point to the downloaded libspotify.framework manually, something like this:

`../../libspotify-12.1.45-Darwin-universal`

## Building - iOS ##

The Xcode project requires Xcode 4.3 and iOS SDK version 5.0+ to build since it uses ARC. However, the built binary can be deployed on any iOS version from version 4.0.

The built libCocoaLibSpotify contains libspotify internally as a static library, as well as all of the required header files in a directory called "include".

In addition, you MUST include SPLoginResources.bundle as a resource of your application.

When including libCocoaLibSpotify in your application, you must also link to the following frameworks:

- SystemConfiguration.framework
- CFNetwork.framework
- libstdc++
- CoreAudio.framework
- AudioToolbox.framework
- AVFoundation.framework

In addition, you must add the following two items to the "Other Linker Flags" build setting:

- -all_load
- -ObjC

If you're building the CocoaLibSpotify project alongside your application as an embedded Xcode project then linking it with your application in a build step, you can tell Xcode where the header files are by adding the following setting to the "Framework Search Paths" build setting of your project:

`$CONFIGURATION_BUILD_DIR/include`

Otherwise, you can simply add all of the header files to your project manually. 

Once everything is set up, simply import the following header to get started with CocoaLibSpotify!

`#import "CocoaLibSpotify.h"`

## Documentation ##

The headers of CocoaLibSpotify are well documented, and we've provided an Xcode DocSet to provide documentation right in Xcode. With these and the sample projects, you should have everything you need to dive right in!

## Unit Tests ##

CocoaLibSpotify now ships with a number of unit tests, which run inside a standalone application built by the project. If you find a bug in CocoaLibSpotify, please fork the project, add or modify a unit test so it fails (demonstrating the bug), then issue a pull request. We can then fix the underlying bug and keep your test so it stays that way.

To run the tests, open the "CocoaLibSpotify Mac Framework" or "CocoaLibSpotify iOS Library" project as needed, then switch to the "CocoaLSTests" scheme in Xcode. Then:

- Edit the scheme to pass the following arguments on launch: -TestUserName MyAwesomeUser -TestPassword MyAwesomePassword
- Add your `appkey.c` file to the `common/Tests` folder in the repository. DO NOT commit your key!
- Run the "CocoaLSTests" target.

You'll find examples on how to make a good test in the tests themselves.

## Contact ##

If you have any problems or find any bugs, see our GitHub page for known issues and discussion. Otherwise, we may be available in irc://irc.freenode.net/spotify. 