//
//  SearchViewController.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 4/18/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <NSURLConnectionDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection* geocodeConnection;
@property (nonatomic, strong) NSURLConnection* searchConnection;
@property (nonatomic, strong) NSDictionary* searchResponse;
@property (weak, nonatomic) IBOutlet UITextField *query;
@property (weak, nonatomic) IBOutlet UITextField *location;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;

- (void)hideKeyboard;

@end
