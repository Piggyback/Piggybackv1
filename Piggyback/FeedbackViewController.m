//
//  FeedbackViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/29/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "FeedbackViewController.h"
#import <Restkit/Restkit.h>

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

#pragma mark - view lifecycle
@synthesize textField;

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - storyboard stuff

- (IBAction)cancelAddToList:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendFeedback:(id)sender {
    if ([[self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *noText = [[UIAlertView alloc] initWithTitle:@"Empty Submission" message:@"Cannot submit an empty comment!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noText show];
    } else {
        
        
    }
}

@end
