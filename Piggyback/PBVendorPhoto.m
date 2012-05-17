//
//  PBVendorPhoto.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/7/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBVendorPhoto.h"
#import "PBVendor.h"


@implementation PBVendorPhoto

@dynamic vid;
@dynamic pid;
@dynamic photoURL;
@dynamic vendor;

@end

@implementation PBVendorPhotoObject

@synthesize vid = _vid;
@synthesize pid = _pid;
@synthesize photoURL = _photoURL;
@synthesize vendor = _vendor;

@end