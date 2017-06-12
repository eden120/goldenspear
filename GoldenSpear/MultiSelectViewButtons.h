//
//  PickerViewButtons.h
//  GoldenSpear
//
//  Created by Alberto Seco on 5/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiSelectViewButtons;

@protocol MultiSelectViewButtonsDelegate

- (void) multiSelectButtonView:(MultiSelectViewButtons *)pickerView didButtonClick:(BOOL)bOk withSelected:(NSArray *) arSelected;
- (void) multiSelectButtonView:(MultiSelectViewButtons *)pickerView changeSelection:(NSArray *) arSelected;

@end

//@interface DatePickerViewButtons : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
@interface MultiSelectViewButtons : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView * tableView;
@property (nonatomic) UIButton * btnOk;
@property (nonatomic) UIButton * btnCancel;

@property (nonatomic) NSMutableArray * arElements;
@property (nonatomic) NSMutableArray * arElementsSelected;

-(void) setElements: (NSMutableArray *) elements;
-(void) setElementsSelected: (NSMutableArray *) elements;

-(void) updateFrame:(CGRect) Frame;

// Track delegate
@property (assign) id <MultiSelectViewButtonsDelegate> delegate;

@end
