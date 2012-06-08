//
//  VendorViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "VendorViewController.h"
#import "Constants.h"
#import "PBVendorReferralComment.h"
#import <QuartzCore/QuartzCore.h>
#import "PBVendorPhoto.h"
#import "MBProgressHUD.h"
#import "Restkit/JSONKit.h"
#import "PBVendorPhoto.h"
#import "AddToListViewController.h"
#import "ReferToFriendsViewController.h"

@interface VendorViewController () 

typedef enum tableViewSection {
    vendorInfoSection,
    vendorReferralsSection
} tableViewSection;

@property BOOL hasAddress;
@property BOOL hasPhone;
@property (nonatomic, strong) NSMutableArray* vendorInfo;
@property (nonatomic, strong) EGORefreshTableHeaderView* refreshHeaderView;
@property BOOL reloading;

@end

@implementation VendorViewController

NSString* const RK_VENDOR_REFERRAL_COMMENTS_ID_RESOURCE_PATH = @"vendorapi/coreDataVendorReferralComments/user/"; // ?/vendor/?";

@synthesize vendorTableView = _vendorInfoTable;

@synthesize vendor = _vendor;
@synthesize referralComments = _referralComments;
@synthesize scrollView = _scrollView;
@synthesize photos = _photos;
@synthesize photoScrollView = _photoScrollView;
@synthesize photoPageControl = _photoPageControl;
@synthesize source = _source;
@synthesize responseData = _responseData;
@synthesize detailsResponse = _detailsResponse;

@synthesize hasAddress = _hasAddress;
@synthesize hasPhone = _hasPhone;
@synthesize vendorInfo = _vendorInfo;

@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;
const CGFloat photoHeight = 153;
const CGFloat photoWidth = 320;

#pragma mark getter / setter methods

- (void)setVendor:(PBVendor *)vendor
{    
    self.vendorInfo = [[NSMutableArray alloc] init];
    
    // check if vendor has address and phone number
    if ([vendor.addr length] == 0 && [vendor.addrCity length] == 0 && [vendor.addrState length])  
        self.hasAddress = NO; 
    else {
        self.hasAddress = YES;
        // build self.formattedAddress
        NSMutableString* formattedAddress = [[NSMutableString alloc] init];
        formattedAddress = [[NSMutableString alloc] init];
        if ([vendor.addr length])
            [formattedAddress appendFormat:@"%@\n", vendor.addr];
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

- (void)setReferralComments:(NSArray *)referralComments
{
    _referralComments = referralComments;
    [self.vendorTableView reloadData];
}

- (NSArray*)photos 
{
    if (_photos == nil) {
        _photos = [[NSArray alloc] init];
    }
    return _photos;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
}

- (NSString*)source {
    if (_source == nil) {
        _source = [[NSString alloc] init];
    }
    return _source;
}

- (void)setSource:(NSString *)source {
    _source = source;
}

- (NSMutableData*)responseData {
    if (_responseData == nil) {
        _responseData = [[NSMutableData alloc] init];
    }
    return _responseData;
}

#pragma mark - Private Helper Methods

- (void)loadReferralCommentsObjectsFromDataStore {
    self.vendor = [PBVendor findFirstByAttribute:@"vendorID" withValue:self.vendor.vendorID];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"referralDate" ascending:YES]];
    self.referralComments = [self.vendor.vendorReferralComments sortedArrayUsingDescriptors:sortDescriptors];
    NSLog(@"LOAD REFERRAL COMMENTS FROM CORE DATA: %@", self.referralComments);
    [self resizeReferralCommentsTable];
    
    // for refreshing on pull down
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    self.reloading = NO;
}

- (void)loadReferralCommentsData {
    // Load the object model via RestKit
    NSString* vendorReferralCommentsPath = [RK_VENDOR_REFERRAL_COMMENTS_ID_RESOURCE_PATH stringByAppendingFormat:@"%@/vendor/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"], self.vendor.vendorID];
    NSLog(@"path to vendor referral comments is %@",vendorReferralCommentsPath);
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* vendorReferralCommentsLoader = [objManager loadObjectsAtResourcePath:vendorReferralCommentsPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"referralComment"] delegate:self];
    vendorReferralCommentsLoader.userData = @"vendorReferralCommentsLoader";
    NSLog(@"LOADING REFERRAL COMMENTS FROM PIGGYBACK API");
}

- (void)loadPhotosObjectsFromDataStore {
    self.vendor = [PBVendor findFirstByAttribute:@"vendorID" withValue:self.vendor.vendorID];
    NSLog(@"vendor from photo core data is : %@",self.vendor);
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pid" ascending:NO]];
    self.photos = [self.vendor.vendorPhotos sortedArrayUsingDescriptors:sortDescriptors];
//#warning - currently doesnt work without this nslog printing vid bc will fault unless it needs photo attributes
//    NSLog(@"LOAD VENDOR PHOTOS FOR %@ FROM CORE DATA: %@", self.vendor.vendorID, [(PBVendorPhoto*)[self.photos objectAtIndex:0] vid]);
    [self displayPhotos];
}

