//
//  ContentCell.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "ContentCell.h"
#import "CellBackgroundView.h"

#define kCellBackgroundColor clearColor
#define kCellBackgroundAlpha 1.0f
#define kCellBorderColor grayColor
#define kCellBorderWidth 0.0f
#define kCellShadowColor grayColor
#define kCellShadowRadius 0.0f
#define kCellShadowOffsetX 0.0f
#define kCellShadowOffsetY 0.0f
#define kCellShadowOpacity 0.0f
#define kCellNumberOfLinesInTitle 1
#define kCellFontSizeInTitle 12
#define kCellTitleBackgroundColor clearColor

@implementation ContentCell

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
    [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Init the activity indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // Position and show the activity indicator
    [self.activityIndicator setCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator startAnimating];
    [self.contentView addSubview: self.activityIndicator];
}

// Setup Image View
- (void)setupImageWithImage:(UIImage *)image andFrame:(CGRect)imageViewFrame
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [imageView setClipsToBounds:YES];
    
    [imageView setFrame:imageViewFrame];
    
    // Hide the activity indicator
    [self.activityIndicator stopAnimating];
    
    [self.contentView addSubview:imageView];
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    
}

@end
