//
//  IndividualListViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/12/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "IndividualListViewController.h"
#import "PBListEntry.h"
#import "Vendor.h"
#import "VendorViewController.h"

const double metersToMilesMultiplier = 0.000621371192;

@interface IndividualListViewController()

- (void)fetchReferralCommentsData:(id)destinationViewController;

@end

@implementation IndividualListViewController

@synthesize list = _list;
@synthesize listEntryTableView = _listEntryTableView;
@synthesize shownListEntrys = _shownListEntrys;
@synthesize locationController = _locationController;
@synthesize segmentedControl = _segmentedControl;

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

- (NSArray*)shownListEntrys
{
    if (!_shownListEntrys) {
        _shownListEntrys = [[NSArray alloc] init];
    }
    
    return _shownListEntrys;
}

- (void)setShownListEntrys:(NSArray *)shownListEntrys
{
    _shownListEntrys = shownListEntrys;
    [self.listEntryTableView reloadData];
}

- (void)awakeFromNib
{
    self.locationController = [[LocationController alloc] init];
}

#pragma - Private Helper Methods

- (void)sortListEntrysByMostRecommendations
{
    NSArray* listEntrys = [self.list.listEntrys sortedArrayUsingComparator: ^(PBListEntry* a, PBListEntry* b) {
        if ([a.numUniqueReferredBy intValue] < [b.numUniqueReferredBy intValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else if ([a.numUniqueReferredBy intValue] > [b.numUniqueReferredBy intValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    self.shownListEntrys = listEntrys;
}

- (void)sortListEntrysByDistance
{
    // get the current location in a separate thread (blocking occurs until location is retrieved)
    dispatch_queue_t getCurrentLocationQueue = dispatch_queue_create("getCurrentLocation", NULL);
    dispatch_async(getCurrentLocationQueue, ^{
        CLLocation* currentLocation = [self.locationController getCurrentLocationAndStopLocationManager];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"GOT THE CURRENT LOCATION: %@", currentLocation);
            // compare distances of listEntrys and store in a temp array
            NSArray* listEntrys = [self.list.listEntrys sortedArrayUsingComparator: ^(PBListEntry* a, PBListEntry* b) {
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
            }];
            
            self.shownListEntrys = listEntrys;
        });
    });
    dispatch_release(getCurrentLocationQueue);
}

// **** Kim Hsiao: HELPER FUNCTIONS TO FETCH DATA DURING SEGUE **** //

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
        self.locationController = [[LocationController alloc] init];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // most popular
            NSLog(@"IndividualListViewController will appear with 'most popular' selected");            
            [self sortListEntrysByMostRecommendations];
            break;
        case 1:
            // nearby
            NSLog(@"IndividualListViewController will appear with 'nearby' selected");
            [self sortListEntrysByDistance];
            break;
            
        default:
            break;
    }
}

- (void)viewDidUnload
{
    self.list = nil;
    [self setListEntryTableView:nil];
    self.shownListEntrys = nil;
    [self setSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// functions from kim
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToVendorFromListEntry"]) {
        // fetch API data for referral comments
        [self fetchReferralCommentsData:segue.destinationViewController];
        
        // set VendorViewController's vendor to selected vendor
        [(VendorViewController*)segue.destinationViewController setVendor:[[self.list.listEntrys objectAtIndex:[self.listEntryTableView indexPathForCell:sender].row] vendor]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.shownListEntrys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listEntryTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
#warning: take care of empty list case -- new viewController in storyboard for empty cases and push programmatically? DECIDED TO CREATE VIEWCONTROLLER ON STORYBOARD
    cell.textLabel.text = [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] name];
    if ([[[self.shownListEntrys objectAtIndex:indexPath.row] numUniqueReferredBy] intValue] == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"From %@ friend", [[self.shownListEntrys objectAtIndex:indexPath.row] numUniqueReferredBy]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"From %@ friends", [[self.shownListEntrys objectAtIndex:indexPath.row] numUniqueReferredBy]];
    }
    NSLog(@"cellForRowAtIndexPath listEntry name: %@", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] name]);
    NSLog(@"listEntry distance: %f", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles]);

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (IBAction)segmentedControlChanged {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // most popular
            NSLog(@"segmentedControlChanged to 'most popular'");            
            [self sortListEntrysByMostRecommendations];
            break;
        case 1:
            // nearby
            NSLog(@"segmentedControlChanged to 'nearby'");
            [self sortListEntrysByDistance];
            break;
            
        default:
            break;
    }
}
@end
