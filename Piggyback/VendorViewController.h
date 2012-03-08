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
#import "VendorReferralComment.h"

@interface VendorViewController : UIViewController <RKObjectLoaderDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Vendor *vendor;
@property (weak, nonatomic) IBOutlet UIButton *addrButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIImageView *vendorImage;
@property (nonatomic, strong) NSArray *referralComments;
@property (weak, nonatomic) IBOutlet UILabel *referralCommentsLabel;
@property (weak, nonatomic) IBOutlet UITableView *referralCommentsTable;

- (void)retrieveVendorData:(NSArray*)objects;
- (void)retrieveReferralCommentsData:(NSArray*)objects;

@end
