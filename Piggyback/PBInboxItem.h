//
//  InboxItem.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import "PBVendor.h"
#import "PBUser.h"
#import "PBList.h"

@interface PBInboxItem : NSManagedObject

@property (nonatomic, strong) NSNumber* referralID;
@property (nonatomic, strong) NSDate* referralDate;
@property (nonatomic, strong) NSString* referralComment;
@property (nonatomic, strong) PBUser* referrer;
@property (nonatomic, strong) PBVendor* vendor;
@property (nonatomic, strong) PBList* list;

@end
