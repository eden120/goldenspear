//
//  LiveLookView.m
//  GoldenSpear
//
//  Created by Crane on 9/22/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "LiveLookView.h"

@implementation LiveLookView

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