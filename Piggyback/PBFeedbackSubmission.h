//
//  PBFeedbackSubmission.h
//  Piggyback
//
//  Created by Kimberly Hsiao on 5/30/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBUser.h"

@interface PBFeedbackSubmission : NSObject

@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSString* date;

@end
