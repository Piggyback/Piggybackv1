//
//  AddToListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 5/22/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PBVendor.h"

typedef enum pbApiCall {
    pbAPIGetCurrentUserListsAndListEntrysandIncomingReferrals,
} pbApiCall;

@interface AddToListViewController : UIViewController <RKObjectLoaderDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *lists;
@property (nonatomic, strong) PBVendor *vendor;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
- (IBAction)cancelAddToList:(id)sender;
- (IBAction)addToList:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *grayLayer;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end