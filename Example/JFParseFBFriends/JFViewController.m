//
//  JFViewController.m
//  JFParseFBFriends
//
//  Created by Jason Fieldman on 03/04/2015.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "JFViewController.h"

#import <Parse/Parse.h>
#import <FacebookSDK.h>
#import <PFFacebookUtils.h>
#import "JFParseFBFriends.h"

@interface JFViewController ()

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *getFriends;

@end


@implementation JFViewController


- (id)init {
    if ((self = [super init])) {
        self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _loginButton.frame = CGRectMake(80, 100, self.view.bounds.size.width - 160, 60);
        [_loginButton addTarget:self action:@selector(handleLogin:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_loginButton];
        
        _getFriends = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _getFriends.frame = CGRectMake(80, 200, self.view.bounds.size.width - 160, 60);
        [_getFriends setTitle:@"Get Friends" forState:UIControlStateNormal];
        [_getFriends addTarget:self action:@selector(handleGetFriends:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_getFriends];
        
        [self updateLoginButton];
    }
    return self;
}

- (void)updateLoginButton {
    [_loginButton setTitle:[PFUser currentUser]?@"Logout":@"Login" forState:UIControlStateNormal];
}

- (void)handleLogin:(id)sender {
    if (PFUser.currentUser) {
        [PFUser logOut];
        [[FBSession activeSession] closeAndClearTokenInformation];
        [self updateLoginButton];
        NSLog(@"Logged out");
    } else {
     
        [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"user_friends"] block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                NSLog(@"User logged in through Facebook!");
            }
           
            if (user) {
                [JFParseFBFriends updateCurrentUserWithCompletion:^(BOOL success, NSError *error) {
                    NSLog(@"updateCurrentUserWithCompletion: %d %@", success, error);
                    NSLog(@"Current parse user: %@", PFUser.currentUser);
                }];
            }
            
        }];
        
    }
}

- (void)handleGetFriends:(id)sender {
    [JFParseFBFriends findFriendsAndUpdate:YES completion:^(BOOL success, BOOL localStore, NSArray *pfusers, NSError *error) {
        NSLog(@"findFriendsAndUpdate:completion: success:%d localstore:%d pfusers:%@ error:%@", success, localStore, pfusers, error);
    }];
}

@end
