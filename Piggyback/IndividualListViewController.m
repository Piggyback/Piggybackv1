//
//  IndividualListViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/12/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "IndividualListViewController.h"
#import "PBListEntry.h"
#import "PBVendor.h"
#import "VendorViewController.h"
#import "PBVendorReferralComment.h"
#import "listEntryTableViewCell.h"
#import "MBProgressHUD.h"

@interface IndividualListViewController()

@property (nonatomic, strong) NSMutableArray* sortedDateListEntrys;
@property (nonatomic, strong) EGORefreshTableHeaderView* refreshHeaderView;
@property BOOL reloading;

@end

@implementation IndividualListViewController

NSString* const RK_LIST_ENTRYS_ID_RESOURCE_PATH = @"/listapi/coreDataListEntrys/user/"; // ?/list/?
NSString* const RK_MY_LIST_ENTRYS_ID_RESOURCE_PATH = @"/listapi/coreDataMyListEntrys/user/"; // ?/list/?
double const metersToMilesMultiplier = 0.000621371192;

@synthesize list = _list;
@synthesize listEntryTableView = _listEntryTableView;
@synthesize shownListEntrys = _shownListEntrys;
@synthesize locationController = _locationController;
@synthesize segmentedControl = _segmentedControl;
@synthesize scrollView = _scrollView;
@synthesize sortedDateListEntrys = _sortedDateListEntrys;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;
@synthesize fromReferral = _fromReferral;

#pragma mark - Getters and Setters

- (PBList*)list 
{
    if (!_list) {
        _list = [[PBList alloc] init];
    }
    
    return _list;
}

- (void)setList:(PBList *)list
{
    _list = list;
    self.title = list.name;
}

- (NSMutableArray*)shownListEntrys
{
    if (!_shownListEntrys) {
        _shownListEntrys = [[NSMutableArray alloc] init];
    }
    
    return _shownListEntrys;
}

- (void)setShownListEntrys:(NSMutableArray *)shownListEntrys
{
    _shownListEntrys = shownListEntrys;
    [self.listEntryTableView reloadData];
}

#pragma mark - Private Helper Methods

- (void)loadObjectsFromDataStore {
    self.list = [PBList findFirstByAttribute:@"listID" withValue:self.list.listID];
    NSArray* sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"addedDate" ascending:YES]];
    self.sortedDateListEntrys = [[self.list.listEntrys sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    for (PBListEntry* currentEntry in self.sortedDateListEntrys) {
        currentEntry.vendor.distanceFromCurrentLocationInMiles = -1;
    }
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // most popular          
            [self sortListEntrysByMostRecommendations:self.sortedDateListEntrys];
            [self calculateDistanceOnViewWillAppear];
            break;
        case 1:
            // nearby
            [self sortListEntrysByDistance:self.sortedDateListEntrys];
            break;
            
        default:
            break;
    }
}

- (void)loadData {
    // Load the object model via RestKit
    self.reloading = YES;
    NSString* listEntrysPath;
    if (!self.fromReferral) {
        listEntrysPath = [RK_MY_LIST_ENTRYS_ID_RESOURCE_PATH stringByAppendingFormat:@"%@/list/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"], self.list.listID];
        NSLog(@"my list!!!!!!!!!!! is called %@",listEntrysPath);
    } else {
        listEntrysPath = [RK_LIST_ENTRYS_ID_RESOURCE_PATH stringByAppendingFormat:@"%@/list/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"], self.list.listID];
        NSLog(@"NOT my list!!!!!!!!!!!");
    }
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* listEntrysLoader = [objManager loadObjectsAtResourcePath:listEntrysPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"listEntry"] delegate:self];
    listEntrysLoader.userData = @"listEntrysLoader";
}

