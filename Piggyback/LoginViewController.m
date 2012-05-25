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

NSString* const RK_USER_FBID_RESOURCE_PATH = @"/userapi/user/fbid/";

@synthesize delegate = _delegate;
@synthesize currentFbAPICall = _currentFbAPICall;
@synthesize currentPbAPICall = _currentPbAPICall;

#pragma mark - Private Helper Methods

- (void)storeCurrentUserFbInformation:(id)meGraphApiResult {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[meGraphApiResult objectForKey:@"name"] forKey:@"Name"];
    [defaults setObject:[meGraphApiResult objectForKey:@"first_name"] forKey:@"FirstName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"last_name"] forKey:@"LastName"];
    [defaults setObject:[meGraphApiResult objectForKey:@"id"] forKey:@"FBID"];
    [defaults setObject:[meGraphApiResult objectForKey:@"email"] forKey:@"Email"];
    [defaults synchronize];
}

- (void)getCurrentUserUidFromLogin:(NSString *)fbid {
    // Load the user object via RestKit	
//    RKObjectManager* objectManager = [RKObjectManager sharedManager];
//    NSString* resourcePath = [RK_USER_FBID_RESOURCE_PATH stringByAppendingString:fbid];
//    [objectManager loadObjectsAtResourcePath:resourcePath objectMapping:[objectManager.mappingProvider mappingForKeyPath:@"user"] delegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    PBUser *currentUser = [PBUser findFirstByAttribute:@"fbid" withValue:[NSNumber numberWithInt:[fbid intValue]]];
//    if (!currentUser) {
        self.currentFbAPICall = fbAPIGraphMeFriendsFromLogin;
        Facebook *facebook = [(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
        
        [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
#warning - uncomment the following segment
//    } else {
//        [defaults setObject:currentUser.userID forKey:@"UID"];
//        [defaults synchronize];
//        
//        PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
//        appDelegate.currentUser = currentUser;
//        
//        [self.delegate showLoggedIn];
//    }
}

- (void)addUserAndFriends:(NSArray *)currentUserFBFriends {
    NSLog(@"add user");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    PBUser *newUser = [PBUser object];
    newUser.fbid = [NSNumber numberWithInt:[[defaults objectForKey:@"FBID"] intValue]];
    newUser.email = [defaults objectForKey:@"Email"];
    newUser.firstName = [defaults objectForKey:@"FirstName"];
    newUser.lastName = [defaults objectForKey:@"LastName"];
    
    NSMutableArray *currentUserFBFriendsID = [[NSMutableArray alloc] init];
    for (NSDictionary *currentFriend in currentUserFBFriends) {
        [currentUserFBFriendsID addObject:[NSNumber numberWithInt:[[currentFriend objectForKey:@"id"] intValue]]];
    }
    
    newUser.friendsID = currentUserFBFriendsID;
    
    [[RKObjectManager sharedManager] postObject:newUser mapResponseWith:[[[RKObjectManager sharedManager] mappingProvider] mappingForKeyPath:@"user"] delegate:self]; 
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
//    if ([result isKindOfClass:[NSDictionary class]]) {
//        result = [result objectForKey:@"data"];
//    }
    
    switch (self.currentFbAPICall) {
        case fbAPIGraphMeFromLogin:
        {
            NSLog(@"ID: %@", [result objectForKey:@"id"]);
            [self storeCurrentUserFbInformation:result];
            [self getCurrentUserUidFromLogin:[result objectForKey:@"id"]];

            break;
        }
        case fbAPIGraphMeFriendsFromLogin:
        {
            NSArray *currentUserFBFriends = [result objectForKey:@"data"];
            NSLog(@"num of friends: %i", [currentUserFBFriends count]);
            [self addUserAndFriends:currentUserFBFriends];

            break;
        }
        default: 
            break;
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"FBRequestDelegate Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"did load objects");
    switch (self.currentPbAPICall) {
        case pbAPICurrentUserUidFromLogin:
        {
            PBUser *currentUser = (PBUser *)[objects objectAtIndex:0];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:currentUser.userID forKey:@"UID"];
            [defaults synchronize];
            
            PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.currentUser = currentUser;
                    
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
	NSLog(@"RKObjectLoaderDelegate error: %@", error);
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction definitions

- (IBAction)loginWithFacebook:(id)sender {
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", nil];
    [[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] authorize:permissions];
}

@end
