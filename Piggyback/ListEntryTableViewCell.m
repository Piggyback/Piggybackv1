//
//  listEntryTableViewCell.m
//  Piggyback
//
//  Created by Michael Gao on 3/17/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ListEntryTableViewCell.h"

@implementation ListEntryTableViewCell

@synthesize name = _name;
@synthesize referredByOrDescription = _referredByOrDescription;
@synthesize distance = _distance;
@synthesize descriptionOrBlank = _descriptionOrBlank;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
