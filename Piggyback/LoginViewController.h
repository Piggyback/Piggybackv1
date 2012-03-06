//
//  PiggybackViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface LoginViewController : UIViewController <FBSessionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *greeting;
- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)logout:(id)sender;

@end
