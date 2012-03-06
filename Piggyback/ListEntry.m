//
//  ListEntry.m
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/2/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "ListEntry.h"

@implementation ListEntry

@synthesize comment = _comment;

//- (void)loadListEntry {
//    RKObjectMapping *objMapping = [RKObjectMapping mappingForClass:[ListEntry class]];
//    [objMapping mapKeyPath:@"comment" toAttribute:@"comment"];
//    RKObjectManager *manager = [RKObjectManager objectManagerWithBaseURL:@"https://api.parse.com/1"];
//    [manager loadObjectsAtResourcePath:@"/classes/ListEntry" objectMapping:objMapping delegate:self];
//}
//
//- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    ListEntry *listEntry = [objects objectAtIndex:0];
//    NSLog(@"Loaded ListEntry with comment: %@",listEntry.comment);
//}
//
//- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
//    NSLog(@"Encountered an error: %@", error);
//}

- (void)sendRequest {
    [[RKClient sharedClient] get:@"json?location=-33.8670522,151.1957362&radius=500&types=food&name=harbour&sensor=false&key=AIzaSyA4g2M3awvxLFMxKfTyM2rBwoWxfs_1Ljs" delegate:self];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    if ([request isGET]) {
        NSLog(@"response for get request returned with: %ld",(long)response.statusCode);
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error{
    NSLog(@"an error occurred: %@",error);
}


@end