- (void)sortListEntrysByMostRecommendations:(NSMutableArray *)listEntrys
{
    self.shownListEntrys = [[listEntrys sortedArrayUsingComparator: ^(PBListEntry* a, PBListEntry* b) {
        if ([a.vendor.vendorReferralCommentsCount intValue] < [b.vendor.vendorReferralCommentsCount intValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if ([a.vendor.vendorReferralCommentsCount intValue] > [b.vendor.vendorReferralCommentsCount intValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }] mutableCopy];
}

- (void)sortListEntrysByDistance:(NSMutableArray *)listEntrys
{
//    // get the current location in a separate thread (blocking occurs until location is retrieved)
    dispatch_queue_t getCurrentLocationQueue = dispatch_queue_create("getCurrentLocation", NULL);
    dispatch_async(getCurrentLocationQueue, ^{
        CLLocation* currentLocation = [self.locationController getCurrentLocationAndStopLocationManager];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.list.listEntrys count] == 1) {
                PBListEntry* currentListEntry = [listEntrys objectAtIndex:0];
                currentListEntry.vendor.distanceFromCurrentLocationInMiles = [[[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[currentListEntry.vendor.lat doubleValue] longitude:(CLLocationDegrees)[currentListEntry.vendor.lng doubleValue]] distanceFromLocation:currentLocation] * metersToMilesMultiplier;
                self.shownListEntrys = [NSMutableArray arrayWithObject:currentListEntry];
            } else {
                self.shownListEntrys = [[listEntrys sortedArrayUsingComparator: ^(PBListEntry* a, PBListEntry* b) {
                    // store distance in current list entry
                    CLLocation* locationA = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[a.vendor.lat doubleValue] longitude:(CLLocationDegrees)[a.vendor.lng doubleValue]];
                    CLLocation* locationB = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[b.vendor.lat doubleValue] longitude:(CLLocationDegrees)[b.vendor.lng doubleValue]];
                    
                    CLLocationDistance distanceInMilesA = [locationA distanceFromLocation:currentLocation] * metersToMilesMultiplier;
                    CLLocationDistance distanceInMilesB = [locationB distanceFromLocation:currentLocation] * metersToMilesMultiplier;
                    
                    a.vendor.distanceFromCurrentLocationInMiles = distanceInMilesA;
                    b.vendor.distanceFromCurrentLocationInMiles = distanceInMilesB;
                    
                    if (distanceInMilesA < distanceInMilesB) {
                        return (NSComparisonResult)NSOrderedAscending;
                    } else if (distanceInMilesA > distanceInMilesB) {
                        return (NSComparisonResult)NSOrderedDescending;
                    } else {
                        return (NSComparisonResult)NSOrderedSame;
                    }
                }] mutableCopy];
            }
        });
    });
    dispatch_release(getCurrentLocationQueue);
}

- (void)calculateDistanceOnViewWillAppear
{
    dispatch_queue_t getCurrentLocationViewWillAppearQueue = dispatch_queue_create("getCurrentLocationViewWillAppear", NULL);
    dispatch_async(getCurrentLocationViewWillAppearQueue, ^{
        CLLocation* currentLocation = [self.locationController getCurrentLocationAndStopLocationManager];
        for (PBListEntry* currentListEntry in self.list.listEntrys) {
            currentListEntry.vendor.distanceFromCurrentLocationInMiles = [[[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[currentListEntry.vendor.lat doubleValue] longitude:(CLLocationDegrees)[currentListEntry.vendor.lng doubleValue]] distanceFromLocation:currentLocation] * metersToMilesMultiplier;
            NSLog(@"vendor lat: %f, vendor long: %f, currentDistance: %f", [currentListEntry.vendor.lat doubleValue], [currentListEntry.vendor.lng doubleValue], currentListEntry.vendor.distanceFromCurrentLocationInMiles);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listEntryTableView reloadData];
        });
    });
    dispatch_release(getCurrentLocationViewWillAppearQueue);
}

