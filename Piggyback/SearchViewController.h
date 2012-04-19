//
//  SearchViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 4/18/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <NSURLConnectionDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection* geocodeConnection;
@property (nonatomic, strong) NSURLConnection* searchConnection;
@property (weak, nonatomic) IBOutlet UITextField *query;
@property (weak, nonatomic) IBOutlet UITextField *location;

@end
