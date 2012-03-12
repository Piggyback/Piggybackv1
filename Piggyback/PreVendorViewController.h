//
//  PreVendorViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "Vendor.h"
#import "VendorReferralComment.h"

@interface PreVendorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *vendorItemButton;

- (void)fetchVendorData:(id)destinationViewController;
- (void)fetchReferralCommentsData:(id)destinationViewController;

@end
