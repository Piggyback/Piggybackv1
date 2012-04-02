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

@interface PBVendorReferralComment : NSManagedObject

@property (nonatomic, strong) NSString* vendorID;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSDate* referralDate;

@property (nonatomic, strong) PBUser* referrer;
@property (nonatomic, strong) NSString* referrerID;

@end
