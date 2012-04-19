//
//  SearchViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 4/18/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "SearchViewController.h"
#import "JSONKit.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize responseData = _responseData;
@synthesize geocodeConnection = _geocodeConnection;
@synthesize searchConnection = _searchConnection;
@synthesize query = _query;
@synthesize location = _location;

const NSString* radius = @"10000000";
const NSString* intent = @"checkin";
const NSString* limit = @"20";
const NSString* clientID = @"LQYMHEIG05TK2HIQJGJ3MUGDNBAW1OKJKM4SSUFNYGSQMQIZ";
const NSString* clientSecret = @"AXDTUGX5AA1DXDI2HUWVSODSFGKIK2RQYYGUWSUBDC0R5OLX";

#pragma mark - getters and setters

- (NSMutableData*)responseData {
    if (_responseData == nil) {
        _responseData = [[NSMutableData alloc] init];
    }
    return _responseData;
}

- (NSURLConnection*)geocodeConnection {
    if (_geocodeConnection == nil) {
        _geocodeConnection = [[NSURLConnection alloc] init];
    }
    return _geocodeConnection;
}

- (NSURLConnection*)searchConnection {
    if (_searchConnection == nil) {
        _searchConnection = [[NSURLConnection alloc] init];
    }
    return _searchConnection;
}

#pragma mark - keyboard delegate functions

// hide keyboard when touch outside of textfield
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.query resignFirstResponder];
    [self.location resignFirstResponder];
}

// perform search when search button is hit on keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    NSString *location = [self.location.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // get lat and lng of specified location
    NSURLRequest *geocodeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://maps.googleapis.com/maps/api/geocode/json?address=",location,@"&sensor=false"]]];
    NSURLConnection *geocodeConnection = [[NSURLConnection alloc] initWithRequest:geocodeRequest delegate:self];
    self.geocodeConnection = geocodeConnection;
    
    return YES;
}

#pragma mark - nsurlconnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    if (connection == self.geocodeConnection) {
        [self.responseData setLength:0];
//    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    if (connection == self.geocodeConnection) {
        [self.responseData appendData:data];
//    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.geocodeConnection) {
        NSLog(@"Geocode connection error");
    } else if (connection == self.searchConnection) {
        NSLog(@"Search connection error");
    }
    
    NSLog(@"%@",[NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.geocodeConnection) {
        // fetch lat and lng of requested location
        NSDictionary *geocodeResponse = [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
        NSString* lat = [[[[[geocodeResponse objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
        NSString* lng = [[[[[geocodeResponse objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
        NSString* latlng = [NSString stringWithFormat:@"%@%@%@",lat,@",",lng];
        NSLog(@"%@",latlng);
        
        // call foursquare search API with retrieved lat lng     
        NSString *query = [self.query.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        NSDate* now = [NSDate date];
        NSString *date = [dateFormat stringFromDate:now];
        
        NSURLRequest *searchRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"https://api.foursquare.com/v2/venues/search?query=",query,@"&ll=",latlng,@"&radius=",radius,@"&intent=",intent,@"&limit=",limit,@"&client_id=",clientID,@"&client_secret=",clientSecret,@"&v=",date]]];
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"https://api.foursquare.com/v2/venues/search?query=",query,@"&ll=",latlng,@"&radius=",radius,@"&intent=",intent,@"&limit=",limit,@"&client_id=",clientID,@"&client_secret=",clientSecret,@"&v=",date]);
        NSURLConnection *searchConnection = [[NSURLConnection alloc] initWithRequest:searchRequest delegate:self];
        self.searchConnection = searchConnection;
    }
    
    if (connection == self.searchConnection) {
        NSDictionary *searchResponse = [[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
        NSLog(@"search response! %@",searchResponse);
    }
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
        
    // change keyboard buttons
    self.query.returnKeyType = UIReturnKeySearch;
    self.location.returnKeyType = UIReturnKeySearch;
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

@end
