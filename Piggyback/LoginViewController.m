//
//  PiggybackViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "LoginViewController.h"
#import "PiggybackAppDelegate.h"


@implementation LoginViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma - Private Helper Methods

- (void)showLoggedIn {
    // segue to inbox view
    // present listview programatically (no segue). possibly display loginView as a modal view. dismiss once user is logged in.
    // modal sounds ideal. switch rootViewController to listView (eventually inboxView) and check if user is logged in within piggybackAppDelegate.
    // if not logged in, then display login modal view. dismiss once user logs in.
}

- (void)showLoggedOut {
    // show login view
    // present loginView (self) programatically. possibly display loginView as a modal view. present once user is logged out.
}

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)storeCurrentUserFbInformation:(id)meGraphApiResult {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[meGraphApiResult objectForKey:@"name"] forKey:@"Name"];
    [defaults setObject:[meGraphApiResult objectForKey:@"first_name"] forKey:@"FirstName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"last_name"] forKey:@"LastName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"id"] forKey:@"FBID"];
    [defaults synchronize];
}

- (void)getCurrentUserFbInformation {
    PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate facebook] requestWithGraphPath:@"me" andDelegate:self];
}

#pragma mark - FBRequestDelegate Methods

- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }    
    
    if ([result objectForKey:@"name"]) {
        [self storeCurrentUserFbInformation:result];
    }
}

#pragma mark - FBSessionDelegate Methods

- (void)fbDidLogin {
    // get information about the currently logged in user
    [self getCurrentUserFbInformation];
    
    [self showLoggedIn];
    
    PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self storeAuthData:[[appDelegate facebook] accessToken] expiresAt:[[appDelegate facebook] expirationDate]];
}

-(void)fbDidNotLogin:(BOOL)cancelled {
    // do nothing for now
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

- (void)fbDidLogout {   
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self showLoggedOut];
}

/**
 * Called when the session has expired.
 */
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate facebook] isSessionValid]) {
        [self showLoggedOut];
    } else {
        [self showLoggedIn];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma - IBAction definitions

- (IBAction)loginWithFacebook:(id)sender {
    PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[appDelegate facebook] isSessionValid]) {
        [[appDelegate facebook] authorize:nil];
    } else {
        // do nothing for now
    }
}

@end
