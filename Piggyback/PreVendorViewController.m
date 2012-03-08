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
    
    [self setupVendorMapping];
}

- (void)setupVendorMapping
{
    // set up mapping from API data to objective-c Vendor object
    self.vendorMapping = [RKObjectMapping mappingForClass:[Vendor class]];
    [self.vendorMapping mapAttributes:@"name",@"reference",@"lat",@"lng",@"phone",@"addr",@"addrNum",@"addrStreet",@"addrCity",@"addrState",@"addrCountry",@"addrZip",@"vicinity",@"website",@"icon",@"rating",nil];
    [self.vendorMapping mapKeyPath:@"id" toAttribute:@"vid"];
    
    // set up mapping from APi data to referral comments object
    self.referralCommentsMapping = [RKObjectMapping mappingForClass:[VendorReferralComment class]];
    [self.referralCommentsMapping mapAttributes:@"firstName",@"lastName",@"comment",nil];
    [self.referralCommentsMapping mapKeyPath:@"uid1" toAttribute:@"referredByUID"];
    
    // set up manager to handle requests
    self.manager = [RKObjectManager objectManagerWithBaseURL:@"http://192.168.11.28/api"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"goToVendorPage"]) {
        
        // fetch API data for vendor info
        NSString* vendorPath = [@"vendorapi/vendor/vid/" stringByAppendingString:self.vendorItemButton.currentTitle];
        RKObjectLoader* vendorLoader = [self.manager loadObjectsAtResourcePath:vendorPath objectMapping:self.vendorMapping delegate:segue.destinationViewController];
        vendorLoader.userData = @"vendorLoader";
        
        // fetch API data for referral comments
        NSString* uid = @"2";
        NSString* vid = @"20e88edee4c1c8bb4c59e58015b66146e21ff45b";
        NSString* referralCommentsPath = [[[@"vendorapi/referredby/uid/" stringByAppendingString:uid] stringByAppendingString: @"/vid/"] stringByAppendingString:vid];
        RKObjectLoader* referralCommentsLoader = [self.manager loadObjectsAtResourcePath:referralCommentsPath objectMapping:self.referralCommentsMapping delegate:segue.destinationViewController];
        referralCommentsLoader.userData = @"referralCommentsLoader";
    }
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