- (void)loadPhotosData {
    NSString* vendorPhotoPath = [@"vendorapi/vendorphotos/id/" stringByAppendingFormat:@"%@",self.vendor.vendorID];
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* vendorPhotoLoader = [objManager loadObjectsAtResourcePath:vendorPhotoPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"vendor-photo"] delegate:self];
    vendorPhotoLoader.userData = @"vendorPhotoLoader";
    NSLog(@"LOAD PHOTOS FROM PIGGYBACK API");
}

- (void)resizeReferralCommentsTable
{
    if ([self.referralComments count]) {         
        // re-set scrollView height
        CGFloat totalTableHeight = [self.vendorTableView rectForSection:vendorInfoSection].size.height + [self.vendorTableView rectForHeaderInSection:vendorReferralsSection].size.height + [self.vendorTableView rectForSection:vendorReferralsSection].size.height;
        
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
        
        
        
        [self.scrollView setContentSize:CGSizeMake(320,totalTableHeight+self.photoScrollView.bounds.size.height+10)];
    }
}

- (void)layoutPhotoScrollImages {
    UIImageView *photo = nil;
    NSArray *subviews = [self.photoScrollView subviews];
    
    // reposition all image subviews in a horizontal serial fashion
    CGFloat curXLoc = photoWidth;
    for (photo in subviews) {
        if ([photo isKindOfClass:[UIImageView class]] && photo.tag > 0) {
            CGRect frame = photo.frame;
            frame.origin = CGPointMake(curXLoc,0);
            photo.frame = frame;
            
            curXLoc += (photoWidth);
        }
    }
    
    // set width of photo scroll view to fit all images
    [self.photoScrollView setContentSize:CGSizeMake([self.photos count] * photoWidth,self.photoScrollView.bounds.size.height)];
    
    // hide spinner when photos are done loading
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.reloading = NO;
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
}

- (void)displayPhotos {
    [self.photoPageControl setNumberOfPages:[self.photos count]];
    [self.photoPageControl setCurrentPage:0];
    
    if ([self.photos count] > 0) {
        // create new thread
        dispatch_queue_t downloadImageQueue = dispatch_queue_create("downloadImage",NULL);
        dispatch_queue_t downloadOtherImagesQueue = dispatch_queue_create("downloadOtherImages",NULL);
        
        // show first photo immediately
        dispatch_async(downloadImageQueue, ^{
            
            PBVendorPhoto* firstPhoto = [self.photos objectAtIndex:0];
            NSString* squareFirstPhotoString = [[firstPhoto.photoURL stringByReplacingOccurrencesOfString:@".jpg" withString:@"_300x300.jpg"] stringByReplacingOccurrencesOfString:@"pix" withString:@"derived_pix"];
            UIImage *firstImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:squareFirstPhotoString]]];
            UIImageView *firstImageView = [[UIImageView alloc] initWithImage:firstImage];
            firstImageView.contentMode = UIViewContentModeScaleAspectFill;
            firstImageView.tag = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                firstImageView.frame = CGRectMake(0,0,photoWidth,photoHeight);
                [self.photoScrollView addSubview:firstImageView];
            });
        });
        
        // download the rest of the photos
        dispatch_async(downloadOtherImagesQueue, ^{
            for (int i = 1; i < [self.photos count]; i++) {
                NSString* squarePhotoString = [[[[self.photos objectAtIndex:i] photoURL] stringByReplacingOccurrencesOfString:@".jpg" withString:@"_300x300.jpg"] stringByReplacingOccurrencesOfString:@"pix" withString:@"derived_pix"];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:squarePhotoString]]];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                CGRect rect = imageView.frame;
                rect.size.height = photoHeight;
                rect.size.width = photoWidth;
                imageView.frame = rect;
                imageView.tag = i;
                [self.photoScrollView addSubview:imageView];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self layoutPhotoScrollImages];
            });
        });
    } else {
        // display icon for no picture
        UIImage *image = [UIImage imageNamed:@"no_photo.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.photoScrollView addSubview:imageView];
        
        // hide spinner bc no photos. done loading.
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    }
}

