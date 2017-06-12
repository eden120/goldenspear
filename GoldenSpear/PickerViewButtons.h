//
//  PickerViewButtons.h
//  GoldenSpear
//
//  Created by Alberto Seco on 5/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PickerViewButtons;

@protocol PickerViewButtonsDelegate

- (void) pickerButtonView:(PickerViewButtons *)pickerView changeSelected:(NSInteger) iRow;
- (void) pickerButtonView:(PickerViewButtons *)pickerView didButtonClick:(BOOL)bOk withindex:(NSInteger) iRow;

@end

//@interface DatePickerViewButtons : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
@interface PickerViewButtons : UIView <UIPickerViewDelegate>

@property (nonatomic) UIPickerView * pickerView;
@property (nonatomic) UIButton * btnOk;
@property (nonatomic) UIButton * btnCancel;

@property (nonatomic) NSArray * arElements;

-(void) setElements: (NSMutableArray *) elements;
-(void) updateFrame:(CGRect) Frame;

// Track delegate
@property (assign) id <PickerViewButtonsDelegate> delegate;

@end
