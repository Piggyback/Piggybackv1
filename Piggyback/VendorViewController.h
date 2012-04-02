//
//  VendorViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PBVendor.h"

@interface VendorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PBVendor *vendor;
@property (weak, nonatomic) IBOutlet UIImageView *vendorImage;
@property (nonatomic, strong) NSArray *referralComments;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *vendorTableView;


@end
