//
//  SCSlider.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-19.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidChangeValueBlock)(CGFloat value);
typedef void(^TouchEndBlock)(CGFloat value, BOOL isTouchEnd);
@protocol SCSliderDelegate;

typedef enum {
    SCSliderDirectionHorizonal  =   0,
    SCSliderDirectionVertical   =   1
} SCSliderDirection;

@interface SCSlider : UIControl

@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat value;

@property (nonatomic, assign) BOOL showHalfWhenCirlceIsTop;
@property (nonatomic, assign) BOOL lineWidth;
@property (nonatomic, assign) BOOL circleRadius;
@property (nonatomic, assign) BOOL isFullFillCircle;

@property (nonatomic, assign) BOOL isSliding;


@property (nonatomic, copy) DidChangeValueBlock didChangeValueBlock;
@property (nonatomic, copy) TouchEndBlock touchEndBlock;
@property (nonatomic, assign) id <SCSliderDelegate> delegate;

- (id)initWithFrame:(CGRect)frame direction:(SCSliderDirection)direction;

- (void)fillLineColor:(UIColor*)bgLineColor
      slidedLineColor:(UIColor*)slidedLineColor
          circleColor:(UIColor*)circleColor
       shouldShowHalf:(BOOL)shouldShowHalf
            lineWidth:(CGFloat)lineWidth
         circleRadius:(CGFloat)circleRadius
     isFullFillCircle:(BOOL)isFullFillCircle;

- (void)buildDidChangeValueBlock:(DidChangeValueBlock)didChangeValueBlock;
- (void)buildTouchEndBlock:(TouchEndBlock)touchEndBlock;
- (void)setValue:(CGFloat)value shouldCallBack:(BOOL)shouldCallBack;

@end



@protocol SCSliderDelegate <NSObject>

@optional
- (void)didChangeValueSCSlider:(SCSlider*)slider value:(CGFloat)value;
- (void)didSCSliderTouchEnd:(SCSlider*)slider value:(CGFloat)value isTouch:(BOOL)isTouchEnd;

@end