//
//  PHAppDelegate.m
//  PHStreets44 project - Streets '44 iOS app
//
//  Created by Pawel Hryczuk on 1.05.2015.
//  Copyright (c) 2015 Pawel Hryczuk. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//

#import "PHAppDelegate.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "PHConstants.h"
#import "PHAppContext.h"
#import "GAI.h"

@implementation PHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupLogging];
    [self setupGoogleAnalytics];

    APP_CONTEXT; // ensures the context is initialized on app start
    [self setupWindow];

    return YES;
}

- (void)setupLogging {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogDebug(@"Starting application");
}

- (void)setupGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;

#ifdef DEBUG
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:@"<insert your tracking id here>"];
    [[GAI sharedInstance] setDryRun:YES];
#else
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    [[GAI sharedInstance] trackerWithTrackingId:@"<insert your tracking id here>"];
    [[GAI sharedInstance] setDryRun:NO];
#endif
}

- (void)setupWindow {
    [self setupRootViewController];
    [self.window makeKeyAndVisible];
}

- (void)setupRootViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initialViewController = (UINavigationController *)[storyboard instantiateInitialViewController];
    self.window.rootViewController = initialViewController;
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
