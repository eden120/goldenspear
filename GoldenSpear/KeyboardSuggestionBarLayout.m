//
//  KeyboardSuggestionBarLayout.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "KeyboardSuggestionBarLayout.h"
#import "KeyboardSuggestionBarView.h"

@implementation KeyboardSuggestionBarLayout

- (instancetype)initWithFrame:(CGRect)frame
     numberOfSuggestionFields:(NSInteger)numberOfSuggestionFields
{
    self = [super init];
    if (self) {
        CGFloat width = (frame.size.width - (numberOfSuggestionFields - 1) * kKeyboardSuggestionBarCellPadding) / (CGFloat)numberOfSuggestionFields;
        self.itemSize = CGSizeMake(width, frame.size.height);
        self.minimumInteritemSpacing = kKeyboardSuggestionBarCellPadding;
    }
    return self;
}

@end
