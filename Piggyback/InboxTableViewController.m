//
//  InboxViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "InboxTableViewController.h"
#import "PiggybackAppDelegate.h"
#import "VendorViewController.h"
#import "IndividualListViewController.h"
#import "PBInboxItem.h"
#import "PBList.h"
#import "PBListEntry.h"
#import "PBVendorReferralComment.h"
#import "Constants.h"
#import "InboxTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "FlurryAnalytics.h"

@interface InboxTableViewController()

@property (nonatomic, strong) NSMutableArray* inboxItems;
@property (nonatomic, strong) NSMutableDictionary* userFbPics;
@property (nonatomic, strong) EGORefreshTableHeaderView* refreshHeaderView;
@property BOOL reloading;

@end

@implementation InboxTableViewController

NSString* const RK_INBOX_ID_RESOURCE_PATH = @"inboxapi/coreDataInbox/id/";
NSString* const NO_INBOX_TEXT = @"Your inbox is empty!";
NSString* const NO_INBOX_DETAILED_TEXT = @"Tell your friends to recommend you places they think you will like at www.getpiggyback.com and stay tuned for mobile app updates!";

@synthesize inboxItems = _inboxItems;
@synthesize userFbPics = _userFbPics;
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize reloading = _reloading;

#pragma mark - Getters and Setters
-(NSMutableArray *)inboxItems
{
    if (!_inboxItems) {
        _inboxItems = [[NSMutableArray alloc] init];
    }

    return _inboxItems;
}

-(void)setInboxItems:(NSMutableArray *)inboxItems
{
    _inboxItems = inboxItems;
    [self.tableView reloadData];
}

-(NSMutableDictionary *)userFbPics
{
    if (!_userFbPics) {
        _userFbPics = [[NSMutableDictionary alloc] init];
    }
    
    return _userFbPics;
}

#pragma mark - Private Helper Methods
- (void)loadObjectsFromDataStore {
    NSFetchRequest* request = [PBInboxItem fetchRequest];
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"referralDate" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    self.inboxItems = [[PBInboxItem objectsWithFetchRequest:request] mutableCopy];
}

- (void)loadData {
    // Load the object model via RestKit
    self.reloading = YES;
    NSString* inboxPath = [RK_INBOX_ID_RESOURCE_PATH stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
    NSLog(@"inbox path is %@",inboxPath);
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* inboxLoader = [objManager loadObjectsAtResourcePath:inboxPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"inbox"] delegate:self];
    inboxLoader.userData = @"inboxLoader";
}

// get string for time elapsed e.g., "2 days ago"
- (NSString*)timeElapsed:(NSDate*)date {
    NSUInteger desiredComponents = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* elapsedTimeUnits = [[NSCalendar currentCalendar] components:desiredComponents fromDate:date toDate:[NSDate date] options:0];
    
    NSInteger number = 0;
    NSString* unit;
    
    if ([elapsedTimeUnits year] > 0) {
        number = [elapsedTimeUnits year];
        unit = [NSString stringWithFormat:@"yr"];
    }
    else if ([elapsedTimeUnits month] > 0) {
        number = [elapsedTimeUnits month];
        unit = [NSString stringWithFormat:@"mo"];
    }
    else if ([elapsedTimeUnits week] > 0) {
        number = [elapsedTimeUnits week];
        unit = [NSString stringWithFormat:@"wk"];
    }
    else if ([elapsedTimeUnits day] > 0) {
        number = [elapsedTimeUnits day];
        unit = [NSString stringWithFormat:@"d"];
    }
    else if ([elapsedTimeUnits hour] > 0) {
        number = [elapsedTimeUnits hour];
        unit = [NSString stringWithFormat:@"hr"];
    }
    else if ([elapsedTimeUnits minute] > 0) {
        number = [elapsedTimeUnits minute];
        unit = [NSString stringWithFormat:@"min"];
    }
    else if ([elapsedTimeUnits second] > 0) {
        number = [elapsedTimeUnits second];
        unit = [NSString stringWithFormat:@"sec"];
    } else if ([elapsedTimeUnits second] <= 0) {
        number = 0;
    }
    // check if unit number is greater then append s at the end
    //    if (number > 1) {
    //        unit = [NSString stringWithFormat:@"%@s", unit];
    //    }
    
    NSString* elapsedTime = [NSString stringWithFormat:@"%d%@",number,unit];
    
    if (number == 0) {
        elapsedTime = @"1sec";
    }
    
    return elapsedTime;
}

