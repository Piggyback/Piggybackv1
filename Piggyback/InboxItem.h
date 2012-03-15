//
//  InboxItem.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vendor.h"

@interface InboxItem : NSObject

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSNumber* rid;
@property (nonatomic, strong) NSNumber* lid;
@property (nonatomic, strong) NSNumber* referredByUID;
@property (nonatomic, strong) NSNumber* referredByFBID;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* listName;
@property (nonatomic, strong) Vendor* vendor;
@property (nonatomic, strong) NSArray* listEntrys;
@property (nonatomic, strong) NSArray* otherFriends;
@property (nonatomic, strong) NSArray* referralComments;

@end
