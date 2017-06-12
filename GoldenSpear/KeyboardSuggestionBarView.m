//
//  KeyboardSuggestionBarView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "KeyboardSuggestionBarView.h"
#import "KeyboardSuggestionBarController.h"
#import "KeyboardSuggestionBarLayout.h"
#import "KeyboardSuggestionBarCell.h"
#import "KeyboardSuggestionBar.h"


@implementation KeyboardSuggestionBarView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
     numberOfSuggestionFields:(NSInteger)numberOfSuggestionFields
{
    KeyboardSuggestionBarLayout *suggestionBarLayout = [[KeyboardSuggestionBarLayout alloc] initWithFrame:frame
                                                                         numberOfSuggestionFields:numberOfSuggestionFields];
    self = [super initWithFrame:frame collectionViewLayout:suggestionBarLayout];
    if (self) {
        self.numberOfSuggestionFields = numberOfSuggestionFields;
        
        [self registerCellClasses];
        self.suggestionBarController = [[KeyboardSuggestionBarController alloc] initWithSuggestionBarView:self];
        self.delegate = self.suggestionBarController;
    }
    return self;
}

- (void)registerCellClasses
{
    static NSString * const cellIdentifier = @"kKeyboardSuggestionBarCell";
    for (int i = 0; i < self.numberOfSuggestionFields; ++i) {
        [self registerClass:[KeyboardSuggestionBarCell class] forCellWithReuseIdentifier:[cellIdentifier stringByAppendingFormat:@"_%d", i]];
    }
}

@end
