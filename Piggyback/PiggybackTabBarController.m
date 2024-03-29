//
//  PiggybackTabBarController.m
//  Piggyback
//
//  Created by Michael Gao on 3/9/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackTabBarController.h"
#import "PiggybackAppDelegate.h"
#import <RestKit/CoreData.h>

@implementation PiggybackTabBarController

#pragma mark - Private Helper Methods

- (void)showLoggedOut {
    // release all pre-existing view controllers
    self.viewControllers = nil;
    
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    loginViewController.delegate = self;
    [self presentViewController:loginViewController animated:NO completion:nil];
    
    // release existing view controllers and create new instances for next user who logs in
    UIViewController* inboxNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"inboxNavigationController"];
    UIViewController* listsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"listsNavigationController"];
    UIViewController* searchNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchNavigationController"];
    NSArray* newTabViewControllers = [NSArray arrayWithObjects:inboxNavigationController, listsNavigationController, searchNavigationController, nil];
    self.viewControllers = newTabViewControllers;
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
    [(LoginViewController*)[self presentedViewController] getAndStoreCurrentUserFbInformationAndUid];    
}

-(void)fbDidNotLogin:(BOOL)cancelled {
    // do nothing for now
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"fb token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

- (void)fbDidLogout {   
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    
    // clear coredata
    [[[RKObjectManager sharedManager] objectStore] deletePersistantStoreUsingSeedDatabaseName:nil];
    
    NSLog(@"logout");
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
