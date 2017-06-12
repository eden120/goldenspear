//
//  KeyboardSuggestionBarController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "keyboardCoreDataCollectionViewController.h"

@class KeyboardSuggestionBarView;
@class KeyboardSuggestionBar;

@interface KeyboardSuggestionBarController : keyboardCoreDataCollectionViewController

- (instancetype)initWithSuggestionBarView:(KeyboardSuggestionBarView *)suggestionBarView;

- (void)suggestableTextDidChange:(NSString *)context;

- (void)didSelectSuggestionAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak) KeyboardSuggestionBar *suggestionBar;

@end
