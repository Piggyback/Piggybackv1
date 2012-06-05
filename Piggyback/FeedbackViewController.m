//
//  FeedbackViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/29/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "FeedbackViewController.h"
#import "PBFeedbackSubmission.h"

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

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    switch (self.currentPbAPICall) {
        case pbAPIPostFeedback:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController dismissModalViewControllerAnimated:YES];
            });
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    // reachability handling
    if (error.code == 2) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connecton with server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        switch (self.currentPbAPICall) {
            case pbAPIPostFeedback:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController dismissModalViewControllerAnimated:YES];
                });
                break;
            }
            default:
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"FeedbackViewController RK Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                NSLog(@"FeedbackViewController RK error: %@", error);
                break;
                break;
            }
        }
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
    [self.navigationController dismissModalViewControllerAnimated:YES];
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
        
        self.currentPbAPICall = pbAPIPostFeedback;
        
        [[RKObjectManager sharedManager] postObject:feedback delegate:self];
    }
}

@end
