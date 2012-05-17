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
#import "PBVendor.h"

typedef enum pbApiCall {
    pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals,
} pbApiCall;

@interface addToListTableViewController : UITableViewController <RKObjectLoaderDelegate>

@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) PBVendor *vendor;
- (IBAction)cancelAddToList:(id)sender;
- (IBAction)addToList:(id)sender;

@end
