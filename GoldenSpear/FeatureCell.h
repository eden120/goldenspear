//
//  FeatureCell.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeatureCell : UICollectionViewCell

// Setters for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor;
- (void)setupImageWithImage:(UIImage *)image andLabel:(NSString *)label andLabelBackgroundColor:(UIColor*)labelBackgroundColor andFrame:(CGRect)imageViewFrame;
@property (weak, nonatomic) IBOutlet UIImageView *featureImageView;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel;
@property (weak, nonatomic) IBOutlet UIView *featureViewLabel;

@property UIActivityIndicatorView *activityIndicator;

// zoom button
@property UIButton *zoomButton;
- (void)setupZoomButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;

@end
