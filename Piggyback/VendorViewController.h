//
//  VendorViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "Vendor.h"
#warning - moving header import to .m file
//#import "VendorReferralComment.h"

@interface VendorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Vendor *vendor;
@property (weak, nonatomic) IBOutlet UIImageView *vendorImage;
//@property (weak, nonatomic) IBOutlet UIButton *addrButton;
//@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
#warning: does referralComments need to be of type NSMutableArray vs NSArray? according to stackoverflow, NSMutableArrays are not threadsafe
@property (nonatomic, strong) NSMutableArray *referralComments;
//@property (weak, nonatomic) IBOutlet UILabel *referralCommentsLabel;
//@property (weak, nonatomic) IBOutlet UITableView *referralCommentsTable;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// mike gao
@property (weak, nonatomic) IBOutlet UITableView *vendorInfoTable;



@end
