//
//  GSBaseElementCell.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "GSBaseElementCell.h"
#import "CellBackgroundView.h"
#import "UILabel+CustomCreation.h"

#define kCellBackgroundColor whiteColor
#define kCellBackgroundAlpha 1.0f
#define kCellBorderColor clearColor
#define kCellBorderWidth 0.0f
#define kCellShadowColor clearColor
#define kCellShadowRadius 0.0f//2.0f
#define kCellShadowOffsetX 0.0f
#define kCellShadowOffsetY 0.0f//2.0f
#define kCellShadowOpacity 0.0f//0.5f

#define kCellNumberOfLinesInTitle 2
#define kCellFontSizeInTitle 12.5
#define kCellTitleBackgroundColor whiteColor

#define kFontInHangerButton "Avenir-Light"
#define kFontSizeInHangerButton 12
#define kHangerButtonBorderWidth 0
#define kHangerButtonBorderColor darkGrayColor

#define kFontInHeartButton "Avenir-Light"
#define kFontSizeInHeartButton 12
#define kHeartButtonBorderWidth 0
#define kHeartButtonBorderColor darkGrayColor

#define kFontInPriceLabel "Avenir-Heavy"
#define kFontSizeInPriceLabel 14.0
#define kPriceLabelBorderWidth 0.5
#define kPriceLabelBorderColor clearColor
#define kPriceLabelBackgroundColor clearColor
#define kPriceLabelTextColor blackColor
#define kFontInNOPriceLabel "Avenir-Light"
#define kFontSizeInNOPriceLabel 12.0
#define kNOPriceLabelTextColor lightGrayColor


#define kFontInCreateViewMoveDeleteAddToButton "Avenir-Medium"
#define kFontSizeInCreateViewMoveDeleteAddToButton 16
#define kCreateViewMoveDeleteAddToButtonBorderWidth 0.5
#define kCreateViewMoveDeleteAddToButtonBorderColor darkGrayColor

#define kFontInEditTitleButton "GillSans"
#define kFontSizeInEditTitleButton 16
#define kEditTitleButtonBorderWidth 0.0
#define kEditTitleButtonBorderColor blackColor

#define kSeparatorLineViewInset 10
#define kSeparatorLineViewHeight 1

#define kPortionForNumberInInfoLabel 1
#define kInfoLabelAlpha 1.0
#define kFontInInfoLabel "Avenir-Heavy"
#define kFontSizeInInfoLabel 7
#define kFontColorInInfoLabel blackColor
#define kShadowColorInInfoLabel whiteColor


@implementation GSBaseElementCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        
        // Initialize view cell properties
        
        [self setBackgroundColor:[UIColor kCellBackgroundColor]];
        [self setAlpha:kCellBackgroundAlpha];
        
        [self.layer setBorderColor:[UIColor kCellBorderColor].CGColor];
        [self.layer setBorderWidth:kCellBorderWidth];
        [self.layer setShadowColor:[UIColor kCellShadowColor].CGColor];
        [self.layer setShadowRadius:kCellShadowRadius];
        [self.layer setShadowOffset:CGSizeMake(kCellShadowOffsetX, kCellShadowOffsetY)];
        [self.layer setShadowOpacity:kCellShadowOpacity];
        
        // Make sure to rasterize nicely for retina
        [self.layer setRasterizationScale:[UIScreen mainScreen].scale];
        [self.layer setShouldRasterize:YES];
    }
    
    return self;
}

