//
//  VendorPhoto.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/23/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VendorPhoto : NSObject

@property (nonatomic, strong) NSString* vid;
@property (nonatomic, strong) NSString* pid;
@property (nonatomic, strong) NSURL* photoURL;

@end
