//
//  UILabel+CustomCreation.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 21/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UILabel (CustomCreation)

+ (UILabel *)createLabelWithOrigin:(CGPoint)labelOrigin andSize:(CGSize)labelSize andBackgroundColor:(UIColor*)backgroundColor andAlpha:(float)alpha andText:(NSString *)labelText andTextColor:(UIColor*)textColor andFont:(UIFont*)labelFont andUppercasing:(BOOL)bUppercasing andAligned:(NSTextAlignment)textAlignment;

@end