// Setter for cell properties
- (void)setAppearanceForCellOfType:(NSString *)cellType withBackgroundColor:(UIColor *)backgroundColor andBorderColor:(UIColor *)borderColor andBorderWith:(CGFloat)borderWidth andShadowColor:(UIColor *)shadowColor
{
    [self.layer setBorderColor:borderColor.CGColor];
    [self.layer setBorderWidth:borderWidth];
    [self.layer setShadowColor:shadowColor.CGColor];
    
    // Setup Cell Views
    [self setBackgroundColor:backgroundColor];
    [self setBackgroundView:(CellBackgroundView *) [[CellBackgroundView alloc] initWithFrame:self.bounds]];
    [[self backgroundView] setBackgroundColor:backgroundColor];
    [self setSelectedBackgroundView:[[UIView alloc] initWithFrame:self.bounds]];
    [[self selectedBackgroundView] setBackgroundColor:[UIColor clearColor]];
    
    CGRect frame = self.bounds;
    // Remove subviews from previous usage of this cell
    [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
//    if (!([cellType isEqualToString:@"WardrobeCell"]))
//    {
//        for (UIView *view in [self.contentView subviews])
//        {
//            if(![view isKindOfClass:[UIButton class]])
//            {
//                [view removeFromSuperview];
//            }
//        }
//    }

    // Init the activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // Position and show the activity indicator
    [self.activityIndicator setCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator startAnimating];
    [self.contentView addSubview: self.activityIndicator];
}

// Setup Image View
- (void)setupImageWithImage:(UIImage *)image andFrame:(CGRect)imageViewFrame forCellLayout:(resultCellLayout)layout 
{
    self.mainImageView = [[UIImageView alloc] initWithImage:image];
    
    [self.mainImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.mainImageView setClipsToBounds:YES];
    
    [self.mainImageView setFrame:imageViewFrame];
    
    // Hide the activity indicator
    [self.activityIndicator stopAnimating];
    
    [self.contentView addSubview:self.mainImageView];
    
    [self.contentView sendSubviewToBack:self.mainImageView];
}

// Setup Hanger Button
- (void)setupHangerButtonAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)bSelected inFrame:(CGRect)buttonFrame
{
    // Setup the hanger button
    
    self.hangerButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.hangerButton setFrame:buttonFrame];
    [[self.hangerButton layer] setBorderWidth:kHangerButtonBorderWidth];
    [[self.hangerButton layer] setBorderColor:[UIColor kHangerButtonBorderColor].CGColor];
    [self.hangerButton setBackgroundColor:[UIColor clearColor]];
    [self.hangerButton setAlpha:0.55];
    [[self.hangerButton titleLabel] setFont:[UIFont fontWithName:@kFontInHangerButton size:kFontSizeInHangerButton]];
    [self.hangerButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.hangerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.hangerButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    UIImage * buttonImage = [UIImage imageNamed:(bSelected ? (@"hanger_checked.png") : (@"hanger_unchecked.png"))];
    
    if (buttonImage == nil)
    {
        [self.hangerButton setTitle:NSLocalizedString(@"_ADDTOWARDROBE_BTN_", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.hangerButton setImage:buttonImage forState:UIControlStateNormal];
        [self.hangerButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[self.hangerButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [self.hangerButton setTag:(int)(([indexPath indexAtPosition:0]*OFFSET)+([indexPath indexAtPosition:1]))];
    
    [self.contentView addSubview:self.hangerButton];
    [self.contentView bringSubviewToFront:self.hangerButton];
}

// Setup Verified Badge
- (void)setupVerifiedBadgeInFrame:(CGRect)imageFrame
{
    // Setup the hanger button
    
    self.verifiedBadgeImage = [[UIImageView alloc] initWithFrame:imageFrame];
    
    // Button appearance
    [self.verifiedBadgeImage setImage:[UIImage imageNamed:@"verifiedbadge.png"]];
    
    [self.contentView addSubview:self.verifiedBadgeImage];
    [self.contentView bringSubviewToFront:self.verifiedBadgeImage];
}

-(NSString *) formatNumber:(NSNumber *) num
{
    int intNumber = [num intValue];
    NSString * sRes = [NSString stringWithFormat:@"%d", intNumber ];

    if (intNumber > 1000000)
    {
        float floatNumber = intNumber/ 1000000;
        sRes = [NSString stringWithFormat:@"%.1fM", floatNumber ];
    }
    else if (intNumber > 1000)
    {
        float floatNumber = intNumber/ 1000;
        sRes = [NSString stringWithFormat:@"%.1fk", floatNumber ];
    }
    
    return sRes;
}

// Setup Number of Images in a Post
- (void)setupNumImages:(NSNumber *)imagesNum inFrame:(CGRect)infoFrame
{
    if ((imagesNum == nil) || ((imagesNum != nil) && (imagesNum.intValue <= 0)))
    {
        return;
    }
    
    self.numImagesIcon = [[UIImageView alloc] initWithFrame:infoFrame];
    
    // Icon appearance
    [self.numImagesIcon setImage:[UIImage imageNamed:@"postImagesNum.png"]];
    [self.numImagesIcon setAlpha:kInfoLabelAlpha];
    
    [self.numImagesIcon.layer setShadowColor:[[UIColor kShadowColorInInfoLabel] CGColor]];
    [self.numImagesIcon.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.numImagesIcon.layer setShadowRadius:1.0];
    [self.numImagesIcon.layer setShadowOpacity:1.0];
    [self.numImagesIcon.layer setMasksToBounds:NO];

    // Number of items
    self.numImages = [UILabel createLabelWithOrigin:CGPointMake(0, infoFrame.size.height - (infoFrame.size.height*kPortionForNumberInInfoLabel))
                                            andSize:CGSizeMake(infoFrame.size.width, infoFrame.size.height*kPortionForNumberInInfoLabel)
                                       andBackgroundColor:[UIColor clearColor]
                                                 andAlpha:0.4
                                                  andText:[self formatNumber:imagesNum]
                                             andTextColor:[UIColor kFontColorInInfoLabel]
                                                  andFont:[UIFont fontWithName:@kFontInInfoLabel size:kFontSizeInInfoLabel]
                                           andUppercasing:YES
                                               andAligned:NSTextAlignmentCenter];

    [self.numImagesIcon addSubview:self.numImages];

    [self.contentView addSubview:self.numImagesIcon];
    [self.contentView bringSubviewToFront:self.numImagesIcon];
}

// Setup Verified Badge
- (void)setupNumLikes:(NSNumber *)likesNum inFrame:(CGRect)infoFrame
{
    if ((likesNum == nil) || ((likesNum != nil) && (likesNum.intValue <= 0)))
    {
        return;
    }
    
    self.numLikesIcon = [[UIImageView alloc] initWithFrame:infoFrame];
    
    // Icon appearance
    [self.numLikesIcon setImage:[UIImage imageNamed:@"postLikesNum.png"]];
    [self.numLikesIcon setAlpha:kInfoLabelAlpha];
    
    [self.numLikesIcon.layer setShadowColor:[[UIColor kShadowColorInInfoLabel] CGColor]];
    [self.numLikesIcon.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.numLikesIcon.layer setShadowRadius:1.0];
    [self.numLikesIcon.layer setShadowOpacity:1.0];
    [self.numLikesIcon.layer setMasksToBounds:NO];
    
    // Number of items
    
    // Number of items
    self.numLikes = [UILabel createLabelWithOrigin:CGPointMake(0, infoFrame.size.height - (infoFrame.size.height*kPortionForNumberInInfoLabel))
                                            andSize:CGSizeMake(infoFrame.size.width, infoFrame.size.height*kPortionForNumberInInfoLabel)
                                andBackgroundColor:[UIColor clearColor]
                                          andAlpha:0.4
                                            andText:[self formatNumber:likesNum]
                                       andTextColor:[UIColor kFontColorInInfoLabel]
                                            andFont:[UIFont fontWithName:@kFontInInfoLabel size:kFontSizeInInfoLabel]
                                     andUppercasing:YES
                                         andAligned:NSTextAlignmentCenter];

    [self.numLikesIcon addSubview:self.numLikes];
    
    [self.contentView addSubview:self.numLikesIcon];
    [self.contentView bringSubviewToFront:self.numLikesIcon];
}

// Setup Verified Badge
- (void)setupNumComments:(NSNumber *)commentsNum inFrame:(CGRect)infoFrame
{
    if ((commentsNum == nil) || ((commentsNum != nil) && (commentsNum.intValue <= 0)))
    {
        return;
    }
    
    self.numCommentsIcon = [[UIImageView alloc] initWithFrame:infoFrame];
    
    // Icon appearance
    [self.numCommentsIcon setImage:[UIImage imageNamed:@"postCommentsNum.png"]];
    [self.numCommentsIcon setAlpha:kInfoLabelAlpha];
    
    [self.numCommentsIcon.layer setShadowColor:[[UIColor kShadowColorInInfoLabel] CGColor]];
    [self.numCommentsIcon.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.numCommentsIcon.layer setShadowRadius:1.0];
    [self.numCommentsIcon.layer setShadowOpacity:1.0];
    [self.numCommentsIcon.layer setMasksToBounds:NO];
    
    // Number of items
    self.numComments = [UILabel createLabelWithOrigin:CGPointMake(0, infoFrame.size.height - (infoFrame.size.height*kPortionForNumberInInfoLabel))
                                              andSize:CGSizeMake(infoFrame.size.width, infoFrame.size.height*kPortionForNumberInInfoLabel)
                                   andBackgroundColor:[UIColor clearColor]
                                             andAlpha:0.4
                                            andText:[self formatNumber:commentsNum]
                                       andTextColor:[UIColor kFontColorInInfoLabel]
                                            andFont:[UIFont fontWithName:@kFontInInfoLabel size:kFontSizeInInfoLabel]
                                     andUppercasing:YES
                                         andAligned:NSTextAlignmentCenter];

    [self.numCommentsIcon addSubview:self.numComments];
    
    [self.contentView addSubview:self.numCommentsIcon];
    [self.contentView bringSubviewToFront:self.numCommentsIcon];
}

- (void)setSelectedHanger
{
    UIImage * buttonImage = [UIImage imageNamed:@"hanger_checked.png"];
    
    if (buttonImage == nil)
    {
        [self.hangerButton setTitle:NSLocalizedString(@"_ADDTOWARDROBE_BTN_", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.hangerButton setImage:buttonImage forState:UIControlStateNormal];
        [self.hangerButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[self.hangerButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [self.contentView bringSubviewToFront:self.hangerButton];
}

// Setup Heart Button
- (void)setupHeartButtonAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)bSelected inFrame:(CGRect)buttonFrame
{
    // Setup the heart button
    
    self.heartButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.heartButton setFrame:buttonFrame];
    [[self.heartButton layer] setBorderWidth:kHeartButtonBorderWidth];
    [[self.heartButton layer] setBorderColor:[UIColor kHeartButtonBorderColor].CGColor];
    [self.heartButton setBackgroundColor:[UIColor clearColor]];
    [self.heartButton setAlpha:1.0];
    [[self.heartButton titleLabel] setFont:[UIFont fontWithName:@kFontInHeartButton size:kFontSizeInHeartButton]];
    [self.heartButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.heartButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.heartButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    UIImage * buttonImage = [UIImage imageNamed:(bSelected ? (@"heart_checked.png") : (@"heart_unchecked.png"))];
    
    if (buttonImage == nil)
    {
        [self.heartButton setTitle:NSLocalizedString(@"_FOLLOW_BTN_", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.heartButton setImage:buttonImage forState:UIControlStateNormal];
        [self.heartButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[self.heartButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [self.heartButton setTag:(int)(([indexPath indexAtPosition:0]*OFFSET)+([indexPath indexAtPosition:1]))];
    
    [self.contentView addSubview:self.heartButton];
    [self.contentView bringSubviewToFront:self.heartButton];
}

- (void)setSelectedHeart
{
    UIImage * buttonImage = [UIImage imageNamed:@"heart_checked.png"];
    
    if (buttonImage == nil)
    {
        [self.heartButton setTitle:NSLocalizedString(@"_FOLLOW_BTN_", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.heartButton setImage:buttonImage forState:UIControlStateNormal];
        [self.heartButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[self.heartButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [self.contentView bringSubviewToFront:self.heartButton];
}

// Setup View Button
- (void)setupViewButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the view button
    
    self.viewButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.viewButton setFrame:buttonFrame];
    [[self.viewButton layer] setBorderWidth:kCreateViewMoveDeleteAddToButtonBorderWidth];
    [[self.viewButton layer] setBorderColor:[UIColor kCreateViewMoveDeleteAddToButtonBorderColor].CGColor];
    [self.viewButton setBackgroundColor:[UIColor clearColor]];
    [self.viewButton setAlpha:0.8];
    [[self.viewButton titleLabel] setFont:[UIFont fontWithName:@kFontInCreateViewMoveDeleteAddToButton size:kFontSizeInCreateViewMoveDeleteAddToButton]];
    [self.viewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.viewButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.viewButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    [self.viewButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateNormal];
    [self.viewButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateHighlighted];
    [[self.viewButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self.viewButton layer] setCornerRadius:5];
    [self.viewButton setClipsToBounds:YES];
    
    [self.viewButton setTitle:NSLocalizedString(@"_VIEW_BTN_", nil) forState:UIControlStateNormal];
    
    [self.viewButton setTag:(int)[indexPath indexAtPosition:1]];
    
    [self.contentView addSubview:self.viewButton];
    [self.contentView bringSubviewToFront:self.viewButton];
}

// Setup Move Button
- (void)setupMoveButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the view button
    
    self.moveButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.moveButton setFrame:buttonFrame];
    [[self.moveButton layer] setBorderWidth:kCreateViewMoveDeleteAddToButtonBorderWidth];
    [[self.moveButton layer] setBorderColor:[UIColor kCreateViewMoveDeleteAddToButtonBorderColor].CGColor];
    [self.moveButton setBackgroundColor:[UIColor clearColor]];
    [self.moveButton setAlpha:0.8];
    [[self.moveButton titleLabel] setFont:[UIFont fontWithName:@kFontInCreateViewMoveDeleteAddToButton size:kFontSizeInCreateViewMoveDeleteAddToButton]];
    [self.moveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.moveButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.moveButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    [self.moveButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateNormal];
    [self.moveButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateHighlighted];
    [[self.moveButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self.moveButton layer] setCornerRadius:5];
    [self.moveButton setClipsToBounds:YES];
    
    
    [self.moveButton setTitle:NSLocalizedString(@"_MOVE_BTN_", nil) forState:UIControlStateNormal];
    
    [self.moveButton setTag:(int)[indexPath indexAtPosition:1]];
    
    [self.contentView addSubview:self.moveButton];
    [self.contentView bringSubviewToFront:self.moveButton];
}

// Setup Edit Button
- (void)setupEditButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the edit button
    
    self.editButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.editButton setFrame:buttonFrame];
    [[self.editButton layer] setBorderWidth:kCreateViewMoveDeleteAddToButtonBorderWidth];
    [[self.editButton layer] setBorderColor:[UIColor kCreateViewMoveDeleteAddToButtonBorderColor].CGColor];
    [self.editButton setBackgroundColor:[UIColor clearColor]];
    [self.editButton setAlpha:0.8];
    [[self.editButton titleLabel] setFont:[UIFont fontWithName:@kFontInCreateViewMoveDeleteAddToButton size:kFontSizeInCreateViewMoveDeleteAddToButton]];
    [self.editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.editButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.editButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    [self.editButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateNormal];
    [self.editButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateHighlighted];
    [[self.editButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self.editButton layer] setCornerRadius:5];
    [self.editButton setClipsToBounds:YES];
    
    
    [self.editButton setTitle:NSLocalizedString(@"_EDIT_BTN_", nil) forState:UIControlStateNormal];
    
    [self.editButton setTag:(int)[indexPath indexAtPosition:1]];
    
    [self.contentView addSubview:self.editButton];
    [self.contentView bringSubviewToFront:self.editButton];
}

// Setup Delete Button
- (void)setupDeleteButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the view button
    
    self.deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.deleteButton setFrame:buttonFrame];
    [[self.deleteButton layer] setBorderWidth:kCreateViewMoveDeleteAddToButtonBorderWidth];
    [[self.deleteButton layer] setBorderColor:[UIColor kCreateViewMoveDeleteAddToButtonBorderColor].CGColor];
    [self.deleteButton setBackgroundColor:[UIColor clearColor]];
    [self.deleteButton setAlpha:0.8];
    [[self.deleteButton titleLabel] setFont:[UIFont fontWithName:@kFontInCreateViewMoveDeleteAddToButton size:kFontSizeInCreateViewMoveDeleteAddToButton]];
    [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.deleteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.deleteButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"SearchTextFieldBackground.png"] forState:UIControlStateHighlighted];
    [[self.deleteButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self.deleteButton layer] setCornerRadius:5];
    [self.deleteButton setClipsToBounds:YES];

    
    [self.deleteButton setTitle:NSLocalizedString(@"_DELETE_BTN_", nil) forState:UIControlStateNormal];
    
    [self.deleteButton setTag:(int)[indexPath indexAtPosition:1]];
    
    [self.contentView addSubview:self.deleteButton];
    [self.contentView bringSubviewToFront:self.deleteButton];
}


// Setup Create New Element Button
- (void)setupCreateNewElementButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the create element button
    
    self.createNewElementButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.createNewElementButton setFrame:buttonFrame];
    [[self.createNewElementButton layer] setBorderWidth:0];//kCreateViewMoveDeleteAddToButtonBorderWidth];
    [[self.createNewElementButton layer] setBorderColor:[UIColor clearColor].CGColor];//]kCreateViewMoveDeleteAddToButtonBorderColor].CGColor];
    [self.createNewElementButton setBackgroundColor:[UIColor whiteColor]];
    [self.createNewElementButton setAlpha:0.7];
    [[self.createNewElementButton titleLabel] setFont:[UIFont fontWithName:@kFontInCreateViewMoveDeleteAddToButton size:kFontSizeInCreateViewMoveDeleteAddToButton]];
    [self.createNewElementButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.createNewElementButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.createNewElementButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    [self.createNewElementButton setTitle:NSLocalizedString(@"_CREATE_BTN_", nil) forState:UIControlStateNormal];
    
    [self.createNewElementButton setTag:(int)[indexPath indexAtPosition:1]];
    
    [self.contentView addSubview:self.createNewElementButton];
    [self.contentView bringSubviewToFront:self.createNewElementButton];
    
    // Hide the activity indicator
    [self.activityIndicator stopAnimating];
}

// Setup Add Bin Content To Wardrobe Button
- (void)setupAddBinContentToWardrobeButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the add bin content to wardrobe button
    
    self.addBinContentToWardrobeButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.addBinContentToWardrobeButton setFrame:buttonFrame];
    [[self.addBinContentToWardrobeButton layer] setBorderWidth:kCreateViewMoveDeleteAddToButtonBorderWidth];
    [[self.addBinContentToWardrobeButton layer] setBorderColor:[UIColor kCreateViewMoveDeleteAddToButtonBorderColor].CGColor];
    [self.addBinContentToWardrobeButton setBackgroundColor:[UIColor whiteColor]];
    [self.addBinContentToWardrobeButton setAlpha:0.7];
    [[self.addBinContentToWardrobeButton titleLabel] setFont:[UIFont fontWithName:@kFontInCreateViewMoveDeleteAddToButton size:kFontSizeInCreateViewMoveDeleteAddToButton]];
    [self.addBinContentToWardrobeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addBinContentToWardrobeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.addBinContentToWardrobeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    [self.addBinContentToWardrobeButton setTitle:NSLocalizedString(@"_ADDHERE_BTN_", nil) forState:UIControlStateNormal];
    
    [self.addBinContentToWardrobeButton setTag:(int)[indexPath indexAtPosition:1]];
    
    [self.contentView addSubview:self.addBinContentToWardrobeButton];
    [self.contentView bringSubviewToFront:self.addBinContentToWardrobeButton];
}

// Setup Price Label
- (void)setupPriceWithValue:(NSString *)priceText andFrame:(CGRect)priceFrame
{
    BOOL bNoPrice = (([priceText isEqualToString:(NSLocalizedString(@"_PRICE_NOT_AVAILABLE_", nil))]) || ([priceText isEqualToString:(NSLocalizedString(@"_PASTCOLLECTIONPRODUCT_", nil))]));

    UILabel* priceLabel = [[UILabel alloc] initWithFrame:priceFrame];
    
    [priceLabel setBackgroundColor:[UIColor kPriceLabelBackgroundColor]];
    
    [priceLabel setNumberOfLines:1];
    
    [priceLabel setTextAlignment:NSTextAlignmentCenter];
    
    [priceLabel setFont:[UIFont fontWithName:((bNoPrice) ? (@kFontInNOPriceLabel) : (@kFontInPriceLabel)) size:((bNoPrice) ? (kFontSizeInNOPriceLabel) : (kFontSizeInPriceLabel))]];
    
    [priceLabel setTextColor:((bNoPrice) ? ([UIColor kNOPriceLabelTextColor]) : ([UIColor kPriceLabelTextColor]))];
    
    [priceLabel setText:priceText];
    
    [priceLabel setAdjustsFontSizeToFitWidth:YES];
    
    [self.contentView addSubview:priceLabel];
}

// Helper function to format PRODUCTLAYOUT text
- (NSAttributedString *)attributedMessageFromMessage:(NSString *)message withBrandFont:(NSString *)brandFont andProductFont:(NSString *)productFont andSize:(NSNumber *)fontSize
{
    NSArray* messageWords = [message componentsSeparatedByString: @"\n"];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:@""];
 
    if(!(messageWords == nil))
    {
        if([messageWords count] > 1)
        {
            NSString * brandText = [messageWords objectAtIndex:0];
            NSString * productText = @"";
            
            for (int i = 1; i < messageWords.count; i++)
            {
                productText = [productText stringByAppendingString:[messageWords objectAtIndex:i]];
            }
            
            NSAttributedString * attributedBrandText = [[NSAttributedString alloc]
                                              initWithString:[NSString stringWithFormat:@"%@\n",brandText]
                                                        attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                     @"WordType": @"BoldKey",
                                                                     NSFontAttributeName:[UIFont fontWithName:brandFont size:[fontSize intValue]]}];
            
            [attributedMessage appendAttributedString:attributedBrandText];
            
            NSAttributedString * attributedProductText = [[NSAttributedString alloc]
                                                        initWithString:[NSString stringWithFormat:@"%@",productText]
                                                        attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                     @"WordType": @"BoldKey",
                                                                     NSFontAttributeName:[UIFont fontWithName:productFont size:[fontSize intValue]]}];
            
            [attributedMessage appendAttributedString:attributedProductText];
        }
        else if([messageWords count] > 0)
        {
            NSString * productText = [messageWords objectAtIndex:0];
            
            NSAttributedString * attributedProductText = [[NSAttributedString alloc]
                                                          initWithString:[NSString stringWithFormat:@"%@",productText]
                                                          attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                       @"WordType": @"BoldKey",
                                                                       NSFontAttributeName:[UIFont fontWithName:productFont size:[fontSize intValue]]}];
            
            [attributedMessage appendAttributedString:attributedProductText];
        }
    }

    return attributedMessage;
}

// Setup Title
-(void)setupTitleWithText:(NSString *)titleText forCellLayout:(resultCellLayout)layout inFrame:(CGRect)titleFrame
{
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    
    [titleLabel setBackgroundColor:[UIColor kCellTitleBackgroundColor]];
    
    [titleLabel setNumberOfLines:kCellNumberOfLinesInTitle];
    
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [titleLabel setAdjustsFontSizeToFitWidth:NO];

    if (!(layout >= maxResultCellLayouts))
    {
        switch (layout)
        {
//            case ARTICLELAYOUT:
//            case TUTORIALLAYOUT:
//            case REVIEWLAYOUT:
            case POSTLAYOUT:
            {
                titleFrame.origin.y = titleFrame.origin.y - titleFrame.size.height;
                titleFrame.size.height = titleFrame.size.height*2;
                
                self.transparencyView = [[UIImageView alloc] initWithFrame:titleFrame];
                
                [self.transparencyView setImage:[UIImage imageNamed:@"PostsTransparency"]];
                
                [self.transparencyView setContentMode:UIViewContentModeScaleAspectFill];
                
                [self.contentView addSubview:self.transparencyView];

                [self bringSubviewToFront:self.transparencyView];

                [titleLabel setFont:[UIFont fontWithName:@"GillSans" size:15]];
                
                [titleLabel setBackgroundColor:[UIColor clearColor]];

                [titleLabel setText:titleText];

                [titleLabel setTextColor:[UIColor blackColor]];

                [titleLabel setNumberOfLines:1];

                break;
            }
            case WARDROBELAYOUT:
            {
                [titleLabel setBackgroundColor:[UIColor blackColor]];

                [titleLabel setTextColor:[UIColor whiteColor]];
                
                [titleLabel setNumberOfLines:1];
                
                [titleLabel setAdjustsFontSizeToFitWidth:YES];
                
                [titleLabel setMinimumScaleFactor:0.5];
                
                [titleLabel setFont:[UIFont fontWithName:@kFontInEditTitleButton size:kFontSizeInEditTitleButton]];
                
                [titleLabel setText:titleText];
                
                break;
            }
            case STYLISTLAYOUT:
            {
                [titleLabel setNumberOfLines:1];
                
                [titleLabel setAdjustsFontSizeToFitWidth:YES];
                
                [titleLabel setMinimumScaleFactor:0.5];
                
                [titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:kCellFontSizeInTitle]];
                
                [titleLabel setText:[titleText uppercaseString]];
                
                break;
            }
            case PRODUCTLAYOUT:
            {
                [titleLabel setAttributedText:[self attributedMessageFromMessage:[titleText uppercaseString] withBrandFont:@"Avenir-Heavy" andProductFont:@"Avenir-Roman" andSize:[NSNumber numberWithInt:kCellFontSizeInTitle]]];

//                [titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:kCellFontSizeInTitle]];
//                
//                [titleLabel setText:[titleText uppercaseString]];
                
                break;
            }
            case PAGELAYOUT:
            case BRANDLAYOUT:
            {
                [titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:kCellFontSizeInTitle]];
                
                [titleLabel setText:[titleText uppercaseString]];
             
                break;
            }
            default:
                
                break;
        }
        
    }
    else
    {
        [titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:kCellFontSizeInTitle]];
        
        [titleLabel setText:[titleText uppercaseString]];
    }
    
    [self.contentView addSubview:titleLabel];
    
    [self.contentView bringSubviewToFront:titleLabel];
    
    if(layout == PRODUCTLAYOUT)
    {
        UIView * separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + kSeparatorLineViewInset, titleLabel.frame.origin.y + titleLabel.frame.size.height - kSeparatorLineViewHeight, titleLabel.frame.size.width-(kSeparatorLineViewInset * 2), kSeparatorLineViewHeight)];
        
        [separatorLineView setBackgroundColor:[UIColor blackColor]];
        
        [self.contentView addSubview:separatorLineView];
    }
}

