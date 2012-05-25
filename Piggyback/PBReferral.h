//
//  PBReferral.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBVendor.h"

@interface PBReferral : NSObject

@property (nonatomic, strong) NSNumber* senderUID;
@property (nonatomic, strong) NSNumber* receiverUID;
@property (nonatomic, strong) NSString* date;
@property (nonatomic, strong) NSNumber* lid;
@property (nonatomic, strong) PBVendor* vendor;
@property (nonatomic, strong) NSString* comment;

@end
