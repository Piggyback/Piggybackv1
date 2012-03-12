//
//  PiggybackViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "LoginViewController.h"
#import "PiggybackAppDelegate.h"
#import "PBUser.h"

@interface LoginViewController ()
@property int currentFbAPICall;
@property int currentPbAPICall;
@end

@implementation LoginViewController
@synthesize delegate = _delegate;
@synthesize currentFbAPICall = _currentFbAPICall;
@synthesize currentPbAPICall = _currentPbAPICall;

#pragma - Private Helper Methods

- (void)storeCurrentUserFbInformation:(id)meGraphApiResult {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[meGraphApiResult objectForKey:@"name"] forKey:@"Name"];
    [defaults setObject:[meGraphApiResult objectForKey:@"first_name"] forKey:@"FirstName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"last_name"] forKey:@"LastName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"id"] forKey:@"FBID"];
    [defaults synchronize];
}

- (void)getCurrentUserUidFromLogin:(NSString *)fbid {
    // Load the user object via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    NSString* resourcePath = [@"/userapi/user/fbid/" stringByAppendingString:fbid];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {
        // returns user as a naked array in JSON, so we instruct the loader
        // to user the appropriate object mapping
        if ([objectManager.acceptMIMEType isEqualToString:RKMIMETypeJSON]) {
            loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[PBUser class]];
        }
        NSLog(@"in getCurrentUserUidFromLogin:");
    }];
}

#pragma mark - Public Methods
- (void)getAndStoreCurrentUserFbInformationAndUid {
    Facebook *facebook = [(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    
    // Uid is retrieved from request:didLoad: method (FBRequestDelegate method) -- for synchronous purposes
    self.currentFbAPICall = fbAPIGraphMeFromLogin;
    self.currentPbAPICall = pbAPICurrentUserUidFromLogin;
    [facebook requestWithGraphPath:@"me" andDelegate:self];
}

#pragma mark - FBRequestDelegate Methods

- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }    
    
    switch (self.currentFbAPICall) {
        case fbAPIGraphMeFromLogin:
        {
            NSLog(@"in request:didLoad: callback function, case fbAPIGraphMeFromLogin");
            [self storeCurrentUserFbInformation:result];
            [self getCurrentUserUidFromLogin:[result objectForKey:@"id"]];
            
            break;
        }
        default: 
            break;
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    // implement showMessage
    //    [self showMessage:@"Oops, something went haywire."];
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    switch (self.currentPbAPICall) {
        case pbAPICurrentUserUidFromLogin:
        {
            PBUser *currentUser = (PBUser *)[objects objectAtIndex:0];
            NSLog(@"Loaded user: %@", currentUser.firstName);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:currentUser.uid forKey:@"UID"];
            
            [self.delegate showLoggedIn];

            break;
        }
        default:
            break;
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	NSLog(@"Hit error: %@", error);
}

#pragma - IBAction definitions

- (IBAction)loginWithFacebook:(id)sender {
    PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate facebook] authorize:nil];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
