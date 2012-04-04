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

@interface VendorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RKObjectLoaderDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) Vendor *vendor;
@property (nonatomic, strong) NSArray *referralComments;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *vendorTableView;
@property (nonatomic, strong) NSArray *photos;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *photoPageControl;

@end
