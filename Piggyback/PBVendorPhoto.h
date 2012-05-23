//
//  PBVendorPhoto.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/7/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PBVendor;

@protocol VendorPhotoInterface <NSObject>

@property (nonatomic, retain) NSString * vid;
@property (nonatomic, retain) NSString * pid;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) PBVendor *vendor;

@end

@interface PBVendorPhoto : NSManagedObject <VendorPhotoInterface>
@end

@interface PBVendorPhotoObject : NSObject <VendorPhotoInterface>
@end