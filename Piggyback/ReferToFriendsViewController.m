//
//  ReferToFriendsViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ReferToFriendsViewController.h"

@interface ReferToFriendsViewController ()

@end

@implementation ReferToFriendsViewController

@synthesize friends = _friends;
@synthesize vendor = _vendor;
@synthesize list = _list;
@synthesize tableView = _tableView;
@synthesize commentTextField = _commentTextField;
@synthesize grayLayer = _grayLayer;
@synthesize backgroundView = _backgroundView;

#pragma mark - getters / setters

- (NSArray *)friends {
    if (!_friends) {
        _friends = [[NSArray alloc] init];
    }
    
    return _friends;
}

#pragma mark - keyboard delegate functions

- (void)hideKeyboard {
    [self.commentTextField resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *)note 
{
    NSLog(@"hello keyboard showde");
    [self.view bringSubviewToFront:self.grayLayer];
}

- (void)keyboardDidHide:(NSNotification *)note 
{
    [self.view bringSubviewToFront:self.backgroundView];
    [self.view bringSubviewToFront:self.tableView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.commentTextField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"referToFriendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    PBList* myList = [self.lists objectAtIndex:indexPath.row];
//    cell.textLabel.text = myList.name;
//    if ([myList.listCount intValue] == 1)
//        cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@", myList.listCount] stringByAppendingString:@" item"];
//    else
//        cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@", myList.listCount] stringByAppendingString:@" items"];
//    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.accessoryType == UITableViewCellAccessoryNone) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        [self.selectedListIndexes addObject:[NSNumber numberWithInt:indexPath.row]];
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        [self.selectedListIndexes removeObject:[NSNumber numberWithInt:indexPath.row]];
//    }
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - view lifecycle 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // resize height of comment text field
    self.commentTextField.frame = CGRectMake(self.commentTextField.frame.origin.x, self.commentTextField.frame.origin.y, self.commentTextField.frame.size.width,25);
    
    // tap outside of textfield hides keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.grayLayer addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - storyboard actions

- (IBAction)cancelAddToList:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)referToFriends:(id)sender {
    
}

@end
