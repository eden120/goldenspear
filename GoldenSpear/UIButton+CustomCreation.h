//
//  UIButton+CustomCreation.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 21/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIButton (CustomCreation)

+ (UIButton*)createButtonWithOrigin:(CGPoint)buttonOrigin andSize:(CGSize)buttonSize andBorderWidth:(float)borderWidth andBorderColor:(UIColor *)borderColor andText:(NSString *)buttonText andFont:(UIFont *)buttonFont  andFontColor:(UIColor *)fontColor andUppercasing:(BOOL)bUppercasing andAlignment:(UIControlContentHorizontalAlignment)alignment andImage:(UIImage*)buttonImage andImageMode:(UIViewContentMode)imageMode andBackgroundImage:(UIImage*)buttonBackgroundImage;

@end
