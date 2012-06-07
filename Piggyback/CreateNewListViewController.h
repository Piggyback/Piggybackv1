//
//  CreateNewListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 5/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface CreateNewListViewController : UIViewController <UITextFieldDelegate>

- (IBAction)cancelCreateNewList:(id)sender;
- (IBAction)createNewList:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *listNameTextField;
@property (strong, nonatomic) UIViewController *realPresentingViewController;

@end
