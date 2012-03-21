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
    
    self.textLabel.frame = CGRectMake(FACEBOOKPICWIDTH + 2*FACEBOOKPICMARGIN,
                                      FACEBOOKPICMARGIN/1.5,
                                      self.textLabel.frame.size.width,
                                      self.textLabel.frame.size.height);
    
    self.detailTextLabel.frame = CGRectMake(FACEBOOKPICWIDTH + 2*FACEBOOKPICMARGIN,
                                            2.8*FACEBOOKPICMARGIN,
                                            self.detailTextLabel.frame.size.width,
                                            self.detailTextLabel.frame.size.height);
}

@end