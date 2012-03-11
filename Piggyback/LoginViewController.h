//
//  PiggybackViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import <Restkit/Restkit.h>

typedef enum fbApiCall {
    fbAPIGraphMeFromLogin,
} fbApiCall;

typedef enum pbApiCall {
    pbAPICurrentUserUidFromLogin,
} pbApiCall;

@protocol LoginViewControllerDelegate <NSObject>
- (void)showLoggedIn;
@end

@interface LoginViewController : UIViewController <FBRequestDelegate, RKObjectLoaderDelegate>
@property (nonatomic, weak) id <LoginViewControllerDelegate> delegate;

- (void)getAndStoreCurrentUserFbInformationAndUid;
- (IBAction)loginWithFacebook:(id)sender;
@end
