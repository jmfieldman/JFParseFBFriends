//
// JFParseFBFriends.m
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

#import "JFParseFBFriends.h"
#import <Parse.h>
#import <PFFacebookUtils.h>
#import <FacebookSDK.h>


@interface JFParseFBFriends ()

@property (nonatomic, strong) NSArray *friendIds;

+ (JFParseFBFriends*)sharedInstance;

@end

@implementation JFParseFBFriends

+ (JFParseFBFriends*)sharedInstance {
    static JFParseFBFriends *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[JFParseFBFriends alloc] init];
    });
    return singleton;
}

- (id)init {
    if ((self = [super init])) {
        /* Extract the saved friend ID array */
        _friendIds = [[NSUserDefaults standardUserDefaults] objectForKey:kJFParseFBFriendsUserDefaultsKeyFriendIDs];
        if (!_friendIds) _friendIds = [NSArray array];
    }
    return self;
}

- (void)setFriendIds:(NSArray *)friendIds {
    _friendIds = friendIds;
    [[NSUserDefaults standardUserDefaults] setObject:_friendIds forKey:kJFParseFBFriendsUserDefaultsKeyFriendIDs];
    [[NSUserDefaults standardUserDefaults] setObject:PFUser.currentUser.objectId forKey:kJFParseFBFriendsUserDefaultsKeyCurrentUserID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)updateCurrentUserWithCompletion:(void (^)(BOOL success, NSError *error))block {
    /* Do not operate w/o a current parse user */
    if (!PFUser.currentUser) {
        NSLog(@"JFParseFBFriends: Cannot update current user: PFUser.currentUser == nil");
        dispatch_async(dispatch_get_main_queue(), ^{
            block(NO, [NSError errorWithDomain:@"JFParseFBFriends" code:1 userInfo:nil]);
        });
        return;
    }
    
    /* Issue FB request for /me info */
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            PFUser.currentUser[@"fbId"]      = result[@"id"];
            if (result[@"first_name"]) PFUser.currentUser[@"firstname"] = result[@"first_name"];
            if (result[@"last_name"])  PFUser.currentUser[@"lastname"]  = result[@"last_name"];
            if (result[@"name"])       PFUser.currentUser[@"fullname"]  = result[@"name"];
            if (result[@"gender"])     PFUser.currentUser[@"gender"]    = result[@"gender"]; 
            [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    block(succeeded, error);
                } else {
                    NSLog(@"JFParseFBFriends: Error saving current user info to Parse: %@", error);
                    block(NO, error);
                }
            }];
        } else {
            NSLog(@"JFParseFBFriends: Error retrieving /me info from FB; %@", error);
            block(NO, error);
        }
    }];
    
}

+ (void)findFriendsAndUpdate:(BOOL)update completion:(void (^)(BOOL success, BOOL localStore, NSArray* pfusers, NSError *error))block {
	if (!PFUser.currentUser) {
		NSLog(@"JFParseFBFriends: Cannot find friends if PFUser.currentUser is nil");
		return;
	}
	
    if (![Parse isLocalDatastoreEnabled]) {
        NSLog(@"JFParseFBFriends: Cannot use Parse local datastore to retrieve cached friend list: datastore not enabled");
    } else {
        /* Skip this step if the current user isn't the one we last cached data for */
        if (![[[NSUserDefaults standardUserDefaults] stringForKey:kJFParseFBFriendsUserDefaultsKeyCurrentUserID] isEqual:PFUser.currentUser.objectId]) {
            update = YES;
        } else {
            
            /* Run the datastore query */
            PFQuery *friendQuery = [PFUser query];
            [friendQuery fromPinWithName:kJFParseFBFriendsDatastorePin];
            [friendQuery whereKey:@"fbId" containedIn:[JFParseFBFriends sharedInstance].friendIds];
            [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    block(NO, YES, nil, error);
                } else {
                    block(YES, YES, objects, error);
                }
            }];
            
        }
    }
    
    /* Done if we don't need to update the friends list */
    if (!update && [JFParseFBFriends sharedInstance].friendIds.count) return;
    
    /* Now update the friend list */
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            block(NO, NO, nil, error);
            return;
        }
        
        /* Get friends from the query response */
        NSArray *friendObjects = [result objectForKey:@"data"];
        
        /* Start building the friend ID array */
        NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];

        for (NSDictionary *friendObject in friendObjects) {
            [friendIds addObject:[friendObject objectForKey:@"id"]];
        }
        
        /* Save it for later! */
        [JFParseFBFriends sharedInstance].friendIds = friendIds;
        
        /* Construct a PFUser query that will find friends whose facebook ids are contained in the current user's friend list. */
        PFQuery *friendQuery = [PFUser query];
        [friendQuery whereKey:@"fbId" containedIn:friendIds];
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                block(NO, NO, nil, error);
                return;
            }
            
            /* Pin results! */
            [PFUser pinAllInBackground:objects withName:kJFParseFBFriendsDatastorePin block:^(BOOL succeeded, NSError *error) {
                if (error) {
                    block(NO, NO, nil, error);
                } else {
                    block(YES, NO, objects, error);
                }
            }];
        }];
    }];
}


@end
