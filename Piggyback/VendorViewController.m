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
#import <QuartzCore/QuartzCore.h>

@interface VendorViewController () 

typedef enum tableViewSection {
    vendorInfoSection,
    vendorReferralsSection
} tableViewSection;

@property BOOL hasAddress;
@property BOOL hasPhone;
@property (nonatomic, strong) NSMutableArray* vendorInfo;

@end

@implementation VendorViewController
@synthesize vendorTableView = _vendorInfoTable;

@synthesize vendor = _vendor;
@synthesize vendorImage = _vendorImage;
@synthesize referralComments = _referralComments;
@synthesize scrollView = _scrollView;

@synthesize hasAddress = _hasAddress;
@synthesize hasPhone = _hasPhone;
@synthesize vendorInfo = _vendorInfo;

#pragma mark getter / setter methods

- (void)setVendor:(Vendor *)vendor
{    
    self.vendorInfo = [[NSMutableArray alloc] init];
    
    // check if vendor has address and phone number
    if ([vendor.addrNum length] == 0 && [vendor.addrStreet length] == 0 && [vendor.addrCity length] == 0)  
        self.hasAddress = NO; 
    else {
        self.hasAddress = YES;
        
        // build self.formattedAddress
        NSMutableString* formattedAddress = [[NSMutableString alloc] init];
        formattedAddress = [[NSMutableString alloc] init];
        if ([vendor.addrNum length] && [vendor.addrStreet length])
            [formattedAddress appendFormat:@"%@ %@\n", vendor.addrNum, vendor.addrStreet];
        if ([vendor.addrCity length] && [vendor.addrState length])
            [formattedAddress appendFormat:@"%@, %@ ", vendor.addrCity, vendor.addrState];
        if ([vendor.addrZip length])
            [formattedAddress appendString:[vendor.addrZip substringToIndex:5]];
        
        [self.vendorInfo addObject:formattedAddress];
    }
    
    if ([vendor.phone length] == 0)
        self.hasPhone = NO;
    else {
        self.hasPhone = YES;
        
        [self.vendorInfo addObject:vendor.phone];
    }
    
    _vendor = vendor;
}

- (NSArray*)referralComments 
{
    if (_referralComments == nil) {
        _referralComments = [[NSArray alloc] init];
    }
    return _referralComments;
}

