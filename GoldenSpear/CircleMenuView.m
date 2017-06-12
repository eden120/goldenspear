//
//  CircleMenuView.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 15/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "CircleMenuView.h"
#import <QuartzCore/QuartzCore.h>

@interface CircleMenuView()

@property (nonatomic) NSMutableArray* buttons;
@property (weak, nonatomic) UIGestureRecognizer* recognizer;
@property (nonatomic) int hovertag;

@property (nonatomic) UIColor* innerViewColor;
@property (nonatomic) UIColor* innerViewActiveColor;
@property (nonatomic) UIColor* borderViewColor;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat maxAngle;
@property (nonatomic) CGFloat animationDelay;
@property (nonatomic) CGFloat startingAngle;
@property (nonatomic) CGFloat fixedInterItemAngle;
@property (nonatomic) BOOL depth;
@property (nonatomic) CGFloat buttonRadius;
@property (nonatomic) CGFloat buttonBorderWidth;

@property (nonatomic, weak) UIView* clippingView;

@end

// Each button is made up of two views (button image, and background view)
// The buttons get tagged, starting at 1
// Components are identified by adding the corresponding offset to the button's logical tag
static int TAG_BUTTON_OFFSET = 100;
static int TAG_INNER_VIEW_OFFSET = 1000;

// Constants used for the configuration dictionary
NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL = @"kCircleMenuNormal";
NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE = @"kCircleMenuActive";
NSString* const CIRCLE_MENU_BUTTON_BORDER = @"kCircleMenuBorder";
NSString* const CIRCLE_MENU_OPENING_DELAY = @"kCircleMenuDelay";
NSString* const CIRCLE_MENU_RADIUS = @"kCircleMenuRadius";
NSString* const CIRCLE_MENU_MAX_ANGLE = @"kCircleMenuMaxAngle";
NSString* const CIRCLE_FIXED_INTERITEM_ANGLE = @"kCircleFixedInterItemAngle";
NSString* const CIRCLE_MENU_DIRECTION = @"kCircleMenuDirection";
NSString* const CIRCLE_MENU_DEPTH = @"kCircleMenuDepth";
NSString* const CIRCLE_MENU_BUTTON_RADIUS = @"kCircleMenuButtonRadius";
NSString* const CIRCLE_MENU_BUTTON_BORDER_WIDTH = @"kCircleMenuButtonBorderWidth";

#define kLabelHeight 20
#define kLabelBackgroundColor clearColor
#define kLabelAlpha 1.0
#define kFontInLabel "Avenir-Medium"
#define kFontSizeInLabel 12
#define kFontColorInLabel blackColor
#define kShadowColorInLabel lightGrayColor //colorWithRed:0.95 green:0.80 blue:0.46 alpha:0.95

@implementation CircleMenuView

