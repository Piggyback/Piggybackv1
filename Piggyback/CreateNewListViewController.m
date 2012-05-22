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

@interface CreateNewListViewController ()

@end

@implementation CreateNewListViewController
@synthesize listNameTextField;

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
    [listNameTextField becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setListNameTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelCreateNewList:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)createNewList:(id)sender {
    NSLog(@"text is: %@", [listNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
    if ([[listNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {
        PBList *newList = [PBList object];
        newList.name = listNameTextField.text;
        newList.createdDate = [NSDate date];
        newList.listEntrys = [[NSMutableSet alloc] init];
        PiggybackAppDelegate *appDelegate = (PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate];
        newList.listOwner = appDelegate.currentUser;
        newList.listOwnerID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
        newList.listCount = [NSNumber numberWithInt:0];
        
        [[RKObjectManager sharedManager] postObject:newList mapResponseWith:[[[RKObjectManager sharedManager] mappingProvider] mappingForKeyPath:@"list"] delegate:(id<RKObjectLoaderDelegate>)[self presentingViewController]];
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}
@end
