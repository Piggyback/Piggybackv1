//
//  LocationController.m
//  Piggyback
//
//  Created by Michael Gao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "LocationController.h"

@interface LocationController()
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation LocationController

@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;

//static LocationController *sharedInstance;

//+ (LocationController *)sharedInstance {
//    @synchronized(self) {
//        if (!sharedInstance)
//            sharedInstance=[[LocationController alloc] init];       
//    }
//    return sharedInstance;
//}
//
//+(id)alloc {
//    @synchronized(self) {
//        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationController.");
//        sharedInstance = [super alloc];
//    }
//    return sharedInstance;
//}

-(id) init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

-(void) start {
    [self.locationManager startUpdatingLocation];
}

-(void) stop {
    [self.locationManager stopUpdatingLocation];
}

-(BOOL) locationKnown { 
//    if (round(self.currentLocation.speed) == -1) return NO; else return YES; 
    if (self.currentLocation) return YES; else return NO;
}

-(CLLocation*) getCurrentLocationAndStopLocationManager {
    self.currentLocation = nil;     // better way to 'wait' for currentLocation? check timeStamp?
    [self start];
    while (!self.currentLocation) {
        // block
    }
    [self stop];
    return self.currentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
//    if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {     
        self.currentLocation = newLocation;
        NSLog(@"current location: %@", self.currentLocation);
//    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)dealloc
{
    NSLog(@"LocationController DEALLOC'ed");
}

@end
