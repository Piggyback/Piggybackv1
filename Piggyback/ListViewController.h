//
//  ListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/6/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import <RestKit/RestKit.h>

typedef enum fbApiCall {
    fbAPIGraphMeFromLogin,
} fbApiCall;

typedef enum pbApiCall {
    pbAPICurrentUserUidFromLogin,
} pbApiCall;

@interface ListViewController : UIViewController <FBSessionDelegate, FBRequestDelegate, RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *greeting;
- (IBAction)logout:(id)sender;

@end
