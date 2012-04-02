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

@interface InboxTableViewController()

@property (nonatomic, strong) NSArray* inboxItems;
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
-(NSArray *)inboxItems
{
    if (!_inboxItems) {
        _inboxItems = [[NSArray alloc] init];
    }

    return _inboxItems;
}

-(void)setInboxItems:(NSArray *)inboxItems
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
    self.inboxItems = [PBInboxItem objectsWithFetchRequest:request];
}

- (void)loadData {
    // Load the object model via RestKit
    self.reloading = YES;
    NSString* inboxPath = [RK_INBOX_ID_RESOURCE_PATH stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
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
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"inboxLoader") {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"InboxLastUpdatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadObjectsFromDataStore];
        self.reloading = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
//        [self.tableView reloadData];
        
//        self.inboxItems = objects;
//        
//        // store all user FB pics in a NSMutableDictionary
//        for (InboxItem* currentInboxItem in self.inboxItems) {
//            NSString* fbImageLocation = [[@"http://graph.facebook.com/" stringByAppendingString:[currentInboxItem.referrer.fbid stringValue]] stringByAppendingString:@"/picture"];
//            if (![self.userFbPics objectForKey:currentInboxItem.referrer.fbid]) {
//                [self.userFbPics setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fbImageLocation]]] forKey:currentInboxItem.referrer.fbid];
//            }
//        }
//        
//        [self.tableView reloadData];
    } 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{    
    if (objectLoader.userData == @"inboxLoader") {
        // handle case where user has no inbox items
        self.inboxItems = [NSArray arrayWithObject:[NSString stringWithString:@"Your inbox is empty!"]];      
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"InboxTableViewController RK Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        NSLog(@"InboxTableViewController RK error: %@", error);
    }

}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if ([self.inboxItems count] == 0) {
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
            cell.numItemsInList.text = [[@" (" stringByAppendingFormat:@"%d",[inboxItem.listCount intValue]] stringByAppendingString:@")"];
            
            // set position of number of items in list
            CGSize listNameSize = [inboxItem.list.name sizeWithFont:[UIFont boldSystemFontOfSize:15.0f] constrainedToSize:CGSizeMake(195.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
            CGRect listNameFrame = cell.name.frame;
            listNameFrame.origin.x = listNameFrame.origin.x + listNameSize.width;
            listNameFrame.size.width = listNameSize.width;
            cell.numItemsInList.frame = listNameFrame;
        }
        // date
        cell.date.text = [self timeElapsed:inboxItem.referralDate];
        
        // referred by
        cell.referredBy.text = [[[@"From " stringByAppendingString:inboxItem.referrerFirstName] stringByAppendingString:@" "] stringByAppendingString:inboxItem.referrerLastName];
        
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
//    if (![[self.inboxItems objectAtIndex:indexPath.row] isKindOfClass:[InboxItem class]]) {
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
    [self loadObjectsFromDataStore];
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
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    // re-fetch inbox items for users whenever inbox view appears
//    NSString* inboxPath = [RK_INBOX_ID_RESOURCE_PATH stringByAppendingFormat:@"%@",[defaults objectForKey:@"UID"]];
//    RKObjectManager* objManager = [RKObjectManager sharedManager];
//    RKObjectLoader* inboxLoader = [objManager loadObjectsAtResourcePath:inboxPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"inbox"] delegate:self];
//    inboxLoader.userData = @"inboxLoader";
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PBInboxItem* inboxItem = [self.inboxItems objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    if([[segue identifier] isEqualToString:@"inboxToVendor"]) {
        // set vendor for display on vendor detail view
        [segue.destinationViewController setVendor:inboxItem.vendor];
        
        // get list of unique people / comments who referred vendor to you and set for next view to display
//        NSMutableOrderedSet* uniqueReferrerUIDs = [[NSMutableOrderedSet alloc] init];
//        NSMutableArray* uniqueReferralComments = [[NSMutableArray alloc] init];
//        for (VendorReferralComment* commentObject in inboxItem.nonUniqueReferralComments) {
//            if (![uniqueReferrerUIDs containsObject:commentObject.referrer.uid]) {
//                [uniqueReferrerUIDs addObject:commentObject.referrer.uid];
//                [uniqueReferralComments addObject:commentObject];
//            }
//        }
//        [(VendorViewController*)segue.destinationViewController setReferralComments:[NSArray arrayWithArray:uniqueReferralComments]];
        
    } else if ([[segue identifier] isEqualToString:@"inboxToList"]) {
        [(IndividualListViewController*)segue.destinationViewController setList:inboxItem.list];
    }
}

#pragma mark - IBAction methods

- (IBAction)logout:(id)sender 
{
    [[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] logout];
}

@end
