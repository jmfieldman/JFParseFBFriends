//
// JFParseFBFriends.h
//
// Copyright (c) 2015 Jason Fieldman. All rights reserved.
// http://www.fieldman.org
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

/**
 This class helps manage Facebook friend networks through Parse.  Specifically,
 it caches the PFUser objects associated with the current user's friends so that
 those objects are available immediately at launch.
 
 @warning The Parse local data store must be enabled for local caching to work.
 */
@interface JFParseFBFriends : NSObject

/**
 This method updates the Facebook information for the current PFUser.
 
 This method must be called after FB authenticating the user for the first time, and
 may be called anytime you'd like to update the user information.
 
 It will create the following columns in your PFUser table:
 fbId:       The user's FB ID string
 fullname:   The full user name from FB
 lastname:   The last name from FB
 firstname:  The first name from FB
 gender:     The gender string returned by FB 
 
 @warning A valid Facebook session is required for this operation to succeed.
 
 @param block The block to call on completion
 */
+ (void)updateCurrentUserWithCompletion:(void (^)(BOOL success, NSError *error))block;

/*
 Call this method to retrieve an array of PFUser objects associated with the current user's friends.
 
 The behavior of the function is:
 * The block is called once with the data present in the parse local store.  If no friends are found, pfusers will be an empty array.
 * If no friends are found, or the update parameter is YES, the class will query Parse for the latest list of users and call the block again.
 
 @param update Set this to true if you want to query for new friends (i.e. update the data)
 @param block Use this block to handle the returned PFUser array.  The localStore flag tells you if the data came from the local store (YES) or new from the remote database (NO).
 */
+ (void)findFriendsAndUpdate:(BOOL)update completion:(void (^)(BOOL success, BOOL localStore, NSArray* pfusers, NSError *error))block;

@end

#define kJFParseFBFriendsDatastorePin                 @"kJFParseFBFriendsDatastorePin"
#define kJFParseFBFriendsUserDefaultsKeyFriendIDs     @"kJFParseFBFriendsUserDefaultsKeyFriendIDs"
#define kJFParseFBFriendsUserDefaultsKeyCurrentUserID @"kJFParseFBFriendsUserDefaultsKeyCurrentUserID"

