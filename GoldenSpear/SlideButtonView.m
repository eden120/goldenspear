//
//  SlideButtonView.m
//  ControlsGoldenSpear
//
//  Created by Alberto Seco on 21/4/15.
//  Copyright (c) 2015 com example. All rights reserved.
//

#import "SlideButtonView.h"
#import "UIView+Shadow.h"
#import "UIImage+ImageCache.h"
#import "NSObject+ButtonSlideView.h"
#import "AppDelegate.h"

#define kDefaultFontSize 16
#define kDefaultMinWidthButton 10
#define kDefaultPaddingButton 5

@implementation SlideButtonView
{
    UIFont *            _fontDefault;
    UIFont *            _fontDefaultBold;
    float fPosX;
    BOOL                _bShadowsAlreadyCreated;
    
    UIView *            _shadowLeft;
    UIView *            _shadowRight;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// Initialize variables to default values
- (void)initSlideButtonView
{
    
    _typeButton = TEXT;
    
    _fontDefault = [UIFont fontWithName:@"Avenir-Medium" size:kDefaultFontSize];
    _fontDefaultBold = [UIFont fontWithName:@"Avenir-Black" size:kDefaultFontSize];
//    _colorTextButtons = [UIColor blackColor];
//    _colorSelectedTextButtons = [UIColor blackColor];
    _colorTextButtons = [UIColor whiteColor];
    _colorSelectedTextButtons = [UIColor whiteColor];
    _colorBackgroundSelectedButtons = [UIColor clearColor];
    //_colorUnderlineSelected = [UIColor blackColor];
    _colorUnderlineSelected = [UIColor whiteColor];
    _minWidthButton = kDefaultMinWidthButton;
    _spaceBetweenButtons = 0;
    _paddingButton = kDefaultPaddingButton;
    _fShadowRadius = 0.0;
    _leftMarginControl = _fShadowRadius * 2;
    
    _typeSelection = NOHIGHLIGHT;
    
    _arrayButtons = [[NSMutableArray alloc] init];
    _arrayLastButtons = nil;
    _arrayButtonsProperties = [[NSMutableArray alloc] init];
    _arrayLastButtonsProperties = nil;
    _delegate = nil;
    
    _arNonCloseButtons = nil;
    
    _arSelectedButtons = [[NSMutableArray alloc] init];
    _arLastSelectedButtons = nil;
    _bMultiselect = NO;
    _bUnselectWithClick = YES;
    _bSeparator = NO;
    //_colorSeparator = [UIColor blackColor];
    _colorSeparator = [UIColor whiteColor];
    
    _bButtonsCentered = YES;
    _bButtonsDistributed = NO;
    
    _bShowShadowsSides = NO;
    _bShadowsAlreadyCreated = NO;
    
    _heightUnderLine = 5;
    _bottomMarginUnderline = 2;
    
    _borderWidthButtons = 0.0;
    _colorBackground = [UIColor clearColor];
    _colorBorderButtons = [UIColor clearColor];
    _colorBackgroundButtons = [UIColor whiteColor];
    //_colorShadowButtons = [UIColor blackColor];
    _colorShadowButtons = [UIColor whiteColor];
    _alphaButtons = 1.0;
    
    _colorBorderView = [UIColor clearColor];
    _borderWidthView = 0.0;
    
    _fHeightSeparator = -1.0;
    _fWidthSeparator = 0.5;
    
    _bBoldSelected = NO;
    _fTabHeight = 0.8;
    
    _bUppercaseButtonsText = NO;
    
    [self setUserInteractionEnabled:YES];
}


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initSlideButtonView];
        
        CGRect rect = frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        self.buttonsScrollView = [[UIScrollView alloc] initWithFrame:rect];
        self.buttonsScrollView.showsVerticalScrollIndicator=NO;
        self.buttonsScrollView.showsHorizontalScrollIndicator=NO;
        self.buttonsScrollView.userInteractionEnabled=YES;
        self.buttonsScrollView.scrollEnabled=YES;
        self.buttonsScrollView.layer.borderColor = _colorBorderView.CGColor;
        self.buttonsScrollView.layer.borderWidth = _borderWidthView;
        self.clipsToBounds = YES;
        [self addSubview:self.buttonsScrollView];
    }
    
    return self;
}

// View controller can add the view via XIB
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initSlideButtonView];
    }
    return self;
}

// Initialize the Slide Button View entries
- (void) initSlideButtonWithButtons:(NSMutableArray *) buttonsLabels andDelegate: (id <SlideButtonViewDelegate>)delegate
{
    [self setDelegate:delegate];

    [self setLastState];
    // Add new menu entries
    // looping through the button, adding the buttons to the view

    [_arSelectedButtons removeAllObjects];
    [_arrayButtons removeAllObjects];
    [_arrayButtons addObjectsFromArray:buttonsLabels];
    for (NSString * slabel in _arrayButtons)
    {
        [_arrayButtonsProperties addObject:[NSNull null]];
    }
//    _arrayButtons = [buttonsLabels copy];
    [self updateButtons];
    
}

-(void) setLastState
{
    _arLastSelectedButtons = [[NSMutableArray alloc] initWithArray:_arSelectedButtons];
    _arrayLastButtons = [[NSMutableArray alloc] initWithArray:_arrayButtons];
    _arrayLastButtonsProperties = [[NSMutableArray alloc] initWithArray:_arrayButtonsProperties];
    _arLastNonCloseButtons =  [[NSMutableArray alloc] initWithArray:_arNonCloseButtons];
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.buttonsScrollView.frame = frame;

//    [self updateButtons];
    
}

- (void) restoreLastState
{
    if (_arrayLastButtons != nil)
    {
        [_arSelectedButtons removeAllObjects];
        [_arrayButtons removeAllObjects];
        [_arrayButtonsProperties removeAllObjects];
        [_arNonCloseButtons removeAllObjects];
        
        [_arrayButtons addObjectsFromArray:_arrayLastButtons];
        [_arSelectedButtons addObjectsFromArray:_arLastSelectedButtons];
        [_arrayButtonsProperties addObjectsFromArray:_arrayLastButtonsProperties];
        [_arNonCloseButtons addObjectsFromArray:_arLastNonCloseButtons];
        
        [_arrayLastButtons removeAllObjects];
        _arrayLastButtons = nil;
        [_arLastSelectedButtons removeAllObjects];
        _arLastSelectedButtons = nil;
        [_arrayLastButtonsProperties removeAllObjects];
        _arrayLastButtonsProperties = nil;
        [_arLastNonCloseButtons removeAllObjects];
        _arLastNonCloseButtons = nil;
        
        [self updateButtons];
    }
}