#pragma mark - table data source protocol methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == vendorInfoSection)
       return [self.vendorInfo count];
    else if (section == vendorReferralsSection)
        return [self.referralComments count];
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == vendorReferralsSection) {
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        
        UILabel* referralsSectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(15,10,285,20)];

        referralsSectionHeader.backgroundColor = [UIColor clearColor];
        referralsSectionHeader.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        referralsSectionHeader.textColor = [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:1];
        referralsSectionHeader.adjustsFontSizeToFitWidth = YES;
        
        
        if ([self.referralComments count] == 1)
            referralsSectionHeader.text = [[NSString alloc] initWithFormat:@"Recommended to you by %i friend:", [self.referralComments count]];
        else if ([self.referralComments count] > 1)
            referralsSectionHeader.text = [[NSString alloc] initWithFormat:@"Recommended to you by %i friends:", [self.referralComments count]];
        else
            return nil;

        [headerView addSubview:referralsSectionHeader];
        
        return headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{
    if (section == vendorReferralsSection)
        return 30;
    else
        return tableView.sectionHeaderHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *VendorInfoCellIdentifier = @"vendorInfoCell";
    static NSString* ReferralsCellIdentifier = @"vendorReferralsCell";
    
    UITableViewCell *cell;
    
    if (indexPath.section == vendorInfoSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:VendorInfoCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VendorInfoCellIdentifier];
        }
        
        if ([self.vendorInfo count] == 1) {
            if (self.hasAddress) {
                cell.textLabel.numberOfLines = 0;
                cell.imageView.image = [UIImage imageNamed:@"geolocation_icon"];
                
            } else {
                cell.imageView.image = [UIImage imageNamed:@"phone_icon"];
                cell.indentationWidth = 4;
            }
        } else {
            if (indexPath.row == 0) {
                // address row
                cell.textLabel.numberOfLines = 0;
                cell.imageView.image = [UIImage imageNamed:@"geolocation_icon"];
            } else {
                // phone number row
                cell.imageView.image = [UIImage imageNamed:@"phone_icon"];
                cell.indentationWidth = 4;
            }
        }
        
        cell.textLabel.text = [self.vendorInfo objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (indexPath.section == vendorReferralsSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:ReferralsCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReferralsCellIdentifier];
        }
        
        VendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [[vendorReferralComment.referrer.firstName stringByAppendingString:@" "] stringByAppendingString:vendorReferralComment.referrer.lastName];
        
        if ([vendorReferralComment.referralLid intValue] > 0) {
           cell.detailTextLabel.text = vendorReferralComment.listEntryComment;
        } else {
           cell.detailTextLabel.text = vendorReferralComment.comment;
        }
        cell.detailTextLabel.numberOfLines = 0;
        
        NSString* imgURL = [[@"http://graph.facebook.com/" stringByAppendingString:[vendorReferralComment.referrer.fbid stringValue]] stringByAppendingString:@"/picture"];
        UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
        cell.imageView.layer.cornerRadius = 5.0;
        cell.imageView.layer.masksToBounds = YES;
        cell.imageView.image = img;
    }
        
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    // mike gao
    if (indexPath.section == vendorInfoSection) {
        if ([self.vendorInfo count] == 1) {
            if (self.hasAddress) {
                return tableView.rowHeight + 10;
            }
        } else {
            if (indexPath.row == 0) {
                // address row
                return tableView.rowHeight + 10;
            }
        }
    } else if (indexPath.section == vendorReferralsSection) {
        VendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
        NSString* displayedComment;
        if ([vendorReferralComment.referralLid intValue] > 0) {
            displayedComment = vendorReferralComment.listEntryComment;
        } else {
            displayedComment = vendorReferralComment.comment;
        }
        
        CGSize size = [displayedComment sizeWithFont:[UIFont systemFontOfSize:18.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
        
        if (size.height < FACEBOOKPICHEIGHT)
            return FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN;
        else
            return size.height + 2*FACEBOOKPICMARGIN;
    }
    
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"pressed a button here");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // address row
        
        // ask user if he wants to open native maps app (dialog box)
        
        // if yes, then pass information to google maps.
        
        NSString *convertedAddressStr = [[self.vendorInfo objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        convertedAddressStr = [convertedAddressStr stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=%s", convertedAddressStr, "Current%20Location"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else {
        // phone number row
        NSString *numberStr = self.vendor.phone.description;
        
        NSCharacterSet *illegalCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890*#"] invertedSet];
        NSString *convertedStr = [[numberStr componentsSeparatedByCharactersInSet:illegalCharSet] componentsJoinedByString:@""];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:convertedStr]]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
    
    [self.scrollView setScrollEnabled:YES];
    
    self.title = self.vendor.name;
    
    // display image in a separate thread
    dispatch_queue_t downloadImageQueue = dispatch_queue_create("downloadImage",NULL);
    dispatch_async(downloadImageQueue, ^{
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.vendor.icon]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.vendorImage setImage:image];
        });
    });

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.referralComments count]) {         
        // re-set scrollView height
        CGFloat totalTableHeight = [self.vendorTableView rectForSection:vendorInfoSection].size.height + [self.vendorTableView rectForHeaderInSection:vendorReferralsSection].size.height + [self.vendorTableView rectForSection:vendorReferralsSection].size.height;
        
        NSLog(@"header height: %f", [self.vendorTableView rectForHeaderInSection:vendorReferralsSection].size.height);
        
        CGRect tableBounds = [self.vendorTableView bounds];
        [self.vendorTableView setBounds:CGRectMake(tableBounds.origin.x,
                                                         tableBounds.origin.y,
                                                         tableBounds.size.width,
                                                         totalTableHeight)];
        
        CGRect tableFrame = [self.vendorTableView frame];
        [self.vendorTableView setFrame:CGRectMake(tableFrame.origin.x,
                                                        tableFrame.origin.y+(totalTableHeight-tableBounds.size.height)/2,
                                                        tableFrame.size.width,
                                                        tableFrame.size.height)];


        
        [self.scrollView setContentSize:CGSizeMake(320,totalTableHeight+self.vendorImage.image.size.height+100+25)];
        
    }

}

- (void)viewDidUnload
{
    [self setVendorImage:nil];
    [self setScrollView:nil];
    [self setVendorTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
