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
@synthesize vendor = _vendor;
@synthesize comment = _comment;

- (NSString*)description {
    NSString *descriptionString = [NSString stringWithFormat:@"senderUID: %@\n, receiverUID: %@\n, date: %@\n, lid: %i\n, vendor: %@\n, comment: %@", self.senderUID, self.receiverUID, self.date, [self.lid intValue], self.vendor, self.comment]; 
    return descriptionString;
}

@end
