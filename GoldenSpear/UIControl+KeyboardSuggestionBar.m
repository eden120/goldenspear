//
//  UIControl+KeyboardSuggestionBar.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UIControl+KeyboardSuggestionBar.h"
#import <objc/runtime.h>

@implementation UIControl (KeyboardSuggestionBar)

#pragma mark - Property extension

NSString const *KEYBOARDSUGGESTIONBAR_KEY = @"KEYBOARDSUGGESTIONBAR_KEY";


- (void)setKeyboardSuggestionBar:(KeyboardSuggestionBar *)keyboardSuggestionBar
{
    objc_setAssociatedObject(self, &KEYBOARDSUGGESTIONBAR_KEY, keyboardSuggestionBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KeyboardSuggestionBar *)keyboardSuggestionBar
{
    return objc_getAssociatedObject(self, &KEYBOARDSUGGESTIONBAR_KEY);
}

@end
