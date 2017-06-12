//
//  UIButton+CustomCreation.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 21/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UIButton+CustomCreation.h"


@implementation UIButton (CustomCreation)

// Create button
+ (UIButton*)createButtonWithOrigin:(CGPoint)buttonOrigin andSize:(CGSize)buttonSize andBorderWidth:(float)borderWidth andBorderColor:(UIColor *)borderColor andText:(NSString *)buttonText andFont:(UIFont *)buttonFont    andFontColor:(UIColor *)fontColor andUppercasing:(BOOL)bUppercasing andAlignment:(UIControlContentHorizontalAlignment)alignment andImage:(UIImage*)buttonImage andImageMode:(UIViewContentMode)imageMode andBackgroundImage:(UIImage*)buttonBackgroundImage
{
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Button appearance
    [newButton setFrame:CGRectMake(buttonOrigin.x, buttonOrigin.y, buttonSize.width, buttonSize.height)];
    [[newButton layer] setBorderWidth:borderWidth];
    [[newButton layer] setBorderColor:borderColor.CGColor];
    [newButton setBackgroundColor:[UIColor clearColor]];
    [newButton setAlpha:1.0];
    [[newButton titleLabel] setFont:buttonFont];
    [newButton setTitleColor:fontColor forState:UIControlStateNormal];
    [newButton setContentHorizontalAlignment:alignment];
    [[newButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[newButton titleLabel] setMinimumScaleFactor:0.5];
    
    if (buttonImage == nil)
    {
        (bUppercasing) ? [newButton setTitle:[buttonText uppercaseString] forState:UIControlStateNormal] : [newButton setTitle:buttonText forState:UIControlStateNormal];
    }
    else
    {
        [newButton setImage:buttonImage forState:UIControlStateNormal];
        [newButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[newButton imageView] setContentMode:imageMode];
    }

    if (!(buttonBackgroundImage == nil))
    {
        [newButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
        [newButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateHighlighted];
        [[newButton imageView] setContentMode:imageMode];
    }

    return newButton;
}


@end
