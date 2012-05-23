//
//  PiggybackAppDelegate.m
//  Piggyback
//
//  Created by Michael Gao on 3/1/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackAppDelegate.h"
#import "PiggybackTabBarController.h"
#import "LoginViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "PBVendor.h"
#import "PBVendorReferralComment.h"
#import "PBUser.h"
#import "PBList.h"
#import "PBListEntry.h"
#import "PBInboxItem.h"
#import "PBVendorPhoto.h"

@implementation PiggybackAppDelegate

NSString* const FB_APP_ID = @"251920381531962";
//NSString* RK_BASE_URL = @"http://beta.getpiggyback.com/api";
NSString* RK_BASE_URL = @"http://192.168.11.28/api";
NSString* const RK_DATE_FORMAT = @"yyyy-MM-dd HH:mm:ss";

@synthesize window = _window;
@synthesize facebook = _facebook;
@synthesize currentUser = _currentUser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /* Setting up RestKit SDK */
    RKObjectManager* objectManager = [RKObjectManager objectManagerWithBaseURL:RK_BASE_URL];
    objectManager.acceptMIMEType = RKMIMETypeJSON;
//    objectManager.serializationMIMEType = RKMIMETypeFormURLEncoded;
    objectManager.serializationMIMEType = RKMIMETypeJSON;
    
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;     // Enable automatic network activity indicator management
#pragma note - access context globally in code using [[[RKObjectManager sharedManager] objectStore] managedObjectContext]
    
    // add default date formatter to convert mysql datetime to nsdate
    [RKObjectMapping addDefaultDateFormatterForString:RK_DATE_FORMAT inTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
    
    // Initialize object store
//    NSString* seedDatabaseName = RKDefaultSeedDatabaseFileName;
    NSString* seedDatabaseName = nil;
    NSString* databaseName = @"Piggyback.sqlite";
    
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:databaseName usingSeedDatabaseName:seedDatabaseName managedObjectModel:nil delegate:self];
    
    RKObjectRouter *router = objectManager.router;
    [router routeClass:[PBList class] toResourcePath:@"/listapi/coreDataLists"];
    [router routeClass:[PBList class] toResourcePath:@"/listapi/coreDataLists" forMethod:RKRequestMethodPOST];
    [router routeClass:[PBListEntry class] toResourcePath:@"/listapi/coreDataMyListEntrys"];
    [router routeClass:[PBListEntry class] toResourcePath:@"/listapi/coreDataMyListEntrys" forMethod:RKRequestMethodPOST];
    objectManager.router = router;
    
    // Setup our object mappings
    RKManagedObjectMapping* listMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBList"];
    listMapping.primaryKeyAttribute = @"listID";
    
    RKObjectMapping *listSerializationMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [listSerializationMapping mapKeyPath:@"createdDate" toAttribute:@"date"];
    [listSerializationMapping mapKeyPath:@"name" toAttribute:@"name"];
    [listSerializationMapping mapKeyPath:@"listOwnerID" toAttribute:@"uid"];
    [objectManager.mappingProvider setSerializationMapping:listSerializationMapping forClass:[PBList class]];
    
    RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBUser"];
    userMapping.primaryKeyAttribute = @"userID";
    [userMapping mapAttributes:@"userID", @"fbid", @"email", @"firstName", @"lastName", @"thumbnail", nil];
    [userMapping mapRelationship:@"lists" withMapping:listMapping];
    [objectManager.mappingProvider setMapping:userMapping forKeyPath:@"user"];
    
    RKManagedObjectMapping* vendorMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBVendor"];
    vendorMapping.primaryKeyAttribute = @"vendorID";
    [vendorMapping mapAttributes:@"vendorID",@"name",@"lat",@"lng",@"phone",@"addr",@"addrCrossStreet",@"addrCity",@"addrState",@"addrCountry",@"addrZip",@"website",@"vendorReferralCommentsCount",nil];
    [objectManager.mappingProvider setMapping:vendorMapping forKeyPath:@"vendor"];
    
    RKManagedObjectMapping* vendorReferralCommentsMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBVendorReferralComment"];
    vendorReferralCommentsMapping.primaryKeyAttribute = @"referralAndVendorID";
    [vendorReferralCommentsMapping mapAttributes:@"referralAndVendorID", @"referralID", @"assignedVendorID",@"comment",@"referralDate",nil];
    [vendorReferralCommentsMapping mapRelationship:@"referrer" withMapping:userMapping];
    [vendorReferralCommentsMapping mapRelationship:@"assignedVendor" withMapping:vendorMapping];
    [vendorReferralCommentsMapping connectRelationship:@"assignedVendor" withObjectForPrimaryKeyAttribute:@"assignedVendorID"];
    [objectManager.mappingProvider setMapping:vendorReferralCommentsMapping forKeyPath:@"referralComment"];

    RKManagedObjectMapping* listEntryMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBListEntry"];
    listEntryMapping.primaryKeyAttribute = @"listEntryID";
    
    [listMapping mapAttributes:@"listID", @"createdDate", @"name", @"listOwnerID", @"listCount", nil];
    [listMapping mapRelationship:@"listEntrys" withMapping:listEntryMapping];
    [listMapping mapRelationship:@"listOwner" withMapping:userMapping];
    [listMapping connectRelationship:@"listOwner" withObjectForPrimaryKeyAttribute:@"listOwnerID"];
    [objectManager.mappingProvider setMapping:listMapping forKeyPath:@"list"]; 
    
    [listEntryMapping mapAttributes:@"listEntryID", @"assignedListID", @"comment", @"addedDate", nil];
    [listEntryMapping mapRelationship:@"vendor" withMapping:vendorMapping];
    [listEntryMapping mapRelationship:@"assignedList" withMapping:listMapping];
    [listEntryMapping connectRelationship:@"assignedList" withObjectForPrimaryKeyAttribute:@"assignedListID"];
    [objectManager.mappingProvider setMapping:listEntryMapping forKeyPath:@"listEntry"];
    
