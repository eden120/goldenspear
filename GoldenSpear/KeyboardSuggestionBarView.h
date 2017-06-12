//
//  KeyboardSuggestionBarView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kKeyboardSuggestionBarCellPadding 2.f


@class KeyboardSuggestionBarController;

@interface KeyboardSuggestionBarView : UICollectionView

- (instancetype)initWithFrame:(CGRect)frame
     numberOfSuggestionFields:(NSInteger)numberOfSuggestionFields;

@property (nonatomic, strong) KeyboardSuggestionBarController *suggestionBarController;
@property (nonatomic, assign) NSInteger numberOfSuggestionFields;
@property (nonatomic, strong) NSString *attributeName;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSString *modelName;

@end
