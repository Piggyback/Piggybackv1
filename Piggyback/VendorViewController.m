//
//  VendorViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "VendorViewController.h"
#import "Constants.h"
#import "VendorReferralComment.h"

@implementation VendorViewController

@synthesize vendor = _vendor;
@synthesize addrButton = _addrButton;
@synthesize phoneButton = _phoneButton;
@synthesize vendorImage = _vendorImage;
@synthesize referralComments = _referralComments;
@synthesize referralCommentsLabel = _referralCommentsLabel;
@synthesize referralCommentsTable = _referralCommentsTable;
@synthesize scrollView = _scrollView;

#pragma mark getter / setter methods

- (NSMutableArray*)referralComments {
    if (_referralComments == nil) {
        _referralComments = [[NSMutableArray alloc] init];
    }
    return _referralComments;
}

#pragma mark table data source protocol methods
// **** PROTOCOL FUNCTIONS FOR UITABLEVIEWDATASOURCE **** // 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.referralComments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // get cell for displaying current comment
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"referralCommentCell"];
    VendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
    
    // set name, comment, and image
    cell.textLabel.text = [[vendorReferralComment.referrer.firstName stringByAppendingString:@" "] stringByAppendingString:vendorReferralComment.referrer.lastName];
    
    if ([vendorReferralComment.referralLid intValue] > 0) {
        cell.detailTextLabel.text = vendorReferralComment.listEntryComment;
    } else {
        cell.detailTextLabel.text = vendorReferralComment.comment;
    }
    cell.detailTextLabel.numberOfLines = 0;
    
    NSString* imgURL = [[@"http://graph.facebook.com/" stringByAppendingString:[vendorReferralComment.referrer.fbid stringValue]] stringByAppendingString:@"/picture"];
    UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
    cell.imageView.image = img;
    
    NSLog(@"height in cell for index path is %f",[self.referralCommentsTable rectForSection:0].size.height);
    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    NSLog(@"in the height function");
    VendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
    CGSize size = [vendorReferralComment.comment sizeWithFont:[UIFont systemFontOfSize:18.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
    
    if (size.height < FACEBOOKPICHEIGHT) {
        NSLog(@"height of row is %f",FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN);
        return FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN;
    } else {
        NSLog(@"height of row is %f",size.height + 2*FACEBOOKPICMARGIN);
        
        return size.height + 2*FACEBOOKPICMARGIN;
    }
}

#pragma mark - View lifecycle

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ************ set delegate and datasource for UITableView (referral comments) ************ //
    [self.referralCommentsTable setDelegate:self];
    [self.referralCommentsTable setDataSource:self];
    
    [self.scrollView setScrollEnabled:YES];
    
    // ************ display vendor information and image ********* //
    self.title = self.vendor.name;
    [self.addrButton setTitle:self.vendor.vicinity forState:UIControlStateNormal];
    [self.phoneButton setTitle:self.vendor.phone forState:UIControlStateNormal];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_queue_t downloadImageQueue = dispatch_queue_create("downloadImage",NULL);
    dispatch_async(downloadImageQueue, ^{
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.vendor.icon]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.vendorImage setImage:image];
        });
    });
    
    // ************ display referral comments ********* //
    if ([self.referralComments count] > 0) {
        
        NSString* numReferrals = [NSString stringWithFormat:@"%d",self.referralComments.count];
        if (self.referralComments.count == 1) {
            self.referralCommentsLabel.text = [[@"Recommended to you by " stringByAppendingString:numReferrals] stringByAppendingString:@" friend:"];
        } else {
            self.referralCommentsLabel.text = [[@"Recommended to you by " stringByAppendingString:numReferrals] stringByAppendingString:@" friends:"];
        }
        
        // set table height so that it fits all rows without scrolling
        CGFloat totalTableHeight = [self.referralCommentsTable rectForSection:0].size.height;
        NSLog(@"height of table in view did load is %f",totalTableHeight);
        
        CGRect tableBounds = [self.referralCommentsTable bounds];
        NSLog(@"height of bounds before they are set is %f",tableBounds.size.height);
        [self.referralCommentsTable setBounds:CGRectMake(tableBounds.origin.x,
                                                         tableBounds.origin.y,
                                                         tableBounds.size.width,
                                                         totalTableHeight+20)];
        
        CGRect tableBounds2 = [self.referralCommentsTable bounds];
        NSLog(@"height of bounds after they are set is %f",tableBounds2.size.height);
        
        // set frame so that the newly sized table is positioned correctly in parent view
        CGRect tableFrame = [self.referralCommentsTable frame];
        [self.referralCommentsTable setFrame:CGRectMake(tableFrame.origin.x,
                                                        tableFrame.origin.y+(totalTableHeight-tableBounds.size.height)/2,
                                                        tableFrame.size.width,
                                                        tableFrame.size.height)];
        
        // refresh data so table is loaded with retrieved data
        [self.referralCommentsTable reloadData];
        
        // set scrollView
        [self.scrollView setContentSize:CGSizeMake(320,totalTableHeight+280)];
        
    }

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