- (id)initWithOptions:(NSDictionary*)optionsDictionary
{
    self = [super init];
    
    if (self)
    {
        self.buttons = [NSMutableArray new];
    
        if (optionsDictionary)
        {
            self.innerViewColor = [optionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL];

            self.innerViewActiveColor = [optionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE];
            
            self.borderViewColor = [optionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BORDER];
            
            self.animationDelay = [[optionsDictionary valueForKey:CIRCLE_MENU_OPENING_DELAY] doubleValue];
            
            self.radius = [[optionsDictionary valueForKey:CIRCLE_MENU_RADIUS] doubleValue];
            
            self.maxAngle = [[optionsDictionary valueForKey:CIRCLE_MENU_MAX_ANGLE] doubleValue];
            
            switch ([[optionsDictionary valueForKey:CIRCLE_MENU_DIRECTION] integerValue])
            {
                case CircleMenuDirectionUp:
            
                    self.startingAngle = 0.0;
                    break;
                    
                case CircleMenuDirectionRight:
                    self.startingAngle = 90.0;
                    break;
                    
                case CircleMenuDirectionDown:
                    self.startingAngle = 180.0;
                    break;
                    
                case CircleMenuDirectionLeft:
                    self.startingAngle = 270.0;
                    break;
            }
            
            self.fixedInterItemAngle = [[optionsDictionary valueForKey:CIRCLE_FIXED_INTERITEM_ANGLE] doubleValue];
            
            self.depth = [[optionsDictionary valueForKey:CIRCLE_MENU_DEPTH] boolValue];
            
            self.buttonRadius = [[optionsDictionary valueForKey:CIRCLE_MENU_BUTTON_RADIUS] doubleValue];
            
            self.buttonBorderWidth = [[optionsDictionary valueForKey:CIRCLE_MENU_BUTTON_BORDER_WIDTH] doubleValue];
        }
        else
        {
            // Using some default settings
            
            self.innerViewColor = [UIColor colorWithRed:0.0 green:0.25 blue:0.5 alpha:1.0];
            
            self.innerViewActiveColor = [UIColor colorWithRed:0.25 green:0.5 blue:0.75 alpha:1.0];
            
            self.borderViewColor = [UIColor whiteColor];
            
            self.animationDelay = 0.0;
            
            self.radius = 65.0;
            
            self.maxAngle = 180.0;
            
            self.startingAngle = 0.0;
            
            self.fixedInterItemAngle = 0.0;
            
            self.depth = NO;
            
            self.buttonRadius = 39.0;
            
            self.buttonBorderWidth = 2.0;
        }
    }
    
    return self;
}

- (id)initAtOrigin:(CGPoint)centerPoint usingOptions:(NSDictionary*)optionsDictionary withImageArray:(NSArray*)imagesArray andLabelArray:(NSArray *)labelsArray
{
    self = [self initWithOptions:optionsDictionary];
    
    if (self)
    {
        self.frame = CGRectMake(centerPoint.x - self.radius - self.buttonRadius, centerPoint.y - self.radius - self.buttonRadius, self.radius * 2 + self.buttonRadius * 2, self.radius * 2 + self.buttonRadius * 2);
     
        int ttag = 1;
        
        for (UIImage* img in imagesArray)
        {
            // Round buton view
            
            UIView* tView = [self createButtonViewWithImage:img andtag:ttag];
            
            // Button label
            
            UILabel * tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tView.frame.size.height, tView.frame.size.width, kLabelHeight)];
            
            [tLabel setBackgroundColor:[UIColor kLabelBackgroundColor]];
            [tLabel setAlpha:kLabelAlpha];
            [tLabel setText:NSLocalizedString([labelsArray objectAtIndex:(ttag-1)], nil)];
            [tLabel setFont:[UIFont fontWithName:@kFontInLabel size:kFontSizeInLabel]];
            [tLabel setTextColor:[UIColor kFontColorInLabel]];
            [tLabel setClipsToBounds:YES];
            [tLabel setTextAlignment:NSTextAlignmentCenter];
            [tLabel setNumberOfLines:1];
            [tLabel setAdjustsFontSizeToFitWidth:YES];
            [tLabel setMinimumScaleFactor:0.5];
            
            [tLabel.layer setShadowColor:[[UIColor kShadowColorInLabel] CGColor]];
            [tLabel.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
            [tLabel.layer setShadowRadius:1.0];
            [tLabel.layer setShadowOpacity:0.8];
            [tLabel.layer setMasksToBounds:NO];
            [tLabel.layer setShouldRasterize:YES];
            
            // Parent view
            
            UIView* pView = [[UIView alloc] initWithFrame:CGRectMake(tView.frame.origin.x, tView.frame.origin.y, tView.frame.size.width, tView.frame.size.height+kLabelHeight)];

            // Add round button view
            [pView addSubview:tView];
            
            // Add button label
            [pView addSubview:tLabel];
        
            [self.buttons addObject:pView];
            
            ttag++;
        }
    }
    
    return self;
}

