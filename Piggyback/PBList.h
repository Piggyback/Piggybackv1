//
//  PBList.h
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBList : NSObject

@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSNumber* lid;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSArray* listEntrys;



@end
