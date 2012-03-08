//
//  RKUser.h
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKUser : NSObject

@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSNumber* fbid;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;

@end
