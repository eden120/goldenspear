//
//  PlaceHolderUITextView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 14/10/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceHolderUITextView : UITextView

@property(nonatomic, strong) NSString *placeholder;

@property (nonatomic, strong) UIColor *realTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *placeholderColor UI_APPEARANCE_SELECTOR;

@end
