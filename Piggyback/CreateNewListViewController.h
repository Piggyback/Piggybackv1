//
//  CreateNewListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 5/21/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateNewListViewController : UIViewController

- (IBAction)cancelCreateNewList:(id)sender;
- (IBAction)createNewList:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *listNameTextField;

@end