// Setup Title
-(void)setupUpperTitleWithText:(NSString *)titleText forCellLayout:(resultCellLayout)layout inFrame:(CGRect)titleFrame
{
    UILabel* upperTitleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    
    [upperTitleLabel setBackgroundColor:[UIColor kCellTitleBackgroundColor]];

    [upperTitleLabel setAlpha:0.7];

    [upperTitleLabel setNumberOfLines:kCellNumberOfLinesInTitle];
    
    [upperTitleLabel setTextAlignment:NSTextAlignmentCenter];
    
    if (!(layout >= maxResultCellLayouts))
    {
        switch (layout)
        {
//            case ARTICLELAYOUT:
//            case TUTORIALLAYOUT:
//            case REVIEWLAYOUT:
            case POSTLAYOUT:
            {
                [upperTitleLabel setBackgroundColor:[UIColor clearColor]];

                [upperTitleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
                
                [upperTitleLabel setText:[titleText uppercaseString]];
                
                [upperTitleLabel setTextColor:[UIColor blackColor]];
                
                break;
            }
            case PAGELAYOUT:
            case WARDROBELAYOUT:
            {
                [upperTitleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:kCellFontSizeInTitle]];
                
                [upperTitleLabel setText:[titleText uppercaseString]];
                
                break;
            }
            case PRODUCTLAYOUT:
            case STYLISTLAYOUT:
            case BRANDLAYOUT:
            default:
                
                break;
        }
        
    }
    else
    {
        [upperTitleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:kCellFontSizeInTitle]];
        
        [upperTitleLabel setText:[titleText uppercaseString]];
    }
    
    [upperTitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [upperTitleLabel setAdjustsFontSizeToFitWidth:NO];
    
    [self.contentView addSubview:upperTitleLabel];
    
    [self.contentView bringSubviewToFront:upperTitleLabel];
}

