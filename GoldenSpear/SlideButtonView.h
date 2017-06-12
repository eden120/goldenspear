//
//  SlideButtonView.h
//  ControlsGoldenSpear
//
//  Created by Alberto Seco on 21/4/15.
//  Copyright (c) 2015 com example. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductGroup+Manage.h"

typedef enum eButtonHighlightType
{
    NOHIGHLIGHT,
    HIGHLIGHT_TYPE,
    TAB_TYPE,
    UNDERLINE_TYPE
}ButtonHighlightType;

typedef enum eButtonType
{
    TEXT,
    IMAGE
}ButtonType;

@class SlideButtonView;
@class SlideButtonProperties;

// Set up a delegate to notify the view controller when the rating changes
@protocol SlideButtonViewDelegate

- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry;

@end

@interface SlideButtonView : UIView

@property (nonatomic) NSString* sNameButtonImage;
@property (nonatomic) NSString* sNameButtonImageHighlighted;

@property (nonatomic) UIFont* font;
@property (nonatomic) UIFont* fontBold;

@property (nonatomic) int minWidthButton;
@property (nonatomic) int spaceBetweenButtons;
@property (nonatomic) int paddingButton;
@property (nonatomic) int leftMarginControl;

@property (nonatomic) BOOL bShowPointRight;
@property (nonatomic) BOOL bUppercaseButtonsText;

@property (nonatomic) UIColor* colorTextButtons;
@property (nonatomic) UIColor* colorSelectedTextButtons;
@property (nonatomic) BOOL bBoldSelected;
@property (nonatomic) UIColor* colorBackground;
@property (nonatomic) UIColor* colorBackgroundButtons;
@property (nonatomic) UIColor* colorBackgroundSelectedButtons;
@property (nonatomic) UIColor* colorShadowButtons;
@property (nonatomic) float fShadowRadius;
@property (nonatomic) float alphaButtons;
@property (nonatomic) float borderWidthButtons;
@property (nonatomic) UIColor* colorBorderButtons;

@property (nonatomic) UIColor* colorUnderlineSelected;
@property (nonatomic) float heightUnderLine;
@property (nonatomic) float bottomMarginUnderline;

@property (nonatomic) UIColor* colorBorderView;
@property (nonatomic) float borderWidthView;

@property (nonatomic) BOOL bButtonsCentered;
@property (nonatomic) BOOL bButtonsDistributed;

@property (nonatomic) IBOutlet UIScrollView *buttonsScrollView;

@property (nonatomic) ButtonHighlightType typeSelection;

@property (nonatomic) BOOL bMultiselect;
@property (nonatomic) BOOL bUnselectWithClick;  // if TRUE when you click in a button it will be unselect, if FALSE, then not will be unselected

@property (nonatomic) BOOL bSeparator;
@property (nonatomic) UIColor* colorSeparator;
@property (nonatomic) float fHeightSeparator;
@property (nonatomic) float fWidthSeparator;
@property (nonatomic) BOOL bShowShadowsSides;
@property (nonatomic) float fTabHeight;


@property (nonatomic) NSMutableArray* arSelectedButtons;
@property (nonatomic) NSMutableArray* arrayButtons;
@property (nonatomic) NSMutableArray* arrayButtonsProperties;
@property (nonatomic) NSMutableArray* arNonCloseButtons;

@property (nonatomic) NSMutableArray* arLastSelectedButtons;
@property (nonatomic) NSMutableArray* arrayLastButtons;
@property (nonatomic) NSMutableArray* arrayLastButtonsProperties;
@property (nonatomic) NSMutableArray* arLastNonCloseButtons;

@property (nonatomic) ButtonType typeButton;

@property (nonatomic) NSObject * object;

// Track delegate
@property (assign) id <SlideButtonViewDelegate> delegate;

// Initialize the Slide Button View entries
- (void) initSlideButtonWithButtons:(NSMutableArray *) buttonsLabels andDelegate: (id <SlideButtonViewDelegate>)delegate;
- (void) setLastState;

- (NSUInteger) count;
// add new button
- (void) addButton:(NSString*)name;
- (void) addButtonWithObject:(NSObject *) objButton;
- (void) insertButtonWithObject:(NSObject *) objButton atIndex:(int)iIndex;
- (void) addButton:(NSString*)name withProperties:(SlideButtonProperties *)properties;
- (void) addButtonWithObject:(NSObject *) objButton withProperties:(SlideButtonProperties *)properties;;
- (void) insertButtonWithObject:(NSObject *) objButton withProperties:(SlideButtonProperties *)properties atIndex:(int)iIndex;
// remove button
- (void) removeButton:(int) iIdxButtonToRemove;
- (void) removeButtonByName:(NSString *) sNameButtonToRemove;
- (void) removeButtonByObject:(NSObject *) sObjectButtonToRemove;
- (void) removeAllButtons;
// change the text of the button
- (void) changeButtonText:(NSString *)sNewText atIndex:(int) iIdxButton;
- (void) changeButtonObject:(NSObject *)sNewText atIndex:(int) iIdxButton;
// check if the index of the button is selected
- (BOOL) isSelected:(int) iIdexButton;
- (NSString *) sGetNameButtonByIdx:(int) iIdxButton;
- (NSObject *) getObjectByIndex:(int) iIdxButton;
- (int) iGetIndexButtonByName:(NSString *) sName;

// Non Close buttons
- (void) initUnclosedButtons:(NSString*)sUnclosedButtons, ...;
- (void) initUnclosedButtonsWithArray:(NSMutableArray *) unclosedButtons;
- (void) addUnclosedButtonWithText:(NSString *) sButton;
- (void) removeUnclosedButtonByName:(NSString *) sButton;
- (void) removeAllUnclosedButtons;
- (bool) isButtonUnclosed:(NSString *) sButton;

// update the pos of the buttons
- (void) updateButtons;
- (void) updateContentSize;
- (void) selectButton:(int) idxButtonSelect;
- (void) forceSelectButton:(int) idxButtonSelect;
- (void) scrollToTheEnd;
- (void) scrollToTheBeginning;
- (void) scrollToButtonByIndex:(int) iIdxButton;
- (void) unselectButton:(int) idxButtonUnselect;
- (void) unselectButtons;
- (void) setClipsToBounds:(BOOL) bClips;
- (void) restoreLastState;
- (BOOL) sameFromLastState;


/*
 *  PROTECTED FUNCTIONS
 */
- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;
- (IBAction)btnClick: (id)sender;
- (void)initSlideButtonView;
- (void) createSeparator:(float) fPosParamX forIndex:(int)iIndex;

@end

@interface SlideButtonProperties: NSObject

@property (nonatomic) UIColor* colorTextButtons;
@property (nonatomic) UIColor* colorSelectedTextButtons;

@end