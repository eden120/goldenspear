//
//  GSSuggestionCell.m
//  GoldenSpear
//
//  Created by JCB on 8/23/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSuggestionCell.h"
#import "AppDelegate.h"

#define kFontInLabelText @"Avenir-Light"
#define kFontInLabelBoldText @"Avenir-Heavy"
#define kFontSizeInLabelText 16

@implementation GSSuggestionCell

- (void)prepareForReuse{
    [super prepareForReuse];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.followButton.clipsToBounds = YES;
    self.followButton.layer.cornerRadius = 5;
}


@end