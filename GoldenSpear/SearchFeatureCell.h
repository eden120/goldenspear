//
//  SearchFeatureCell.h
//  GoldenSpear
//
//  Created by Alberto Seco on 31/7/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFeatureCell : UICollectionViewCell

// Setters for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor;
- (void)setupImageWithImage:(UIImage *)image andLabel:(NSString *)label andLabelBackgroundColor:(UIColor*)labelBackgroundColor andFrame:(CGRect)imageViewFrame;
@property (weak, nonatomic) IBOutlet UIImageView *featureImageView;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel;
@property (weak, nonatomic) IBOutlet UIView *featureViewLabel;

@property UIActivityIndicatorView *activityIndicator;

// zoom button
@property UIButton *zoomButton;
@property UIButton *expandButton;
- (void)setupZoomButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;
- (void)setupExpandButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame expanded:(BOOL) bExpanded;

@end
