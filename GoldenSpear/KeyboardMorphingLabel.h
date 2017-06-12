//
//  KeyboardMorphingLabel.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Morphing.h"

@interface KeyboardMorphingLabel : UILabel

@property (readonly, atomic, strong) NSString *targetText;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) CGFloat characterAnimationOffset;
@property (nonatomic, assign) CGFloat characterShrinkFactor;

@end
