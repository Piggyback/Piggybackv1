//
//  RKUser.h
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>

@interface FBImageToDataTransformer : NSValueTransformer {
}
@end

@interface PBUser : NSManagedObject

@property (nonatomic, strong) NSNumber* userID;
@property (nonatomic, strong) NSNumber* fbid;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) UIImage* thumbnail;
@property (nonatomic, strong) NSMutableSet* lists;

@end
