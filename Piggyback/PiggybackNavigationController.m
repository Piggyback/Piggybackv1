//
//  PiggybackNavigationController.m
//  Piggyback
//
//  Created by Michael Gao on 3/20/12.
//  Copyright (c) 2012 Calimucho. All rights reserved.
//

#import "PiggybackNavigationController.h"

@implementation PiggybackNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"piggyback_titlebar_background"] forBarMetrics:UIBarMetricsDefault];
    return [super initWithRootViewController:rootViewController];
    
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"piggyback_titlebar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor blackColor], UITextAttributeTextColor,
                                                [UIColor clearColor], UITextAttributeTextShadowColor,
                                                nil]];
}

@end
