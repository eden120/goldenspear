//
//  RateView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RateView;

// Set up a delegate to notify the view controller when the rating changes
@protocol RateViewDelegate

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating;

@end

@interface RateView : UIView

// Images to represent not selected, half selected, and fully selected
@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;

// Images spacing and size
@property (assign) int midMargin;
@property (assign) int outerMargin;
@property (assign) CGSize minImageSize;

// Set of children image views
@property (strong) NSMutableArray * imageViews;

// Max rating (minimum is assumed 0)
@property (assign, nonatomic) int maxRating;

// Current rating
@property (assign, nonatomic) float rating;

// The view should be editable or not
@property (assign) BOOL editable;

// Track delegate
@property (assign) id <RateViewDelegate> delegate;

@end