#pragma mark - RKObjectLoaderDelegate methods
//- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData {
//    NSMutableDictionary *userFbPics = [[NSMutableDictionary alloc] init];
//    NSMutableArray *reformattedData = [NSMutableArray arrayWithCapacity:[*mappableData count]];
//    for(id dict in [NSArray arrayWithArray:(NSArray*)*mappableData]) {
//        NSMutableDictionary* newInboxDict = [dict mutableCopy];
//        NSMutableDictionary* newUserDict = [[newInboxDict objectForKey:@"referrer"] mutableCopy];
//        NSNumber* userID = [newUserDict valueForKey:@"userID"];
//        if (![userFbPics objectForKey:userID]) {
//            UIImage* thumbnail = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[newUserDict valueForKey:@"thumbnail"]]]];
//            [userFbPics setObject:thumbnail forKey:userID];
//        }
//        UIImage* thumbnail = [userFbPics objectForKey:userID];
//        [newUserDict setValue:thumbnail forKey:@"thumbnail"];
//        [newInboxDict setValue:newUserDict forKey:@"referrer"];
//        [reformattedData addObject:newInboxDict];
//    }
//    
//    *mappableData = reformattedData;
//}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"inboxLoader") {        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"InboxLastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadObjectsFromDataStore];
        self.reloading = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    } 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{    
    if (objectLoader.userData == @"inboxLoader") {
        // handle case where user has no inbox items
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"InboxLastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.inboxItems = [[NSMutableArray alloc] init];
        self.reloading = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"InboxTableViewController RK Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        NSLog(@"InboxTableViewController RK error: %@", error);
    }

}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"InboxLastUpdatedAt"]) {
        return 0;
    } else if ([self.inboxItems count] == 0) {
        // display empty inbox message
        return 1;
    } else {
        return [self.inboxItems count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // check if user has inbox items
    if ([self.inboxItems count] == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyInboxCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyInboxCell"];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"inboxTableCell";
        
        InboxTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[InboxTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        PBInboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
        
        // vendor or list name 
        if ([inboxItem.list.listID intValue] == 0) {
            cell.name.text = inboxItem.vendor.name;
            cell.numItemsInList.text = @"";
        } else {    
            cell.name.text = inboxItem.list.name;
            cell.numItemsInList.text = [[@" (" stringByAppendingFormat:@"%d",[inboxItem.list.listCount intValue]] stringByAppendingString:@")"];
            
            // set position of number of items in list
            CGSize listNameSize = [inboxItem.list.name sizeWithFont:[UIFont boldSystemFontOfSize:15.0f] constrainedToSize:CGSizeMake(500.0f,9999.0f) lineBreakMode:UILineBreakModeTailTruncation];
            //hacky solution because sizeWithFont cuts off the last word regardless of the lineBreakMode set (returns width less than 185 when expected is 185)
            if (listNameSize.width > 185.0f) {
                listNameSize.width = 185.0f;
            }
            CGRect listNameFrame = cell.name.frame;
            listNameFrame.origin.x = listNameFrame.origin.x + listNameSize.width;
            listNameFrame.size.width = listNameSize.width;
            cell.numItemsInList.frame = listNameFrame;
            NSLog(@"listName width: %f", listNameFrame.size.width);
//            NSLog(@"listNameFrame origin: %f", listNameFrame.origin.x);
        }
        // date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
        cell.date.text = [self timeElapsed:[dateFormatter dateFromString:inboxItem.referralDate]];
        
        // referred by
        cell.referredBy.text = [[[@"From " stringByAppendingString:inboxItem.referrer.firstName] stringByAppendingString:@" "] stringByAppendingString:inboxItem.referrer.lastName];
        
        // number of other friends this was referred to
    //    NSString* numFriendsLabel = @"To you and %d friend";
    //    NSInteger numFriends = [inboxItem.otherFriends count];
    //    if (numFriends == 0) {
    //        numFriendsLabel = @"Just to you!";
    //    } else if (numFriends > 1) {
    //        numFriendsLabel = [numFriendsLabel stringByAppendingString:@"s"];
    //    }
    //    NSString* otherFriends = [NSString stringWithFormat:numFriendsLabel,numFriends];
    //    cell.referredTo.text = otherFriends;
        
        // comment
        cell.comment.numberOfLines = 0;
        cell.comment.text = inboxItem.referralComment;
        CGSize sizeOfComment = [inboxItem.referralComment sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
        CGRect newFrame = cell.comment.frame;
        newFrame.size.height = sizeOfComment.height;
        cell.comment.frame = newFrame;
        
        // image
        cell.image.layer.cornerRadius = 5.0;
        cell.image.layer.masksToBounds = YES;
//        cell.image.image = [self.userFbPics objectForKey:inboxItem.referrer.fbid];
        cell.image.image = inboxItem.referrer.thumbnail;
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBInboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
    if ([inboxItem.list.listID intValue] == 0) {
        [self performSegueWithIdentifier:@"inboxToVendor" sender:[tableView cellForRowAtIndexPath:indexPath]];
    } else {
        [self performSegueWithIdentifier:@"inboxToList" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    // height for empty cell
    if ([self.inboxItems count] == 0) {
        return tableView.rowHeight;
    } else {
        PBInboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
        CGSize size = [inboxItem.referralComment sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
        
        if (size.height + 35 < FACEBOOKPICHEIGHT) {
            return FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN;
        } else {
            return size.height + 2*FACEBOOKPICMARGIN + 35;
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
        NSNumber* rid = [[self.inboxItems objectAtIndex:indexPath.row] referralID];
        NSDictionary* params = [NSDictionary dictionaryWithObject:rid forKey:@"rid"];
        [[RKClient sharedClient] put:@"inboxapi/coreDataInboxItemDelete" params:params delegate:self];
        
        // delete from core data
        PBInboxItem* deletedInboxItem = [self.inboxItems objectAtIndex:indexPath.row];
        [[[[RKObjectManager sharedManager] objectStore] managedObjectContext] deleteObject:deletedInboxItem];
        [[[[RKObjectManager sharedManager] objectStore] managedObjectContext] save:nil];
        
        // delete from view
        [self.inboxItems removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
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
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"InboxLastUpdatedAt"];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [FlurryAnalytics logEvent:@"VIEWED_INBOX"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"inbox view did appear");
    
    //    if ([[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] isSessionValid]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"InboxLastUpdatedAt"]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self loadData];
        } else {
            NSLog(@"loading inbox from core data");
            [self loadObjectsFromDataStore];
        }
    }
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![[segue identifier] isEqualToString:@"inboxToFeedback"]) {
        PBInboxItem* inboxItem = [self.inboxItems objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        if([[segue identifier] isEqualToString:@"inboxToVendor"]) {
            // set vendor for display on vendor detail view
            [segue.destinationViewController setVendor:inboxItem.vendor];
            [segue.destinationViewController setSource:@"inboxVendorReferral"];
            
        } else if ([[segue identifier] isEqualToString:@"inboxToList"]) {
            [(IndividualListViewController*)segue.destinationViewController setList:inboxItem.list];
            [segue.destinationViewController setFromReferral:YES];
        }
    }
}

#pragma mark - IBAction methods

- (IBAction)logout:(id)sender 
{
    [[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] logout];
}

@end
