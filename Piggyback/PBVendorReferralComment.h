//
//  VendorReferralComment.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import "PBUser.h"
#import "PBVendor.h"

@interface PBVendorReferralComment : NSManagedObject

@property (nonatomic, strong) NSString* referralAndVendorID;
@property (nonatomic, strong) NSNumber* referralID;
@property (nonatomic, strong) NSString* assignedVendorID;
@property (nonatomic, strong) PBVendor* assignedVendor;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* referralDate;
@property (nonatomic, strong) PBUser* referrer;

@end
