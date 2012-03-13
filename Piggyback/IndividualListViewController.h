//
//  IndividualListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/12/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PBList.h"

@interface IndividualListViewController : UIViewController

@property (nonatomic, strong) PBList* list;
@property (weak, nonatomic) IBOutlet UIButton *vendorItemButton;

- (void)fetchVendorData:(id)destinationViewController;
- (void)fetchReferralCommentsData:(id)destinationViewController;

@end
