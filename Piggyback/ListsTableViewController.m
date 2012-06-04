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
#import "PBVendorReferralComment.h"
#import "IndividualListViewController.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "CreateNewListViewController.h"
#import "PiggybackNavigationController.h"
#import "FlurryAnalytics.h"
#import "Reachability.h"

@interface ListsTableViewController ()

@property int currentPbAPICall;
@property (nonatomic, strong) EGORefreshTableHeaderView* refreshHeaderView;
@property BOOL reloading;

@end

@implementation ListsTableViewController

@synthesize lists = _lists;
@synthesize currentPbAPICall = _currentPbAPICall;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;

#pragma mark - Getters and Setters

- (NSMutableArray *)lists {
    if (!_lists) {
        _lists = [[NSMutableArray alloc] init];
    }
    
    return _lists;
}

- (void)setLists:(NSMutableArray *)lists {
    if (_lists != lists) {
        _lists = lists;
        [self.tableView reloadData];
    }
}

#pragma mark - Private Helper Methods
- (void) reachabilityChanged:(NSNotification *)note {
    Reachability * reach = [note object];
    if([reach isReachable])
    {
        [self loadData];
    } else
    {
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.reloading = NO;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connection with server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) checkHostStatus {
    // allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"beta.getpiggyback.com"];
    
    // tell the reachability that we DONT want to be reachable on 3G/EDGE/CDMA
    reach.reachableOnWWAN = YES;
    
    // here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [reach startNotifier];
}


- (void)loadObjectsFromDataStore {
    // fetch current user & set self.lists to currentUser.lists   
    PBUser* currentUser = [PBUser findFirstByAttribute:@"userID" withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES]];
    self.lists = [[currentUser.lists sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

- (void)loadData {
    // Load the object model via RestKit
    self.reloading = YES;
    self.currentPbAPICall = pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals;
    NSString* listsPath = [RK_LISTS_ID_RESOURCE_PATH stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* listsLoader = [objManager loadObjectsAtResourcePath:listsPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"list"] delegate:self];
    NSLog(@"list table view controller path is %@",listsPath);
    listsLoader.userData = @"listsLoader";
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"in did load objects");
    switch (self.currentPbAPICall) {
        case pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals:
        {
            NSLog(@"num of lists returned: %i", [objects count]);
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ListsLastUpdatedAt"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loadObjectsFromDataStore];
            self.reloading = NO;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];

            break;
        }
        default:
            break;
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"in failed to load objects");
    if (error.code == 2) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connection with server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        switch (self.currentPbAPICall) {
            case pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals:
            {
                // handle case where user has no lists
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ListsLastUpdatedAt"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.lists = [[NSMutableArray alloc] init];
                self.reloading = NO;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
                
                break;
            }
            default:
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                NSLog(@"ListsTableViewController RK error: %@", error);
                
                break;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"list count: %i", [self.lists count]);
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ListsLastUpdatedAt"]) {
        return 0;
    }
    else if ([self.lists count] == 0) {
        // display empty lists message
        return 1;
    } else {
        return [self.lists count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // check if PB API returned any user lists -- if not, display 'empty lists' message. otherwise, display lists
//    if ([[self.lists objectAtIndex:indexPath.row] isKindOfClass:[PBList class]]) {
    if ([self.lists count] > 0) {
        static NSString *CellIdentifier = @"listTableViewCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        PBList* myList = [self.lists objectAtIndex:indexPath.row];
        cell.textLabel.text = myList.name;
        
        if ([myList.listCount intValue] == 1) {
            cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@", myList.listCount] stringByAppendingString:@" item"];
        } else {
            cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@", myList.listCount] stringByAppendingString:@" items"];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"noListsCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        // user has no lists
//        cell.textLabel.text = NO_LISTS_TEXT;
//        cell.detailTextLabel.text = NO_LISTS_DETAILED_TEXT;
//        cell.detailTextLabel.numberOfLines = 2;
//        tableView.userInteractionEnabled = NO;
//        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // height for empty cell
//    if (![[self.lists objectAtIndex:indexPath.row] isKindOfClass:[PBList class]]) {
    if ([self.lists count] == 0) {
        return 80;
    } else {
        return tableView.rowHeight;
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
        NSNumber* lid = [[self.lists objectAtIndex:indexPath.row] listID];
        NSDictionary* params = [NSDictionary dictionaryWithObject:lid forKey:@"lid"];
        [[RKClient sharedClient] put:@"listapi/coreDataListDelete" params:params delegate:self];
        
        // delete from core data
        PBList* deletedList = [self.lists objectAtIndex:indexPath.row];
        [[[[RKObjectManager sharedManager] objectStore] managedObjectContext] deleteObject:deletedList];
        [[[[RKObjectManager sharedManager] objectStore] managedObjectContext] save:nil];
        
        // delete from view
        [self.lists removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([[[self.lists objectAtIndex:indexPath.row] listEntrys] count] == 0) {
//        // show empty list view controller
//        [self performSegueWithIdentifier:@"goToEmptyListEntryFromLists" sender:[tableView cellForRowAtIndexPath:indexPath]];
//    } else {
//        // show individualListViewController
//        [self performSegueWithIdentifier:@"goToListEntryFromLists" sender:[tableView cellForRowAtIndexPath:indexPath]];
//    }
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
    [self checkHostStatus];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return self.reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ListsLastUpdatedAt"];
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
    [super viewDidLoad];

    if (self.refreshHeaderView == nil) {
        EGORefreshTableHeaderView* view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -180.0f, self.view.frame.size.width, 180.0f) arrowImageName:@"blackArrow" textColor:[UIColor blackColor]];
        view.delegate = self;
        [self.tableView addSubview:view];
        self.refreshHeaderView = view;
    }
    
    // update the last update date
    [self.refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [FlurryAnalytics logEvent:@"VIEWED_YOUR_LISTS"];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ListsLastUpdatedAt"]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self checkHostStatus];
    } else {
        [self loadObjectsFromDataStore];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"lists in array are %@",self.lists);
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
    if ([segue.identifier isEqualToString:@"createNewList"]) {
        [(CreateNewListViewController*)[(PiggybackNavigationController*)segue.destinationViewController topViewController] setRealPresentingViewController:self];
    }

    if ([segue.destinationViewController respondsToSelector:@selector(setList:)]) {
        PBList *list = [self.lists objectAtIndex:[self.tableView indexPathForCell:sender].row];
        [segue.destinationViewController setList:list];
        [segue.destinationViewController setFromReferral:NO];
    }
}

@end
