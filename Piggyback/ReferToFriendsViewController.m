//
//  ReferToFriendsViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ReferToFriendsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "PBUser.h"
#import "PBReferral.h"
#import "PiggybackAppDelegate.h"
#import "MBProgressHUD.h"

@interface ReferToFriendsViewController ()

@property (nonatomic, strong) NSMutableSet *selectedFriendsIndexes;
@property (nonatomic, strong) EGORefreshTableHeaderView* refreshHeaderView;
@property BOOL reloading;
@property int currentPbAPICall;

@end

@implementation ReferToFriendsViewController

NSString* const RK_FRIENDS_RESOURCE_PATH = @"/userapi/userFriends/user/"; // ?

@synthesize friends = _friends;
@synthesize vendor = _vendor;
@synthesize lid = _lid;
@synthesize tableView = _tableView;
@synthesize commentTextField = _commentTextField;
@synthesize grayLayer = _grayLayer;
@synthesize backgroundView = _backgroundView;
@synthesize selectedFriendsIndexes = _selectedFriendsIndexes;
@synthesize source = _source;
@synthesize scrollView = _scrollView;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;
@synthesize currentPbAPICall = _currentPbAPICall;

#pragma mark - getters / setters

- (NSArray *)friends {
    if (!_friends) {
        _friends = [[NSArray alloc] init];
    }
    
    return _friends;
}

- (NSMutableSet*)selectedFriendsIndexes {
    if (!_selectedFriendsIndexes) {
        _selectedFriendsIndexes = [[NSMutableSet alloc] init];
    }
    return _selectedFriendsIndexes;
}

#pragma mark - Private Helper Methods

- (void)loadObjectsFromDataStore {
    PBUser* currentUser = [PBUser findFirstByAttribute:@"userID" withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    NSSortDescriptor *sortDescriptorFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortDescriptorLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorFirstName,sortDescriptorLastName,nil];
    self.friends = [[currentUser.friends allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    [self.tableView reloadData];
}

- (void)loadData {
    // load friends from DB
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.reloading = YES;
    
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* friendsLoader = [objManager loadObjectsAtResourcePath:[RK_FRIENDS_RESOURCE_PATH stringByAppendingFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]] objectMapping:[objManager.mappingProvider mappingForKeyPath:@"user"] delegate:self];
    self.currentPbAPICall = pbAPIRefreshFriends;
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData {
    NSMutableDictionary* currentUserDict = [*mappableData mutableCopy];
    NSMutableArray* friendsWithThumbnails = [[NSMutableArray alloc] init];
    for (id currentFriendDict in [currentUserDict objectForKey:@"friends"]) {
        NSMutableDictionary *currentFriendMutableDict = [currentFriendDict mutableCopy];
        [currentFriendMutableDict setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[currentFriendDict objectForKey:@"thumbnail"]]]] forKey:@"thumbnail"];
        [friendsWithThumbnails addObject:currentFriendMutableDict];
    }
    
    [currentUserDict setObject:friendsWithThumbnails forKey:@"friends"];
    
    *mappableData = currentUserDict;
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"did load objects!");
    switch (self.currentPbAPICall) {
        case pbAPIRefreshFriends:
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"friends"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loadObjectsFromDataStore];
            self.reloading = NO;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
            break;
        }
        case pbAPIPostReferral:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController dismissModalViewControllerAnimated:YES];
            });
            break;
        }
        default:
            break;
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"ERROR");
    switch (self.currentPbAPICall) {
        case pbAPIRefreshFriends:
        {
            // handle case where user has no friends
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"friends"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.reloading = NO;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
            break;
        }
        case pbAPIPostReferral:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController dismissModalViewControllerAnimated:YES];
            });
            break;
        }
        default:
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ReferToFriendsViewController RK Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"ReferToFriendsViewController RK error: %@", error);
            break;
        }
    }
}

#pragma mark - keyboard delegate functions

- (void)hideKeyboard {
    [self.commentTextField resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *)note 
{
    NSLog(@"hello keyboard showde");
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"referToFriendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.friends objectAtIndex:indexPath.row] firstName],[[self.friends objectAtIndex:indexPath.row] lastName]];
    
    PBUser* friend = [self.friends objectAtIndex:indexPath.row];
    UIImage* img = friend.thumbnail;
    cell.imageView.layer.cornerRadius = 8.0;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.image = img;
    
    // set checkmark
    if ([self.selectedFriendsIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
       
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedFriendsIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        [self.selectedFriendsIndexes removeObject:[NSNumber numberWithInt:indexPath.row]];
    } else {
        [self.selectedFriendsIndexes addObject:[NSNumber numberWithInt:indexPath.row]];
    }
    
    NSLog(@"selected friend indexes are %@",self.selectedFriendsIndexes);
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return REFERFRIENDPICHEIGHT + 3;
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
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"friends"];
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
    
    if (self.refreshHeaderView == nil) {
        EGORefreshTableHeaderView* view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -180.0f, self.view.frame.size.width, 180.0f) arrowImageName:@"blackArrow" textColor:[UIColor blackColor]];
        view.delegate = self;
        [self.scrollView addSubview:view];
        self.refreshHeaderView = view;
        self.scrollView.alwaysBounceVertical = YES;
    }
    
    [self.refreshHeaderView refreshLastUpdatedDate];
    
    // set friends
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"friends"]]) {
//        [self loadData];
//    } else {
        [self loadObjectsFromDataStore];
//    }
    
    // tap outside of textfield hides keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.grayLayer addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil]; 
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - storyboard actions

- (IBAction)cancelReferToFriends:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)referToFriends:(id)sender {
    if ([self.selectedFriendsIndexes count] == 0) {
        UIAlertView *noFriendsSelectedAlert = [[UIAlertView alloc] initWithTitle:@"No Friends Selected" message:@"Must recommend to at least one friend!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noFriendsSelectedAlert show];
    } else {
        for (NSNumber *currentFriendIndex in self.selectedFriendsIndexes) {            
            PBReferral* newReferral = [[PBReferral alloc] init];

            // set users
            newReferral.senderUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
            newReferral.receiverUID = [[self.friends objectAtIndex:[currentFriendIndex intValue]] userID];
            
            // set date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
            newReferral.date = [dateFormatter stringFromDate:[NSDate date]];
            
            // set lid or vendor
            if ([self.source isEqualToString:@"list"]) {
                newReferral.lid = self.lid;
                newReferral.vendor = nil;
            } else if ([self.source isEqualToString:@"vendor"]) {
                newReferral.lid = 0;
                newReferral.vendor = self.vendor;
            }
            
            // set comment
            newReferral.comment = self.commentTextField.text;

            NSLog(@"new referral is %@",newReferral);
            
            self.currentPbAPICall = pbAPIPostReferral;
            [[RKObjectManager sharedManager] postObject:newReferral delegate:self];
        }
    }
}

@end
