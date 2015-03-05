# JFParseFBFriends

[![CI Status](http://img.shields.io/travis/Jason Fieldman/JFParseFBFriends.svg?style=flat)](https://travis-ci.org/Jason Fieldman/JFParseFBFriends)
[![Version](https://img.shields.io/cocoapods/v/JFParseFBFriends.svg?style=flat)](http://cocoadocs.org/docsets/JFParseFBFriends)
[![License](https://img.shields.io/cocoapods/l/JFParseFBFriends.svg?style=flat)](http://cocoadocs.org/docsets/JFParseFBFriends)
[![Platform](https://img.shields.io/cocoapods/p/JFParseFBFriends.svg?style=flat)](http://cocoadocs.org/docsets/JFParseFBFriends)

Being able to quickly prototype social apps with Parse/Facebook is great.  One of the annoying tasks is managing the caching/update of the user's friend network.

This helper class is designed to streamline the management of your Parse PFUser's Facebook info, and use blocks to push seamless friend-list updates to your UI.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Three steps to integrating JFParseFBFriends into your application:

* Make sure you've followed the Parse/Facebook integration guide here: https://www.parse.com/tutorials/integrating-facebook-in-ios

* Inject `+[JFParseFBFriends updateCurrentUserWithCompletion:]` into `+[PFFacebookUtils logInWithPermissions:block:]` to ensure that your PFUser.currentUser object is properly linked to the current Facebook user.  

	```objective-c
[PFFacebookUtils logInWithPermissions:@[@"public_profile", @"user_friends"] block:^(PFUser *user, NSError *error) {
	/* ... */
	if (user) {
		[JFParseFBFriends updateCurrentUserWithCompletion:^(BOOL success, NSError *error) {
			/* ... */
		}];
	}
}];
```

	This requires additional columns in your `PFUser` table: fbId, fullname, firstname, lastname, gender (and will autogenerate them if the client is allowed to modify your parse tables).
	
	You may call `+[JFParseFBFriends updateCurrentUserWithCompletion:]` any time you'd like to link `PFUser.currentUser` to the current Facebook session's user. 

* Use `+[JFParseFBFriends findFriendsAndUpdate:completion:]` any time you'd like to get an `NSArray` of `PFUser` objects that are friends with the current user:	

	```objective-c
[JFParseFBFriends findFriendsAndUpdate:YES completion:^(BOOL success, BOOL localStore, NSArray *pfusers, NSError *error) {
        /* ... */
}];
```

	This method will first query your local datastore and call the block with the cached friend array.  If there are no friends, or `update` is `YES`, it will query Parse for a new list of friends, cache the resulting array into your local datastore, and call the block again with the updated data.

	You should use this block to update your controller's local model and refresh any UI that is dependent on the friend array.

## Requirements

JFParseFBFriends has explicit dependencies on the `Parse`, `Facebook-iOS-SDK` and `ParseFacebookUtils` pods.  It also assumes that you are using the Parse/Facebook integration method outlined here: https://www.parse.com/tutorials/integrating-facebook-in-ios

You should also enable the Parse local datastore if you'd like to cache the `PFUser` objects of your current friends.  Without the local datastore you will be required to hit parse each time you want the friend array.  Be sure to include `+[Parse enableLocalDatastore]` before you call `+[Parse setApplicationId:clientKey:]`.

## Installation

JFParseFBFriends is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "JFParseFBFriends"

## Author

Jason Fieldman, jason@fieldman.org

## License

JFParseFBFriends is available under the MIT license. See the LICENSE file for more info.

