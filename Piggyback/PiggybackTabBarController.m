//
//  PiggybackTabBarController.m
//  Piggyback
//
//  Created by Michael Gao on 3/9/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackTabBarController.h"
#import "PiggybackAppDelegate.h"

@implementation PiggybackTabBarController

#pragma - Private Helper Methods

- (void)showLoggedOut {
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:NO completion:nil];
    
    UIViewController* inboxViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"inboxViewController"];
    UIViewController* listsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"listsTableViewController"];
    NSArray* newTabViewControllers = [NSArray arrayWithObjects:inboxViewController, listsTableViewController, nil];
    NSLog(@"setting view controllers");
    self.viewControllers = nil;
    self.viewControllers = newTabViewControllers;
    NSLog(@"finished setting view controllers");
    self.selectedIndex = 0;
}

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

#pragma mark - LoginViewControllerDelegate Methods

- (void)showLoggedIn {
    [self dismissViewControllerAnimated:NO completion:nil]; // dismisses loginViewController
}

#pragma mark - FBSessionDelegate Methods

- (void)fbDidLogin {
    Facebook *facebook = [(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    [self storeAuthData:[facebook accessToken] expiresAt:[facebook expirationDate]];
    
    // get current login instantiation to call getCurrentUserFbInformationAndUid method
    LoginViewController* existingLoginViewController = (LoginViewController*)[self presentedViewController];
    [existingLoginViewController getAndStoreCurrentUserFbInformationAndUid];
}

-(void)fbDidNotLogin:(BOOL)cancelled {
    // do nothing for now
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

- (void)fbDidLogout {   
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    
    [self showLoggedOut];
}

- (void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [self fbDidLogout];
}

@end
