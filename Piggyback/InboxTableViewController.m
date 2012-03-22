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
#import "InboxItem.h"
#import "PBList.h"
#import "PBListEntry.h"
#import "VendorReferralComment.h"
#import "Constants.h"
#import "InboxTableCell.h"
#import <QuartzCore/QuartzCore.h>

@interface InboxTableViewController()

@property (nonatomic, strong) NSArray* inboxItems;
@property (nonatomic, strong) NSMutableDictionary* userFbPics;

@end

@implementation InboxTableViewController

@synthesize inboxItems = _inboxItems;
@synthesize userFbPics = _userFbPics;

#pragma mark - Getters and Setters
-(NSArray *)inboxItems
{
    if (!_inboxItems) {
        _inboxItems = [[NSArray alloc] init];
    }

    return _inboxItems;
}

-(NSMutableDictionary *)userFbPics
{
    if (!_userFbPics) {
        _userFbPics = [[NSMutableDictionary alloc] init];
    }
    
    return _userFbPics;
}


#pragma mark - private helper functions
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

#pragma mark - rest kit protocol methods
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"inboxLoader") {
        self.inboxItems = objects;
        
        // store all user FB pics in private property in a separate thread
        for (InboxItem* currentInboxItem in self.inboxItems) {
            NSString* fbImageLocation = [[@"http://graph.facebook.com/" stringByAppendingString:[currentInboxItem.referrer.fbid stringValue]] stringByAppendingString:@"/picture"];
            if (![self.userFbPics objectForKey:currentInboxItem.referrer.fbid]) {
                [self.userFbPics setObject:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fbImageLocation]]] forKey:currentInboxItem.referrer.fbid];
//                UIImageView* userFbPic = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fbImageLocation]]]];
//                userFbPic.layer.masksToBounds = YES;
//                userFbPic.layer.cornerRadius = 5.0;

//                [self.userFbPics setObject:userFbPic forKey:currentInboxItem.referrer.fbid];
            }
        }
        
        [self.tableView reloadData];
    } 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{
    NSLog(@"Encountered an error: %@", error);
}

#pragma mark - table data source protocol methods
// **** PROTOCOL FUNCTIONS FOR TABLE DATA SOURCE **** //
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSLog(@"num of inbox items is %ld",(long)[self.inboxItems count]);
    return [self.inboxItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inboxTableCell";
    
    InboxTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[InboxTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    InboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
    
    // vendor or list name 
    if ([inboxItem.lid intValue] == 0) {
        cell.name.text = inboxItem.vendor.name;
        cell.numItemsInList.text = @"";
    } else {    
        cell.name.text = inboxItem.listName;
        cell.numItemsInList.text = [[@" (" stringByAppendingFormat:@"%d",[inboxItem.listEntrys count]] stringByAppendingString:@")"];
        
        // set position of number of items in list
        CGSize listNameSize = [inboxItem.listName sizeWithFont:[UIFont boldSystemFontOfSize:15.0f] constrainedToSize:CGSizeMake(195.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
        NSLog(@"size needed for vendor name is %f",listNameSize.width);
        CGRect listNameFrame = cell.name.frame;
        listNameFrame.origin.x = listNameFrame.origin.x + listNameSize.width;
        cell.numItemsInList.frame = listNameFrame;
    }
    // date
    NSString* timeElapsed = [self timeElapsed:inboxItem.date];
    cell.date.text = timeElapsed;
    
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
    cell.comment.text = inboxItem.comment;
    CGSize sizeOfComment = [inboxItem.comment sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = cell.comment.frame;
    newFrame.size.height = sizeOfComment.height;
    cell.comment.frame = newFrame;
    
    // image
    cell.image.layer.cornerRadius = 5.0;
    cell.image.layer.masksToBounds = YES;
    cell.image.image = [self.userFbPics objectForKey:inboxItem.referrer.fbid];
    
    return cell;
}

#pragma mark - Table view delegate protocol methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
    if ([inboxItem.lid intValue] == 0) {
        [self performSegueWithIdentifier:@"inboxToVendor" sender:[tableView cellForRowAtIndexPath:indexPath]];
    } else {
        [self performSegueWithIdentifier:@"inboxToList" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    InboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
    CGSize size = [inboxItem.comment sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
    
    if (size.height + 35 < FACEBOOKPICHEIGHT) {
        return FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN;
    } else {
        return size.height + 2*FACEBOOKPICMARGIN + 35;
    }
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
    NSLog(@"inbox viewDidLoad");
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // re-fetch inbox items for users whenever inbox view appears
    NSString* inboxPath = [@"inboxapi/inbox/id/" stringByAppendingFormat:@"%@",[defaults objectForKey:@"UID"]];
    NSLog(@"INBOX PATH: %@", inboxPath);
    RKObjectManager* objManager = [RKObjectManager sharedManager];
    RKObjectLoader* inboxLoader = [objManager loadObjectsAtResourcePath:inboxPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"inbox"] delegate:self];
    inboxLoader.userData = @"inboxLoader";
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
    InboxItem* inboxItem = [self.inboxItems objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    if([[segue identifier] isEqualToString:@"inboxToVendor"]) {
        // set vendor for display on vendor detail view
        [segue.destinationViewController setVendor:inboxItem.vendor];
        
        // get list of unique people / comments who referred vendor to you and set for next view to display
        NSMutableOrderedSet* uniqueReferrerUIDs = [[NSMutableOrderedSet alloc] init];
        NSMutableArray* uniqueReferralComments = [[NSMutableArray alloc] init];
        for (VendorReferralComment* commentObject in inboxItem.nonUniqueReferralComments) {
            if (![uniqueReferrerUIDs containsObject:commentObject.referrer.uid]) {
                [uniqueReferrerUIDs addObject:commentObject.referrer.uid];
                [uniqueReferralComments addObject:commentObject];
            }
        }
        [(VendorViewController*)segue.destinationViewController setReferralComments:[NSArray arrayWithArray:uniqueReferralComments]];
    } else if ([[segue identifier] isEqualToString:@"inboxToList"]) {
        PBList* list = [[PBList alloc] init];
        list.uid = inboxItem.referrer.uid;
        list.lid = inboxItem.lid;
        list.date = inboxItem.date; // i put date list was referred, not date list was created
        list.name = inboxItem.listName;
        
        // get number of people who referred each vendor in list
        for (PBListEntry* currentListEntry in inboxItem.listEntrys) {
            NSMutableSet* uniqueReferrers = [[NSMutableSet alloc] init];
            
            for (VendorReferralComment* currentReferralComment in currentListEntry.referredBy) {
                [uniqueReferrers addObject:currentReferralComment.referrer.uid];
            }

            currentListEntry.numUniqueReferredBy = [NSNumber numberWithInt:[uniqueReferrers count]];
        }
        
        list.listEntrys = inboxItem.listEntrys;
        [(IndividualListViewController*)segue.destinationViewController setList:list];
    }
}

#pragma mark - IBAction methods

- (IBAction)logout:(id)sender 
{
    [[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] logout];
}

@end
