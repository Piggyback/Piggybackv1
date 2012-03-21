//
//  VendorReferralComment.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBUser.h"

@interface VendorReferralComment : NSObject

@property (nonatomic, strong) PBUser* referrer;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSNumber* referralLid;
@property (nonatomic, strong) NSString* listEntryComment;

@end
