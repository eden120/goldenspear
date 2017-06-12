//
//  CollectionViewHeaderReusableView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 22/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "CollectionViewHeaderReusableView.h"
#import "UILabel+CustomCreation.h"


//#define kTitleBackgroundColor colorWithRed:0.95 green:0.80 blue:0.46 alpha:0.65
//#define kTitleTextColor darkGrayColor
#define kTitleBackgroundColor clearColor//darkGrayColor
#define kTitleTextColor whiteColor
#define kTitleAlpha 1.0
#define kDefaultText ""
#define kFontInTitle "Avenir-MediumOblique"
#define kFontSizeInTitle 16
#define kFontSizeInSubStyleTitle 12
#define kSubStyleTitleTextColor darkGrayColor


@implementation CollectionViewHeaderReusableView


#pragma mark - Accessors


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];

        // Setup the title label

        self.headerTitle = [UILabel createLabelWithOrigin:CGPointMake(0, 0)
                                                       andSize:CGSizeMake(self.frame.size.width,self.frame.size.height)
                                            andBackgroundColor:[UIColor kTitleBackgroundColor]
                                                      andAlpha:kTitleAlpha
                                                       andText:@kDefaultText
                                                  andTextColor:[UIColor kTitleTextColor]
                                                       andFont:[UIFont fontWithName:@kFontInTitle size:kFontSizeInTitle]
                                                andUppercasing:YES
                                                    andAligned:NSTextAlignmentCenter];
        
        UIImageView *headerBackground = [[UIImageView alloc] initWithFrame:self.headerTitle.frame];
                                         
        [headerBackground setImage:[UIImage imageNamed:@"SectionHeaderBackground.png"]];
        
        [headerBackground setContentMode:UIViewContentModeScaleAspectFill];

        [self addSubview:headerBackground];
        
        [self sendSubviewToBack:headerBackground];

        [self.headerTitle setNumberOfLines:2];
        
//        [self.headerTitle.layer setCornerRadius:5];
        
        [self addSubview:self.headerTitle];
    }
    
    return self;
}

- (void)setHeaderTitleText:(NSString*) titleText
{
    // Set the title text
    self.headerTitle.text = titleText;
}

- (void) setupSearchFeatureCellHeader:(NSString *)titleLabel
{
    for (UIView * view in self.subviews)
    {
        if (![view isKindOfClass:[UILabel class]])
        {
            [view removeFromSuperview];
        }
    }
    
    [self.headerTitle setNumberOfLines:1];
    [self.headerTitle setFont:[UIFont fontWithName:@kFontInTitle size:kFontSizeInSubStyleTitle]];
    self.headerTitle.textColor = [UIColor kSubStyleTitleTextColor];
    
    if (titleLabel != nil)
    {
        self.headerTitle.text = titleLabel;
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(self.headerTitle.frame.origin.x, self.headerTitle.frame.origin.y-1, self.headerTitle.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor kSubStyleTitleTextColor];
        [self addSubview:lineView];
    }
    else
    {
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(self.headerTitle.frame.origin.x, self.headerTitle.frame.origin.y/*+self.headerTitle.frame.size.height*/, self.headerTitle.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor kSubStyleTitleTextColor];
        [self addSubview:lineView];
    }
    
}

// Setter for title label text and properties
- (void)setHeaderTitleAppearanceWithBackgroundColor:(UIColor *)backgroundColor andFontType:(UIFont *)fontType andTextColor:(UIColor *)fontColor
{
    self.backgroundColor = backgroundColor;
    
    self.headerTitle.font = fontType;
    
    self.headerTitle.textColor = fontColor;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.headerTitle.text = nil;
}

@end
