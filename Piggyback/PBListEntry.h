//
//  PBListEntry.h
//  Piggyback
//
//  Created by Michael Gao on 3/11/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBListEntry : NSObject

@property (nonatomic, strong) NSString* vid;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSString* comment;

@end
