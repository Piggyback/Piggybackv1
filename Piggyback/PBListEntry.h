//
//  PBListEntry.h
//  Piggyback
//
//  Created by Michael Gao on 3/11/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vendor.h"

@interface PBListEntry : NSObject

@property (nonatomic, strong) Vendor* vendor;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSArray* referredBy;  // array of VendorReferralComment objects
@property (nonatomic, strong) NSNumber* numUniqueReferredBy;

@end
