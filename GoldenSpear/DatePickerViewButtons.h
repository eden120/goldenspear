//
//  PickerViewButtons.h
//  GoldenSpear
//
//  Created by Alberto Seco on 5/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatePickerViewButtons;

@protocol DatePickerViewButtonsDelegate

- (void) datePickerButtonView:(DatePickerViewButtons *)datePickerView didButtonClick:(BOOL)bOk withDate:(NSDate*) date;
- (void) datePickerButtonView:(DatePickerViewButtons *)datePickerView changeDate: (NSDate*)date;

@end

//@interface DatePickerViewButtons : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
@interface DatePickerViewButtons : UIView

@property (nonatomic) UIDatePicker * pickerView;
@property (nonatomic) UIButton * btnOk;
@property (nonatomic) UIButton * btnCancel;

@property (nonatomic) NSArray * dataPicker;

-(void) setDate:(NSDate *)date;
-(void) updateFrame:(CGRect) Frame;

// Track delegate
@property (assign) id <DatePickerViewButtonsDelegate> delegate;

@end
