//
//  PiggybackTabBarController.h
//  Piggyback
//
//  Created by Michael Gao on 3/9/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "LoginViewController.h"

@interface PiggybackTabBarController : UITabBarController <FBSessionDelegate, LoginViewControllerDelegate>

@end