// Setup Edit Wardrobe Title Button
- (void)setupEditWardrobeTitleButtonWithTitle:(NSString *)title atIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the edit wardrobe title button
    
    self.editWardrobeTitleButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.editWardrobeTitleButton setFrame:buttonFrame];
    [[self.editWardrobeTitleButton layer] setBorderWidth:kEditTitleButtonBorderWidth];
    [[self.editWardrobeTitleButton layer] setBorderColor:[UIColor kEditTitleButtonBorderColor].CGColor];
    [self.editWardrobeTitleButton setBackgroundColor:[UIColor blackColor]];
    [self.editWardrobeTitleButton setAlpha:1.0];
    [[self.editWardrobeTitleButton titleLabel] setFont:[UIFont fontWithName:@kFontInEditTitleButton size:kFontSizeInEditTitleButton]];
    [self.editWardrobeTitleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.editWardrobeTitleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.editWardrobeTitleButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    [self.editWardrobeTitleButton setTitle:title forState:UIControlStateNormal];
    
    [self.editWardrobeTitleButton setTag:(int)[indexPath indexAtPosition:1]];
    
    [self.contentView addSubview:self.editWardrobeTitleButton];
    [self.contentView bringSubviewToFront:self.editWardrobeTitleButton];
}

-(void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (self.selected)
    {
        [self.layer setBorderColor:[UIColor darkGrayColor].CGColor];
        [self.layer setBorderWidth:3];
        [self.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    }
    else
    {
        [self.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.layer setBorderWidth:1.0f];
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
    }
    
    [self setNeedsDisplay];
}

// setup buttons
- (void)setupWardrobeButtonsForState:(NSInteger)state andIndexPath:(NSIndexPath *)indexPath
{
    int iIndex = (int)[indexPath indexAtPosition:1];
    
    self.addBinContentToWardrobeButton.tag = iIndex;
    self.deleteButton.tag = iIndex;
    self.viewButton.tag = iIndex;
    self.editWardrobeTitleButton.tag = iIndex;
    
    if(state == 0)
    {
        self.mainImageView.hidden = YES;

        self.createNewElementButton.hidden = NO;
        self.createNewElementButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.createNewElementButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.createNewElementButton.titleLabel.adjustsFontSizeToFitWidth = YES;

        self.editWardrobeTitleButton.hidden = YES;

        self.viewButton.hidden = YES;
        self.deleteButton.hidden = YES;

        self.addBinContentToWardrobeButton.hidden = YES;
        
        self.backgroundColor = [UIColor blueColor];
        
        // Hide the activity indicator, beacuse there's no image to load
        [self.activityIndicator stopAnimating];
    }
    else if(state == 1)
    {
        self.mainImageView.hidden = NO;

        self.createNewElementButton.hidden = YES;

        self.editWardrobeTitleButton.hidden = NO;
        self.editWardrobeTitleButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.editWardrobeTitleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.editWardrobeTitleButton.titleLabel.adjustsFontSizeToFitWidth = YES;

        self.viewButton.hidden = NO;
        self.deleteButton.hidden = NO;

        self.addBinContentToWardrobeButton.hidden = YES;

        self.backgroundColor = [UIColor whiteColor];
    }
    else if(state == 2)
    {
        self.mainImageView.hidden = NO;

        self.createNewElementButton.hidden = YES;
        
        self.editWardrobeTitleButton.hidden = NO;
        self.editWardrobeTitleButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.editWardrobeTitleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.editWardrobeTitleButton.titleLabel.adjustsFontSizeToFitWidth = YES;

        self.viewButton.hidden = YES;
        self.deleteButton.hidden = YES;

        self.addBinContentToWardrobeButton.hidden = NO;

        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.mainImageView = nil;
    self.hangerButton = nil;
    self.heartButton = nil;
    self.viewButton = nil;
    self.deleteButton = nil;
    self.createNewElementButton = nil;
    self.editWardrobeTitleButton = nil;
    self.addBinContentToWardrobeButton = nil;
    self.moveButton = nil;
    self.transparencyView = nil;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
