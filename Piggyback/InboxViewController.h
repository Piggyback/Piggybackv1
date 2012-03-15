//
//  InboxViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "InboxItem.h"
#import "PBListEntry.h"
#import "Constants.h"
#import "InboxTableCell.h"
#import "VendorReferralComment.h"
#import "VendorViewController.h"
#import "PBList.h"
#import "ListsTableViewController.h"

@interface InboxViewController : UITableViewController <RKObjectLoaderDelegate>

@property (nonatomic, strong) NSArray* inboxItems;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)logout:(id)sender;
- (NSString*)timeElapsed:(NSDate*)date;

@end
