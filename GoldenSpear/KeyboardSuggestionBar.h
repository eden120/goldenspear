//
//  KeyboardSuggestionBar.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KeyboardSuggestionBarDataSource.h"
#import "KeyboardSuggestionBarDelegate.h"
#import "UIControl+KeyboardSuggestionBar.h"

@interface KeyboardSuggestionBar : NSObject

- (instancetype)initWithNumberOfSuggestionFields:(NSInteger)numberOfSuggestionFields;

- (BOOL)subscribeTextInputView:(UIControl<UITextInput> *)textInputView
toSuggestionsForAttributeNamed:(NSString *)attributeName
                 ofEntityNamed:(NSString *)entityName
                  inModelNamed:(NSString *)modelName;

- (NSRange)rangeOfRelevantContext;
- (void)textChanged:(UIControl<UITextInput> *)textInputView;

@property (nonatomic, weak) UIControl<UITextInput> *textInputView;
@property (nonatomic, weak) id<KeyboardSuggestionBarDataSource> dataSource;
@property (nonatomic, weak) id<KeyboardSuggestionBarDelegate> delegate;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *tileColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;

@end
