//
//  CreateNewListViewController.m
//  Piggyback
//
//  Created by Michael Gao on 5/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "CreateNewListViewController.h"
#import "PiggybackAppDelegate.h"
#import "PBList.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"

@interface CreateNewListViewController ()

@end

@implementation CreateNewListViewController
@synthesize submitButton = _submitButton;
@synthesize listNameTextField = _listNameTextField;
@synthesize realPresentingViewController = _realPresentingViewController;

- (void) reachabilityChanged:(NSNotification *)note {
    Reachability * reach = [note object];
    if([reach isReachable])
    {
        [self postData];
    } else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connection with server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) checkHostStatus {
    // allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"beta.getpiggyback.com"];
    
    // tell the reachability that we DONT want to be reachable on 3G/EDGE/CDMA
    reach.reachableOnWWAN = YES;
    
    // here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [reach startNotifier];
}

- (void) postData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    
    PBList *newList = [PBList object];
    newList.name = self.listNameTextField.text;
    newList.createdDate = [dateFormatter stringFromDate:[NSDate date]];
    newList.listEntrys = [[NSMutableSet alloc] init];
    newList.listOwner = [PBUser findFirstByAttribute:@"userID" withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    newList.listOwnerID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
    newList.listCount = [NSNumber numberWithInt:0];
    
    [[RKObjectManager sharedManager] postObject:newList mapResponseWith:[[[RKObjectManager sharedManager] mappingProvider] mappingForKeyPath:@"list"] delegate:nil];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

// return button on keyboard calls the same function as pressing the 'submit' button
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self createNewList:self];
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.listNameTextField.delegate = self;
    [self.listNameTextField becomeFirstResponder];
    self.submitButton.layer.cornerRadius = 5;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setListNameTextField:nil];
    [self setSubmitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController dismissModalViewControllerAnimated:YES];
    });
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    UIAlertView *alert;
    if (error.code == 2) {
        alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connection with server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    else {
        alert = [[UIAlertView alloc] initWithTitle:@"CreateNewListViewController RK Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    [alert show];
    NSLog(@"CreateNewListViewController RK error: %@", error);
}


- (IBAction)cancelCreateNewList:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)createNewList:(id)sender {
    if ([[self.listNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {
        [self checkHostStatus];
    } else {
        UIAlertView *emptyNameAlert = [[UIAlertView alloc] initWithTitle:@"Empty list name" message:@"Name cannot be blank!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [emptyNameAlert show];
    }
}
@end
