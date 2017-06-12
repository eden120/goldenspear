//
//  NSObject+ButtonSlideView.m
//  GoldenSpear
//
//  Created by Alberto Seco on 28/7/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NSObject+ButtonSlideView.h"
#import <objc/runtime.h>

static char UNCLOSEDBUTTON_KEY;

@implementation NSObject (ButtonSlideView)

// Getter and setter for picImage
- (BOOL)unclosedButton
{
    return [(NSNumber *)objc_getAssociatedObject(self, &UNCLOSEDBUTTON_KEY) boolValue];
}

- (void)setUnclosedButton:(BOOL)unclosedButton
{
    NSNumber * nsValue = [NSNumber numberWithBool:unclosedButton];
    objc_setAssociatedObject(self, &UNCLOSEDBUTTON_KEY, nsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSString *) toStringButtonSlideView
{
    return @"";
}

- (NSString *) toImageButtonSlideView
{
    return @"";
}

@end
