//
//  TabSlide.m
//  ControlsGoldenSpear
//
//  Created by Alberto Seco on 28/4/15.
//  Copyright (c) 2015 com example. All rights reserved.
//

#import "TabSlideView.h"

@implementation TabSlideView


// Initialize variables to default values
- (void)initSlideButtonView
{
    [super initSlideButtonView];
    
    super.spaceBetweenButtons = 20;
    super.fShadowRadius = 0.0;
    super.leftMarginControl = 0.0;
    
    super.typeSelection = HIGHLIGHT_TYPE;
    super.bMultiselect = NO;
    
    super.colorShadowButtons = [UIColor clearColor];
    
    super.fHeightSeparator = -1.0;
    super.fWidthSeparator = 0.5;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIButton *) createButton:(NSString *)sButton
                      index:(int) iIndex
                       posX:(float) fPosParamX
                       font:(UIFont*) fontStringButtons
                   fontBold:(UIFont*) fontStringButtonsBold
                imageNormal:(UIImage *) imgNormal
           imageHighlighted:(UIImage *) imgHighlighted
            withWidthButton:(NSNumber *) widthButton
{
    float fWidthButton = [super widthOfString:sButton withFont:fontStringButtons];
    
    if (fWidthButton < self.minWidthButton)
        fWidthButton = self.minWidthButton;
    fWidthButton += (super.paddingButton * 2);
    
    // check if the button is selected, if so, then we can show it
    CGRect cgRectButton = CGRectMake(fPosParamX, 0, fWidthButton, self.bounds.size.height - self.fShadowRadius * 2 );
    
    UIButton * btn = [[UIButton alloc] initWithFrame:cgRectButton];
    
    [btn.titleLabel setFont:fontStringButtons];
    [btn setTitle:sButton forState:UIControlStateNormal];
    [btn setTitleColor:self.colorTextButtons forState:UIControlStateNormal];
    
    btn.backgroundColor = self.colorBackgroundButtons;
    [btn setAlpha:self.alphaButtons];
    btn.tag = iIndex;
    
    if (imgNormal != nil)
        [btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    if (imgHighlighted != nil)
        [btn setBackgroundImage:imgHighlighted forState:UIControlStateHighlighted];
    
    
    // check if button is selected, therefor we show the highlighted image
    if ([self isSelected:iIndex])
    {
        [btn setBackgroundColor:self.colorBackgroundSelectedButtons];
        [btn setTitleColor:self.colorSelectedTextButtons forState:UIControlStateNormal];
        if (self.bBoldSelected)
            [btn.titleLabel setFont:fontStringButtonsBold];
        // draw left
        CGPoint p1 = CGPointMake(0, 0);
        CGPoint p2 = CGPointMake(0, btn.bounds.size.height);
        [TabSlideView drawLine:btn topleft:p1 bottomright:p2 withColor:self.colorSeparator andLineWidth:0.5];
        
        // draw right
        p1 = CGPointMake(fWidthButton, 0);
        p2 = CGPointMake(fWidthButton, btn.bounds.size.height);
        [TabSlideView drawLine:btn topleft:p1 bottomright:p2 withColor:self.colorSeparator andLineWidth:0.5];
        
        // draw bottom line
        p1 = CGPointMake(0, 0);
        p2 = CGPointMake(fWidthButton, 0);
        
        [TabSlideView drawLine:btn topleft:p1 bottomright:p2 withColor:self.colorSeparator andLineWidth:0.5];
    }
    else{
        // draw bottom line
        CGPoint p1 = CGPointMake(0, btn.bounds.size.height);
        CGPoint p2 = CGPointMake(0 + fWidthButton, btn.bounds.size.height);
        
        [TabSlideView drawLine:btn topleft:p1 bottomright:p2 withColor:self.colorSeparator andLineWidth:0.5];
    }
    
    //        btn.imageView.layer.cornerRadius = 7.0f;
    btn.layer.shadowRadius = self.fShadowRadius;
    btn.layer.shadowColor = self.colorShadowButtons.CGColor;
    btn.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    btn.layer.shadowOpacity = 0.5f;
    btn.layer.masksToBounds = NO;
    
    // add event to the button
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttonsScrollView addSubview:btn];
    
    return btn;
    
}

- (void) createSeparator:(float) fPosParamX forIndex:(int)iIndex
{
    // index: index of the button, need in tabslideview
    if ([super isSelected:iIndex]  || [super isSelected:iIndex-1])
    {
        
    }
    else
    {
        [super createSeparator:fPosParamX forIndex:iIndex];
    }
}


- (void) fillBegining:(float) fPosXParam
{
    float fHeight = self.buttonsScrollView.bounds.size.height - self.fShadowRadius * 2;
    CGRect cgRec = CGRectMake(0, 0, fPosXParam, fHeight);
    
    UIView *view = [[UIView alloc] initWithFrame:cgRec];
//    CGPoint p1 = CGPointMake(0, fHeight);
    CGPoint p1 = CGPointMake(-150, fHeight); // if you want the line does not be cut
    CGPoint p2 = CGPointMake(fPosXParam, fHeight);
//    [self drawLine:self.buttonsScrollView topleft:p1 bottomright:p2];
    [TabSlideView drawLine:view topleft:p1 bottomright:p2 withColor:self.colorSeparator andLineWidth:0.5];
    [self.buttonsScrollView addSubview:view];
}

-(void) fillEnding:(float) fPosXParam
{
    float fHeight = self.buttonsScrollView.bounds.size.height - self.fShadowRadius * 2;
    CGRect cgRec = CGRectMake(fPosXParam, 0, fPosXParam + super.leftMarginControl, fHeight);
    
    UIView *view = [[UIView alloc] initWithFrame:cgRec];
    CGPoint p1 = CGPointMake(0, fHeight);
//    CGPoint p2 = CGPointMake(super.leftMarginControl, fHeight);
    CGPoint p2 = CGPointMake(super.leftMarginControl + 150, fHeight); // if you want the line does not be cut
    [TabSlideView drawLine:view topleft:p1 bottomright:p2 withColor:self.colorSeparator andLineWidth:0.5];
    [self.buttonsScrollView addSubview:view];
}

+(void) drawLine:(UIView *)view topleft:(CGPoint) pTopLeft bottomright:(CGPoint) pBottomRight withColor:(UIColor*) color andLineWidth:(float)width
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pTopLeft];
    [path addLineToPoint:pBottomRight];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.lineWidth = width;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [view.layer addSublayer:shapeLayer];
}

@end
