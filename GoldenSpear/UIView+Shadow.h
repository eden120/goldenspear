//
//  UIView+Shadow.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 01/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface UIView (Shadow)

- (UIView *) makeInsetShadow;
- (UIView *) makeInsetShadowWithRadius:(float)radius Alpha:(float)alpha;
- (UIView *) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions;
- (UIView *) makeInsetShadowWithRadius:(float)radius Color:(UIColor *)color Directions:(NSArray *)directions Insets:(float)inset;

@end
