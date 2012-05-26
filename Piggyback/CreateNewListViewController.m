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

@interface CreateNewListViewController ()

@end

@implementation CreateNewListViewController
@synthesize submitButton = _submitButton;
@synthesize listNameTextField = _listNameTextField;
@synthesize realPresentingViewController = _realPresentingViewController;

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
    NSLog(@"in did load objects");
    NSLog(@"num of lists returned: %i", [objects count]);
            
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"in failed to load objects");
}


- (IBAction)cancelCreateNewList:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)createNewList:(id)sender {
    if ([[self.listNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {
        PBList *newList = [PBList object];
        newList.name = self.listNameTextField.text;
        newList.createdDate = [NSDate date];
        newList.listEntrys = [[NSMutableSet alloc] init];
        newList.listOwner = [PBUser findFirstByAttribute:@"userID" withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
        newList.listOwnerID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
        newList.listCount = [NSNumber numberWithInt:0];

        [[RKObjectManager sharedManager] postObject:newList mapResponseWith:[[[RKObjectManager sharedManager] mappingProvider] mappingForKeyPath:@"list"] delegate:(id<RKObjectLoaderDelegate>)self.realPresentingViewController]; 
        [self.navigationController dismissModalViewControllerAnimated:YES];
    } else {
        UIAlertView *emptyNameAlert = [[UIAlertView alloc] initWithTitle:@"Empty list name" message:@"Name cannot be blank!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [emptyNameAlert show];
    }
}
@end