#pragma mark - nsurlconnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",[NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.detailsResponse = [[[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] objectFromJSONString] objectForKey:@"response"];
    self.vendor.website = [[self.detailsResponse objectForKey:@"venue"] objectForKey:@"url"];
    
    NSMutableArray* photos = [[NSMutableArray alloc] init];
    for (NSDictionary* group in [[[self.detailsResponse objectForKey:@"venue"] objectForKey:@"photos"] objectForKey:@"groups"]) {
        for (NSDictionary* photo in [group objectForKey:@"items"]) {
            PBVendorPhotoObject* newPhoto = [[PBVendorPhotoObject alloc] init];
            newPhoto.pid = [photo objectForKey:@"id"];
            newPhoto.photoURL = [photo objectForKey:@"url"];
            newPhoto.vid = self.vendor.vendorID;
            newPhoto.vendor = self.vendor;
            [photos addObject:newPhoto];
        }
    }

    self.photos = [photos copy]; 
    [self displayPhotos];
    
//    [self.searchResultsTable reloadData];
}

#pragma mark - RKObjectLoaderDelegate methods
//- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData {
//    if (loader.userData == @"vendorReferralCommentsLoader") {
//        NSMutableDictionary *userFbPics = [[NSMutableDictionary alloc] init];
//        NSMutableArray *reformattedData = [NSMutableArray arrayWithCapacity:[*mappableData count]];
//        for(id dict in [NSArray arrayWithArray:(NSArray*)*mappableData]) {
//            NSMutableDictionary* newVendorReferralCommentsDict = [dict mutableCopy];
//            NSMutableDictionary* newUserDict = [[newVendorReferralCommentsDict objectForKey:@"referrer"] mutableCopy];
//            NSNumber* userID = [newUserDict valueForKey:@"userID"];
//            if (![userFbPics objectForKey:userID]) {
//                UIImage* thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[newUserDict valueForKey:@"thumbnail"]]]];
//                [userFbPics setObject:thumbnail forKey:userID];
//            }
//            UIImage* thumbnail = [userFbPics objectForKey:userID];
//            [newUserDict setValue:thumbnail forKey:@"thumbnail"];
//            [newVendorReferralCommentsDict setValue:newUserDict forKey:@"referrer"];
//            [reformattedData addObject:newVendorReferralCommentsDict];
//        }
//
//        *mappableData = reformattedData;
//    }
//}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"vendorReferralCommentsLoader") {
        for (PBVendorReferralComment* comment in objects) {
            comment.assignedVendor = self.vendor; 
        }
        
        NSError* error;
        [[NSManagedObject managedObjectContext] save:&error];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"vid%@LastUpdatedAt", self.vendor.vendorID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadReferralCommentsObjectsFromDataStore];
    }
    
    if(objectLoader.userData == @"vendorPhotoLoader") {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"vidPhotos%@LastUpdatedAt", self.vendor.vendorID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadPhotosObjectsFromDataStore];
    } 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{    
    NSLog(@"IN ERROR: No Results Returned. Status Code: %i",[objectLoader.response statusCode]);
    
    if (objectLoader.userData == @"vendorReferralCommentsLoader") {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"vid%@LastUpdatedAt", self.vendor.vendorID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"vidPhotos%@LastUpdatedAt", self.vendor.vendorID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadPhotosObjectsFromDataStore];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }

    self.reloading = NO;
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
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
        
        PBVendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [[vendorReferralComment.referrer.firstName stringByAppendingString:@" "] stringByAppendingString:vendorReferralComment.referrer.lastName];
        cell.detailTextLabel.text = vendorReferralComment.comment;
        cell.detailTextLabel.numberOfLines = 0;
        
//        NSString* imgURL = [[@"http://graph.facebook.com/" stringByAppendingString:[vendorReferralComment.referrer.fbid stringValue]] stringByAppendingString:@"/picture"];
//        UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
        
//        UIImage *img = vendorReferralComment.referrer.thumbnail;
//        cell.imageView.layer.cornerRadius = 5.0;
//        cell.imageView.layer.masksToBounds = YES;
//        cell.imageView.image = img;
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
        PBVendorReferralComment* vendorReferralComment = [self.referralComments objectAtIndex:indexPath.row];
        
        CGSize size = [vendorReferralComment.comment sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(280.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
//        if ((size.height + 12) < FACEBOOKPICHEIGHT)
//            return FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN;
//        else
            return size.height + 2*FACEBOOKPICMARGIN + 20;
    }
    
    return tableView.rowHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 && self.hasAddress) {
            // address row
            NSString *convertedAddressStr = [[self.vendorInfo objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            convertedAddressStr = [convertedAddressStr stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=%s", convertedAddressStr, "Current%20Location"];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else if (self.hasPhone) {
            // phone number row
            NSString *numberStr = self.vendor.phone.description;
            
            NSCharacterSet *illegalCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890*#"] invertedSet];
            NSString *convertedStr = [[numberStr componentsSeparatedByCharactersInSet:illegalCharSet] componentsJoinedByString:@""];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:convertedStr]]];
        }
    }
        
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	

	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
    
