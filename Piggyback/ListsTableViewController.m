//
//  ListTableViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ListsTableViewController.h"
#import "PBList.h"
#import "PBListEntry.h"
#import "VendorReferralComment.h"
#import "IndividualListViewController.h"

@interface ListsTableViewController ()

@property int currentPbAPICall;

@end

@implementation ListsTableViewController

@synthesize lists = _lists;
@synthesize currentPbAPICall = _currentPbAPICall;

#pragma mark - Getters and Setters

- (NSArray *)lists {
    if (!_lists) {
        _lists = [[NSArray alloc] init];
    }
    
    return _lists;
}

- (void)setLists:(NSArray *)lists {
    if (_lists != lists) {
        _lists = lists;
        [self.tableView reloadData];
    }
}

#pragma mark - Private Helper Methods

- (void)getCurrentUserLists:(NSString *)uid {
    // Load the user object via RestKit	
    self.currentPbAPICall = pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals;
    
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    NSString* resourcePath = [@"/listapi/listsAndEntrysAndIncomingReferrals/id/" stringByAppendingString:uid];
    [objectManager loadObjectsAtResourcePath:resourcePath objectMapping:[objectManager.mappingProvider mappingForKeyPath:@"list"] delegate:self];
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    switch (self.currentPbAPICall) {
        case pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals:
        {
            NSLog(@"in pbAPIGetCurrentUserListsAndListEntrys");
            // retrieve listEntrys for each list
            self.lists = objects;
            
            break;
        }
        default:
            break;
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    switch (self.currentPbAPICall) {
        case pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals:
        {
            NSLog(@"in pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals error handler");
            // handle case where user has no lists
            NSArray *userHasNoLists = [NSArray arrayWithObject:[NSString stringWithString:@"You have no lists!"]];
            self.lists = userHasNoLists;
            
            break;
        }
        default:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"Hit error: %@", error);
            
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // check if PB API returned any user lists -- if not, display 'empty lists' message. otherwise, display lists
    if ([[self.lists objectAtIndex:indexPath.row] isKindOfClass:[PBList class]]) {
        PBList* myList = [self.lists objectAtIndex:indexPath.row];
        cell.textLabel.text = myList.name;
        cell.detailTextLabel.text = [[NSString stringWithFormat:@"%d", [myList.listEntrys count]] stringByAppendingString:@" items"];
        tableView.userInteractionEnabled = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSLog(@"cellForRowAtIndexPath list name: %@", myList.name);
    } else {
        // user has no lists
        cell.textLabel.text = @"You don't have any lists!";
        cell.detailTextLabel.text = @"Create lists at www.getpiggyback.com and stay tuned for mobile app updates!";
        cell.detailTextLabel.numberOfLines = 2;
        tableView.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // height for empty cell
    if (![[self.lists objectAtIndex:indexPath.row] isKindOfClass:[PBList class]]) {
        return 80;
    } else {
        return tableView.rowHeight;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self.lists objectAtIndex:indexPath.row] listEntrys] count] == 0) {
        // show empty list view controller
        [self performSegueWithIdentifier:@"goToEmptyListEntryFromLists" sender:[tableView cellForRowAtIndexPath:indexPath]];
    } else {
        // show individualListViewController
        [self performSegueWithIdentifier:@"goToListEntryFromLists" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piggyback_titlebar"]];
    }
    return self;
}

- (void)awakeFromNib
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piggyback_titlebar"]];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    NSLog(@"lists viewDidLoad");
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"lists viewWillAppear");
    [super viewWillAppear:animated];
#warning: need to optimize so that lists do not get retrieved each time the view appears
    [self getCurrentUserLists:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] stringValue]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PBList *list = [self.lists objectAtIndex:[self.tableView indexPathForCell:sender].row];
    
    if ([segue.destinationViewController respondsToSelector:@selector(setList:)]) {
        // get num of unique referrals for specific listEntry
        for (PBListEntry* currentListEntry in list.listEntrys) {
            NSMutableSet* uniqueReferrers = [[NSMutableSet alloc] init];
                
            for (VendorReferralComment* currentReferralComment in currentListEntry.referredBy) {
                [uniqueReferrers addObject:currentReferralComment.referrer.uid];
            }
            currentListEntry.numUniqueReferredBy = [NSNumber numberWithInt:[uniqueReferrers count]];
        }

        [segue.destinationViewController setList:list];
    }
}

@end
