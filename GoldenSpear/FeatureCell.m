//
//  FeatureCell.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FeatureCell.h"

#define kCellBackgroundColor whiteColor
#define kCellBackgroundAlpha 0.0f
#define kCellBorderColor whiteColor
#define kCellBorderWidth 1.0f
#define kCellShadowColor whiteColor
#define kCellShadowRadius 0.0f
#define kCellShadowOffsetX 0.0f
#define kCellShadowOffsetY 0.0f
#define kCellShadowOpacity 0.0f
#define kCellNumberOfLinesInTitle 1
#define kCellFontSizeInTitle 12
#define kCellTitleBackgroundColor whiteColor
#define kFeatureItemHeightOnlyLabel 22.0

#define kFontInZoomButton "Avenir-Light"
#define kFontSizeInZoomButton 12
#define kZoomButtonBorderWidth 0
#define kZoomButtonBorderColor darkGrayColor

#define OFFSET 100000


@implementation FeatureCell


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
        //[self.layer setRasterizationScale:[UIScreen mainScreen].scale];
        //[self.layer setShouldRasterize:YES];
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
    //    [self setBackgroundView:(CellBackgroundView *) [[CellBackgroundView alloc] initWithFrame:self.bounds]];
    //    [[self backgroundView] setBackgroundColor:backgroundColor];
    //    [self setSelectedBackgroundView:[[UIView alloc] initWithFrame:self.bounds]];
    //    [[self selectedBackgroundView] setBackgroundColor:[UIColor clearColor]];
    
    // Remove subviews from previous usage of this cell
    //[[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.frame.size.height != kFeatureItemHeightOnlyLabel)
    {
        
        // Init the activity indicator
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        // Position and show the activity indicator
        [self.activityIndicator setCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
        [self.activityIndicator setHidesWhenStopped:YES];
        [self.activityIndicator startAnimating];
        [self.contentView addSubview: self.activityIndicator];
    }
}

// Setup Image View
- (void)setupImageWithImage:(UIImage *)image andLabel:(NSString *)label andLabelBackgroundColor:(UIColor*)labelBackgroundColor andFrame:(CGRect)imageViewFrame
{
    self.featureImageView.image = image;
    self.featureLabel.text = [label uppercaseString];
    self.featureLabel.textColor = [UIColor blackColor];
    [self.featureLabel setFont:[UIFont fontWithName:@"AvantGarde-Book" size:12]];
    [self.featureLabel setAdjustsFontSizeToFitWidth:YES];
    self.featureViewLabel.backgroundColor = labelBackgroundColor;
    
    // Hide the activity indicator
    if (self.activityIndicator != nil)
    {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview ];
    }
    else
    {
        //        NSLog(@"activity indicator nil %@", label);
    }
}


- (void)prepareForReuse
{
    self.featureImageView.image = nil;
    self.featureLabel.text = @"";
    self.featureViewLabel.backgroundColor = [UIColor whiteColor];
    if (self.activityIndicator != nil)
        [self.activityIndicator removeFromSuperview ];
    self.activityIndicator = nil;
    
    [super prepareForReuse];
    
    [self.zoomButton removeFromSuperview];
    self.zoomButton = nil;
    
}

// Setup Hanger Button
- (void)setupZoomButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame
{
    // Setup the hanger button
    
    self.zoomButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    [self.zoomButton setFrame:buttonFrame];
    [[self.zoomButton layer] setBorderWidth:kZoomButtonBorderWidth];
    [[self.zoomButton layer] setBorderColor:[UIColor kZoomButtonBorderColor].CGColor];
    [self.zoomButton setBackgroundColor:[UIColor clearColor]];
    [self.zoomButton setAlpha:0.6];
    [[self.zoomButton titleLabel] setFont:[UIFont fontWithName:@kFontInZoomButton size:kFontSizeInZoomButton]];
    [self.zoomButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.zoomButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.zoomButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    UIImage * buttonImage = [UIImage imageNamed:@"zoom_in.png"];
    
    if (buttonImage == nil)
    {
        [self.zoomButton setTitle:NSLocalizedString(@"_ZOOM_", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.zoomButton setImage:buttonImage forState:UIControlStateNormal];
        [self.zoomButton setImage:buttonImage forState:UIControlStateHighlighted];
        [[self.zoomButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    [self.zoomButton setTag:(int)(([indexPath indexAtPosition:0]*OFFSET)+([indexPath indexAtPosition:1]))];
    
    [self.contentView addSubview:self.zoomButton];
    [self.contentView bringSubviewToFront:self.zoomButton];
}


@end
