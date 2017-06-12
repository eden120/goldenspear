//
//  KeyboardSuggestionBarCell.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "KeyboardSuggestionBarCell.h"
#import "KeyboardSuggestionBar.h"
#import "KeyboardSuggestionBarController.h"

@implementation KeyboardSuggestionBarCell

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self designatedInitialization];
    }
    return self;
}

- (void)designatedInitialization
{
    self.textLabel = [[KeyboardMorphingLabel alloc] initWithFrame:self.bounds];
    self.textLabel.textColor = self.tintColor;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.userInteractionEnabled = NO;
    
    [self addSubview:self.textLabel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(touchedUpInside)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)setSuggestionBarController:(KeyboardSuggestionBarController *)suggestionBarController
{
    _suggestionBarController = suggestionBarController;
    
    self.backgroundColor = self.suggestionBarController.suggestionBar.tileColor;
    self.tintColor = self.suggestionBarController.suggestionBar.textColor;
    self.textLabel.textColor = self.suggestionBarController.suggestionBar.textColor;
    self.textLabel.font = self.suggestionBarController.suggestionBar.font;
}

#pragma mark - Delegation

- (void)touchedUpInside
{
    [self.suggestionBarController didSelectSuggestionAtIndexPath:self.indexPath];
}

@end
