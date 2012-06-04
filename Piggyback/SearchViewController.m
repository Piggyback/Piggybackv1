//
//  SearchViewController.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 4/18/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "SearchViewController.h"
#import "Restkit/JSONKit.h"
#import "SearchTableViewCell.h"
#import "LocationController.h"
#import "VendorViewController.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "FlurryAnalytics.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize responseData = _responseData;
@synthesize geocodeConnection = _geocodeConnection;
@synthesize searchConnection = _searchConnection;
@synthesize searchResponse = _searchResponse;
@synthesize query = _query;
@synthesize location = _location;
@synthesize searchResultsTable = _searchResultsTable;
@synthesize grayLayer = _grayLayer;

const NSString* radius = @"10000000";
const NSString* intent = @"checkin";
const NSString* limit = @"20";

#pragma mark - getters and setters

- (NSMutableData*)responseData {
    if (_responseData == nil) {
        _responseData = [[NSMutableData alloc] init];
    }
    return _responseData;
}

- (NSDictionary*)searchResponse {
    if (_searchResponse == nil) {
        _searchResponse = [[NSDictionary alloc] init];
    }
    return _searchResponse;
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

#pragma mark - priviate helper functions

- (void)callGeocodeAPI:(NSString*)location {
    // get lat and lng of specified location
    NSURLRequest *geocodeRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"https://maps.googleapis.com/maps/api/geocode/json?address=",location,@"&sensor=false"]]];
    NSURLConnection *geocodeConnection = [[NSURLConnection alloc] initWithRequest:geocodeRequest delegate:self];
    self.geocodeConnection = geocodeConnection;
}

#pragma mark - keyboard delegate functions

- (void)hideKeyboard {
    [self.query resignFirstResponder];
    [self.location resignFirstResponder]; 
}

- (void)keyboardDidShow:(NSNotification *)note 
{
    [self.view bringSubviewToFront:self.grayLayer];
}

- (void)keyboardDidHide:(NSNotification *)note 
{
    [self.view bringSubviewToFront:self.searchResultsTable];
}

