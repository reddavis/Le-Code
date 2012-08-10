CocoaLibSpotify 2.0 for libspotify 12, released May 23rd 2012
=============================================================

* Huge re-engineering of CocoaLibSpotify to run libspotify in its own background thread. This has brought on a large set of API changes, and you must now be aware of potential threading issues. See the project's README file for more information.

* Added small and large cover images to `SPAlbum`, as well as `smallestAvailableCover` and `largestAvailableCover` convenience methods.

* Added `fetchLoginUserName:` method to `SPSession` to get the username used to log into the current session. This also fixes `[SPSessionDelegate -session:didGenerateLoginCredentials:forUserName]` giving an incorrect username for users logging in with Facebook details.

* Added the ability to control scrobbling to various social services, including Last.fm and the user's connected Facebook account.

* Added `SPAsyncLoading` and `SPDelayableAsyncLoading`, a new way of working with objects that load asynchonously. If you pass `SPAsyncLoadingManual` to `[SPSession -initWithApplicationKey:userAgent:loadingPolicy:error:]`, anything conforming to `SPDelayableAsyncLoading` (such as user playlists, etc) won't be loaded until you want them to load. See the README file and sample projects for examples.

* Added a number of unit tests.


CocoaLibSpotify for libspotify 11, released March 27th 2012
===========================================================

* SPSearch can now search for playlists.

* SPSearch can now do a "live search", appropriate for showing a "live search" menu when the user is typing. See `[SPSearch +liveSearchWithSearchQuery:inSession:]` for details.

* Added `[SPTrack -playableTrack]`. Use this to get the actual track that will be played instead of the receiver if the receiver is unplayable in the user's locale.  Normally, your application does not need to worry about this but the method is here for completeness.

* Added the `topTracks` property to `SPArtistBrowse`. All browse modes fill in this property, and the `tracks` property has been deprecated and will be removed in a future release.

* Added `[SPSession -attemptLoginWithUserName:existingCredential:rememberCredentials:]` and `[<SPSessionDelegate> -session:didGenerateLoginCredentials:forUserName:]`. Every time a user logs in you'll be given a safe credential "blob" to store as you wish (no encryption is required). This blob can be used to log the user in again. Use this if you want to save login details for multiple users.

* Added `[SPSession -flushCaches]`, appropriate for use when iOS applications go into the background. This will ensure libspotify's caches are flushed to disk so saved logins and so on will be saved.

* Added the `audioDeliveryDelegate` property to `SPSession`, which conforms to the `<SPSessionAudioDeliveryDelegate>` protocol, which allows you more freedom in your audio pipeline. The new protocol also uses standard Core Audio types to ease integration.

* Added SPLoginViewController to the iOS library. This view controller provides a Spotify-designed login and signup flow.