//
//  PreVendorViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PreVendorViewController.h"

@implementation PreVendorViewController

@synthesize vendorMapping = _vendorMapping;
@synthesize referralCommentsMapping = _referralCommentsMapping;
@synthesize manager = _manager;
@synthesize vendorItemButton = _vendorItemButton;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create mapping from API data to objective-c objects
    [self setupVendorMapping];
    [self setupReferralCommentsMapping];
    
    // set up manager to handle API reqs: can access through [RKObjectManager sharedManager] also
    self.manager = [RKObjectManager objectManagerWithBaseURL:@"http://192.168.11.28/api"];
}

// **** HELPER FUNCTIONS TO MAP DATA FROM API TO OBJECTS **** //
- (void)setupVendorMapping 
{
    self.vendorMapping = [RKObjectMapping mappingForClass:[Vendor class]];
    [self.vendorMapping mapAttributes:@"name",@"reference",@"lat",@"lng",@"phone",@"addr",@"addrNum",@"addrStreet",@"addrCity",@"addrState",@"addrCountry",@"addrZip",@"vicinity",@"website",@"icon",@"rating",nil];
    [self.vendorMapping mapKeyPath:@"id" toAttribute:@"vid"];
}

- (void)setupReferralCommentsMapping
{
    self.referralCommentsMapping = [RKObjectMapping mappingForClass:[VendorReferralComment class]];
    [self.referralCommentsMapping mapAttributes:@"firstName",@"lastName",@"comment",nil];
    [self.referralCommentsMapping mapKeyPath:@"uid1" toAttribute:@"referredByUID"]; 
}

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
    RKObjectLoader* vendorLoader = [self.manager loadObjectsAtResourcePath:vendorPath objectMapping:self.vendorMapping delegate:destinationViewController];
    vendorLoader.userData = @"vendorLoader";
}

- (void)fetchReferralCommentsData:(id)destinationViewController
{
    NSString* uid = @"2";
    NSString* vid = @"20e88edee4c1c8bb4c59e58015b66146e21ff45b";
    NSString* referralCommentsPath = [[[@"vendorapi/referredby/uid/" stringByAppendingString:uid] stringByAppendingString: @"/vid/"] stringByAppendingString:vid];
    RKObjectLoader* referralCommentsLoader = [self.manager loadObjectsAtResourcePath:referralCommentsPath objectMapping:self.referralCommentsMapping delegate:destinationViewController];
    referralCommentsLoader.userData = @"referralCommentsLoader";
}

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
