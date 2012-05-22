//
//  ListTableViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "EGORefreshTableHeaderView.h"

typedef enum pbApiCall {
    pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals,
} pbApiCall;


@interface ListsTableViewController : UITableViewController <RKObjectLoaderDelegate, EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) NSMutableArray* lists;

@end