// perform search when search button is hit on keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];

    // start spinner
    [MBProgressHUD showHUDAddedTo:self.searchResultsTable animated:YES];
    
    NSString *location = [self.location.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([location length] == 0) {
        LocationController* locationController = [[LocationController alloc] init];
        dispatch_queue_t getCurrentLocationQueue = dispatch_queue_create("getCurrentLocation", NULL);
        dispatch_async(getCurrentLocationQueue, ^{
            CLLocation* currentLocation = [locationController getCurrentLocationAndStopLocationManager];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString* currentLatLng = [NSString stringWithFormat:@"%f%@%f",currentLocation.coordinate.latitude,@",",currentLocation.coordinate.longitude];
                NSLog(@"location is %@",currentLatLng);
                [self callGeocodeAPI:currentLatLng];
            });
        });
    } else {
        // get lat and lng of specified text-location
        [self callGeocodeAPI:location];
    }
    
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
    
    // hide spinner
    [MBProgressHUD hideHUDForView:self.searchResultsTable animated:YES];
    UIAlertView *searchConectionError = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Cannot establish connection with server." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [searchConectionError show];
    NSLog(@"%@",[NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [FlurryAnalytics logEvent:@"PERFORMED_SEARCH"];
    
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
        
        NSURLRequest *searchRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",@"https://api.foursquare.com/v2/venues/search?query=",query,@"&ll=",latlng,@"&radius=",radius,@"&intent=",intent,@"&limit=",limit,@"&client_id=",FOURSQUARECLIENTID,@"&client_secret=",FOURSQUARECLIENTSECRET,@"&v=",date]]];
        NSURLConnection *searchConnection = [[NSURLConnection alloc] initWithRequest:searchRequest delegate:self];
        self.searchConnection = searchConnection;
    }
    
    if (connection == self.searchConnection) {
        self.searchResponse = [[[[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding] objectFromJSONString] objectForKey:@"response"];
        
        [self.searchResultsTable reloadData];
        
        // hide spinner
        [MBProgressHUD hideHUDForView:self.searchResultsTable animated:YES];
    }
}

#pragma mark - table delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // add a row for foursquare cell
    if ([[self.searchResponse objectForKey:@"venues"] count] == 0) {
        return 1;
    } else {
        return [[self.searchResponse objectForKey:@"venues"] count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"in tableview, size is %u",[self.searchResponse count]);
    if ([self.searchResponse count] == 0) {
        static NSString *CellIdentifier = @"defaultSearchCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        return cell;
    } else if ([[self.searchResponse objectForKey:@"venues"] count] == 0) {
        static NSString *CellIdentifier = @"noSearchResultsCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        return cell;
    } else {
        NSLog(@"total number of objects is %i",[[self.searchResponse objectForKey:@"venues"] count]);
        
        if (indexPath.row == [[self.searchResponse objectForKey:@"venues"] count]) {
            static NSString *CellIdentifier = @"foursquareCell";
            NSLog(@"index path row of foursquare is %i",indexPath.row);
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
                        
            return cell;
        } else {
            static NSString *CellIdentifier = @"searchCell";
            
            SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
                    
            NSLog(@"index path row is %i",indexPath.row);
            NSDictionary *vendorDetails = [[self.searchResponse objectForKey:@"venues"] objectAtIndex:indexPath.row];
            NSString* addr = [[vendorDetails objectForKey:@"location"] objectForKey:@"address"];
            NSString* addrCity = [[vendorDetails objectForKey:@"location"] objectForKey:@"city"];
            NSString* addrState = [[vendorDetails objectForKey:@"location"] objectForKey:@"state"];
            
            NSMutableString* formattedAddress = [[NSMutableString alloc] init];
            if ([addr length] != 0 || [addrCity length] != 0 || [addrState length] != 0)  {
                formattedAddress = [[NSMutableString alloc] init];
                if ([addr length])
                    [formattedAddress appendFormat:@"%@", addr];
                if ([addr length] && ([addrCity length] || [addrState length])) {
                    [formattedAddress appendFormat:@", "];
                }
                if ([addrCity length] || [addrState length]) {
                    if ([addrCity length]) {
                        [formattedAddress appendFormat:@"%@",addrCity];
                        if ([addrState length]) {
                            [formattedAddress appendFormat:@", %@",addrState];
                        }
                    } else {
                        [formattedAddress appendFormat:@"%@",addrState];
                    }
                }      
            }
            
            cell.name.text = [[[self.searchResponse objectForKey:@"venues"] objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.address.text = formattedAddress;
            
            return cell;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if ([self.searchResponse count] == 0) {
        return 51;
    } else if ([[self.searchResponse objectForKey:@"venues"] count] == 0) {
        return 60;
    } else {
        if (indexPath.row == [[self.searchResponse objectForKey:@"venues"] count]) {
            return 25;
        } else {
            return 46;
        }
    }
}

#pragma mark - table view delegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piggyback_titlebar"]];
    }
    return self;
}

- (void)awakeFromNib
{
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"piggyback_titlebar"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // change keyboard buttons
    self.query.returnKeyType = UIReturnKeySearch;
    self.location.returnKeyType = UIReturnKeySearch;
    
    // change height of text fields
//    self.query.frame = CGRectMake(self.query.frame.origin.x,self.query.frame.origin.y,self.query.frame.size.width,25);
//    self.location.frame = CGRectMake(self.location.frame.origin.x,self.location.frame.origin.y,self.location.frame.size.width,25);
    
    // tap outside of textfield hides keyboard
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.grayLayer addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil]; 
}

- (void)viewDidUnload
{
    [self setSearchResultsTable:nil];
    [self setGrayLayer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"searchToVendor"]) {
        NSDictionary* vendorDetails = [[self.searchResponse objectForKey:@"venues"] objectAtIndex:[self.searchResultsTable indexPathForCell:sender].row];
        PBVendor* selectedVendor = [PBVendor findFirstByAttribute:@"vendorID" withValue:[vendorDetails objectForKey:@"id"]];
        
        if (selectedVendor == nil) {
            // set VendorViewController's vendor to selected vendor; website populated later with detailed venue call
            selectedVendor = [PBVendor object];

            NSDictionary* vendorDetails = [[self.searchResponse objectForKey:@"venues"] objectAtIndex:[self.searchResultsTable indexPathForCell:sender].row];
            selectedVendor.vendorID = [vendorDetails objectForKey:@"id"];
            selectedVendor.name = [vendorDetails objectForKey:@"name"];
            selectedVendor.lat = [[vendorDetails objectForKey:@"location"] objectForKey:@"lat"];
            selectedVendor.lng = [[vendorDetails objectForKey:@"location"] objectForKey:@"lng"];
            selectedVendor.phone = [[vendorDetails objectForKey:@"contact"] objectForKey:@"formattedPhone"];
            selectedVendor.addr = [[vendorDetails objectForKey:@"location"] objectForKey:@"address"];
            selectedVendor.addrCrossStreet = [[vendorDetails objectForKey:@"location"] objectForKey:@"crossStreet"];
            selectedVendor.addrCity = [[vendorDetails objectForKey:@"location"] objectForKey:@"city"];
            selectedVendor.addrState = [[vendorDetails objectForKey:@"location"] objectForKey:@"state"];
            selectedVendor.addrCountry = [[vendorDetails objectForKey:@"location"] objectForKey:@"country"];
            selectedVendor.addrZip = [[vendorDetails objectForKey:@"location"] objectForKey:@"postalCode"];
        }

                    NSLog(@"newly created vendor : %@",selectedVendor);
        
        [(VendorViewController*)segue.destinationViewController setVendor:selectedVendor];
        [(VendorViewController*)segue.destinationViewController setSource:@"search"];
    }
}

@end
