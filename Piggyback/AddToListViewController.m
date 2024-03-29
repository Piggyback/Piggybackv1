//
//  AddToListViewController.m
//  Piggyback
//
//  Created by Michael Gao on 5/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "AddToListViewController.h"
#import "MBProgressHUD.h"
#import "PBUser.h"
#import "PBList.h"
#import "PBListEntry.h"
#import "Constants.h"
#import "Reachability.h"

@interface AddToListViewController ()

@property int currentPbAPICall;
@property (nonatomic, strong) NSMutableSet *selectedListsIndexes;
@property (nonatomic, strong) NSMutableSet *completedListAdds;

@end

@implementation AddToListViewController
@synthesize grayLayer = _grayLayer;
@synthesize backgroundView = _backgroundView;
@synthesize tableView = _tableView;
@synthesize commentTextField = _commentTextField;
@synthesize lists = _lists;
@synthesize currentPbAPICall = _currentPbAPICall;
@synthesize vendor = _vendor;
@synthesize selectedListsIndexes = _selectedListsIndexes;
@synthesize completedListAdds = _completedListAdds;

#pragma mark - Getters and Setters

- (NSArray *)lists {
    if (!_lists) {
        _lists = [[NSArray alloc] init];
    }
    
    return _lists;
}

- (NSMutableSet *)selectedListsIndexes {
    if (!_selectedListsIndexes) {
        _selectedListsIndexes = [[NSMutableSet alloc] init];
    }
    
    return _selectedListsIndexes;
}

-(NSMutableSet *)completedListAdds {
    if (!_completedListAdds) {
        _completedListAdds = [[NSMutableSet alloc] init];
    }
    return _completedListAdds;
}

- (void)setLists:(NSArray *)lists {
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connection with server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    self.lists = [currentUser.lists sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)loadData {
    // Load the object model via RestKit
    self.currentPbAPICall = pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals;
    NSString* listsPath = [RK_LISTS_ID_RESOURCE_PATH stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* listsLoader = [objManager loadObjectsAtResourcePath:listsPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"list"] delegate:self];
    NSLog(@"list table view controllerp ath is %@",listsPath);
    listsLoader.userData = @"listsLoader";
}

#pragma mark - keyboard delegate functions

- (void)hideKeyboard {
    [self.commentTextField resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *)note 
{
    [self.view bringSubviewToFront:self.grayLayer];
}

- (void)keyboardDidHide:(NSNotification *)note 
{
    [self.view bringSubviewToFront:self.backgroundView];
    [self.view bringSubviewToFront:self.tableView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.commentTextField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"did load add to list view controller");
    switch (self.currentPbAPICall) {
        case pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals:
        {
            NSLog(@"num of lists returned: %i", [objects count]);
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ListsLastUpdatedAt"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loadObjectsFromDataStore];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            break;
        }
        case pbAPIAddToList:
        {
            [self.completedListAdds addObject:objects];
            if ([self.completedListAdds count] == [self.selectedListsIndexes count]) {
                [self.navigationController dismissModalViewControllerAnimated:YES];
                NSLog(@"dismissing vc");
            }
            break;
        }
        default:
            break;
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"failed to map list entry");
    if (error.code == 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connection with error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        switch (self.currentPbAPICall) {
            case pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals:
            {
                // handle case where user has no lists
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ListsLastUpdatedAt"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.lists = [[NSArray alloc] init];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                break;
            }
            case pbAPIAddToList:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Adding to List" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
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

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.commentTextField.delegate = self;
//    self.commentTextField.frame = CGRectMake(self.commentTextField.frame.origin.x, self.commentTextField.frame.origin.y, self.commentTextField.frame.size.width,25);
    
    // tap outside of textfield hides keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.grayLayer addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil]; 
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ListsLastUpdatedAt"]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self checkHostStatus];
    } else {
        [self loadObjectsFromDataStore];
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setCommentTextField:nil];
    [self setGrayLayer:nil];
    [self setBackgroundView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    [[[[RKObjectManager sharedManager] client] requestQueue] cancelRequestsWithDelegate:self];
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
    
    // set checkmark
    if ([self.selectedListsIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedListsIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        [self.selectedListsIndexes removeObject:[NSNumber numberWithInt:indexPath.row]];
    } else {
        [self.selectedListsIndexes addObject:[NSNumber numberWithInt:indexPath.row]];
    }
    
    NSLog(@"selected list indexes are %@",self.selectedListsIndexes);
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)cancelAddToList:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)addToList:(id)sender {
    if ([self.selectedListsIndexes count] == 0) {
        UIAlertView *noListsSelectedAlert = [[UIAlertView alloc] initWithTitle:@"No Lists Selected" message:@"A list must be selected!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noListsSelectedAlert show];
    } else {
        int counter = 0;
        for (NSNumber *currentListIndex in self.selectedListsIndexes) {
            counter++;
            PBList *currentList = [self.lists objectAtIndex:[currentListIndex intValue]];
            currentList.listCount = [NSNumber numberWithInt:[currentList.listCount intValue] + 1];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];

            PBListEntry *newListEntryDB = [PBListEntry object];
            newListEntryDB.assignedListID = currentList.listID;
            newListEntryDB.vendorID = self.vendor.vendorID;
            newListEntryDB.comment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            newListEntryDB.addedDate = [dateFormatter stringFromDate:[NSDate date]];
            newListEntryDB.vendor = self.vendor;
            newListEntryDB.assignedList = currentList;
            NSLog(@"vendor in add to list is %@",newListEntryDB.vendor);

            self.currentPbAPICall = pbAPIAddToList;
                
            [[RKObjectManager sharedManager] postObject:newListEntryDB mapResponseWith:[[[RKObjectManager sharedManager] mappingProvider] mappingForKeyPath:@"listEntry"] delegate:nil];
            [self.navigationController dismissModalViewControllerAnimated:YES];
        }
    }
    
}

@end
