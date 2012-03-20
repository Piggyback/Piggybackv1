//
//  listEntryTableViewCell.h
//  Piggyback
//
//  Created by Michael Gao on 3/17/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListEntryTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* referredBy;
@property (nonatomic, weak) IBOutlet UILabel* distance;
@property (nonatomic, weak) IBOutlet UILabel* description;

@end
