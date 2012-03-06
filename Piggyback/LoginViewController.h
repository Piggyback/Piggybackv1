//
//  PiggybackViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface LoginViewController : UIViewController <FBSessionDelegate, FBRequestDelegate>

- (IBAction)loginWithFacebook:(id)sender;

@end
