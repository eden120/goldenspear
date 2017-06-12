//
//  GSBaseElementCell.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define OFFSET 100000

// Different possible layouts in a ResultsCell
typedef enum resultLayout
{
    PRODUCTLAYOUT,
    
//    ARTICLELAYOUT,
//    TUTORIALLAYOUT,
//    REVIEWLAYOUT,

    POSTLAYOUT,
    
    PAGELAYOUT,
    
    WARDROBELAYOUT,
    
    BRANDLAYOUT,
    
    STYLISTLAYOUT,
    
    maxResultCellLayouts
}
resultCellLayout;

@interface GSBaseElementCell : UICollectionViewCell


// Setters and cell properties

// Generic
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor;
- (void)setupImageWithImage:(UIImage *)image andFrame:(CGRect)imageViewFrame forCellLayout:(resultCellLayout)layout;

@property UIImageView *mainImageView;

@property UIActivityIndicatorView *activityIndicator;

// ResultsCell - All (Except Stylist)
  // Hanger
@property UIButton *hangerButton;
- (void)setupHangerButtonAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)bSelected inFrame:(CGRect)buttonFrame;
- (void)setSelectedHanger;
  // Title
- (void)setupTitleWithText:(NSString *)titleText forCellLayout:(resultCellLayout)layout inFrame:(CGRect)titleFrame;

// ResultsCell  - Product
  // Price
- (void)setupPriceWithValue:(NSString *)priceText andFrame:(CGRect)priceFrame;

// ResultsCell - Post (Article, Tutorial, Review), Wardrobe
  // Upper Title
- (void)setupUpperTitleWithText:(NSString *)titleText forCellLayout:(resultCellLayout)layout inFrame:(CGRect)titleFrame;
@property UIImageView* transparencyView;
  // Post Num Images
@property UILabel *numImages;
@property UIImageView *numImagesIcon;
- (void)setupNumImages:(NSNumber *)imagesNum inFrame:(CGRect)infoFrame;
// Post Num Likes
@property UILabel *numLikes;
@property UIImageView *numLikesIcon;
- (void)setupNumLikes:(NSNumber *)likesNum inFrame:(CGRect)infoFrame;
// Post Num Comments
@property UILabel *numComments;
@property UIImageView *numCommentsIcon;
- (void)setupNumComments:(NSNumber *)commentsNum inFrame:(CGRect)infoFrame;

// ResultsCell - Stylist
  // Heart
@property UIButton *heartButton;
- (void)setupHeartButtonAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)bSelected inFrame:(CGRect)buttonFrame;
- (void)setSelectedHeart;
  // Verified Badge
@property UIImageView *verifiedBadgeImage;
- (void)setupVerifiedBadgeInFrame:(CGRect)imageFrame;


// WardrobeCell & WardrobeContentCell & PostCell
// View
@property UIButton *viewButton;
- (void)setupViewButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;
// Delete
@property UIButton *deleteButton;
- (void)setupDeleteButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;


// Wardrobe Cell & Post Cell
  // AddNewWardrobe or AddNewPost
@property UIButton *createNewElementButton;
- (void)setupCreateNewElementButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;


// Wardrobe Cell
// Title
@property UIButton *editWardrobeTitleButton;
- (void)setupEditWardrobeTitleButtonWithTitle:(NSString *)title atIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;
// Add
@property UIButton *addBinContentToWardrobeButton;
- (void)setupAddBinContentToWardrobeButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;


// WardrobeContentCell
  // Move
@property UIButton *moveButton;
- (void)setupMoveButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;


// PostCell
// Edit
@property UIButton *editButton;
- (void)setupEditButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame;

@end
