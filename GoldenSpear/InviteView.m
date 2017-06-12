//
//  InviteView.m
//  GoldenSpear
//
//  Created by Crane on 8/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "InviteView.h"

@implementation InviteView

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
    self.sendBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.sendBtn.layer.borderWidth = 1.0f;
    self.tagBtn.enabled = NO;
}
@end