#pragma mark - scrollview page control delegate methods
- (IBAction)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int newOffset = scrollView.contentOffset.x;
    int newPage = (int)(newOffset/(scrollView.frame.size.width));
    [self.photoPageControl setCurrentPage:newPage];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self loadReferralCommentsData];
    // dont reload photos: if coming from search, calling load photos will fail
    // right now, photos in db dont change anyway so no need
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return self.reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"vid%@LastUpdatedAt", self.vendor.vendorID]];
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
        
    self.title = self.vendor.name;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView bringSubviewToFront:self.photoPageControl];
    
    // set up page control
    self.photoScrollView.delegate = self;
    CGRect frame = self.photoPageControl.frame;
    frame.size.height = frame.size.height/2.5;
    self.photoPageControl.frame = frame;
    
    if (self.refreshHeaderView == nil) {
        EGORefreshTableHeaderView* view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -180.0f, self.view.frame.size.width, 180.0f) arrowImageName:@"blackArrow" textColor:[UIColor blackColor]];
        view.delegate = self;
        [self.scrollView addSubview:view];
        self.refreshHeaderView = view;
        self.scrollView.alwaysBounceVertical = YES;
    }
    
    // show spinner on page load
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.reloading = YES;
    
    if ([self.source isEqualToString:@"search"]) {        

        // get photos from foursquare API or core data
        if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"vidPhotos%@LastUpdatedAt", self.vendor.vendorID]]) {
            NSLog(@"CALLING FOURSQUARE API FOR PHOTOS");
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyyMMdd"];
            NSDate* now = [NSDate date];
            NSString *date = [dateFormat stringFromDate:now];
            
            NSURLRequest *detailsRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@?client_id=%@&client_secret=%@&v=%@",self.vendor.vendorID,FOURSQUARECLIENTID,FOURSQUARECLIENTSECRET,date]]];
//            NSURLConnection *detailsConnection = [[NSURLConnection alloc] initWithRequest:detailsRequest delegate:self];
            [NSURLConnection connectionWithRequest:detailsRequest delegate:self];
        } else {
            [self loadPhotosObjectsFromDataStore];
        }
        
        // get referal comments
        if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"vid%@LastUpdatedAt", self.vendor.vendorID]]) {
            [self loadReferralCommentsData];
        } else {
            [self loadReferralCommentsObjectsFromDataStore];
        }
    } else {        

        // get photos from piggyback api or core data
        if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"vidPhotos%@LastUpdatedAt", self.vendor.vendorID]]) {
            [self loadPhotosData];
        } else {
            [self loadPhotosObjectsFromDataStore];
        }
    }
    
    // update the last update date
    [self.refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // get referral comments
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"vid%@LastUpdatedAt", self.vendor.vendorID]]) {
        [self loadReferralCommentsData];
//    } else {
//        [self loadReferralCommentsObjectsFromDataStore];
//    }
    
    [self resizeReferralCommentsTable];

}

- (void)viewDidUnload
{
//    [self setVendorImage:nil];
    [self setScrollView:nil];
    [self setVendorTableView:nil];
    [self setPhotoScrollView:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // self.photos from foursquare is an array of PBVENDORPHOTOOBJECTs (nsobject)
    // selfphotos from coredata is an array of PBVENDORPHOTOs (nsmanagedobject)
    // trying to add nsobject to core data
    
    // if photos are from foursquare, convert the photos from NSObjects to NSManagedObjects so they can be stored in core data
    if ([[segue identifier] isEqualToString:@"addVendorToList"]) {  
        if ([self.source isEqualToString:@"search"] && ![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"vidPhotos%@LastUpdatedAt", self.vendor.vendorID]]) {
            
            for (PBVendorPhotoObject* photoObject in self.photos) {
                PBVendorPhoto* photo = [PBVendorPhoto object];
                photo.pid = photoObject.pid;
                photo.vid = photoObject.vid;
                photo.photoURL = photoObject.photoURL;
                photo.vendor = photoObject.vendor;
                [self.vendor.vendorPhotos addObject:photo];
                
                // update nsuserdefaults to indicate that photos are stored in core data
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"vidPhotos%@LastUpdatedAt", self.vendor.vendorID]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            self.vendor.vendorPhotos = [NSMutableSet setWithArray:self.photos];
        }
        
        // set AddToListViewController's vendor to selected vendor
        [(AddToListViewController*)[segue.destinationViewController topViewController] setVendor:self.vendor];
    } else if ([[segue identifier] isEqualToString:@"vendorToRefer"]) {
        [(ReferToFriendsViewController*)[segue.destinationViewController topViewController] setSource:@"vendor"];
        [(ReferToFriendsViewController*)[segue.destinationViewController topViewController] setVendor:self.vendor];
    }
}

@end
