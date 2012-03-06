//
//  PiggybackAppDelegate.h
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface PiggybackAppDelegate : UIResponder <UIApplicationDelegate, RKRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Facebook *facebook;

@end
