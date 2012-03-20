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
#import "VendorReferralComment.h"
#import "listEntryTableViewCell.h"

const double metersToMilesMultiplier = 0.000621371192;

@implementation IndividualListViewController

@synthesize list = _list;
@synthesize listEntryTableView = _listEntryTableView;
@synthesize shownListEntrys = _shownListEntrys;
@synthesize locationController = _locationController;
@synthesize segmentedControl = _segmentedControl;

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

#pragma mark - Private Helper Methods

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

- (void)calculateDistanceOnViewWillAppear
{
    dispatch_queue_t getCurrentLocationViewWillAppearQueue = dispatch_queue_create("getCurrentLocationViewWillAppear", NULL);
    dispatch_async(getCurrentLocationViewWillAppearQueue, ^{
        CLLocation* currentLocation = [self.locationController getCurrentLocationAndStopLocationManager];
        NSLog(@"current location on view will appear for 'most popular' tab ONLY: %@", currentLocation);
        for (PBListEntry* currentListEntry in self.list.listEntrys) {
            currentListEntry.vendor.distanceFromCurrentLocationInMiles = [[[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[currentListEntry.vendor.lat doubleValue] longitude:(CLLocationDegrees)[currentListEntry.vendor.lng doubleValue]] distanceFromLocation:currentLocation] * metersToMilesMultiplier;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listEntryTableView reloadData];
        });
    });
    dispatch_release(getCurrentLocationViewWillAppearQueue);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.shownListEntrys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listEntryTableViewCell";
    
    ListEntryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ListEntryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.name.text = [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] name];

    if ([[[self.shownListEntrys objectAtIndex:indexPath.row] numUniqueReferredBy] intValue] == 1) {
        cell.referredBy.text = [NSString stringWithFormat:@"From %@ friend", [[self.shownListEntrys objectAtIndex:indexPath.row] numUniqueReferredBy]];
    } else {
        cell.referredBy.text = [NSString stringWithFormat:@"From %@ friends", [[self.shownListEntrys objectAtIndex:indexPath.row] numUniqueReferredBy]];
    }

    CLLocationDistance distance = [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles];
    if (distance < 0.1) {
        cell.distance.text = [NSString stringWithFormat:@"%.2f mi", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles]];
    } else if (distance >= 100) {
        cell.distance.text = [NSString stringWithString:@"100+ mi"];
    } else {
        cell.distance.text = [NSString stringWithFormat:@"%.1f mi", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles]];
    }
    
    cell.description.numberOfLines = 0;    
    cell.description.text = [[self.shownListEntrys objectAtIndex:indexPath.row] comment];
    CGSize expectedLabelSize = [[[self.shownListEntrys objectAtIndex:indexPath.row] comment] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = cell.description.frame;
    newFrame.size.height = expectedLabelSize.height;
    cell.description.frame = newFrame;

    NSLog(@"cellForRowAtIndexPath listEntry name: %@", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] name]);
    NSLog(@"listEntry distance: %f", [[[self.shownListEntrys objectAtIndex:indexPath.row] vendor] distanceFromCurrentLocationInMiles]);

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    CGSize size = [[[self.shownListEntrys objectAtIndex:indexPath.row] comment] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
    
    return size.height + 60;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            // most popular
            NSLog(@"IndividualListViewController will appear with 'most popular' selected");            
            [self sortListEntrysByMostRecommendations];
            [self calculateDistanceOnViewWillAppear];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToVendorFromListEntry"]) {
        // set VendorViewController's vendor to selected vendor
        [(VendorViewController*)segue.destinationViewController setVendor:[[self.shownListEntrys objectAtIndex:[self.listEntryTableView indexPathForCell:sender].row] vendor]];
        
        NSMutableOrderedSet* uniqueReferrerUIDs = [[NSMutableOrderedSet alloc] init];
        NSMutableArray* uniqueReferralComments = [[NSMutableArray alloc] init];
        for (VendorReferralComment* commentObject in [[self.shownListEntrys objectAtIndex:[self.listEntryTableView indexPathForCell:sender].row] referredBy]) {
            NSLog(@"*********** comment object is: %@",[commentObject comment]);
            if (![uniqueReferrerUIDs containsObject:commentObject.referrer.uid]) {
                [uniqueReferrerUIDs addObject:commentObject.referrer.uid];
                [uniqueReferralComments addObject:commentObject];
            }
        }
        
        // set VendorViewController's referralComments to selected uniqueReferralComments
        [(VendorViewController*)segue.destinationViewController setReferralComments:[NSArray arrayWithArray:uniqueReferralComments]];
    }
}

#pragma mark - IBAction definitions

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
