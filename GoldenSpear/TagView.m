//
//  TagView.m
//  GoldenSpear
//
//  Created by Crane on 8/2/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "TagView.h"

@implementation TagView

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
