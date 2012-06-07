//
//  FeedbackViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/29/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "FeedbackViewController.h"
#import "PBFeedbackSubmission.h"
#import "PiggybackTabBarController.h"

@interface FeedbackViewController ()

@property int currentPbAPICall;

@end

@implementation FeedbackViewController

@synthesize currentPbAPICall = _currentPbAPICall;

#pragma mark - keyboard delegate functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.textField resignFirstResponder];
    }
}

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
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendFeedback:(id)sender {
    if ([[self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *noText = [[UIAlertView alloc] initWithTitle:@"Empty Submission" message:@"Cannot submit an empty comment!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noText show];
    } else {
        PBFeedbackSubmission *feedback = [[PBFeedbackSubmission alloc] init];
        
        feedback.comment = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        feedback.uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
        
        // set date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
        feedback.date = [dateFormatter stringFromDate:[NSDate date]];
        
        [[RKObjectManager sharedManager] postObject:feedback delegate:nil];
        
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}

@end
