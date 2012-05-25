//
//  PBReferral.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBReferral.h"

@implementation PBReferral

@synthesize senderUID = _senderUID;
@synthesize receiverUID = _receiverUID;
@synthesize date = _date;
@synthesize lid = _lid;
@synthesize vid = _vid;
@synthesize comment = _comment;

- (NSString*)description {
    NSString *descriptionString = [NSString stringWithFormat:@"senderUID: %@\n, receiverUID: %@\n, date: %@\n, lid: %i\n, vid: %@\n, comment: %@", self.senderUID, self.receiverUID, self.date, [self.lid intValue], self.vid, self.comment]; 
    return descriptionString;
}

@end
