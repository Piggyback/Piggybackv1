//
//  ListTableViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import <RestKit/RestKit.h>

typedef enum fbApiCall {
    fbAPIGraphMeFromLogin,
} fbApiCall;

typedef enum pbApiCall {
    pbAPICurrentUserUidFromLogin,
    pbAPIGetCurrentUserLists,
} pbApiCall;


@interface ListsTableViewController : UITableViewController <FBSessionDelegate, FBRequestDelegate, RKObjectLoaderDelegate>

@property (nonatomic, strong) NSArray* lists;

@end
