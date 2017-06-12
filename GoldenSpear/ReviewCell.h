//
//  ReviewCell.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 13/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RateView.h"


@interface ReviewCell : UICollectionViewCell <RateViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userPic;
@property (weak, nonatomic) IBOutlet RateView *overallRateView;
@property (weak, nonatomic) IBOutlet RateView *comfortRateView;
@property (weak, nonatomic) IBOutlet RateView *qualityRateView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (weak, nonatomic) IBOutlet UITextView *reviewStr;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString * videoURL;

/*
// Profile pic of the review author
@property (weak, nonatomic) IBOutlet UIImageView *userPic;

// Name of the review author
@property (weak, nonatomic) IBOutlet UILabel *userName;

// Location of the review author
@property (weak, nonatomic) IBOutlet UILabel *userLocation;

// Rating stars
@property (weak, nonatomic) IBOutlet RateView *overallRateView;
@property (weak, nonatomic) IBOutlet RateView *comfortRateView;
@property (weak, nonatomic) IBOutlet RateView *qualityRateView;

// Content of the review
@property (weak, nonatomic) IBOutlet UITextView *reviewStr;*/

// Setter for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor andImageContentMode:(UIViewContentMode)contentMode;
- (void)setVideoURL:(NSString*) videoURL andIndex:(NSInteger)index;
@end
