//
//  LocationController.h
//  Piggyback
//
//  Created by Michael Gao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocation* currentLocation;

//+ (LocationController*) sharedInstance;

-(void) start;
-(void) stop;
-(BOOL) locationKnown;
-(CLLocation*) getCurrentLocationAndStopLocationManager;

@end
