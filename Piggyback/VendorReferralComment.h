//
//  VendorReferralComment.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VendorReferralComment : NSObject

@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSNumber* referredByUID;
@property (nonatomic, strong) NSNumber* referredByFBID;

@end
