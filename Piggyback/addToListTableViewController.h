//
//  addToListTableViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 4/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "EGORefreshTableHeaderView.h"

typedef enum pbApiCall {
    pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals,
} pbApiCall;

@interface addToListTableViewController : UITableViewController

@property (nonatomic, strong) NSArray* lists;
- (IBAction)cancelAddToList:(id)sender;

@end
