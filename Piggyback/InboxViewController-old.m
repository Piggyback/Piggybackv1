//
//  ListViewController.m
//  Piggyback
//
//  Created by Michael Gao on 3/6/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "InboxViewController.h"
#import "PiggybackAppDelegate.h"

@implementation InboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"inbox viewDidLoad");
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
     
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if([[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] isSessionValid])
    {
        NSLog(@"inbox viewWillAppear -- session is valid");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
        // re-fetch inbox items for users whenever inbox view appears
        NSString* inboxPath = [@"inboxapi/inbox/uid/" stringByAppendingFormat:@"%@",[defaults objectForKey:@"UID"]];
        RKObjectManager* objManager = [RKObjectManager sharedManager];
        RKObjectLoader* inboxLoader = [objManager loadObjectsAtResourcePath:inboxPath objectMapping:[objManager.mappingProvider mappingForKeyPath:@"inbox"] delegate:self];
        inboxLoader.userData = @"inboxLoader";
    } else {
        NSLog(@"inbox viewWillAppear -- session is NOT valid");
    }
}

// **** PROTOCOL FUNCTIONS FOR RKOBJECTDELEGATE **** //
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects 
{
    // retrieve data from API and use information for displaying
    if(objectLoader.userData == @"inboxLoader") {
        InboxItem* item = [objects objectAtIndex:0];
        NSLog(@"in inbox loader call back function: %@",item.firstName);
    } 
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error 
{
    NSLog(@"Encountered an error: %@", error);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)logout:(id)sender 
{
    [[(PiggybackAppDelegate *)[[UIApplication sharedApplication] delegate] facebook] logout];
}

@end
