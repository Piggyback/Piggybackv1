//
//  ReferToFriendsViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBVendor.h"
#import "PBList.h"
#import "EGORefreshTableHeaderView.h"

@interface ReferToFriendsViewController : UIViewController <RKObjectLoaderDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) PBVendor *vendor;
@property (nonatomic, strong) NSNumber *lid;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
- (IBAction)cancelReferToFriends:(id)sender;
- (IBAction)referToFriends:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *grayLayer;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) NSString* source;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
