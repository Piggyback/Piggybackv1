//
//  PBListEntry.h
//  Piggyback
//
//  Created by Michael Gao on 3/11/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import "PBVendor.h"
#import "PBList.h"

@interface PBListEntry : NSManagedObject

@property (nonatomic, strong) NSNumber* listEntryID;
@property (nonatomic, strong) NSNumber* assignedListID;
@property (nonatomic, strong) PBList* assignedList;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSDate* addedDate;
@property (nonatomic, strong) PBVendor* vendor;
//@property (nonatomic, strong) NSString* vendorID;   // vendor and vendorReferralComments foreign key

@end
