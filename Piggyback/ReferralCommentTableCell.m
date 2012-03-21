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
    
    // set alignment of friend's picture to top left of the table cell
    self.imageView.frame = CGRectMake(FACEBOOKPICMARGIN,
                                      FACEBOOKPICMARGIN,
                                      FACEBOOKPICWIDTH,
                                      FACEBOOKPICHEIGHT);
}

@end