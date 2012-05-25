//
//  ReferToFriendsCell.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ReferToFriendsCell.h"
#import "Constants.h"

@implementation ReferToFriendsCell



- (void) layoutSubviews
{   
    [super layoutSubviews];
    
    // set alignment of friend's picture to top left of the table cell
    self.imageView.frame = CGRectMake(1,1,REFERFRIENDPICWIDTH,REFERFRIENDPICHEIGHT);
    
    self.textLabel.frame = CGRectMake(REFERFRIENDPICWIDTH + FACEBOOKPICMARGIN,
                                      0,
                                      self.textLabel.frame.size.width - FACEBOOKPICMARGIN,
                                      self.textLabel.frame.size.height);
}

@end
