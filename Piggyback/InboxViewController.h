//
//  ListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/6/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *greeting;
- (IBAction)logout:(id)sender;

@end
