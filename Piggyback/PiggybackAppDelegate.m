//
//  PiggybackAppDelegate.m
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackAppDelegate.h"
#import <RestKit/RestKit.h>

@implementation PiggybackAppDelegate 

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    RKClient *client = [RKClient clientWithBaseURL:@"https://maps.googleapis.com/maps/api/place/search/json?"];
    
    [client get:@"location=-33.8670522,151.1957362&radius=500&types=food&name=harbour&sensor=false&key=AIzaSyA4g2M3awvxLFMxKfTyM2rBwoWxfs_1Ljs" delegate:self];
    //    NSLog(@"I am the client you just created: %@",client);
    //    [client.HTTPHeaders setValue:@"SOhi1ZzY3e0aQaStZdAroUGfo2y4Hrc4pGnV3IyH" forKey:@"X-Parse-Application-Id"];
    //    [client.HTTPHeaders setValue:@"JyQv835eCDNiY42wyhxvkhZy0qMdBKIAdkL1GSRu" forKey:@"X-Parse-REST-API-Key"];

    return YES;
}
				
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse *)response {
    NSLog(@"and then this function was called");
        if ([request isGET]) {
            NSLog(@"response status code: %ld",(long)response.statusCode);
//            if ([response isOK]) {
//                NSLog(@"Get request succeeded!");
//            }
        }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error{
    NSLog(@"an error occurred: %@",error);
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
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
