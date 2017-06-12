//
//  ProductFeatureSearchViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 20/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface ProductFeatureSearchViewController : BaseViewController <SlideButtonViewDelegate, UIWebViewDelegate>

// Information coming from previous controller: the product and the image the user was looking at
@property Product *shownProduct;
@property NSMutableArray *shownProductFeatureTerms;
@property UIImage *shownImage;

// Web View to show the product image
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

// View to show the feature terms
@property (weak, nonatomic) IBOutlet UIView *productFeatureTermsView;
  // Constraint to animate showing/hiding the view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productFeatureTermsViewBottomSpaceConstraint;
  // Name of the product Feature
@property (weak, nonatomic) IBOutlet UILabel *productFeatureName;

// List of terms selected by the user
@property NSMutableArray *selectedSearchTerms;
@property NSMutableArray *featureTermsList;
@property NSMutableArray *productFeaturesList;

@end
