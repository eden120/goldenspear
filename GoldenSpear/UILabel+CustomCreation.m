//
//  UILabel+CustomCreation.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 21/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UILabel+CustomCreation.h"

@implementation UILabel (CustomCreation)


// Create label
+ (UILabel *)createLabelWithOrigin:(CGPoint)labelOrigin andSize:(CGSize)labelSize andBackgroundColor:(UIColor*)backgroundColor andAlpha:(float)alpha andText:(NSString *)labelText andTextColor:(UIColor*)textColor andFont:(UIFont*)labelFont andUppercasing:(BOOL)bUppercasing andAligned:(NSTextAlignment)textAlignment
{
    UILabel * newLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelOrigin.x, labelOrigin.y, labelSize.width, labelSize.height)];
    
    // Label appearance
    [newLabel setBackgroundColor:backgroundColor];
    [newLabel setAlpha:alpha];
    (bUppercasing) ? [newLabel setText:[labelText uppercaseString]] : [newLabel setText:labelText] ;
    [newLabel setFont:labelFont];
    [newLabel setTextColor:textColor];
    [newLabel setClipsToBounds:YES];
    //[newLabel setBaselineAdjustment:YES];
    [newLabel setTextAlignment:textAlignment];
    [newLabel setNumberOfLines:1];
    [newLabel setAdjustsFontSizeToFitWidth:YES];
    [newLabel setMinimumScaleFactor:0.5];
    
    return newLabel;
}

@end
