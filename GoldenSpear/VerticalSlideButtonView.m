//
//  VerticalSlideButtonView.m
//  GoldenSpear
//
//  Created by Alberto Seco on 30/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "VerticalSlideButtonView.h"
#import <math.h>

#define kDefaultFontSize 16
#define kDefaultMinWidthButton 10
#define kDefaultPaddingButton 5
#define kDefaultHeightButton 20
#define kDefaultSpaceBetweenButtons 20

@implementation VerticalSlideButtonView

UIFont *            _fontDefault;
UIFont *            _fontDefaultBold;
NSMutableArray *    _arrayButtons;


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
    _fontDefault = [UIFont fontWithName:@"Avenir-Roman" size:kDefaultFontSize];
    _fontDefaultBold = [UIFont fontWithName:@"Avenir-Black" size:kDefaultFontSize];
    _colorTextButtons = [UIColor blackColor];
    _colorSelectedTextButtons = [UIColor blackColor];
    _minWidthButton = kDefaultMinWidthButton;
    _iHeightButton = kDefaultHeightButton;
    _spaceBetweenButtons = kDefaultSpaceBetweenButtons;
    _paddingButton = kDefaultPaddingButton;
    _fShadowRadius = 0.0;
    _leftMarginControl = _fShadowRadius * 2;
    _bShowPointRight = NO;
    
    _arrayButtons = [[NSMutableArray alloc] init];
    _delegate = nil;
    
    
    _colorShadowButtons = [UIColor blackColor];
    
    _bBoldSelected = NO;
    
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
        self.buttonsScrollView.scrollEnabled=YES;
        self.buttonsScrollView.userInteractionEnabled=YES;
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
- (void) initVerticalSlideButtonWithButtons:(NSMutableArray *) buttonsLabels andDelegate: (id <VerticalSlideButtonViewDelegate>)delegate
{
    [self setDelegate:delegate];
    
    // Add new menu entries
    // looping through the button, adding the buttons to the view
    
    [_arrayButtons removeAllObjects];
    [_arrayButtons addObjectsFromArray:buttonsLabels];
    //    _arrayButtons = [buttonsLabels copy];
    [self updateButtons];
    
}

- (void) addButton:(NSString*)name
{
    [_arrayButtons addObject:name];
    [self updateButtons];
}

- (void) removeButton:(long) iIdxButtonToRemove
{
    if (iIdxButtonToRemove < [_arrayButtons count])
    {
        [_arrayButtons removeObjectAtIndex:iIdxButtonToRemove];
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
    
    // init variable for the loop
    float fPosX = _leftMarginControl;
    float fPosY = _topMarginControl;
    
    // get the total width of the buttons
    float fMaxWidth = [self fGetMaxWidth:fontStringButtons];
    float fWidthScrollView = (self.buttonsScrollView.frame.size.width / 2.0);
    int iNumCols = (fWidthScrollView / fMaxWidth);
    float fWidth = fWidthScrollView / (iNumCols*1.0f);
    // looping through the button, adding the buttons to the view
    int iIndex = 0;
    
//    NSLog(@"fMaxWidth: %f, fWidthScrollView: %f, iNumCols:%d, fWidth: %f", fMaxWidth, fWidthScrollView, iNumCols, fWidth);
    for( NSString *sButton in _arrayButtons)
    {
//        NSLog(@"Pos %f %f", fPosX, fPosY);
        // create the button
        [self createButton: sButton
                     index: iIndex
                      posX: fPosX
                      posY: fPosY
                      font: fontStringButtons
                  fontBold: fontStringButtonsBold];
        
        
        iIndex++;
        
        // check position for the next button
        if((iIndex % iNumCols) == 0)
        {
            fPosY += _iHeightButton + self.verticalSpaceBetweenButtons;
            fPosX = _leftMarginControl;
        }
        else
        {
            fPosX = fPosX + fWidth;
        }
        
        
        
    }
    
    
    //    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fPosX, self.frame.size.height);
    //CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y, fPosX, self.frame.size.height);
    CGSize contentSize = CGSizeMake(fPosX, fPosY);
    [self.buttonsScrollView setContentSize:contentSize];
    
    
    // transparency of container not buttons
    [self setBackgroundColor:[UIColor clearColor]]; // colorWithAlphaComponent:0.5]];
    [self.buttonsScrollView setBackgroundColor:[UIColor clearColor]]; // colorWithAlphaComponent:0.5]];
    
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    CGSize size = [string sizeWithAttributes:@{NSFontAttributeName: font}];
    
    // Values are fractional -- you should take the ceilf to get equivalent values
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    return adjustedSize.width;
    
}

- (UIButton *) createButton:(NSString *)sButton
                      index:(int) iIndex
                       posX:(float) fPosX
                       posY:(float) fPosY
                       font:(UIFont*) fontStringButtons
                   fontBold:(UIFont*) fontStringButtonsBold
{
    NSString * sFinalButton = sButton;
    if (self.bShowPointRight)
        sFinalButton = [sButton stringByAppendingString:@" •"];
    float fWidth = [self widthOfString:sFinalButton withFont:fontStringButtons];
    
    CGRect cgRectButton = CGRectMake(fPosX, fPosY, fWidth, _iHeightButton );
    
    UIButton * btn = [[UIButton alloc] initWithFrame:cgRectButton];
    
    [btn.titleLabel setFont:fontStringButtons];
    
    [btn setTitle:sFinalButton forState:UIControlStateNormal];
    [btn setTitleColor:self.colorTextButtons forState:UIControlStateNormal];
    
    btn.backgroundColor = self.colorBackgroundButtons;
    [btn setAlpha:self.alphaButtons];
    btn.tag = iIndex;
    
    //        btn.imageView.layer.cornerRadius = 7.0f;
    btn.layer.shadowRadius = _fShadowRadius;
    btn.layer.shadowColor = _colorShadowButtons.CGColor;
    btn.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    btn.layer.shadowOpacity = 0.5f;
    btn.layer.masksToBounds = NO;
    
    // add event to the button
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonsScrollView addSubview:btn];
    
    return btn;
    
}

- (IBAction)btnClick: (id)sender
{
    UIButton *button = (UIButton*)sender;
    // highlight the button
    
    // get the index of the button in the array
    [self.delegate verticalSlideButtonView:self btnClick:(int)button.tag];
    
    // remove item from the array and update the button
    [self removeButton:(int)button.tag];
    
    [self updateButtons];
}

- (float) fGetTotalWidth:(UIFont*) fontStringButtons
{
    float fTotalWidth = 0.0; //_leftMarginControl;
    float fWidthButton = 0.0;
    // loop through all the button calculating the total width
    for( NSString *sButton in _arrayButtons)
    {
        NSString * sFinalButton = sButton;
        if (self.bShowPointRight)
            sFinalButton = [sButton stringByAppendingString:@" •"];
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

-(float) fGetMaxWidth:(UIFont *) fontStringButtons
{
    float fMaxWidth = 0.0;
    float fWidthButton = 0.0;
    
    // loop through all the button calculating the total width
    for( NSString *sButton in _arrayButtons)
    {
        NSString * sFinalButton = sButton;
        if (self.bShowPointRight)
            sFinalButton = [sButton stringByAppendingString:@" •"];
        fWidthButton = [self widthOfString:sButton withFont:fontStringButtons];
        if (fWidthButton < _minWidthButton)
            fWidthButton = _minWidthButton;
        fWidthButton += (_paddingButton * 2);
        if (fWidthButton > fMaxWidth)
            fMaxWidth = fWidthButton;
    }
    
    return fMaxWidth;
}

@end
