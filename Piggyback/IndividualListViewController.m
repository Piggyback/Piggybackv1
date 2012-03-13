//
//  IndividualListViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/12/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "IndividualListViewController.h"

@implementation IndividualListViewController

@synthesize list = _list;
@synthesize vendorItemButton = _vendorItemButton;

- (void)setList:(PBList *)list
{
    _list = list;
    self.title = list.name;
}

// functions from kim
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToVendorPage"]) {
        
        // fetch API data for vendor info
        [self fetchVendorData:segue.destinationViewController];
        
        // fetch API data for referral comments
        [self fetchReferralCommentsData:segue.destinationViewController];
    }
}

// **** HELPER FUNCTIONS TO FETCH DATA DURING SEGUE **** //
- (void)fetchVendorData:(id)destinationViewController
{
    NSString* vendorPath = [@"vendorapi/vendor/vid/" stringByAppendingString:self.vendorItemButton.currentTitle];
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* vendorLoader = [objManager loadObjectsAtResourcePath:vendorPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"vendor"] delegate:destinationViewController];
    vendorLoader.userData = @"vendorLoader";
}

- (void)fetchReferralCommentsData:(id)destinationViewController
{
    NSString* uid = @"2";
    NSString* vid = @"20e88edee4c1c8bb4c59e58015b66146e21ff45b";
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    NSString* referralCommentsPath = [[[@"vendorapi/referredby/uid/" stringByAppendingString:uid] stringByAppendingString: @"/vid/"] stringByAppendingString:vid];
    RKObjectLoader* referralCommentsLoader = [objManager loadObjectsAtResourcePath:referralCommentsPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"referral-comment"] delegate:destinationViewController];
    referralCommentsLoader.userData = @"referralCommentsLoader";
}

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
    [self setVendorItemButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
