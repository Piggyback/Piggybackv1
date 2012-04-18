//
//  InboxViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "EGORefreshTableHeaderView.h"

@interface InboxTableViewController : UITableViewController <RKObjectLoaderDelegate, EGORefreshTableHeaderDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)logout:(id)sender;

@end