- (id)initAtOrigin:(CGPoint)centerPoint usingOptions:(NSDictionary*)optionsDictionary withImages:(UIImage*)anImage, ...
{
    self = [self initWithOptions:optionsDictionary];
    
    if (self)
    {
        self.frame = CGRectMake(centerPoint.x - self.radius - self.buttonRadius, centerPoint.y - self.radius - self.buttonRadius, self.radius * 2 + self.buttonRadius * 2, self.radius * 2 + self.buttonRadius * 2);

        int ttag = 1;
        
        va_list args;
        
        va_start(args, anImage);
        
        for (UIImage* img = anImage; img != nil; img = va_arg(args, UIImage*))
        {
            UIView* tView = [self createButtonViewWithImage:img andtag:ttag];

            [self.buttons addObject:tView];
            
            ttag++;
        }
        
        va_end(args);
    }
    
    return self;
}

// Create a circle button consisting of the image, a background and a border. tag is a unique identifier (should be index + 1)
// Returns UIView to be used as button
- (UIView*)createButtonViewWithImage:(UIImage*)buttonImage andtag:(int)tag
{
    UIButton* tButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tButton.userInteractionEnabled = NO;
    
    CGFloat tButtonViewX = 0; //self.buttonRadius - self.buttonRadius / 2;
    
    CGFloat tButtonViewY = 0; //self.buttonRadius - self.buttonRadius / 2;
    
    tButton.frame = CGRectMake(tButtonViewX, tButtonViewY, self.buttonRadius*2, self.buttonRadius*2);
    
    [tButton setImage:buttonImage forState:UIControlStateNormal];

    [[tButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    
    [tButton setTitle:@"Testing" forState:UIControlStateNormal];

    tButton.tag = tag + TAG_BUTTON_OFFSET;
    
    UIView* tInnerView = [[RoundView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.buttonRadius * 2, self.buttonRadius * 2)];
    
    tInnerView.backgroundColor = self.innerViewColor;
    
    tInnerView.opaque = YES;
    
    tInnerView.clipsToBounds = YES;
    
    tInnerView.layer.cornerRadius = self.buttonRadius;
    
    tInnerView.layer.borderColor = [self.borderViewColor CGColor];
    
    tInnerView.layer.borderWidth = self.buttonBorderWidth;
    
    if (self.depth)
    {
        [self applyInactiveDepthToButtonView:tInnerView];
    }
    
    tInnerView.tag = tag + TAG_INNER_VIEW_OFFSET;
    
    [tInnerView addSubview:tButton];
    
    return tInnerView;
}

// Maths to put buttons on a circle
- (void)calculateButtonPositions
{
    if (!self.clippingView)
    {
        // Climb view hierarchy up, until first view with clipToBounds = YES
        self.clippingView = [self clippingViewOfChild:self];
    }
    
    CGFloat tMaxX = self.frame.size.width - self.buttonRadius;
    
    CGFloat tMinX = self.buttonRadius;
    
    CGFloat tMaxY = self.frame.size.height - self.buttonRadius;
    
    CGFloat tMinY = self.buttonRadius;
    
    if (self.clippingView)
    {
        CGRect tClippingFrame = [self.clippingView convertRect:self.clippingView.bounds toView:self];
    
        tMaxX = tClippingFrame.size.width + tClippingFrame.origin.x - self.buttonRadius * 2;
        
        tMinX = tClippingFrame.origin.x;
        
        tMaxY = tClippingFrame.size.height + tClippingFrame.origin.y - self.buttonRadius * 2;
        
        tMinY = tClippingFrame.origin.y;
    }
    
    int tButtonCount = (int)self.buttons.count;

    CGPoint tOrigin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    CGFloat tRadius = self.radius;
    
    int tCounter = 0;
    
    // If the InterItem Angle is fixed, change the max Angle and startingAngle accordingly
    
    if (self.fixedInterItemAngle > 0.0)
    {
        float totalAngle = self.fixedInterItemAngle *  (tButtonCount - 1);
        
        self.startingAngle = (self.maxAngle - totalAngle)/2;
        
        self.maxAngle -= (self.startingAngle + self.startingAngle);
    }
    
    // Issue #1 - align buttons perfectly on circle of max angle is 360.0
    if (self.maxAngle == 360.0)
    {
        self.maxAngle = 360.0 - 360.0 / self.buttons.count;
    }
    
    for (UIView* tView in self.buttons)
    {
        CGFloat tCurrentWinkel;
    
        if (tCounter == 0)
        {
            tCurrentWinkel = self.startingAngle + 0.0;
        }
        else if (tCounter > 0 && tCounter < tButtonCount)
        {
            tCurrentWinkel = self.startingAngle + (self.maxAngle / (tButtonCount-1)) * tCounter;
        }
        else
        {
            tCurrentWinkel = self.startingAngle + self.maxAngle;
        }
        
        CGSize tSize = tView.frame.size;
        
        CGFloat tX = tOrigin.x - (tRadius * cosf(tCurrentWinkel / 180.0 * M_PI)) - (tSize.width / 2);
        
        CGFloat tY = tOrigin.y - (tRadius * sinf(tCurrentWinkel / 180.0 * M_PI)) - (tSize.width / 2);
        
        if (tX > tMaxX) tX = tMaxX;
        
        if (tX < tMinX) tX = tMinX;
        
        if (tY > tMaxY) tY = tMaxY;
        
        if (tY < tMinY) tY = tMinY;
        
        CGRect tRect = CGRectMake(tX, tY, tSize.width, tSize.height);
        
        tView.frame = tRect;
        
        tCounter++;
    }
}

// Climb up the view hierarchy to find the first which has clipToBounds = YES.
// Returns the topmost view if no view has clipsToBound set to YES.
- (UIView*)clippingViewOfChild:(UIView*)aView
{
    UIView* tView = [aView superview];

    if (tView)
    {
        if (tView.clipsToBounds)
        {
            return tView;
        }
        else
        {
            return [self clippingViewOfChild:tView];
        }
    }
    else
    {
        return aView;
    }
}

- (void)openMenuWithRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(closeMenu) userInfo:nil repeats:NO];
    self.recognizer = gestureRecognizer;
    
    // Use target action to get notified upon gesture changes
    [gestureRecognizer addTarget:self action:@selector(gestureChanged:)];
    
    CGPoint tOrigin = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);

    [self calculateButtonPositions];
    
    for (UIView* tButtonView in self.buttons)
    {
        [self addSubview:tButtonView];
        
        tButtonView.alpha = 0.0;
        
        CGFloat tDiffX = tOrigin.x - tButtonView.frame.origin.x - self.buttonRadius;
        
        CGFloat tDiffY = tOrigin.y - tButtonView.frame.origin.y - self.buttonRadius;
        
        tButtonView.transform = CGAffineTransformMakeTranslation(tDiffX, tDiffY);
    }
    
    CGFloat tDelay = 0.0;
    
    for (UIView* tButtonView in self.buttons)
    {
        tDelay = tDelay + self.animationDelay;
    
        [UIView animateWithDuration:0.6 delay:tDelay usingSpringWithDamping:0.5 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
            tButtonView.alpha = 1.0;
            
            tButtonView.transform = CGAffineTransformIdentity;
        
        } completion:^(BOOL finished) {
            
        }];
    }
}

