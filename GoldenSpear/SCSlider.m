//
//  SCSlider.m
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-19.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import "SCSlider.h"

#define DARK_GREEN_COLOR        [UIColor colorWithRed:10/255.0f green:107/255.0f blue:42/255.0f alpha:1.f]   
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:143/255.0f green:191/255.0f blue:62/255.0f alpha:1.f]



//#define SHOW_HALF_WHEN_CIRCLE_IS_TOP    1
//#define LINE_WIDTH                      1
//#define CIRCLE_RADIUS                   10
//#define GAP                             (SHOW_HALF_WHEN_CIRCLE_IS_TOP ? CIRCLE_RADIUS : 0)
//#define INVERSE_GAP                     (SHOW_HALF_WHEN_CIRCLE_IS_TOP ? 0 : CIRCLE_RADIUS)

@interface SCSlider () {
    CGFloat gap;
    CGFloat inverseGap;
}

@property (nonatomic, assign) SCSliderDirection direction;
@property (nonatomic, strong) UIColor *bgLineColor;
@property (nonatomic, strong) UIColor *slidedLineColor;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, assign) CGFloat scaleNum;


@end


@implementation SCSlider

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame direction:SCSliderDirectionHorizonal];
}

- (id)initWithFrame:(CGRect)frame direction:(SCSliderDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.minValue = 0;
        self.maxValue = 1;
//        _value = 0;
        self.isFullFillCircle = NO;
        self.direction = direction;
        self.bgLineColor = [UIColor whiteColor];// LIGHT_GREEN_COLOR;
        self.slidedLineColor = [UIColor whiteColor];//DARK_GREEN_COLOR;
        self.circleColor = [UIColor whiteColor];
        
        self.showHalfWhenCirlceIsTop = YES;
        self.lineWidth = 1;
        self.circleRadius = 10;
    }
    return self;
}

#pragma mark ----------public---------
- (void)fillLineColor:(UIColor*)bgLineColor
      slidedLineColor:(UIColor*)slidedLineColor
          circleColor:(UIColor*)circleColor
       shouldShowHalf:(BOOL)shouldShowHalf
            lineWidth:(CGFloat)lineWidth
         circleRadius:(CGFloat)circleRadius
     isFullFillCircle:(BOOL)isFullFillCircle {
    
    if (bgLineColor) {
        self.bgLineColor = bgLineColor;
    }
    if (slidedLineColor) {
        self.slidedLineColor = slidedLineColor;
    }
    if (circleColor) {
        self.circleColor = circleColor;
    }
    self.showHalfWhenCirlceIsTop = shouldShowHalf;
    self.lineWidth = lineWidth;
    self.circleRadius = circleRadius;
    self.isFullFillCircle = isFullFillCircle;
    [self setNeedsDisplay];
}


- (void)setValue:(CGFloat)value {
    [self setValue:value shouldCallBack:YES];
}

- (void)setValue:(CGFloat)value shouldCallBack:(BOOL)shouldCallBack {
    if (value != _value) {
        if (value < _minValue) {
            _value = _minValue;
            return;
        } else if (value > _maxValue) {
            _value = _maxValue;
            return;
        }
        _value = value;
        
        if (!shouldCallBack) {
            _scaleNum = (_value - _minValue) / (_maxValue - _minValue);
        }
        
        [self setNeedsDisplay];
        
        if (shouldCallBack) {
            if (_didChangeValueBlock) {
                _didChangeValueBlock(value);
            } else if ([self.delegate respondsToSelector:@selector(didChangeValueSCSlider:value:)]) {
                [self.delegate didChangeValueSCSlider:self value:value];
            }
        }
    }
}

- (void)buildDidChangeValueBlock:(DidChangeValueBlock)didChangeValueBlock {
    if (_didChangeValueBlock != didChangeValueBlock) {
        self.didChangeValueBlock = didChangeValueBlock;
    }
}

- (void)buildTouchEndBlock:(TouchEndBlock)touchEndBlock {
    if (_touchEndBlock != touchEndBlock) {
        self.touchEndBlock = touchEndBlock;
    }
}

