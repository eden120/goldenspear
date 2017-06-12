//
//  BaseViewController+KeyboardSuggestionBarManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 04/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "KeyboardSuggestionBar.h"

@interface BaseViewController (KeyboardSuggestionBarManagement) <KeyboardSuggestionBarDelegate, KeyboardSuggestionBarDataSource>

- (void)setupKeyboardSuggestionBarForTextField: (UITextField *)textField;
- (void)updateTextRangeWithText: (NSString *)text;
-(void) updateTextFieldWithText: (NSString *)text inRange:(NSRange)range;

@property KeyboardSuggestionBar *keyboardSuggestionBar;
@property NSMutableArray *textRange;

@end
