//
//  InboxViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#warning - move header imports to the .m file if not publicly used
//#import "InboxItem.h"
//#import "PBListEntry.h"
//#import "Constants.h"
//#import "InboxTableCell.h"
//#import "VendorReferralComment.h"
//#import "VendorViewController.h"
//#import "PBList.h"
//#import "IndividualListViewController.h"
//#import "PBListEntry.h"  

@interface InboxViewController : UITableViewController <RKObjectLoaderDelegate>

#warning - outlet should be weak -- 'view' holds a strong pointer to tableView
//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)logout:(id)sender;

@end
