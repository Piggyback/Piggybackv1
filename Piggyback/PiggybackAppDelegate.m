//
//  PiggybackAppDelegate.m
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackAppDelegate.h"
#import "PiggybackTabBarController.h"
#import "LoginViewController.h"
#import <RestKit/RestKit.h>
#import "PBUser.h"
#import "PBList.h"
#import "PBListEntry.h"

static NSString* fbAppId = @"251920381531962";

@implementation PiggybackAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Setting up RestKit SDK */
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:@"http://192.168.11.28/api"];
    
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;     // Enable automatic network activity indicator management
    
    // Setup our object mappings
    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[PBUser class]];
    [userMapping mapAttributes:@"uid", @"fbid", @"email", @"firstName", @"lastName", nil];
    [objectManager.mappingProvider setMapping:userMapping forKeyPath:@"user"];
    
    RKObjectMapping* listEntryMapping = [RKObjectMapping mappingForClass:[PBListEntry class]];
    [listEntryMapping mapAttributes:@"lid", @"vid", @"date", @"comment", nil];
    [objectManager.mappingProvider setMapping:listEntryMapping forKeyPath:@"listEntry"];
    
    RKObjectMapping* listMapping = [RKObjectMapping mappingForClass:[PBList class]];
    [listMapping mapAttributes:@"uid", @"lid", @"date", @"name", nil];
    [listMapping mapRelationship:@"listEntrys" withMapping:listEntryMapping];
    [objectManager.mappingProvider setMapping:listMapping forKeyPath:@"list"];    
    
    /* Setting up Facebook SDK */
    PiggybackTabBarController *rootViewController = (PiggybackTabBarController *)self.window.rootViewController;
    self.facebook = [[Facebook alloc] initWithAppId:fbAppId andDelegate:rootViewController];
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![self.facebook isSessionValid]) {
        UIStoryboard *iphoneStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        LoginViewController *loginViewController = [iphoneStoryboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        loginViewController.delegate = rootViewController;
        
        [self.window makeKeyAndVisible];    // making window visible so loginViewController is pushed modally
        [rootViewController presentViewController:loginViewController animated:NO completion:nil];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.facebook extendAccessTokenIfNeeded];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}

@end
