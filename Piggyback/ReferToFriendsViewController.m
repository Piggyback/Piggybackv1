//
//  ReferToFriendsViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/24/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ReferToFriendsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "PBUser.h"
#import "PBReferral.h"
#import "PiggybackAppDelegate.h"

@interface ReferToFriendsViewController ()

@property (nonatomic, strong) NSMutableSet *selectedFriendsIndexes;

@end

@implementation ReferToFriendsViewController

@synthesize friends = _friends;
@synthesize vendor = _vendor;
@synthesize lid = _lid;
@synthesize tableView = _tableView;
@synthesize commentTextField = _commentTextField;
@synthesize grayLayer = _grayLayer;
@synthesize backgroundView = _backgroundView;
@synthesize selectedFriendsIndexes = _selectedFriendsIndexes;
@synthesize source = _source;

#pragma mark - getters / setters

- (NSArray *)friends {
    if (!_friends) {
        _friends = [[NSArray alloc] init];
    }
    
    return _friends;
}

- (NSMutableSet*)selectedFriendsIndexes {
    if (!_selectedFriendsIndexes) {
        _selectedFriendsIndexes = [[NSMutableSet alloc] init];
    }
    return _selectedFriendsIndexes;
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
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.friends objectAtIndex:indexPath.row] firstName],[[self.friends objectAtIndex:indexPath.row] lastName]];
    
    PBUser* friend = [self.friends objectAtIndex:indexPath.row];
    NSString* fbid = [friend.fbid stringValue];
    NSString* imgURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",fbid];
    
    UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]]];
    cell.imageView.layer.cornerRadius = 8.0;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.image = img;
    
    // set checkmark
    if ([self.selectedFriendsIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
       
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedFriendsIndexes containsObject:[NSNumber numberWithInt:indexPath.row]]) {
        [self.selectedFriendsIndexes removeObject:[NSNumber numberWithInt:indexPath.row]];
    } else {
        [self.selectedFriendsIndexes addObject:[NSNumber numberWithInt:indexPath.row]];
    }
    
    NSLog(@"selected friend indexes are %@",self.selectedFriendsIndexes);
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return REFERFRIENDPICHEIGHT + 3;
}

#pragma mark - RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    NSLog(@"did load objects!");
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"ERROR");
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
    
    // set friends
//    PBUser* currentUser = [(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] currentUser];
    PBUser* currentUser = [PBUser findFirstByAttribute:@"userID" withValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"UID"]];
//    self.friends = [currentUser.friends allObjects];
    self.friends = [currentUser.friends allObjects];
    
    NSLog(@"current user is %@",currentUser);
//    NSLog(@"friends from app delegate are %@",currentUser.friends);
//    NSLog(@"friends in this vc are %@",self.friends);
    
    [self.tableView reloadData];
    
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

- (IBAction)cancelReferToFriends:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)referToFriends:(id)sender {
    if ([self.selectedFriendsIndexes count] == 0) {
        UIAlertView *noFriendsSelectedAlert = [[UIAlertView alloc] initWithTitle:@"No Friends Selected" message:@"Must recommend to at least one friend!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [noFriendsSelectedAlert show];
    } else {
        for (NSNumber *currentFriendIndex in self.selectedFriendsIndexes) {            
            PBReferral* newReferral = [[PBReferral alloc] init];

            // set users
            newReferral.senderUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
            newReferral.receiverUID = [[self.friends objectAtIndex:[currentFriendIndex intValue]] userID];
            
            // set date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
            newReferral.date = [dateFormatter stringFromDate:[NSDate date]];
            
            // set lid or vendor
            if ([self.source isEqualToString:@"list"]) {
                newReferral.lid = self.lid;
                newReferral.vendor = nil;
            } else if ([self.source isEqualToString:@"vendor"]) {
                newReferral.lid = 0;
                newReferral.vendor = self.vendor;
            }
            
            newReferral.comment = self.commentTextField.text;
            // add row to referral table on database (without core data)
            // add vendor to vendor table if it doesnt exist yet in core data and on the database
            
            NSLog(@"new referral is %@",newReferral);
            [[RKObjectManager sharedManager] postObject:newReferral delegate:self];
        }
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

@end
