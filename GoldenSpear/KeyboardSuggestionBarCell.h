//
//  KeyboardSuggestionBarCell.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardMorphingLabel.h"

@class KeyboardSuggestionBarController;

@interface KeyboardSuggestionBarCell : UICollectionViewCell

@property (nonatomic, strong) KeyboardMorphingLabel *textLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) KeyboardSuggestionBarController *suggestionBarController;

@end
