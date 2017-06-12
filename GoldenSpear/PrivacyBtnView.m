//
//  PrivacyBtnView.m
//  GoldenSpear
//
//  Created by Crane on 9/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "PrivacyBtnView.h"

@implementation PrivacyBtnView
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
}

@end
