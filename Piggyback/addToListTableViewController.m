//
//  addToListTableViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 4/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "addToListTableViewController.h"
#import "MBProgressHUD.h"
#import "PBUser.h"
#import "PBList.h"
#import "Constants.h"

@interface addToListTableViewController ()

@property int currentPbAPICall;
@property (nonatomic, strong) EGORefreshTableHeaderView* refreshHeaderView;
@property BOOL reloading;

@end

@implementation addToListTableViewController

@synthesize lists = _lists;
@synthesize reloading = _reloading;
@synthesize currentPbAPICall = _currentPbAPICall;
@synthesize refreshHeaderView = _refreshHeaderView;

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

- (void)loadObjectsFromDataStore {
    // fetch current user & set self.lists to currentUser.lists   
    PBUser* currentUser = [PBUser findFirstByAttribute:@"userID" withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES]];
    self.lists = [currentUser.lists sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)loadData {
    // Load the object model via RestKit
    self.reloading = YES;
    self.currentPbAPICall = pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals;
    NSString* listsPath = [RK_LISTS_ID_RESOURCE_PATH stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* listsLoader = [objManager loadObjectsAtResourcePath:listsPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"list"] delegate:self];
    NSLog(@"list table view controllerp ath is %@",listsPath);
    listsLoader.userData = @"listsLoader";
}



#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
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
    switch (self.currentPbAPICall) {
        case pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals:
        {
            // handle case where user has no lists
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ListsLastUpdatedAt"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.lists = [[NSArray alloc] init];
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

#pragma mark - view lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ListsLastUpdatedAt"]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadData];
    } else {
        [self loadObjectsFromDataStore];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"addToListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PBList* myList = [self.lists objectAtIndex:indexPath.row];
    cell.textLabel.text = myList.name;
    if ([myList.listCount intValue] == 1)
        cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@", myList.listCount] stringByAppendingString:@" item"];
    else
        cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@", myList.listCount] stringByAppendingString:@" items"];
    
    return cell;
}

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
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
    [self loadData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return self.reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ListsLastUpdatedAt"];
}

- (IBAction)cancelAddToList:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
