//
//  SearchFeatureCell.m
//  GoldenSpear
//
//  Created by Alberto Seco on 31/7/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "SearchFeatureCell.h"
#import "AppDelegate.h"

#define kCellBackgroundColor whiteColor
#define kCellBackgroundAlpha 0.0f
#define kCellBorderColor whiteColor
#define kCellBorderWidth 0.0f
#define kCellShadowColor whiteColor
#define kCellShadowRadius 0.0f
#define kCellShadowOffsetX 0.0f
#define kCellShadowOffsetY 0.0f
#define kCellShadowOpacity 0.0f
#define kCellNumberOfLinesInTitle 1
#define kCellFontSizeInTitle 12
#define kCellTitleBackgroundColor whiteColor
#define kFeatureItemHeightOnlyLabel 22.0

#define kFontInZoomButton "Avenir-Heavy"
#define kFontSizeInZoomButton 10
#define kZoomButtonBorderWidth 0
#define kZoomButtonBorderColor darkGrayColor
#define kSearchFeatureZoomWidth 20
#define kSearchFeatureExpandWidth 35

#define OFFSET 100000

@implementation SearchFeatureCell

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
    [self setBackgroundColor:[UIColor kCellBackgroundColor]];
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
    self.featureImageView.backgroundColor = [UIColor whiteColor];
    self.featureImageView.image = image;
    
    float fRatio = 1;
    
    if(image.size.height > image.size.width)
    {
        fRatio = image.size.height / image.size.width;
    }
    else
    {
        fRatio = image.size.width / image.size.height;
    }
    
    if((fRatio - 1) > 0.1)
    {
        [self.featureImageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    else
    {
        [self.featureImageView setContentMode:UIViewContentModeScaleAspectFill];
    }

    self.featureLabel.textColor = [UIColor blackColor];
//    [self.featureLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:12]];
//    [self.featureLabel setAdjustsFontSizeToFitWidth:YES];
//    [self.featureLabel setMinimumScaleFactor:0.1];
//    [self.featureLabel setLineBreakMode:NSLineBreakByTruncatingTail];
//    self.featureLabel.text = label;//[label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    [self adaptTextToUILabel:label];
    
    self.featureViewLabel.backgroundColor = labelBackgroundColor;
    
    [self setBackgroundColor:self.featureViewLabel.backgroundColor];

    //self.featureViewLabel.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"FiltersRibbonButtonBackground.png"]];
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
    
    if (self.zoomButton != nil)
    {
        [self.zoomButton setImage:image forState:UIControlStateApplication];
        [self.zoomButton setTitle:self.featureLabel.text forState:UIControlStateApplication];
        
        CGRect buttonFrame = self.zoomButton.frame;
        
        buttonFrame.origin.x = self.featureImageView.frame.origin.x + self.featureImageView.frame.size.width - kSearchFeatureZoomWidth;
        
        [self.zoomButton setFrame:buttonFrame];
    }
    
    if (self.expandButton != nil)
    {
        CGRect buttonFrame = self.expandButton.frame;
        
//        buttonFrame.origin.y = self.featureViewLabel.frame.origin.y + (self.featureViewLabel.frame.size.height / 2.0) - (kSearchFeatureZoomWidth / 2.0);
        
        buttonFrame =self.featureViewLabel.frame;
        
        CGRect buttonFrameView =self.featureViewLabel.frame;
        buttonFrame.origin.y = buttonFrameView.origin.y + buttonFrameView.size.height / 2;
        buttonFrame.size.height = buttonFrameView.size.height / 2;
        
        [self.expandButton setFrame:buttonFrame];
    }
    

    
}

-(void) adaptTextToUILabel:(NSString *) sText
{
    int maxDesiredFontSize = 16;
    int minFontSize = 7;
    
    /// TO MAKE ALL LABELS FONT SIZE EQUAL:
    maxDesiredFontSize = ((IS_IPHONE_5_OR_LESS) ? (11) : (13));
    minFontSize = maxDesiredFontSize;
    
    CGFloat labelWidth = self.featureLabel.frame.size.width;
    CGFloat labelRequiredHeight = self.featureLabel.frame.size.height;
    //Create a string with the text we want to display.
//    self.ourText = @"This is your variable-length string. Assign it any way you want!";
    
    /* This is where we define the ideal font that the Label wants to use.
     Use the font you want to use and the largest font size you want to use. */
    UIFont *font = [UIFont fontWithName:@"AvantGarde-Book" size:maxDesiredFontSize];
    
    int i;
    /* Time to calculate the needed font size.
     This for loop starts at the largest font size, and decreases by two point sizes (i=i-2)
     Until it either hits a size that will fit or hits the minimum size we want to allow (i > 10) */
    for(i = maxDesiredFontSize; i > minFontSize; i=i-2)
    {
        // Set the new font size.
        font = [font fontWithSize:i];
        // You can log the size you're trying: NSLog(@"Trying size: %u", i);
        
        /* This step is important: We make a constraint box
         using only the fixed WIDTH of the UILabel. The height will
         be checked later. */
        CGSize constraintSize = CGSizeMake(labelWidth, MAXFLOAT);
        
        // This step checks how tall the label would be with the desired font.
        CGRect textRect = [sText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        CGSize labelSize = CGSizeMake(textRect.size.width, textRect.size.height);
//        CGSize labelSize = [sText sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
        /* Here is where you use the height requirement!
         Set the value in the if statement to the height of your UILabel
         If the label fits into your required height, it will break the loop
         and use that font size. */
        if(labelSize.height <= labelRequiredHeight)
            break;
    }
    // You can see what size the function is using by outputting: NSLog(@"Best size is: %u", i);
    
    // Set the UILabel's font to the newly adjusted font.
    self.featureLabel.font = font;
    self.featureLabel.text = sText;
//    msg.font = font;
//    
//    // Put the text into the UILabel outlet variable.
//    msg.text = self.ourText;
}


- (void)prepareForReuse
{
    self.featureImageView.image = nil;
    self.featureLabel.text = @"";
    self.featureViewLabel.backgroundColor = [UIColor clearColor];
    [self setBackgroundColor:[UIColor kCellBackgroundColor]];
    if (self.activityIndicator != nil)
        [self.activityIndicator removeFromSuperview ];
    self.activityIndicator = nil;
    [super prepareForReuse];
    
    
    [self.zoomButton removeFromSuperview];
    self.zoomButton = nil;
    
    [self.expandButton removeFromSuperview];
    self.expandButton = nil;
    
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
//    [self.zoomButton setAlpha:0.6];
    [[self.zoomButton titleLabel] setFont:[UIFont fontWithName:@kFontInZoomButton size:kFontSizeInZoomButton]];
    [self.zoomButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.zoomButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.zoomButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    
    
    UIImage * buttonImage = [UIImage imageNamed:@"Expand.png"];
    
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

- (void)setupExpandButtonAtIndexPath:(NSIndexPath *)indexPath inFrame:(CGRect)buttonFrame expanded:(BOOL) bExpanded
{
    // Setup the hanger button
    
    self.expandButton = [[UIButton alloc] initWithFrame:buttonFrame];
    
    // Button appearance
    CGRect buttonFrameView =self.featureViewLabel.frame;
    buttonFrameView.origin.y = buttonFrameView.origin.y + buttonFrameView.size.height / 2;
    buttonFrameView.size.height = buttonFrameView.size.height / 2;
    [self.expandButton setFrame:buttonFrameView];
//    [self.expandButton setFrame:buttonFrame];
    [[self.expandButton layer] setBorderWidth:kZoomButtonBorderWidth];
    [[self.expandButton layer] setBorderColor:[UIColor kZoomButtonBorderColor].CGColor];
    [self.expandButton setBackgroundColor:[UIColor clearColor]];
    [self.expandButton setAlpha:0.6];
    [[self.expandButton titleLabel] setFont:[UIFont fontWithName:@kFontInZoomButton size:kFontSizeInZoomButton]];
    [self.expandButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    UIColor * goldenColor = [UIColor colorWithRed:178.0/255.0 green:145.0/255.0 blue:68.0/255.0 alpha:0.95];
    [self.expandButton setTitleColor:goldenColor forState:UIControlStateNormal];

    [self.expandButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self.expandButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [self.expandButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
    [self.expandButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 5.0, 0.0)];
//    UIImage * buttonImage = [UIImage imageNamed:@""];
//    [self.expandButton setTitle:@" - SEE STYLES -" forState:UIControlStateNormal];
//    
//    if (bExpanded)
//    {
//        [self.expandButton setTitle:@" - HIDE STYLES -" forState:UIControlStateNormal];
////        buttonImage = [UIImage imageNamed:@"HierarchyClose.png"];
//    }
    
//    if (buttonImage == nil)
    {
        if(!bExpanded)
        {
            [self.expandButton setTitle:NSLocalizedString(@"_EXPAND_", nil) forState:UIControlStateNormal];
        }
        else
        {
            [self.expandButton setTitle:NSLocalizedString(@"_COLLAPSE_", nil) forState:UIControlStateNormal];
        }
    }
//    else
//    {
//        [self.expandButton setImage:buttonImage forState:UIControlStateNormal];
//        [self.expandButton setImage:buttonImage forState:UIControlStateHighlighted];
//        [[self.expandButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
//    }
    
    [self.expandButton setTag:(int)((indexPath.section*OFFSET)+indexPath.item)];
    
    [self.contentView addSubview:self.expandButton];
    [self.contentView bringSubviewToFront:self.expandButton];
}



@end