//    RKObjectMapping *vendorSerializationMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
//    [vendorSerializationMapping mapKeyPath:@"vendorID" toAttribute:@"vid"];
//    [vendorSerializationMapping mapKeyPath:@"name" toAttribute:@"vendorName"];
//    [vendorSerializationMapping mapKeyPath:@"lat" toAttribute:@"lat"];
//    [vendorSerializationMapping mapKeyPath:@"lng" toAttribute:@"lng"];
//    [objectManager.mappingProvider setSerializationMapping:vendorSerializationMapping forClass:[PBVendor class]];
    
//    RKObjectMapping *vendorSerializationMapping = [vendorMapping inverseMapping];
//    [objectManager.mappingProvider setSerializationMapping:vendorSerializationMapping forClass:[PBVendor class]];
    
    RKObjectMapping *vendorPhotoSerializationMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [vendorPhotoSerializationMapping mapAttributes:@"pid",@"vid",@"photoURL",nil];
    [objectManager.mappingProvider setSerializationMapping:vendorPhotoSerializationMapping forClass:[PBVendorPhoto class]];
    
    RKObjectMapping *vendorSerializationMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [vendorSerializationMapping mapAttributes:@"vendorID",@"name",@"lat",@"lng",@"phone",@"addr",@"addrCrossStreet",@"addrCity",@"addrState",@"addrCountry",@"addrZip",@"website",@"vendorReferralCommentsCount",nil];
    [vendorSerializationMapping mapKeyPath:@"vendorPhotos" toRelationship:@"vendorPhotos" withMapping:vendorPhotoSerializationMapping];
    [objectManager.mappingProvider setSerializationMapping:vendorSerializationMapping forClass:[PBVendor class]];
    
    
    
    RKObjectMapping *listEntrySerializationMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [listEntrySerializationMapping mapKeyPath:@"assignedListID" toAttribute:@"lid"];
    [listEntrySerializationMapping mapKeyPath:@"vendorID" toAttribute:@"vid"];
    [listEntrySerializationMapping mapKeyPath:@"addedDate" toAttribute:@"date"];
    [listEntrySerializationMapping mapKeyPath:@"comment" toAttribute:@"comment"];
    [listEntrySerializationMapping mapKeyPath:@"vendor" toRelationship:@"vendor" withMapping:vendorSerializationMapping];
    [objectManager.mappingProvider setSerializationMapping:listEntrySerializationMapping forClass:[PBListEntry class]];
    
    RKManagedObjectMapping* inboxMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBInboxItem"];
    inboxMapping.primaryKeyAttribute = @"referralID";
    [inboxMapping mapAttributes:@"referralID",@"referralComment",@"referralDate",@"listCount",nil];
    [inboxMapping mapRelationship:@"list" withMapping:listMapping];
    [inboxMapping mapRelationship:@"referrer" withMapping:userMapping];
    [inboxMapping mapRelationship:@"vendor" withMapping:vendorMapping];
    [objectManager.mappingProvider setMapping:inboxMapping forKeyPath:@"inbox"];
    
    RKManagedObjectMapping* vendorPhotoMapping = [RKManagedObjectMapping mappingForEntityWithName:@"PBVendorPhoto"];
    vendorPhotoMapping.primaryKeyAttribute = @"pid";
    [vendorPhotoMapping mapAttributes:@"pid",@"vid",@"photoURL",nil];
    [vendorPhotoMapping mapRelationship:@"vendor" withMapping:vendorMapping];
    [vendorPhotoMapping connectRelationship:@"vendor" withObjectForPrimaryKeyAttribute:@"vid"];
    [objectManager.mappingProvider setMapping:vendorPhotoMapping forKeyPath:@"vendor-photo"];

