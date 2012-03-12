//
//  ListTableViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

typedef enum pbApiCall {
    pbAPIGetCurrentUserLists,
    pbAPIGetListEntrysForSingleList,
} pbApiCall;


@interface ListsTableViewController : UITableViewController <RKObjectLoaderDelegate>

@property (nonatomic, strong) NSArray* lists;

@end
