//
//  InboxTableCell.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UILabel* referredBy;
@property (nonatomic, weak) IBOutlet UILabel* referredTo;
@property (nonatomic, weak) IBOutlet UILabel* numItemsInList;
@property (nonatomic, weak) IBOutlet UILabel* comment;
@property (nonatomic, weak) IBOutlet UIImageView* image;

@end
