//
//  LiveTagsView.m
//  GoldenSpear
//
//  Created by Crane on 9/23/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "LiveTagsView.h"

@implementation LiveTagsView

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
