//
//  PickerFilteredViewButtons.h
//  GoldenSpear
//
//  Created by Alberto Seco on 4/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//

#ifndef PickerFilteredViewButtons_h
#define PickerFilteredViewButtons_h

#import <UIKit/UIKit.h>
#import "UserEditProfileViewController.h"

@class PickerFilteredViewButtons;

@class UserEditProfileViewController;

@protocol PickerFilteredViewButtonsDelegate

- (void) pickerFilteredButtonView:(PickerFilteredViewButtons *)pickerView didButtonClick:(BOOL)bOk withSelected:(NSArray *) arSelected;
- (void) pickerFilteredButtonView:(PickerFilteredViewButtons *)pickerView changeSelection:(NSArray *) arSelected;

@end

//@interface DatePickerViewButtons : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
@interface PickerFilteredViewButtons : UIView <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) UserEditProfileViewController * ctrlBase;

@property (nonatomic) BOOL bNewQuery;
@property (nonatomic) BOOL  fixedElements;
@property (nonatomic) BOOL  multiSelect;
@property (nonatomic) UISearchBar * searchBar;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic) UITableView * tableView;
@property (nonatomic) UIButton * btnOk;
@property (nonatomic) UIButton * btnCancel;

@property (nonatomic) NSMutableArray * arElements;
@property (nonatomic) NSMutableArray * arElementsSelected;
@property (nonatomic) NSMutableArray * filteredElements;

-(void) setElements: (NSMutableArray *) elements;
-(void) setElementsSelected: (NSMutableArray *) elements;

-(void) updateFrame:(CGRect) Frame;

-(void) addElements:(NSMutableArray *) elements;

// Track delegate
@property (assign) id <PickerFilteredViewButtonsDelegate> delegate;

@end

#endif /* PickerFilteredViewButtons_h */
