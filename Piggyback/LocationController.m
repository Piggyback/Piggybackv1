//
//  LocationController.m
//  Piggyback
//
//  Created by Michael Gao on 3/13/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "LocationController.h"
#import "FlurryAnalytics.h"

@interface LocationController()
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation LocationController

@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;

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
    if (self.currentLocation) {
        return YES; 
    }
    else {
        return NO;
    }
}

-(CLLocation*) getCurrentLocationAndStopLocationManager {
    self.currentLocation = nil;     // better way to 'wait' for currentLocation? check timeStamp?
    [self start];
    while (!self.currentLocation) {
        // block
    }
    [self stop];
    
    // get geographic information about users
    [FlurryAnalytics setLatitude:self.currentLocation.coordinate.latitude            
                       longitude:self.currentLocation.coordinate.longitude            
              horizontalAccuracy:self.currentLocation.horizontalAccuracy            
                verticalAccuracy:self.currentLocation.verticalAccuracy];
    
    return self.currentLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation { 
    self.currentLocation = newLocation;
    NSLog(@"current location: %@", self.currentLocation);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
