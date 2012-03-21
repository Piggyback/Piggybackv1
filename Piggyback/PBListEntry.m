//
//  PBListEntry.m
//  Piggyback
//
//  Created by Michael Gao on 3/11/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBListEntry.h"

@implementation PBListEntry

@synthesize vendor = _vendor;
@synthesize date = _date;
@synthesize comment = _comment;
@synthesize referredBy = _referredBy;
@synthesize numUniqueReferredBy = _numUniqueReferredBy;

- (NSArray *)referredBy {
    if (!_referredBy) {
        _referredBy = [[NSArray alloc] init];
    }
    
    return _referredBy;
}

@end
