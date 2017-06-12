//
//  VerticalSlideButtonView.h
//  GoldenSpear
//
//  Created by Alberto Seco on 30/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VerticalSlideButtonView;

// Set up a delegate to notify the view controller when the rating changes
@protocol VerticalSlideButtonViewDelegate

- (void)verticalSlideButtonView:(VerticalSlideButtonView *)verticalSlideButtonView btnClick:(int)buttonEntry;

@end

@interface VerticalSlideButtonView : UIView

@property (nonatomic) UIFont* font;
@property (nonatomic) UIFont* fontBold;

@property (nonatomic) int iHeightButton;

@property (nonatomic) BOOL bShowPointRight;
@property (nonatomic) int minWidthButton;
@property (nonatomic) int spaceBetweenButtons;
@property (nonatomic) int verticalSpaceBetweenButtons;
@property (nonatomic) int paddingButton;
@property (nonatomic) int leftMarginControl;
@property (nonatomic) int topMarginControl;

@property (nonatomic) UIColor* colorTextButtons;
@property (nonatomic) UIColor* colorSelectedTextButtons;
@property (nonatomic) BOOL bBoldSelected;
@property (nonatomic) UIColor* colorBackgroundButtons;
@property (nonatomic) UIColor* colorShadowButtons;
@property (nonatomic) float fShadowRadius;
@property (nonatomic) float alphaButtons;

@property (nonatomic) UIScrollView *buttonsScrollView;

// Track delegate
@property (assign) id <VerticalSlideButtonViewDelegate> delegate;

// Initialize the Slide Button View entries
- (void) initVerticalSlideButtonWithButtons:(NSMutableArray *) buttonsLabels andDelegate: (id <VerticalSlideButtonViewDelegate>)delegate;

// add new button
- (void) addButton:(NSString*)name;
// remove button
- (void) removeButton:(long) iIdxButtonToRemove;


/*
 *  PROTECTED FUNCTIONS
 */
- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;
- (IBAction)btnClick: (id)sender;
- (void)initSlideButtonView;

@end
