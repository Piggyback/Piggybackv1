//
//  ListEntry.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 3/2/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface ListEntry : NSObject <RKRequestDelegate>

@property (nonatomic, strong) NSString* comment;

- (void)sendRequests;

@end
