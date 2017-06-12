//
//  TagProductView.m
//  GoldenSpear
//
//  Created by Crane on 8/13/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "TagProductView.h"

@implementation TagProductView

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
