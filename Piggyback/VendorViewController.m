//
//  VendorViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "VendorViewController.h"
#import "Constants.h"

@implementation VendorViewController

@synthesize vendor = _vendor;
@synthesize addrButton = _addrButton;
@synthesize phoneButton = _phoneButton;
@synthesize vendorImage = _vendorImage;
@synthesize referralComments = _referralComments;
@synthesize referralCommentsLabel = _referralCommentsLabel;
@synthesize referralCommentsTable = _referralCommentsTable;
@synthesize scrollView = _scrollView;

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
    
    // set delegate and datasource for UITableView (referral comments)
    [self.referralCommentsTable setDelegate:self];
    [self.referralCommentsTable setDataSource:self];
    
    [self.scrollView setScrollEnabled:YES];    

}

- (void)viewDidUnload
{
    [self setAddrButton:nil];
    [self setPhoneButton:nil];
    [self setVendorImage:nil];
    [self setReferralCommentsLabel:nil];
    [self setReferralCommentsTable:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// **** PROTOCOL FUNCTIONS FOR RKOBJECTDELEGATE **** //
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"vendorLoader") {
        [self retrieveVendorData:objects];
    } else if (objectLoader.userData == @"referralCommentsLoader") {
        [self retrieveReferralCommentsData:objects];
    }
}

- (void)retrieveVendorData:(NSArray*)objects
{
    self.vendor = [objects objectAtIndex:0];
    self.title = self.vendor.name;
    [self.addrButton setTitle:self.vendor.vicinity forState:UIControlStateNormal];
    [self.phoneButton setTitle:self.vendor.phone forState:UIControlStateNormal];
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.vendor.icon]]];
    [self.vendorImage setImage:image];
}

- (void)retrieveReferralCommentsData:(NSArray*)objects
{
    self.referralComments = objects;
    if (self.referralComments.count > 0) {
        NSString* numReferrals = [NSString stringWithFormat:@"%d",self.referralComments.count];
        self.referralCommentsLabel.text = [[@"Recommended to you by " stringByAppendingString:numReferrals] stringByAppendingString:@" friends:"];
        
        // refresh data so table is loaded with retrieved data
        [self.referralCommentsTable reloadData];
        
        // set table height so that it fits all rows without scrolling
        float totalTableHeight = [self.referralCommentsTable rectForSection:0].size.height;
        CGRect tableBounds = [self.referralCommentsTable bounds];
        [self.referralCommentsTable setBounds:CGRectMake(tableBounds.origin.x,
                                                         tableBounds.origin.y,
                                                         tableBounds.size.width,
                                                         totalTableHeight+20)];
        
        // set frame so that the newly sized table is positioned correctly in parent view
        CGRect tableFrame = [self.referralCommentsTable frame];
        [self.referralCommentsTable setFrame:CGRectMake(tableFrame.origin.x,
                                                        tableFrame.origin.y+(totalTableHeight-tableBounds.size.height)/2,
                                                        tableFrame.size.width,
                                                        tableFrame.size.height)];
        
        // set scrollView
        [self.scrollView setContentSize:CGSizeMake(320,totalTableHeight+280)];

    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{
    NSLog(@"Encountered an error: %@", error);
}

// **** PROTOCOL FUNCTIONS FOR UITABLEVIEWDATASOURCE **** // 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSLog(@"count in numberOfRowsInSection: %i", [self.referralComments count]);
    return [self.referralComments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // get cell for displaying current comment
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"referralCommentCell"];
    VendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
    
    // set name, comment, and image
    cell.textLabel.text = [[vendorReferralComment.firstName stringByAppendingString:@" "] stringByAppendingString:vendorReferralComment.lastName];
    
    cell.detailTextLabel.text = vendorReferralComment.comment;
    cell.detailTextLabel.numberOfLines = 0;
    
    NSString* imgURL = [[@"http://graph.facebook.com/" stringByAppendingString:vendorReferralComment.referredByFBID] stringByAppendingString:@"/picture"];
    UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
    cell.imageView.image = img;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    VendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
    CGSize size = [vendorReferralComment.comment sizeWithFont:[UIFont systemFontOfSize:18.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];

    if (size.height < FACEBOOKPICHEIGHT) {
        return FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN;
    } else {
        return size.height + 2*FACEBOOKPICMARGIN;
    }
}

// **** PROTOCOL FUNCTIONS FOR UITABLEVIEWDELEGATE **** //
// none yet

@end