#pragma mark - RKObjectLoaderDelegate methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"listEntrysLoader") {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"lid%@LastUpdatedAt", self.list.listID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadObjectsFromDataStore];
        self.reloading = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    } 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{    
    if (objectLoader.userData == @"listEntrysLoader") {
        // handle case where user has no inbox items
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"lid%@LastUpdatedAt", self.list.listID]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.shownListEntrys = [[NSMutableArray alloc] init];
        self.reloading = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"InboxTableViewController RK Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        NSLog(@"InboxTableViewController RK error: %@", error);
    }
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lid%@LastUpdatedAt", self.list.listID]]) {
        return 0;
    } else if ([self.shownListEntrys count] == 0) {
        return 1;
    } else {
        return [self.shownListEntrys count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.shownListEntrys count] == 0) {
        static NSString *CellIdentifier = @"emptyListEntryTableViewCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        return cell;
    } else {
        static NSString *CellIdentifier = @"listEntryTableViewCell";
        
        ListEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[ListEntryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.name.text = [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] name];

        NSInteger numReferredBy = [[[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] vendorReferralCommentsCount] intValue];
        if (numReferredBy == 1) {
            cell.referredByOrDescription.text = [NSString stringWithFormat:@"From %i friend", numReferredBy];
        } else if (numReferredBy > 1) {
            cell.referredByOrDescription.text = [NSString stringWithFormat:@"From %i friends", numReferredBy];
        }

        CLLocationDistance distance = [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles];
        if (distance < 0) {
            // don't set text
            cell.distance.text = @"";
        }
        else if (distance < 0.1) {
            cell.distance.text = [NSString stringWithFormat:@"%.2f mi", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles]];
        } else if (distance >= 100) {
            cell.distance.text = [NSString stringWithString:@"100+ mi"];
        } else {
            cell.distance.text = [NSString stringWithFormat:@"%.1f mi", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles]];
        }
        
        // determine how tall uilabel must be to fit contents
        CGSize expectedLabelSize = [[[self.shownListEntrys objectAtIndex:indexPath.row] comment] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap]; 
        
        // do not include 'referred by 0 friends' if no one referred to you
        if (numReferredBy == 0) {
            // set referredByOrDescription to description
            CGRect newFrame = cell.referredByOrDescription.frame;
            newFrame.size.height = expectedLabelSize.height;
            
            cell.referredByOrDescription.lineBreakMode = UILineBreakModeWordWrap;
            cell.referredByOrDescription.numberOfLines = 0;
            cell.referredByOrDescription.text = [[self.shownListEntrys objectAtIndex:indexPath.row] comment];
            cell.referredByOrDescription.textColor = [UIColor colorWithRed:78/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f];
            cell.referredByOrDescription.frame = newFrame;
    #warning - need to optimize and change font color
            
            // set description to blank
            cell.descriptionOrBlank.text = @"";
            newFrame = cell .descriptionOrBlank.frame;
            newFrame.size.height = 0;
            cell.descriptionOrBlank.frame = newFrame;
        } else {
            // set referredByorDescription to description
            CGRect newFrame = cell.descriptionOrBlank.frame;
            newFrame.size.height = expectedLabelSize.height;
            
            cell.descriptionOrBlank.lineBreakMode = UILineBreakModeWordWrap;
            cell.descriptionOrBlank.numberOfLines = 0;    
            cell.descriptionOrBlank.text = [[self.shownListEntrys objectAtIndex:indexPath.row] comment];
            cell.descriptionOrBlank.frame = newFrame;
            
            newFrame = cell.referredByOrDescription.frame;
            newFrame.size.height = 20;
            cell.referredByOrDescription.frame = newFrame;
        }

        return cell;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([self.shownListEntrys count] == 0) {
        return 90;
    } else {
        CGSize size = [[[self.shownListEntrys objectAtIndex:indexPath.row] comment] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
        
    //    NSInteger numReferredBy = [[[self.shownListEntrys objectAtIndex:indexPath.row] numUniqueReferredBy] intValue];
    //    if (numReferredBy == 0 && size.height > 15) {
    //        size.height = size.height - 20;
    //    }
        if ([[[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] vendorReferralCommentsCount] intValue] > 0) {
            return size.height + 55;
        } else {
            return size.height + 33;
        }
    }
}

