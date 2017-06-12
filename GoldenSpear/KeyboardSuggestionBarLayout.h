//
//  KeyboardSuggestionBarLayout.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardSuggestionBarLayout : UICollectionViewFlowLayout

- (instancetype)initWithFrame:(CGRect)frame
     numberOfSuggestionFields:(NSInteger)numberOfSuggestionFields;

@end
