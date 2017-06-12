//
//  CollectionViewHeaderReusableView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 22/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewHeaderReusableView : UICollectionReusableView

// Label to store the section title
@property (nonatomic/*, strong, readonly*/) UILabel *headerTitle;

// Setter for title label text
- (void)setHeaderTitleText:(NSString *)titleLabel;

- (void) setupSearchFeatureCellHeader:(NSString *)titleLabel;

// Setter for title label text properties
- (void)setHeaderTitleAppearanceWithBackgroundColor:(UIColor *)backgroundColor andFontType:(UIFont *)fontType andTextColor:(UIColor *)fontColor;

@end
