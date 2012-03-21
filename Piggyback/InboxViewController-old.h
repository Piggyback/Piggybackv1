//
//  ListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/6/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "InboxItem.h"

@interface InboxViewController : UIViewController <RKObjectLoaderDelegate>

- (IBAction)logout:(id)sender;

@end
