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
#import <RestKit/CoreData.h>

@interface InboxItem : NSManagedObject

//@property (nonatomic, strong) NSDate* date;
//@property (nonatomic, strong) NSNumber* rid;
//@property (nonatomic, strong) PBUser* referrer;
//@property (nonatomic, strong) NSString* comment;
//@property (nonatomic, strong) Vendor* vendor;
//@property (nonatomic, strong) PBList* list;
//@property (nonatomic, strong) NSArray* nonUniqueReferralComments;   // array of VendorReferralComments for single vendor inbox item

@property (nonatomic, strong) NSNumber* rid;
@property (nonatomic, strong) NSString* referralComment;
@property (nonatomic, strong) NSDate* referralDate;
@property (nonatomic, strong) PBUser* referrer;
@property (nonatomic, strong) Vendor* vendor;

// minimum data required for list inbox items
@property (nonatomic, strong) NSNumber* lid;
@property (nonatomic, strong) NSString* listName;
@property (nonatomic, strong) NSNumber* listCount;

@end
