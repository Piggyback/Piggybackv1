//
//  IndividualListViewController.h
//  Piggyback
//
//  Created by Michael Gao on 3/12/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PBList.h"
#import "LocationController.h"

@interface IndividualListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PBList* list;
@property (weak, nonatomic) IBOutlet UITableView *listEntryTableView;
@property (nonatomic, strong) NSArray* shownListEntrys;
@property (nonatomic, strong) LocationController* locationController;

@end