//    RKObjectMapping* vendorPhotoMapping = [RKObjectMapping mappingForClass:[PBVendorPhoto class]];
//    [vendorPhotoMapping mapAttributes:@"vid",@"pid",@"photoURL",nil];
//    [objectManager.mappingProvider setMapping:vendorPhotoMapping forKeyPath:@"vendor-photo"];
    
//    RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[PBUser class]];
//    [userMapping mapAttributes:@"uid", @"fbid", @"email", @"firstName", @"lastName", nil];
//    [objectManager.mappingProvider setMapping:userMapping forKeyPath:@"user"];
    
//    RKObjectMapping* vendorObjectMapping = [RKObjectMapping mappingForClass:[Vendor class]];
//    [vendorObjectMapping mapAttributes:@"vid",@"name",@"lat",@"lng",@"phone",@"addr",@"addrCrossStreet",@"addrCity",@"addrState",@"addrCountry",@"addrZip",@"website",nil];
//    [objectManager.mappingProvider setMapping:vendorObjectMapping forKeyPath:@"vendor"];
//    
//    RKObjectMapping* referralCommentsMapping = [RKObjectMapping mappingForClass:[VendorReferralComment class]];
//    [referralCommentsMapping mapAttributes:@"date",@"comment",@"referralLid",@"listEntryComment",nil];
//    [referralCommentsMapping mapRelationship:@"referrer" withMapping:userMapping];
//    [objectManager.mappingProvider setMapping:referralCommentsMapping forKeyPath:@"referralComment"];
//    
//    RKObjectMapping* listEntryMapping = [RKObjectMapping mappingForClass:[PBListEntry class]];
//    [listEntryMapping mapAttributes:@"date", @"comment",nil];
//    [listEntryMapping mapRelationship:@"vendor" withMapping:vendorObjectMapping];
//    [listEntryMapping mapRelationship:@"referredBy" withMapping:referralCommentsMapping];
//    [objectManager.mappingProvider setMapping:listEntryMapping forKeyPath:@"listEntry"];
//    
//    RKObjectMapping* listMapping = [RKObjectMapping mappingForClass:[PBList class]];
//    [listMapping mapAttributes:@"uid", @"lid", @"date", @"name", nil];
//    [listMapping mapRelationship:@"listEntrys" withMapping:listEntryMapping];
//    [objectManager.mappingProvider setMapping:listMapping forKeyPath:@"list"];    
    
//    RKObjectMapping* inboxMapping = [RKObjectMapping mappingForClass:[InboxItem class]];
//    [inboxMapping mapAttributes:@"rid",@"referralComment",@"referralDate",@"lid",@"listName",@"listCount",nil];
//    [inboxMapping mapRelationship:@"referrer" withMapping:userMapping];
//    [inboxMapping mapRelationship:@"vendor" withMapping:vendorObjectMapping];
//    [objectManager.mappingProvider setMapping:inboxMapping forKeyPath:@"inbox"];
    
    /* Setting up Facebook SDK */
    PiggybackTabBarController *rootViewController = (PiggybackTabBarController *)self.window.rootViewController;
    self.facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:rootViewController];
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        NSLog(@"fb token expiration date: %@", self.facebook.expirationDate);
    } else {
        UIStoryboard *iphoneStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        LoginViewController *loginViewController = [iphoneStoryboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        loginViewController.delegate = rootViewController;
        
        [self.window makeKeyAndVisible];    // making window visible so loginViewController is pushed modally
        [rootViewController presentViewController:loginViewController animated:NO completion:nil];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"attempting to extend access token");
    [self.facebook extendAccessTokenIfNeeded];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}

@end