// Perform the closing animation.
- (void)closeMenu
{
    [_timer invalidate];
    [self.recognizer removeTarget:self action:@selector(gestureChanged:)];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        for (UIView* tButtonView in self.buttons)
        {
            if (self.hovertag > 0 && self.hovertag == [self baretagOfView:tButtonView])
            {
                tButtonView.transform = CGAffineTransformMakeScale(1.8, 1.8);
            }
            
            tButtonView.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenuClosed)])
        {
            [self.delegate circleMenuClosed];
        }
    }];
}

- (void)gestureMovedToPoint:(CGPoint)aPoint
{
    UIView* tView = [self hitTest:aPoint withEvent:nil];
    
    int ttag = [self baretagOfView:tView];
    
    if (ttag > 0)
    {
        if (ttag == self.hovertag)
        {
            // This button is already the active one
            return;
        }
        
        self.hovertag = ttag;
        
        // Display all (other) buttons in normal state
        [self resetButtonState];
        
        // Display this button in active color
        ttag = ttag + TAG_INNER_VIEW_OFFSET;

        UIView* tInnerView = [self viewWithTag:ttag];
        
        tInnerView.backgroundColor = self.innerViewActiveColor;
        
        if (self.depth)
        {
            [self applyActiveDepthToButtonView:tInnerView];
        }
        
    }
    else
    {
        // The view "hit" is none of the buttons -> display all in normal state
        
        [self resetButtonState];
    
        self.hovertag = 0;
    }
}

