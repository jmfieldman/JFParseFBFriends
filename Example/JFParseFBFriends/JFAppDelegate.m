//
//  JFAppDelegate.m
//  JFParseFBFriends
//
//  Created by CocoaPods on 03/04/2015.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "JFAppDelegate.h"
#import "JFViewController.h"

#import <Parse/Parse.h>
#import <FacebookSDK.h>
#import <PFFacebookUtils.h>
#import "JFParseFBFriends.h"

@implementation JFAppDelegate


/* REQUIRED FOR FB INTEGRATION */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    /* ------- Initialize Parse ------- */
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"i5h3M4hzq51DmMjCzC4NFKTtWguYb17szcIQO9mn" clientKey:@"bfaDpQYrTwhVGRD9vbihrQhbsvIkfonDO1Pvygnu"];
    [PFFacebookUtils initializeFacebook];
   
    /* Create window */
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[JFViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    /* Required by API */
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    /* Required by API */
    [[PFFacebookUtils session] close];
}

@end
