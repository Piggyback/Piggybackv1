//
//  FeedbackViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/29/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textField;
- (IBAction)cancelAddToList:(id)sender;
- (IBAction)sendFeedback:(id)sender;

@end