-(BOOL) sameFromLastState
{
    unsigned long iCountCurrent = [_arrayButtons count];
    unsigned long iCountLastState = [_arrayLastButtons count];
    
    if (iCountCurrent == iCountLastState)
    {
        for(int iIdx = 0; iIdx < iCountCurrent; iIdx ++)
        {
            NSString * sNameCurrent = [self sGetNameButtonByIdx:iIdx];
            NSString * sNameCurrentTrimmed = [[sNameCurrent.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:NSLocalizedString(@"_SEARCHTERM_SEPARATOR_", nil) withString:@""];
            BOOL bFound = NO;
            for (int jIdx = 0; jIdx < iCountLastState; jIdx++)
            {
                NSString * sNameLast = [self sGetNameButtonByIdxLast:jIdx];
                NSString * sNameLastTrimmed = [[sNameLast.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:NSLocalizedString(@"_SEARCHTERM_SEPARATOR_", nil) withString:@""];
                if ([sNameCurrentTrimmed isEqualToString:sNameLastTrimmed] == YES)
                {
                    bFound = YES;
                    break;
                }
                    
            }
            if (bFound == NO)
                return NO;
            
        }
//        for (NSObject * obj in _arrayButtons)
//        {
//            
//            if ([_arrayLastButtons containsObject:obj] == NO)
//            {
//                return NO;
//            }
//        }
        
        return YES;
    }
    
    return NO;
}

- (void) setClipsToBounds:(BOOL) bClips
{
    self.buttonsScrollView.clipsToBounds = bClips;
//    self.clipsToBounds = bClips;
}

- (NSUInteger) count
{
    return [_arrayButtons count];
}

- (void) addButton:(NSString*)name
{
    [_arrayButtons addObject:name];
    [_arrayButtonsProperties addObject:[NSNull null]];
    
    [self updateButtons];
}

- (void) addButtonWithObject:(NSObject *) objButton
{
    [_arrayButtons addObject:objButton];
    [_arrayButtonsProperties addObject:[NSNull null]];
    [self updateButtons];
}

- (void) insertButtonWithObject:(NSObject *) objButton atIndex:(int)iIndex
{
    [_arrayButtons insertObject:objButton atIndex:iIndex];
    [_arrayButtonsProperties insertObject:[NSNull null] atIndex:iIndex];
    [self updateButtons];
}


- (void) addButton:(NSString*)name withProperties:(SlideButtonProperties *)properties
{

    [_arrayButtons addObject:name];
    if (properties == nil)
        [_arrayButtonsProperties addObject:[NSNull null]];
    else
        [_arrayButtonsProperties addObject:properties];
    [self updateButtons];
    
}

- (void) addButtonWithObject:(NSObject *) objButton withProperties:(SlideButtonProperties *)properties
{
    [_arrayButtons addObject:objButton];
    if (properties == nil)
        [_arrayButtonsProperties addObject:[NSNull null]];
    else
        [_arrayButtonsProperties addObject:properties];
    [self updateButtons];
}

- (void) insertButtonWithObject:(NSObject *) objButton withProperties:(SlideButtonProperties *)properties atIndex:(int)iIndex
{
    [_arrayButtons insertObject:objButton atIndex:iIndex];
    if (properties == nil)
        [_arrayButtonsProperties insertObject:[NSNull null] atIndex:iIndex];
    else
        [_arrayButtonsProperties insertObject:properties atIndex:iIndex];
    
    [self updateButtons];
}

- (NSString *) sGetNameButtonByIdx:(int) iIdxButton
{
    if (iIdxButton < [_arrayButtons count])
    {
        NSString * sButton = @"";
        if ([_arrayButtons[iIdxButton] isKindOfClass:[NSString class]])
        {
            sButton = (NSString*) _arrayButtons[iIdxButton];
        }
        else if ([_arrayButtons[iIdxButton] isKindOfClass:[NSObject class]])
        {
            sButton = [((NSObject*) _arrayButtons[iIdxButton]) toStringButtonSlideView];
        }
        
        return sButton;
    }
    
    return @"";
}
- (NSString *) sGetNameButtonByIdxLast:(int) iIdxButton
{
    if (iIdxButton < [_arrayLastButtons count])
    {
        NSString * sButton = @"";
        if ([_arrayLastButtons[iIdxButton] isKindOfClass:[NSString class]])
        {
            sButton = (NSString*) _arrayLastButtons[iIdxButton];
        }
        else if ([_arrayLastButtons[iIdxButton] isKindOfClass:[NSObject class]])
        {
            sButton = [((NSObject*) _arrayLastButtons[iIdxButton]) toStringButtonSlideView];
        }
        
        return sButton;
    }
    
    return @"";
}

- (NSObject *) getObjectByIndex:(int) iIdxButton
{
    if (iIdxButton < [_arrayButtons count])
    {
        if (![_arrayButtons[iIdxButton] isKindOfClass:[NSString class]])
        {
            if ([_arrayButtons[iIdxButton] isKindOfClass:[NSObject class]])
            {
                return ((NSObject*) _arrayButtons[iIdxButton]);
            }
        }
    }
    
    return nil;
}

- (int) iGetIndexButtonByName:(NSString *) sName
{
    // search the button with the name
    int iIdxButton = 0;
    // loop through all the button calculating the total width
    //    for (NSString * sNameButton in _arrayButtons)
    //    {
    for( NSObject *objButton in _arrayButtons)
    {
        NSString * sNameButton;
        if ([objButton isKindOfClass:[NSString class]])
        {
            sNameButton = (NSString*) objButton;
        }
        else if ([objButton isKindOfClass:[NSObject class]])
        {
            sNameButton = [((NSObject*) objButton) toStringButtonSlideView];
        }
        else{
            continue;
        }
        if ([sNameButton isEqualToString:sName])
        {
            return iIdxButton;
        }
        iIdxButton++;
    }
    
    return -1;
}

- (void) removeButton:(int) iIdxButtonToRemove
{
    if ((iIdxButtonToRemove >= 0) && (iIdxButtonToRemove < [_arrayButtons count]))
    {
        // before rmeove, we must manage the selected items
        // looping through the selected button, if the index is greater than the parameter, then we must substract 1
        int iIdxSelected;
        int iIdx = 0;
        int iIdxSelectedToRemove = -1;
        
        // nos copiamos el array para poder modificar el array final
        NSMutableArray* copySelected = [NSMutableArray arrayWithArray:_arSelectedButtons];
        
        for(NSNumber *nsnIdxSelected in copySelected)
        {
            iIdxSelected = nsnIdxSelected.intValue;
            if (iIdxSelected > iIdxButtonToRemove)
            {
                iIdxSelected--;
                NSNumber* nsnNewNumber = [NSNumber numberWithInt:iIdxSelected];
                [_arSelectedButtons replaceObjectAtIndex:iIdx withObject:nsnNewNumber];
                // the item in the array is update in this way? if not, qe must to create a temporal array of selected, and at the end assign the new array as the selected
            }
            else if (iIdxSelected == iIdxButtonToRemove)
            {
                // remove item from the selected
                iIdxSelectedToRemove= iIdx;
            }
            iIdx ++;
        }
        
        if (iIdxSelectedToRemove != -1)
            [_arSelectedButtons removeObjectAtIndex:iIdxSelectedToRemove];
        
        [_arrayButtons removeObjectAtIndex:iIdxButtonToRemove];
        [_arrayButtonsProperties removeObjectAtIndex:iIdxButtonToRemove];
        [self updateButtons];
    }
}

- (void) removeButtonByName:(NSString *) sNameButtonToRemove
{
    // search the button with the name
    int iIdxButtonToRemove = 0;
    BOOL bFound = NO;
    // loop through all the button calculating the total width
//    for (NSString * sNameButton in _arrayButtons)
//    {
    for( NSObject *objButton in _arrayButtons)
    {
        NSString * sNameButton;
        if ([objButton isKindOfClass:[NSString class]])
        {
            sNameButton = (NSString*) objButton;
        }
        else if ([objButton isKindOfClass:[NSObject class]])
        {
            sNameButton = [((NSObject*) objButton) toStringButtonSlideView];
        }
        else{
            continue;
        }
        if ([sNameButton isEqualToString:sNameButtonToRemove])
        {
            [_arrayButtons removeObject:sNameButton];
            [_arrayButtonsProperties removeObjectAtIndex:iIdxButtonToRemove];
            bFound = YES;
            break;
        }
        iIdxButtonToRemove++;
    }
    
    // remove if the item is selected
    if (bFound)
    {
        // before rmeove, we must manage the selected items
        // looping through the selected button, if the index is greater than the parameter, then we must substract 1
        int iIdxSelected;
        int iIdx = 0;
        int iIdxSelectedToRemove = -1;
        
        // nos copiamos el array para poder modificar el array final
        NSMutableArray* copySelected = [NSMutableArray arrayWithArray:_arSelectedButtons];
        
        for(NSNumber *nsnIdxSelected in copySelected)
        {
            iIdxSelected = nsnIdxSelected.intValue;
            if (iIdxSelected > iIdxButtonToRemove)
            {
                iIdxSelected--;
                NSNumber* nsnNewNumber = [NSNumber numberWithInt:iIdxSelected];
                [_arSelectedButtons replaceObjectAtIndex:iIdx withObject:nsnNewNumber];
                // the item in the array is update in this way? if not, qe must to create a temporal array of selected, and at the end assign the new array as the selected
            }
            else if (iIdxSelected == iIdxButtonToRemove)
            {
                // remove item from the selected
                iIdxSelectedToRemove= iIdx;
            }
            iIdx ++;
        }
        
        if (iIdxSelectedToRemove != -1)
            [_arSelectedButtons removeObjectAtIndex:iIdxSelectedToRemove];
    }
    
    [self updateButtons];
    
}

- (void) removeButtonByObject:(NSObject *) sObjectButtonToRemove
{
    // search the button with the name
    int iIdxButtonToRemove = 0;
    BOOL bFound = NO;
    // loop through all the button calculating the total width
    //    for (NSString * sNameButton in _arrayButtons)
    //    {
    for( NSObject *objButton in _arrayButtons)
    {
        if (objButton == sObjectButtonToRemove)
        {
            [_arrayButtons removeObject:sObjectButtonToRemove];
            [_arrayButtonsProperties removeObjectAtIndex:iIdxButtonToRemove];
            bFound = YES;
            break;
        }
        iIdxButtonToRemove++;
    }
    
    // remove if the item is selected
    if (bFound)
    {
        // before rmeove, we must manage the selected items
        // looping through the selected button, if the index is greater than the parameter, then we must substract 1
        int iIdxSelected;
        int iIdx = 0;
        int iIdxSelectedToRemove = -1;
        
        // nos copiamos el array para poder modificar el array final
        NSMutableArray* copySelected = [NSMutableArray arrayWithArray:_arSelectedButtons];
        
        for(NSNumber *nsnIdxSelected in copySelected)
        {
            iIdxSelected = nsnIdxSelected.intValue;
            if (iIdxSelected > iIdxButtonToRemove)
            {
                iIdxSelected--;
                NSNumber* nsnNewNumber = [NSNumber numberWithInt:iIdxSelected];
                [_arSelectedButtons replaceObjectAtIndex:iIdx withObject:nsnNewNumber];
                // the item in the array is update in this way? if not, qe must to create a temporal array of selected, and at the end assign the new array as the selected
            }
            else if (iIdxSelected == iIdxButtonToRemove)
            {
                // remove item from the selected
                iIdxSelectedToRemove= iIdx;
            }
            iIdx ++;
        }
        
        if (iIdxSelectedToRemove != -1)
            [_arSelectedButtons removeObjectAtIndex:iIdxSelectedToRemove];
    }
    
    [self updateButtons];
    
}

- (void) removeAllButtons
{
    [_arrayLastButtons removeAllObjects];
    [_arrayButtons removeAllObjects];
    [self updateButtons];
}

- (void) changeButtonText:(NSString *)sNewText atIndex:(int) iIdxButton
{
    if ((iIdxButton < [_arrayButtons count]) && (iIdxButton >= 0))
    {
        if ([_arrayButtons[iIdxButton] isKindOfClass:[NSString class]])
        {
            _arrayButtons[iIdxButton] = sNewText;
        }
//        _arrayButtons[iIdxButton] = sNewText;
        [self updateButtons];
    }
}

- (void) changeButtonObject:(NSObject *)sNewObject atIndex:(int) iIdxButton
{
    if ((iIdxButton < [_arrayButtons count]) && (iIdxButton >= 0))
    {
        if ([_arrayButtons[iIdxButton] isKindOfClass:[NSObject class]])
        {
            _arrayButtons[iIdxButton] = sNewObject;
        }
        [self updateButtons];
    }
}


- (void) updateButtons
{
    // clean all the views of the scroll view
    for (UIView *view in self.buttonsScrollView.subviews)
    {
        [view removeFromSuperview];
    }

    // get the font for the buttons
    UIFont * fontStringButtons;
    if (_font != nil)
        fontStringButtons = _font;
    else
        fontStringButtons = _fontDefault;
    UIFont * fontStringButtonsBold;
    if (_fontBold != nil)
        fontStringButtonsBold = _fontBold;
    else
        fontStringButtonsBold = _fontDefaultBold;
    
    // load the image for the button
    UIImage * imgNormal;
    UIEdgeInsets edgeNormal;
    if (_sNameButtonImage != nil)
    {
        imgNormal = [UIImage imageNamed:_sNameButtonImage];
        edgeNormal.left = ((imgNormal.size.width) / 2) - 1;
        edgeNormal.right = ((imgNormal.size.width) / 2) + 1;
        edgeNormal.top = ((imgNormal.size.height) / 2) - 1;
        edgeNormal.bottom = ((imgNormal.size.height) / 2) + 1;
        imgNormal = [imgNormal resizableImageWithCapInsets:edgeNormal];
    }
    UIImage * imgHighlighted;
    UIEdgeInsets edgeHighlighted;
    if (_sNameButtonImageHighlighted != nil)
    {
        imgHighlighted = [UIImage imageNamed:_sNameButtonImageHighlighted];
        edgeHighlighted.left = ((imgNormal.size.width) / 2) - 1;
        edgeHighlighted.right = ((imgNormal.size.width) / 2) + 1;
        edgeHighlighted.top = ((imgNormal.size.height) / 2) - 1;
        edgeHighlighted.bottom = ((imgNormal.size.height) / 2) + 1;
        imgHighlighted = [imgHighlighted resizableImageWithCapInsets:edgeHighlighted];
    }
    
    // init variable for the loop
     fPosX = _leftMarginControl;
    // get the total width of the buttons
    float fTotalWidthButton = [self fGetTotalWidth:fontStringButtons];
    float fWidthScrollView = self.buttonsScrollView.frame.size.width; //(IS_IPHONE_6P ? 16 : 8);
    NSMutableArray * arWidthButtons = nil;
    if ((fTotalWidthButton < fWidthScrollView) && (_bButtonsDistributed))
    {
        
        NSArray *sortedArray;
        sortedArray = [_arrayButtons sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSObject *first = (NSObject*)a;
            NSObject *second = (NSObject*)b;
            float fWidth1 = [self fGetWidth:first withFont:fontStringButtons];
            float fWidth2 = [self fGetWidth:second withFont:fontStringButtons];
            return (fWidth1 < fWidth2);
        }];
        
        int iIdxButton = 1;
        float fCurrentWidth = fWidthScrollView / [_arrayButtons count];
        NSLog(@"Distributed TotalWidth: %f. TotalButtons : %f CurrentWidth: %f", fWidthScrollView, fTotalWidthButton, fCurrentWidth);
        arWidthButtons = [[NSMutableArray alloc] initWithArray:_arrayButtons];
        for( NSObject *objButton in sortedArray)
        {
            float fWidth = [self fGetWidth:objButton withFont:fontStringButtons];
            
            int iIdxButtonOriginal = 0;
            BOOL bFound = NO;
            for (NSObject * btn2 in _arrayButtons)
            {
                if (btn2 == objButton)
                {
                    bFound = YES;
                    break;
                }
                iIdxButtonOriginal++;
            }
            if (bFound)
            {
                if (fWidth > fCurrentWidth)
                {
                    [arWidthButtons replaceObjectAtIndex:iIdxButtonOriginal withObject:[NSNumber numberWithFloat:fWidth]];
                    fWidthScrollView -= fWidth;
                    fCurrentWidth = fWidthScrollView / ([_arrayButtons count] - iIdxButton);
                    NSLog(@"NEW Distributed TotalWidth: %f. TotalButtons : %f CurrentWidth: %f", fWidthScrollView, fTotalWidthButton, fCurrentWidth);
                }
                else
                {
                    [arWidthButtons replaceObjectAtIndex:iIdxButtonOriginal withObject:[NSNumber numberWithFloat:fCurrentWidth]];
                }
            }
            
            iIdxButton++;
            
        }
        
        for(NSNumber * num in arWidthButtons)
        {
            NSLog(@"Array: %f", [num floatValue]);
        }
        
    }
    else if ((fTotalWidthButton < fWidthScrollView) && (_bButtonsCentered))
    {
        fPosX = (fWidthScrollView / 2) - (fTotalWidthButton / 2);
    }

//    NSLog(@"SlideButtonView. updatebuttons. fPosX: %f", fPosX);

    // fill the begining
    [self fillBegining:fPosX];

    // looping through the button, adding the buttons to the view
    int iIndex = 0;
    for( NSObject *objButton in _arrayButtons)
    {
        SlideButtonProperties * prop = nil;
        if (_arrayButtonsProperties != nil)
        {
            prop = [_arrayButtonsProperties objectAtIndex:iIndex];
        }
        
        NSNumber * widthButton = nil;
        if (arWidthButtons != nil)
        {
            widthButton = [arWidthButtons objectAtIndex:iIndex];
        }
        
        UIButton * btn;
        if ([objButton isKindOfClass:[NSString class]])
        {
            if ((prop == nil) || ([prop isKindOfClass:[NSNull class]]))
            {
                // create the button
                btn = [self createButton: (NSString *)objButton
                                   index: iIndex
                                    posX: fPosX
                                    font: fontStringButtons
                                fontBold: fontStringButtonsBold
                             imageNormal: imgNormal
                        imageHighlighted: imgHighlighted
                         withWidthButton: widthButton];
            }
            else
            {
                // create the button
                btn = [self createButton: (NSString *)objButton
                                   index: iIndex
                                    posX: fPosX
                                    font: fontStringButtons
                                fontBold: fontStringButtonsBold
                             imageNormal: imgNormal
                        imageHighlighted: imgHighlighted
                               colorText: prop.colorTextButtons
                       colorTextSelected: prop.colorSelectedTextButtons
                  colorBackgroundButtons: self.colorBackgroundButtons
                              pointRight: self.bShowPointRight
                            alphaButtons: self.alphaButtons
                         withWidthButton: widthButton];
            }
        }
        else if ([objButton isKindOfClass:[NSObject class]])
        {
            if ((prop == nil) || ([prop isKindOfClass:[NSNull class]]))
            {
                btn = [self createButton: [((NSObject *)objButton) toStringButtonSlideView]
                                   index: iIndex
                                    posX: fPosX
                                    font: fontStringButtons
                                fontBold: fontStringButtonsBold
                             imageNormal: imgNormal
                        imageHighlighted: imgHighlighted
                         withWidthButton: widthButton];
            }
            else
            {
                // create the button
                btn = [self createButton: [((NSObject *)objButton) toStringButtonSlideView]
                                   index: iIndex
                                    posX: fPosX
                                    font: fontStringButtons
                                fontBold: fontStringButtonsBold
                             imageNormal: imgNormal
                        imageHighlighted: imgHighlighted
                               colorText: prop.colorTextButtons
                       colorTextSelected: prop.colorSelectedTextButtons
                  colorBackgroundButtons: self.colorBackgroundButtons
                              pointRight: self.bShowPointRight
                            alphaButtons: self.alphaButtons
                         withWidthButton: widthButton];
            }
        }
        else{
            continue;
        }
    
        
        // create the separator
        if ((_bSeparator) && (iIndex > 0) && (iIndex < [_arrayButtons count]))
        {
            [self createSeparator: fPosX forIndex:iIndex];
        }
        
        iIndex++;
        
        fPosX = fPosX + btn.frame.size.width + _spaceBetweenButtons;
        
    }
    
    
    [self fillEnding:fPosX - _spaceBetweenButtons];
    
    // adjust right margin to be the same that left margin
    fPosX = fPosX - _spaceBetweenButtons + _leftMarginControl;

    
    [self updateContentSize];
    
    self.buttonsScrollView.layer.borderColor = _colorBorderView.CGColor;
    self.buttonsScrollView.layer.borderWidth = _borderWidthView;

    // transparency of container not buttons
    [self setBackgroundColor:_colorBackground]; // colorWithAlphaComponent:0.5]];
    [self.buttonsScrollView setBackgroundColor:[UIColor clearColor]]; // colorWithAlphaComponent:0.5]];
    
}

- (void) updateContentSize
{
    CGRect scrollFrame;
    scrollFrame.origin = self.buttonsScrollView.frame.origin;
    // assign teh size of the parent to the scrollview control
    //scrollFrame.size = CGSizeMake(self.superview.frame.size.width, self.frame.size.height);
    scrollFrame.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.buttonsScrollView.frame = scrollFrame;
    // assign the mesaures of the frame to the own control
//    scrollFrame.origin = self.frame.origin;
//    scrollFrame.size = CGSizeMake(self.superview.frame.size.width, self.frame.size.height);
//    self.frame = scrollFrame;
    
    
    //CGSize contentSize = CGSizeMake(fPosX + (self.buttonsScrollView.frame.size.width - 32)/ 2.0, self.frame.size.height);
    CGSize contentSize = CGSizeMake(fPosX, self.frame.size.height); // original code
    [self.buttonsScrollView setContentSize:contentSize];
    
    if (_bShowShadowsSides)
    {
        if (contentSize.width > self.frame.size.width)
        {
            if (_bShadowsAlreadyCreated == NO)
            {
                // Set the left inner shadow
                _shadowLeft = [self makeInsetShadowWithRadius:4 Color:[UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.2] Directions:[NSArray arrayWithObject:@"left"] Insets:8.0];
                
                // Set the right inner shadow
                _shadowRight = [self makeInsetShadowWithRadius:4 Color:[UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.2] Directions:[NSArray arrayWithObject:@"right"] Insets:8.0];
                _bShadowsAlreadyCreated = YES;
            }
        }
        else{
            // remove shadow
            [_shadowLeft removeFromSuperview];
            [_shadowRight removeFromSuperview];
            _bShadowsAlreadyCreated = NO;
        }
    }
}

- (void) createSeparator:(float) fPosParamX forIndex:(int)iIndex
{
    // index: index of the button, need in tabslideview
    
    // create a view
    float fHeightSeparator = _fHeightSeparator;
    float fMaxHeight = self.bounds.size.height - _fShadowRadius * 2;
    float fPosY = 0.0;
    if ((fHeightSeparator <= 0.0) || (fHeightSeparator >= fMaxHeight))
    {
        fHeightSeparator = fMaxHeight;
    }
    else
    {
        if (_typeSelection != UNDERLINE_TYPE)
        {
            fPosY = (fMaxHeight / 2) - (fHeightSeparator / 2);
        }
        else
        {
            fPosY = 8;//(fMaxHeight / 2) - (fHeightSeparator / 2);
        }
    }
    
    fPosParamX = fPosParamX - (_spaceBetweenButtons / 2.0);
    CGRect cgRectSeparator = CGRectMake(fPosParamX, fPosY, _fWidthSeparator, _fHeightSeparator);
    UIView * viewSeparator = [[UIView alloc] initWithFrame:cgRectSeparator];
    viewSeparator.backgroundColor = _colorSeparator;
//    viewSeparator.backgroundColor = [UIColor blackColor];
    [self.buttonsScrollView addSubview:viewSeparator];
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    if (_typeButton == TEXT)
    {
        CGSize size = [string sizeWithAttributes:@{NSFontAttributeName: font}];
        
        // Values are fractional -- you should take the ceilf to get equivalent values
        CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
        
        return adjustedSize.width;
    }
    else if (_typeButton == IMAGE)
    {
        // TODO check width of theimage
    }
    
    return _minWidthButton;
    
}

- (void) initUnclosedButtonsWithArray:(NSMutableArray *) unclosedButtons
{
    [self removeAllUnclosedButtons];
    _arNonCloseButtons = [[NSMutableArray alloc] init];
    
    [_arNonCloseButtons addObjectsFromArray:unclosedButtons];
}

- (void)initUnclosedButtons:(NSString*)sUnclosedButtons, ...;
{
    [self removeAllUnclosedButtons];
    
    va_list args;
    
    va_start(args, sUnclosedButtons);
    
    for (NSString* sButton = sUnclosedButtons; sButton != nil; sButton = va_arg(args, NSString*))
    {
        [self addUnclosedButtonWithText:sButton];
    }
    
    va_end(args);
}


- (void) addUnclosedButtonWithText:(NSString *) sButton
{
    if (_arNonCloseButtons == nil)
    {
        _arNonCloseButtons = [[NSMutableArray alloc] init];
    }
    
    if (![_arNonCloseButtons containsObject:sButton])
    {
        [_arNonCloseButtons addObject:sButton];
    }
}

-(void) removeUnclosedButtonByName:(NSString *) sButton
{
    if (_arNonCloseButtons != nil)
    {
        [_arNonCloseButtons removeObject:sButton];
    }
}

- (void) removeAllUnclosedButtons
{
    if (_arNonCloseButtons != nil)
    {
        [_arNonCloseButtons removeAllObjects];
    }
    _arNonCloseButtons = nil;
}

- (bool) isButtonUnclosed:(NSString *) sButton
{
    if (_arNonCloseButtons != nil)
    {
        return ([_arNonCloseButtons containsObject:sButton]);
    }
    return NO;
}

- (UIButton *) createButton:(NSString *)sButton
                      index:(int) iIndex
                       posX:(float) fPosParamX
                       font:(UIFont*) fontStringButtons
                   fontBold:(UIFont*) fontStringButtonsBold
                imageNormal:(UIImage *) imgNormal
           imageHighlighted:(UIImage *) imgHighlighted
                  colorText:(UIColor *) colorTextButtons
          colorTextSelected:(UIColor *) colorSelectedTextButtons
     colorBackgroundButtons:(UIColor *) colorBackgroundButtons
                 pointRight:(BOOL) bShowPointRight
               alphaButtons:(float) alphaButtons
            withWidthButton:(NSNumber *) widthButton
{
    NSString * sFinalButton = @"";
    if (_typeButton == TEXT)
    {
        sFinalButton = ((_bUppercaseButtonsText) ? ([sButton uppercaseString]) : (sButton));
    }
    else if (_typeButton == IMAGE)
    {
        sFinalButton = @"";
    }
    
    NSString * sPahtImageButton = sButton;
    if ((bShowPointRight) && (![self isButtonUnclosed:sButton]))
    {
        if (_typeButton == TEXT)
        {
            sFinalButton = [((_bUppercaseButtonsText) ? ([sButton uppercaseString]) : (sButton)) stringByAppendingString:@" •"/*@" ⨯"*/];
        }
        else if (_typeButton == IMAGE)
        {
            sFinalButton = [NSString stringWithFormat:@"⨯"];
        }
        
    }
    
    float fWidthButton;
    float fWidthText = [self widthOfString:sFinalButton withFont:fontStringButtons];
    
    if (widthButton != nil)
    {
        fWidthButton = [widthButton floatValue];
    }
    else
    {
        fWidthButton = fWidthText; //[self widthOfString:sFinalButton withFont:fontStringButtons];
        if (fWidthButton < _minWidthButton)
            fWidthButton = _minWidthButton;
        fWidthButton += (_paddingButton * 2);
    }
    
    // check if the button is selected, if so, then we can show it
    CGRect cgRectButton = CGRectMake(fPosParamX, 0, fWidthButton, self.bounds.size.height - _fShadowRadius * 2 );
    CGRect cgRectButtonMiddle = CGRectMake(fPosParamX, 0, fWidthButton, (self.bounds.size.height - _fShadowRadius * 2) * _fTabHeight );
    //    CGRect cgRectButtonTab = CGRectMake(fPosParamX, 0, fWidthButton, (self.bounds.size.height - _fShadowRadius * 2) + 20 ) ;
    
    UIButton * btn = [[UIButton alloc] initWithFrame:cgRectButton];
    
    [btn.titleLabel setFont:fontStringButtons];
    [btn setTitle:sFinalButton forState:UIControlStateNormal];
    if (_typeButton == TEXT)
    {
        [btn setTitleColor:colorTextButtons forState:UIControlStateNormal];
    }
    else if (_typeButton == IMAGE)
    {
        NSURL *noImageFileURL = [[NSBundle mainBundle] URLForResource: @"no_image" withExtension:@"png"];
        
        UIImage * image = [UIImage cachedImageWithURL:sPahtImageButton withNoImageFileURL:noImageFileURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        CGRect cgRectImageButton = CGRectMake(0, 0, fWidthButton, self.bounds.size.height - _fShadowRadius * 2 );
        UIImageView * uiImagebutton = [[UIImageView alloc] initWithFrame:cgRectImageButton];
        [uiImagebutton setImage:image];
        [uiImagebutton setBackgroundColor:[UIColor clearColor]];
        [uiImagebutton setContentMode:UIViewContentModeScaleAspectFit];
        [btn addSubview:uiImagebutton];
        [btn sendSubviewToBack:uiImagebutton];
        
        //        [[btn imageView] setContentMode: UIViewContentModeScaleAspectFit];
        
        //        [btn setBackgroundImage:image forState:UIControlStateNormal];
        //        [btn setImage:image forState:UIControlStateNormal];
        //[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    if (_typeButton == TEXT)
    {
        [btn.layer setBorderWidth:_borderWidthButtons];
        [btn.layer setBorderColor:_colorBorderButtons.CGColor];
    }
    btn.backgroundColor = colorBackgroundButtons;
    [btn setAlpha:alphaButtons];
    btn.tag = iIndex;
    
    if (imgNormal != nil)
        [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    if (imgHighlighted != nil)
        [btn setBackgroundImage:imgHighlighted forState:UIControlStateHighlighted];
    
    
    // check if the selection is TAB_TYPE
    if (_typeSelection == TAB_TYPE)
    {
        // check if button is selected
        if ([self isSelected:iIndex])
        {
            btn.frame = cgRectButton;
            //            [self showButtonTab:btn FromRect:cgRectButtonMiddle ToRect:cgRectButton];
        }
        else
            btn.frame = cgRectButtonMiddle;
    }
    else if (_typeSelection == UNDERLINE_TYPE)
    {
        [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)];

        if ([self isSelected:iIndex])
        {
            // crear la label que hará de resalte del botón
            CGRect rectUnderline = cgRectButton;
            rectUnderline.size.height = _heightUnderLine;
            rectUnderline.origin.y = cgRectButton.size.height - rectUnderline.size.height - _bottomMarginUnderline;
            rectUnderline.size.width = fWidthText;
            rectUnderline.origin.x = (cgRectButton.size.width / 2.0) - (fWidthText / 2.0);
            UIView * viewUnderLine = [[UIView alloc] initWithFrame:rectUnderline];
            [viewUnderLine setBackgroundColor:_colorUnderlineSelected];
            [btn addSubview:viewUnderLine];
        }
    }
    else{
        
        // check if button is selected, therefor we show the highlighted image
        if ([self isSelected:iIndex])
        {
            [btn setTitleColor:colorSelectedTextButtons forState:UIControlStateNormal];
            if (imgHighlighted != nil)
            {
                [btn setBackgroundImage:imgHighlighted forState:UIControlStateHighlighted];
                [btn setBackgroundImage:imgHighlighted forState:UIControlStateNormal];
            }
            else
            {
                if (_bBoldSelected)
                    [btn.titleLabel setFont:fontStringButtonsBold];
            }
        }
    }
    
    //        btn.imageView.layer.cornerRadius = 7.0f;
    btn.layer.shadowRadius = _fShadowRadius;
    if (_fShadowRadius > 0.0)
    {
        btn.layer.shadowColor = _colorShadowButtons.CGColor;
        btn.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        btn.layer.shadowOpacity = 0.5f;
    }
    else
    {
        btn.layer.shadowColor = [UIColor clearColor].CGColor;
    }
    btn.layer.masksToBounds = NO;
    btn.clipsToBounds = NO;
//    [btn.titleLabel setAdjustsFontSizeToFitWidth:NO];
    
    // add event to the button
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonsScrollView addSubview:btn];
    
    return btn;
}

- (UIButton *) createButton:(NSString *)sButton
                      index:(int) iIndex
                       posX:(float) fPosParamX
                       font:(UIFont*) fontStringButtons
                   fontBold:(UIFont*) fontStringButtonsBold
                imageNormal:(UIImage *) imgNormal
           imageHighlighted:(UIImage *) imgHighlighted
            withWidthButton:(NSNumber *) widthButton

{
    return [self createButton:sButton index:iIndex posX:fPosParamX font:fontStringButtons fontBold:fontStringButtonsBold imageNormal:imgNormal imageHighlighted:imgHighlighted colorText:self.colorTextButtons colorTextSelected:self.colorSelectedTextButtons colorBackgroundButtons:self.colorBackgroundButtons pointRight:self.bShowPointRight alphaButtons:self.alphaButtons withWidthButton:widthButton];
    /*
    NSString * sFinalButton = @"";
    if (_typeButton == TEXT)
    {
        sFinalButton = sButton;
    }
    else if (_typeButton == IMAGE)
    {
        sFinalButton = @"";
    }
    
    NSString * sPahtImageButton = sButton;
    if ((self.bShowPointRight) && (![self isButtonUnclosed:sButton]))
    {
        if (_typeButton == TEXT)
        {
            sFinalButton = [sButton stringByAppendingString:@" •"];//@" ⨯"];
        }
        else if (_typeButton == IMAGE)
        {
            sFinalButton = [NSString stringWithFormat:@"⨯"];
        }
        
    }
//    float fWidth = [self widthOfString:sFinalButton withFont:fontStringButtons];

    float fWidthButton = [self widthOfString:sFinalButton withFont:fontStringButtons];
    
    if (fWidthButton < _minWidthButton)
        fWidthButton = _minWidthButton;
    fWidthButton += (_paddingButton * 2);
    
    // check if the button is selected, if so, then we can show it
    CGRect cgRectButton = CGRectMake(fPosParamX, 0, fWidthButton, self.bounds.size.height - _fShadowRadius * 2 );
    CGRect cgRectButtonMiddle = CGRectMake(fPosParamX, 0, fWidthButton, (self.bounds.size.height - _fShadowRadius * 2) * _fTabHeight );
//    CGRect cgRectButtonTab = CGRectMake(fPosParamX, 0, fWidthButton, (self.bounds.size.height - _fShadowRadius * 2) + 20 ) ;
    
    UIButton * btn = [[UIButton alloc] initWithFrame:cgRectButton];
    
    [btn.titleLabel setFont:fontStringButtons];
    [btn setTitle:sFinalButton forState:UIControlStateNormal];
    if (_typeButton == TEXT)
    {
        [btn setTitleColor:self.colorTextButtons forState:UIControlStateNormal];
    }
    else if (_typeButton == IMAGE)
    {
        NSURL *noImageFileURL = [[NSBundle mainBundle] URLForResource: @"no_image" withExtension:@"png"];
        
        UIImage * image = [UIImage cachedImageWithURL:sPahtImageButton withNoImageFileURL:noImageFileURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        CGRect cgRectImageButton = CGRectMake(0, 0, fWidthButton, self.bounds.size.height - _fShadowRadius * 2 );
        UIImageView * uiImagebutton = [[UIImageView alloc] initWithFrame:cgRectImageButton];
        [uiImagebutton setImage:image];
        [uiImagebutton setBackgroundColor:[UIColor clearColor]];
        [uiImagebutton setContentMode:UIViewContentModeScaleAspectFit];
        [btn addSubview:uiImagebutton];
        [btn sendSubviewToBack:uiImagebutton];
        
//        [[btn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    
//        [btn setBackgroundImage:image forState:UIControlStateNormal];
//        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    if (_typeButton == TEXT)
    {
        [btn.layer setBorderWidth:_borderWidthButtons];
        [btn.layer setBorderColor:_colorBorderButtons.CGColor];
    }
    btn.backgroundColor = self.colorBackgroundButtons;
    [btn setAlpha:self.alphaButtons];
    btn.tag = iIndex;
    
    if (imgNormal != nil)
        [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    if (imgHighlighted != nil)
        [btn setBackgroundImage:imgHighlighted forState:UIControlStateHighlighted];
    
    
    // check if the selection is TAB_TYPE
    if (_typeSelection == TAB_TYPE)
    {
        // check if button is selected
        if ([self isSelected:iIndex])
        {
            btn.frame = cgRectButton;
//            [self showButtonTab:btn FromRect:cgRectButtonMiddle ToRect:cgRectButton];
        }
        else
            btn.frame = cgRectButtonMiddle;
    }
    else{
        // check if button is selected, therefor we show the highlighted image
        if ([self isSelected:iIndex])
        {
            [btn setTitleColor:self.colorSelectedTextButtons forState:UIControlStateNormal];
            if (imgHighlighted != nil)
            {
                [btn setBackgroundImage:imgHighlighted forState:UIControlStateHighlighted];
                [btn setBackgroundImage:imgHighlighted forState:UIControlStateNormal];
            }
            else
            {
                if (_bBoldSelected)
                    [btn.titleLabel setFont:fontStringButtonsBold];
            }
        }
    }
    
    //        btn.imageView.layer.cornerRadius = 7.0f;
    btn.layer.shadowRadius = _fShadowRadius;
    btn.layer.shadowColor = _colorShadowButtons.CGColor;
    btn.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    btn.layer.shadowOpacity = 0.5f;
    btn.layer.masksToBounds = NO;
    btn.clipsToBounds = NO;
    
    // add event to the button
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonsScrollView addSubview:btn];
    
    return btn;
     */
}

-(void) showButtonTab:(UIButton*) btn FromRect:(CGRect) fromRect ToRect:(CGRect) toRect
{
    btn.frame = fromRect;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         btn.frame = toRect;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void) fillBegining:(float) fPosXParam
{
    
}

-(void) fillEnding:(float) fPosXParam
{
    
}

- (IBAction)btnClick: (id)sender
{
    UIButton *button = (UIButton*)sender;
    // highlight the button
    
    [self selectButton:(int)button.tag];
    
    // get the index of the button in the array
    [self.delegate slideButtonView:self btnClick:(int)button.tag];
    
}

- (void) unselectButtons;
{
    [self.arSelectedButtons removeAllObjects];
    [self updateButtons];
}

- (void) unselectButton:(int) idxButtonUnselect
{
    // add the idx to the array
    if (_arSelectedButtons)
    {
        NSNumber* nsnIdxButtonSelect = [NSNumber numberWithInt:idxButtonUnselect];
        unsigned long iIdxAlreadySelected = [_arSelectedButtons indexOfObject:nsnIdxButtonSelect];
        
        if (iIdxAlreadySelected != NSNotFound)
        {
            // the item already selected, we must unselect
            [_arSelectedButtons removeObjectAtIndex: iIdxAlreadySelected];
        }
        
        [self updateButtons];
        
    }
}

- (void) selectButton:(int) idxButtonSelect
{
    if (_typeSelection != NOHIGHLIGHT)
    {
        // add the idx to the array
        if (_arSelectedButtons)
        {
            NSNumber* nsnIdxButtonSelect = [NSNumber numberWithInt:idxButtonSelect];
            unsigned long iIdxAlreadySelected = [_arSelectedButtons indexOfObject:nsnIdxButtonSelect];
            
            if (iIdxAlreadySelected != NSNotFound)
            {
                if (_bUnselectWithClick)
                {
                    // the item already selected, we must unselect
                    [_arSelectedButtons removeObjectAtIndex: iIdxAlreadySelected];
                }
//                // update the button
//                [self updateButtonState:idxButtonSelect state:_typeSelection];
            }
            else
            {
                if (_bMultiselect == NO)
                {
                    // is not multiselect so we only must have one item selected at a same time
                    [_arSelectedButtons removeAllObjects];
                }
                // the item does not exist, we add the item to the array of existing items
                [_arSelectedButtons addObject: nsnIdxButtonSelect];
                
//                // update the button
//                [self updateButtonState: idxButtonSelect state:_typeSelection];
            }
            
            [self updateButtons];
            
        }
    }
}
- (void) forceSelectButton:(int) idxButtonSelect
{
    if (_typeSelection != NOHIGHLIGHT)
    {
        // add the idx to the array
        if (_arSelectedButtons)
        {
            NSNumber* nsnIdxButtonSelect = [NSNumber numberWithInt:idxButtonSelect];
            
            if (_bMultiselect == NO)
            {
                // is not multiselect so we only must have one item selected at a same time
                [_arSelectedButtons removeAllObjects];
            }
            // the item does not exist, we add the item to the array of existing items
            if (![_arSelectedButtons containsObject:nsnIdxButtonSelect]){
                [_arSelectedButtons addObject: nsnIdxButtonSelect];
            }
            
           
            [self updateButtons];
            [self scrollToButtonByIndex:idxButtonSelect];
            
        }
    }
}

- (BOOL) isSelected:(int) idxButton
{
    BOOL bRes = NO;
    // add the idx to the array
    if (_arSelectedButtons)
    {
        NSNumber* nsnIdxButtonSelect = [NSNumber numberWithInt:idxButton];
        unsigned long iIdxAlreadySelected = [_arSelectedButtons indexOfObject:nsnIdxButtonSelect];
        bRes = (iIdxAlreadySelected != NSNotFound);
    }
    
    return bRes;
    
}

- (float) fGetTotalWidth:(UIFont*) fontStringButtons
{
    float fTotalWidth = 0.0; //_leftMarginControl;
    float fWidthButton = 0.0;
    // loop through all the button calculating the total width
    for( NSObject *objButton in _arrayButtons)
    {
        NSString * sButton;
        if ([objButton isKindOfClass:[NSString class]])
        {
            sButton = (NSString *)objButton;
            sButton = (NSString*) ((_bUppercaseButtonsText) ? ([sButton uppercaseString]) : (sButton));
        }
        else if ([objButton isKindOfClass:[NSObject class]])
        {
            sButton = [((NSObject*) objButton) toStringButtonSlideView];
        }
        else{
            continue;
        }
        
        NSString * sFinalButton = sButton;
        if (_bUppercaseButtonsText)
            sFinalButton = [sButton uppercaseString];
        
        if ((self.bShowPointRight) && (![self isButtonUnclosed:sButton]))
            sFinalButton = [sFinalButton stringByAppendingString:@" •"/*@" ⨯"*/];
        fWidthButton = [self widthOfString:sFinalButton withFont:fontStringButtons];
        if (fWidthButton < _minWidthButton)
            fWidthButton = _minWidthButton;
        fWidthButton += (_paddingButton * 2) + _spaceBetweenButtons;
        fTotalWidth += fWidthButton;
    }

    // adjust right margin to be the same that left margin
    fTotalWidth = fTotalWidth - _spaceBetweenButtons;// + _leftMarginControl;

    return fTotalWidth;
}

- (float) fGetWidth:(NSObject *) button withFont:(UIFont*) fontStringButtons
{
    NSString * sButton = nil;
    if ([button isKindOfClass:[NSString class]])
    {
        sButton = (NSString *)button;
        sButton = (NSString*) ((_bUppercaseButtonsText) ? ([sButton uppercaseString]) : (sButton));
    }
    else if ([button isKindOfClass:[NSObject class]])
    {
        sButton = [((NSObject*) button) toStringButtonSlideView];
    }
    
    if (sButton != nil)
    {
        NSString * sFinalButton = sButton;
        if (_bUppercaseButtonsText)
            sFinalButton = [sButton uppercaseString];
        
        if ((self.bShowPointRight) && (![self isButtonUnclosed:sButton]))
            sFinalButton = [sFinalButton stringByAppendingString:@" •"/*@" ⨯"*/];

//        if ((self.bShowPointRight) && (![self isButtonUnclosed:sButton]))
//            sFinalButton = [((_bUppercaseButtonsText) ? ([sButton uppercaseString]) : (sButton)) stringByAppendingString:@" •"/*@" ⨯"*/];
        float fWidthButton = [self widthOfString:sFinalButton withFont:fontStringButtons];
        if (fWidthButton < _minWidthButton)
            fWidthButton = _minWidthButton;
        fWidthButton += (_paddingButton * 2);
        
        return fWidthButton;
    }
    
    return 0;
}

- (void) scrollToTheEnd
{
    if (!(self.buttonsScrollView.contentSize.width > self.frame.size.width))
        return;

//    CGPoint bottomOffset = CGPointMake(0, self.buttonsScrollView.contentSize.height - self.buttonsScrollView.bounds.size.height);
    CGPoint rightOffset = CGPointMake(self.buttonsScrollView.contentSize.width - self.buttonsScrollView.bounds.size.width, 0);
    [self.buttonsScrollView setContentOffset:rightOffset animated:YES];
}

- (void) scrollToTheBeginning
{
    //    CGPoint bottomOffset = CGPointMake(0, self.buttonsScrollView.contentSize.height - self.buttonsScrollView.bounds.size.height);
    CGPoint rightOffset = CGPointMake(0, 0);
    [self.buttonsScrollView setContentOffset:rightOffset animated:YES];
}

- (void) scrollToButtonByIndex:(int) iIdxButton
{
    if ((iIdxButton >= 0) && (iIdxButton < _arrayButtons.count))
    {
        if (!(self.buttonsScrollView.contentSize.width > self.frame.size.width))
            return;

        // looping through the button calculatin the offset
        float fOriginX = -1.0f;
        float fWidth = 0.0f;
        int iIdx = 0;
        for (UIView * view in self.buttonsScrollView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                if (iIdx == iIdxButton)
                {
                    fOriginX = view.frame.origin.x;
                    fWidth = view.frame.size.width;
                    break;
                }
                iIdx++;
            }
        }
        
        if (fOriginX  > 0.0f)
        {
            if ((fOriginX + fWidth) > self.buttonsScrollView.frame.size.width)
            {
                if (fOriginX < (self.buttonsScrollView.contentSize.width - self.buttonsScrollView.bounds.size.width))
                {
                    fOriginX = fOriginX + (fWidth/2.0) + (self.buttonsScrollView.frame.size.width / 2.0);
                }
                else
                {
                    fOriginX = self.buttonsScrollView.contentSize.width;
                }
                
                // calculate offset
                CGPoint offset = CGPointMake( fOriginX - self.buttonsScrollView.bounds.size.width, 0);
                
                [self.buttonsScrollView setContentOffset:offset animated:NO];
            }
        }
        
    }
}

@end

@implementation SlideButtonProperties

@end