#pragma mark - swipe to delete delegate methods
-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // delete from piggyback api
        NSNumber* leid = [[self.shownListEntrys objectAtIndex:indexPath.row] listEntryID];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
                
        NSDictionary* params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:leid,timeStamp,nil] forKeys:[NSArray arrayWithObjects:@"leid",@"date",nil]];
        [[RKClient sharedClient] put:@"listapi/coreDataListEntryDelete" params:params delegate:self];
        
        // delete from core data
        PBListEntry* deletedListEntry = [self.shownListEntrys objectAtIndex:indexPath.row];
        [[[[RKObjectManager sharedManager] objectStore] managedObjectContext] deleteObject:deletedListEntry];
        [[[[RKObjectManager sharedManager] objectStore] managedObjectContext] save:nil];
        
        // delete from view
        [self.shownListEntrys removeObjectAtIndex:indexPath.row];
        [self.sortedDateListEntrys removeObject:deletedListEntry];
        [self.listEntryTableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
    
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self loadData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return self.reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lid%@LastUpdatedAt", self.list.listID]];
}


#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)awakeFromNib
{
    self.locationController = [[LocationController alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.locationController = [[LocationController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (self.refreshHeaderView == nil) {
        EGORefreshTableHeaderView* view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -180.0f, self.view.frame.size.width, 180.0f) arrowImageName:@"blackArrow" textColor:[UIColor blackColor]];
        view.delegate = self;
        [self.scrollView addSubview:view];
        self.refreshHeaderView = view;
        self.scrollView.alwaysBounceVertical = YES;
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lid%@LastUpdatedAt", self.list.listID]]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadData];
    } else {
        [self loadObjectsFromDataStore];
    }
    
    // update the last update date
    [self.refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    self.list = nil;
    [self setListEntryTableView:nil];
    self.shownListEntrys = nil;
    [self setSegmentedControl:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToVendorFromListEntry"]) {
        // set VendorViewController's vendor to selected vendor
        [(VendorViewController*)segue.destinationViewController setVendor:[[self.shownListEntrys objectAtIndex:[self.listEntryTableView indexPathForCell:sender].row] vendor]];
        [(VendorViewController*)segue.destinationViewController setSource:@"list"];
        
//        NSLog(@"VENDOR FROM LIST IS : %@", [(VendorViewController*)segue.destinationViewController vendor]);
        
//        NSMutableOrderedSet* uniqueReferrerUIDs = [[NSMutableOrderedSet alloc] init];
//        NSMutableArray* uniqueReferralComments = [[NSMutableArray alloc] init];
////        for (PBVendorReferralComment* commentObject in [[self.shownListEntrys objectAtIndex:[self.listEntryTableView indexPathForCell:sender].row] referredBy]) {
////            if (![uniqueReferrerUIDs containsObject:commentObject.referrer.uid]) {
////                [uniqueReferrerUIDs addObject:commentObject.referrer.uid];
////                [uniqueReferralComments addObject:commentObject];
////            }
////        }
//        
//        // set VendorViewController's referralComments to selected uniqueReferralComments
//        [(VendorViewController*)segue.destinationViewController setReferralComments:[NSArray arrayWithArray:uniqueReferralComments]];
    }
}

#pragma mark - IBAction definitions

- (IBAction)segmentedControlChanged {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // most popular          
            [self sortListEntrysByMostRecommendations:self.sortedDateListEntrys];
            break;
        case 1:
            // nearby
            [self sortListEntrysByDistance:self.sortedDateListEntrys];
            break;
            
        default:
            break;
    }
}
@end
