//
//  Vendor.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBVendor.h"

@implementation PBVendor

@dynamic vendorID;
@dynamic name;
@dynamic lat;
@dynamic lng;
@dynamic phone;
@dynamic addr;
@dynamic addrCrossStreet;
@dynamic addrCity;
@dynamic addrState;
@dynamic addrCountry;
@dynamic addrZip;
@dynamic website;
@dynamic vendorReferralComments;
@dynamic vendorReferralCommentsCount;
@synthesize distanceFromCurrentLocationInMiles = _distanceFromCurrentLocationInMiles;

- (PBVendor*) init
{
    self = [super init];
    self.distanceFromCurrentLocationInMiles = -1;
    
    return self;
}

@end
