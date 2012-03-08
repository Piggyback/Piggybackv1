//
//  VendorViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "VendorViewController.h"

@implementation VendorViewController

@synthesize vendor = _vendor;
@synthesize addrButton = _addrButton;
@synthesize phoneButton = _phoneButton;
@synthesize vendorImage = _vendorImage;
@synthesize referralComments = _referralComments;
@synthesize referralCommentsLabel = _referralCommentsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setAddrButton:nil];
    [self setPhoneButton:nil];
    [self setVendorImage:nil];
    [self setReferralCommentsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    if(objectLoader.userData == @"vendorLoader") {
        self.vendor = [objects objectAtIndex:0];
        self.title = self.vendor.name;
        [self.addrButton setTitle:self.vendor.vicinity forState:UIControlStateNormal];
        [self.phoneButton setTitle:self.vendor.phone forState:UIControlStateNormal];
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.vendor.icon]]];
        [self.vendorImage setImage:image];
    } else if (objectLoader.userData == @"referralCommentsLoader") {
        self.referralComments = objects;
        if (self.referralComments.count > 0) {
            NSString* numReferrals = [NSString stringWithFormat:@"%d",self.referralComments.count];
            self.referralCommentsLabel.text = [[@"Recommended to you by " stringByAppendingString:numReferrals] stringByAppendingString:@" friends:"];
        }
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Encountered an error: %@", error);
}

@end
