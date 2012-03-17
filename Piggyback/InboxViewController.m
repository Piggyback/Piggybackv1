//
//  InboxViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "InboxViewController.h"
#import "PiggybackAppDelegate.h"

@implementation InboxViewController

@synthesize inboxItems = _inboxItems;
@synthesize tableView = _tableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"inbox viewDidLoad");
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] isSessionValid])
    {
        NSLog(@"inbox viewWillAppear -- session is valid");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // re-fetch inbox items for users whenever inbox view appears
        NSString* inboxPath = [@"inboxapi/inbox/uid/" stringByAppendingFormat:@"%@",[defaults objectForKey:@"UID"]];
        RKObjectManager* objManager = [RKObjectManager sharedManager];
        RKObjectLoader* inboxLoader = [objManager loadObjectsAtResourcePath:inboxPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"inbox"] delegate:self];
        inboxLoader.userData = @"inboxLoader";
    } else {
        NSLog(@"inbox viewWillAppear -- session is NOT valid");
    }
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


// **** PROTOCOL FUNCTIONS FOR RKOBJECTDELEGATE **** //
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"inboxLoader") {
        self.inboxItems = objects;
        [self.tableView reloadData];
    } 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{
    NSLog(@"Encountered an error: %@", error);
}


// **** PROTOCOL FUNCTIONS FOR TABLE DATA SOURCE **** //
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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
    NSString* additionalInfo;    
    if([inboxItem.lid isEqualToNumber:[NSNumber numberWithInt:0]]) {
        cell.textLabel.text = inboxItem.vendor.name;
    } else {    
        cell.textLabel.text = inboxItem.listName;
        
        // get number of items in list
        NSString* numListItems = @"List with %d item";
        if ([inboxItem.listEntrys count] > 1) {
            numListItems = [numListItems stringByAppendingString:@"s"];
        }
        
        additionalInfo = [NSString stringWithFormat:numListItems,[inboxItem.listEntrys count]];
    }
    
    // date
    NSString* timeElapsed = [self timeElapsed:inboxItem.date];
    cell.detailTextLabel.text = timeElapsed;
    
    // add number of items (for lists)
    if(![inboxItem.lid isEqualToNumber:[NSNumber numberWithInt:0]]) {
        cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"\n"] stringByAppendingString:additionalInfo];
    }
    
    // number of other friends this was referred to
    NSString* numFriendsLabel = @"Recommended to you and %d friend";
    NSInteger numFriends = [inboxItem.otherFriends count];
    if (numFriends == 0) {
        numFriendsLabel = @"Just to you!";
    } else if (numFriends > 1) {
        numFriendsLabel = [numFriendsLabel stringByAppendingString:@"s"];
    }
    NSString* otherFriends = [NSString stringWithFormat:numFriendsLabel,numFriends];
    cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"\n"] stringByAppendingString:otherFriends];
    
    // comment
    cell.detailTextLabel.text = [[cell.detailTextLabel.text stringByAppendingString:@"\n"] stringByAppendingString:inboxItem.comment];
    cell.detailTextLabel.numberOfLines = 0;
    
    // image
    NSString* fbImage = [[@"http://graph.facebook.com/" stringByAppendingString:[inboxItem.referredByFBID stringValue]] stringByAppendingString:@"/picture"];
    cell.imageView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fbImage]]];
    
    return cell;
}

// get string for time elapsed e.g., "2 days ago"
- (NSString*)timeElapsed:(NSDate*)date {
    NSUInteger desiredComponents = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit |  NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* elapsedTimeUnits = [[NSCalendar currentCalendar] components:desiredComponents fromDate:date toDate:[NSDate date] options:0];
    
    NSInteger number = 0;
    NSString* unit;
    
    if ([elapsedTimeUnits year] > 0) {
        number = [elapsedTimeUnits year];
        unit = [NSString stringWithFormat:@"year"];
    }
    else if ([elapsedTimeUnits month] > 0) {
        number = [elapsedTimeUnits month];
        unit = [NSString stringWithFormat:@"month"];
    }
    else if ([elapsedTimeUnits week] > 0) {
        number = [elapsedTimeUnits week];
        unit = [NSString stringWithFormat:@"week"];
    }
    else if ([elapsedTimeUnits day] > 0) {
        number = [elapsedTimeUnits day];
        unit = [NSString stringWithFormat:@"day"];
    }
    else if ([elapsedTimeUnits hour] > 0) {
        number = [elapsedTimeUnits hour];
        unit = [NSString stringWithFormat:@"hour"];
    }
    else if ([elapsedTimeUnits minute] > 0) {
        number = [elapsedTimeUnits minute];
        unit = [NSString stringWithFormat:@"minute"];
    }
    else if ([elapsedTimeUnits second] > 0) {
        number = [elapsedTimeUnits second];
        unit = [NSString stringWithFormat:@"second"];
    } else if ([elapsedTimeUnits second] <= 0) {
        number = 0;
    }
    // check if unit number is greater then append s at the end
    if (number > 1) {
        unit = [NSString stringWithFormat:@"%@s", unit];
    }
    
    NSString* elapsedTime = [NSString stringWithFormat:@"%d %@ ago",number,unit];
    
    if (number == 0) {
            elapsedTime = @"Just now";
    }
    
    return elapsedTime;
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
        [(VendorViewController*)segue.destinationViewController setReferralComments:uniqueReferralComments];
    } else if ([[segue identifier] isEqualToString:@"inboxToList"]) {
        PBList* list = [[PBList alloc] init];
        list.uid = inboxItem.referredByUID;
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
    InboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
    if ([inboxItem.lid isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [self performSegueWithIdentifier:@"inboxToVendor" sender:self];
    } else {
        [self performSegueWithIdentifier:@"inboxToList" sender:self];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath 
{
    InboxItem* inboxItem = [self.inboxItems objectAtIndex:indexPath.row];
    CGSize size = [inboxItem.comment sizeWithFont:[UIFont systemFontOfSize:18.0f] constrainedToSize:CGSizeMake(265.0f,9999.0f) lineBreakMode:UILineBreakModeWordWrap];
    
    if (size.height + 60 < FACEBOOKPICHEIGHT) {
        return FACEBOOKPICHEIGHT + 2*FACEBOOKPICMARGIN;
    } else {
        return size.height + 2*FACEBOOKPICMARGIN + 60;
    }
}

- (IBAction)logout:(id)sender 
{
    [[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] logout];
}

@end