- (void)resetButtonState
{
    for (int i = 1; i <= self.buttons.count; i++)
    {
        UIView* tView = [self viewWithTag:i + TAG_INNER_VIEW_OFFSET];
    
        tView.backgroundColor = self.innerViewColor;
        
        if (self.depth)
        {
            [self applyInactiveDepthToButtonView:tView];
        }
    }
}

- (void)applyInactiveDepthToButtonView:(UIView*)aView
{
    aView.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    aView.layer.shadowOffset = CGSizeMake(4,2);
    
    aView.layer.shadowRadius = 8;
    
    aView.layer.shadowOpacity = 0.35;
    
    aView.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
}

- (void)applyActiveDepthToButtonView:(UIView*)aView
{
    aView.layer.shadowColor = [[UIColor blackColor] CGColor];

    aView.layer.shadowOffset = CGSizeMake(2,1);
    
    aView.layer.shadowRadius = 5;
    
    aView.layer.shadowOpacity = 0.42;
    
    aView.layer.affineTransform = CGAffineTransformMakeScale(0.985, 0.985);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches)
    {
        CGPoint tPoint = [touch locationInView:self];
        
        UIView* tView = [self hitTest:tPoint withEvent:nil];
        
        int ttag = [self baretagOfView:tView];
        
        if (ttag > 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenuActivatedButtonWithIndex:)])
            {
                [self.delegate circleMenuActivatedButtonWithIndex:ttag-1];
            }
        }
        
        [self closeMenu];
    }
}


//  Target action method that gets called when the gesture used to open CircleMenuView changes
- (void)gestureChanged:(UITapGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint tPoint = [sender locationInView:self];
    
        [self gestureMovedToPoint:tPoint];
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        // Determine wether a button was hit when the gesture ended
        CGPoint tPoint = [sender locationInView:self];
        
        UIView* tView = [self hitTest:tPoint withEvent:nil];
        
        int ttag = [self baretagOfView:tView];
        
        if (ttag > 0)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(circleMenuActivatedButtonWithIndex:)])
            {
                [self.delegate circleMenuActivatedButtonWithIndex:ttag-1];
            }
        }
        
        [self closeMenu];
    }
}

// Return the 'virtual' tag of the button (without offsets), no matter which of its components (image, background, border) is passed as argument, given the view to be examined
- (int)baretagOfView:(UIView*)examinedView
{
    int ttag = (int)examinedView.tag;
    
    if (ttag > 0)
    {
        if (ttag >= TAG_INNER_VIEW_OFFSET)
        {
            ttag = ttag - TAG_INNER_VIEW_OFFSET;
        }
        
        if (ttag >= TAG_BUTTON_OFFSET)
        {
            ttag = ttag - TAG_BUTTON_OFFSET;
        }
    }
    
    return ttag;
}

@end

@implementation RoundView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    // Pythagoras a^2 + b^2 = c^2
    CGFloat tRadius = self.bounds.size.width / 2;
    
    CGFloat tDiffX = tRadius - point.x;
    
    CGFloat tDiffY = tRadius - point.y;
    
    CGFloat tDistanceSquared = tDiffX * tDiffX + tDiffY * tDiffY;
    
    CGFloat tRadiusSquared = tRadius * tRadius;
    
    return tDistanceSquared < tRadiusSquared;
}

@end

