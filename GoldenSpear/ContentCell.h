//
//  ContentCell.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentCell : UICollectionViewCell

// Setters for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor;
- (void)setupImageWithImage:(UIImage *)image andFrame:(CGRect)imageViewFrame;

@property UIActivityIndicatorView *activityIndicator;

@end
