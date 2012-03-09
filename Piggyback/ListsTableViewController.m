//
//  ListTableViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#warning app currently shows alert message if user has no lists (uid does not exist in UserLists table)

#import "ListsTableViewController.h"
#import "PiggybackAppDelegate.h"
#import "LoginViewController.h"
#import "PBUser.h"
#import "PBList.h"

@interface ListsTableViewController ()

@property int currentFbAPICall;
@property int currentPbAPICall;

@end

@implementation ListsTableViewController

@synthesize lists = _lists;

@synthesize currentFbAPICall = _currentFbAPICall;
@synthesize currentPbAPICall = _currentPbAPICall;

- (NSArray *)lists {
    if (!_lists) {
        _lists = [[NSArray alloc] init];
    }
    
    return _lists;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma - Private Helper Methods

- (void)showLoggedIn {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)showLoggedOut {
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self presentViewController:loginViewController animated:NO completion:nil];
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

- (void)getCurrentUserFbInformationAndUid:(Facebook *)facebook {
    // Uid is retrieved from request:didLoad: method (FBRequestDelegate method) -- for synchronous purposes
    self.currentFbAPICall = fbAPIGraphMeFromLogin;
    self.currentPbAPICall = pbAPICurrentUserUidFromLogin;
    [facebook requestWithGraphPath:@"me" andDelegate:self];
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

- (void)getCurrentUserLists:(NSString *)uid {
    // Load the user object via RestKit	
    self.currentPbAPICall = pbAPIGetCurrentUserLists;
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    NSString* resourcePath = [@"/listapi/lists/id/" stringByAppendingString:uid];
    [objectManager loadObjectsAtResourcePath:resourcePath delegate:self block:^(RKObjectLoader* loader) {
        // returns user as a naked array in JSON, so we instruct the loader
        // to user the appropriate object mapping
        if ([objectManager.acceptMIMEType isEqualToString:RKMIMETypeJSON]) {
            loader.objectMapping = [objectManager.mappingProvider objectMappingForClass:[PBList class]];
        }
        NSLog(@"in getCurrentUserLists:");
    }];
}

#pragma mark - FBSessionDelegate Methods

- (void)fbDidLogin {
    Facebook *facebook = [(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook];
    [self storeAuthData:[facebook accessToken] expiresAt:[facebook expirationDate]];
    
    // get information about the currently logged in user
    [self getCurrentUserFbInformationAndUid:facebook];
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
            
            [self getCurrentUserLists:[currentUser.uid stringValue]];
            break;
        }
        case pbAPIGetCurrentUserLists:
        {
            NSLog(@"in pbAPIGetCurrentUserLists");
            self.lists = objects;
            [self.tableView reloadData];
            
#warning decide where to place this message call -- does not belong here
            [self showLoggedIn];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NSLog(@"viewWillAppear");
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning table not reloading correctly
    // this method is not being called each time the login modal view disappears -- must reload table view every time the view is about to appear
    // refer to paul hagerty's flickr demos 
    static NSString *CellIdentifier = @"listTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    PBList* myList = [self.lists objectAtIndex:indexPath.row];
    cell.textLabel.text = myList.name;
    
    NSLog(@"cellForRowAtIndexPath list name: %@", myList.name);
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
