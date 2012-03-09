//
//  ReferralCommentTableCell.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/9/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ReferralCommentTableCell.h"

@implementation ReferralCommentTableCell

- (void) layoutSubviews
{   
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0,10,50,50); // your positioning here
    NSLog(@"hi we are in the baby cell");
}

@end
