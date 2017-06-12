//
//  MenuEntryView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "MenuEntryView.h"
#import "AppDelegate.h"

@implementation MenuEntryView

// Initialize variables to default values
- (void)initMainMenuView
{
    [self setBackgroundColor:[UIColor whiteColor]];

    if(self.menuEntryIcon == nil)
    {
        self.menuEntryIcon = [[UIImageView alloc] init];
        self.menuEntryIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.menuEntryIcon];
    }

    [self bringSubviewToFront:self.menuEntryIcon];

    if(self.menuEntryLabel == nil)
    {
        self.menuEntryLabel = [[UILabel alloc] init];
        [self addSubview:self.menuEntryLabel];
    }

    if(self.menuEntryButton == nil){
        self.menuEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.menuEntryButton];
    }
    
    [self bringSubviewToFront:self.menuEntryLabel];
    [self.menuEntryLabel setFont:[UIFont fontWithName:@"AvantGarde-Book" size:((IS_IPHONE_5_OR_LESS) ? (12) : (14))]];
    [self.menuEntryLabel setTextAlignment:NSTextAlignmentLeft];
    self.menuEntryLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.menuEntryLabel.numberOfLines = 1;

    [self.menuEntryLabel setTextColor:[UIColor darkGrayColor]];
    
    [self bringSubviewToFront:self.menuEntryButton];
}

// View controller can add the view programatically
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initMainMenuView];
    }
    
    return self;
}

// View controller can add the view via XIB
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initMainMenuView];
    }
    return self;
}

@end
