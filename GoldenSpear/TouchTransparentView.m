//
//  TouchTransparentView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 6/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "TouchTransparentView.h"

@implementation TouchTransparentView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *v in self.subviews) {
        CGPoint localPoint = [v convertPoint:point fromView:self];
        if (v.alpha > 0.01 && ![v isHidden] && v.userInteractionEnabled && [v pointInside:localPoint withEvent:event])
            return YES;
    }
    return NO;
}

@end