#pragma mark -----------drawRect--------------
- (void)drawRect:(CGRect)rect {
    gap = (_showHalfWhenCirlceIsTop ? _circleRadius : 0);
    inverseGap = (_showHalfWhenCirlceIsTop ? 0 : _circleRadius);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, _bgLineColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGFloat startLineX = (_direction == SCSliderDirectionHorizonal ? gap : (self.frame.size.width - _lineWidth) / 2);
    CGFloat startLineY = (_direction == SCSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : gap);
    
    CGFloat endLineX = (_direction == SCSliderDirectionHorizonal ? self.frame.size.width - gap : (self.frame.size.width - _lineWidth) / 2);
    CGFloat endLineY = (_direction == SCSliderDirectionHorizonal ? (self.frame.size.height - _lineWidth) / 2 : self.frame.size.height- gap);
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, endLineX, endLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, _slidedLineColor.CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGFloat slidedLineX = (_direction == SCSliderDirectionHorizonal ? MAX(gap, (_scaleNum * self.frame.size.width - gap)) : startLineX);
    CGFloat slidedLineY = (_direction == SCSliderDirectionHorizonal ? startLineY : MAX(gap, (_scaleNum * self.frame.size.height - gap)));
    CGContextMoveToPoint(context, startLineX, startLineY);
    CGContextAddLineToPoint(context, slidedLineX, slidedLineY);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    
    CGFloat penWidth = 1.f;
    CGContextSetStrokeColorWithColor(context, _circleColor.CGColor);
    CGContextSetLineWidth(context, penWidth);
    if (_isFullFillCircle) {
        CGContextSetFillColorWithColor(context, _circleColor.CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    }
    CGContextSetShadow(context, CGSizeMake(1, 1), 1.f);
    CGFloat circleX = (_direction == SCSliderDirectionHorizonal ? MAX(_circleRadius + penWidth, slidedLineX - penWidth - inverseGap) : startLineX);
    CGFloat circleY = (_direction == SCSliderDirectionHorizonal ? startLineY : MAX(_circleRadius + penWidth, slidedLineY - penWidth - inverseGap));
    CGContextAddArc(context, circleX, circleY, _circleRadius, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    if (!_isFullFillCircle) {
        CGContextSetStrokeColorWithColor(context, nil);
        CGContextSetLineWidth(context, 0);
        CGContextSetFillColorWithColor(context, _circleColor.CGColor);
        CGContextSetShadow(context, CGSizeMake(0, 0), 0.f);
        CGContextAddArc(context, circleX, circleY, _circleRadius / 2, 0, 2 * M_PI, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    //    UIBezierPath
}

#pragma mark ---------touch-----------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateTouchPoint:touches];
    [self callbackTouchEnd:YES];
}

#pragma mark ----------private---------

- (void)callbackTouchEnd:(BOOL)isTouchEnd {
    self.isSliding = !isTouchEnd;
    if (_touchEndBlock) {
        _touchEndBlock(_value, isTouchEnd);
    } else if ([self.delegate respondsToSelector:@selector(didSCSliderTouchEnd:value:isTouch:)]) {
        [self.delegate didSCSliderTouchEnd:self value:_value isTouch:isTouchEnd];
    }
}

- (void)updateTouchPoint:(NSSet*)touches {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.scaleNum = (_direction == SCSliderDirectionHorizonal ? touchPoint.x : touchPoint.y) / (_direction == SCSliderDirectionHorizonal ? self.frame.size.width : self.frame.size.height);
}

- (void)setMinValue:(CGFloat)minValue {
    if (_minValue != minValue) {
        _minValue = minValue;
        _value = minValue;
    }
}

- (void)setScaleNum:(CGFloat)scaleNum {
    if (_scaleNum != scaleNum) {
        _scaleNum = scaleNum;
        
        self.value = _minValue + scaleNum * (_maxValue - _minValue);
    }
}


@end
