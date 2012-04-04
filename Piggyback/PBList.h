//
//  PBList.h
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>
#import "PBuser.h"

@interface PBList : NSManagedObject

@property (nonatomic, strong) NSNumber* listID;
@property (nonatomic, strong) NSDate* createdDate;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableSet* listEntrys;  // array of PBListEntry
@property (nonatomic, strong) PBUser* listOwner;
@property (nonatomic, strong) NSNumber* listOwnerID;    // listOwner foreign key
@property (nonatomic, strong) NSNumber* listCount;

@end
