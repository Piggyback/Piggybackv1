//
//  Vendor.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "Vendor.h"

@implementation Vendor

@synthesize vid = _vid;
@synthesize name = _name;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize phone = _phone;
@synthesize addr = _addr;
@synthesize addrCrossStreet = _addrCrossStreet;
@synthesize addrCity = _addrCity;
@synthesize addrState = _addrState;
@synthesize addrCountry = _addrCounty;
@synthesize addrZip = _addrZip;
@synthesize website = _website;
@synthesize distanceFromCurrentLocationInMiles = _distanceFromCurrentLocationInMiles;

- (Vendor*) init
{
    self = [super init];
    self.distanceFromCurrentLocationInMiles = -1;
    
    return self;
}

@end
