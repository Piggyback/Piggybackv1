//
//  Vendor.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface Vendor : NSObject

@property (nonatomic, strong) NSString* vid;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* reference;
@property (nonatomic, strong) NSNumber* lat;
@property (nonatomic, strong) NSNumber* lng;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* addr;
@property (nonatomic, strong) NSString* addrNum;
@property (nonatomic, strong) NSString* addrStreet;
@property (nonatomic, strong) NSString* addrCity;
@property (nonatomic, strong) NSString* addrState;
@property (nonatomic, strong) NSString* addrCountry;
@property (nonatomic, strong) NSString* addrZip;
@property (nonatomic, strong) NSString* vicinity;
@property (nonatomic, strong) NSString* website;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, strong) NSNumber* rating;
@property CLLocationDistance distanceFromCurrentLocationInMiles;

@end
