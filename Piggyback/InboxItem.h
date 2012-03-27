//
//  InboxItem.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vendor.h"
#import "PBUser.h"
#import "PBList.h"

@interface InboxItem : NSObject

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSNumber* rid;
//@property (nonatomic, strong) NSNumber* lid;
@property (nonatomic, strong) PBUser* referrer;
@property (nonatomic, strong) NSString* comment;
//@property (nonatomic, strong) NSString* listName;
@property (nonatomic, strong) Vendor* vendor;
//@property (nonatomic, strong) NSArray* listEntrys; // array of ListEntrys if recommendation is for a list
@property (nonatomic, strong) PBList* list;
@property (nonatomic, strong) NSArray* nonUniqueReferralComments;   // array of VendorReferralComments for single vendor inbox item

@end
