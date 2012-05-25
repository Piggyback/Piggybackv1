//
//  RKUser.m
//  Piggyback
//
//  Created by Michael Gao on 3/8/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PBUser.h"

@implementation PBUser

@dynamic userID;
@dynamic fbid;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic thumbnail;
@dynamic lists;
@dynamic friends;
@synthesize friendsID = _friendsID;

@end

@implementation FBImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSData class];
}


- (id)transformedValue:(id)value {
    NSData *data = UIImagePNGRepresentation(value);
    return data;
}


- (id)reverseTransformedValue:(id)value {
    UIImage *uiImage = [[UIImage alloc] initWithData:value];
    return uiImage;
}

@end