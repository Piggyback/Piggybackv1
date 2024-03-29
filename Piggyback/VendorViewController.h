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
#import "EGORefreshTableHeaderView.h"

@interface VendorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate, RKObjectLoaderDelegate>

@property (nonatomic, strong) PBVendor *vendor;
@property (nonatomic, strong) NSArray *referralComments;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *vendorTableView;
@property (nonatomic, strong) NSArray *photos;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *photoPageControl;

@property (nonatomic, strong) NSString* source;
@property (nonatomic, strong) NSMutableData *responseData; // raw vendor data from 4sq API call
@property (nonatomic, strong) NSDictionary* detailsResponse; // JSON formatted vendor data from 4sq API call

@end
