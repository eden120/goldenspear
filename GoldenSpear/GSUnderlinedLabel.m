//
//  GSUnderlinedLabel.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 13/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSUnderlinedLabel.h"

@implementation GSUnderlinedLabel

CGFloat lineHeight = 2;

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
        [underlineView removeFromSuperview];
        underlineView = [UIView new];
        [self addSubview:underlineView];
        underlineView.backgroundColor = [UIColor blackColor];
        underlineView.frame = CGRectMake(0, rect.size.height-lineHeight, rect.size.width, lineHeight);
}

@end
