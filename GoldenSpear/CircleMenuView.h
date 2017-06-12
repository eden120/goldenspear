//
//  CircleMenuView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 15/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircleMenuDelegate <NSObject>

@optional

// Called when the CircleMenu has shown up.
- (void)circleMenuOpened;

//Informs the delegate that the menu is going to be closed with the button specified by the index being activated.
- (void)circleMenuActivatedButtonWithIndex:(int)buttonIndex;

// Called when the CircleMenu has been closed. This is usually sent immediately after circleMenuActivatedButtonWithIndex:.
- (void)circleMenuClosed;

@end

// Constants used for the configuration dictionary
extern NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_NORMAL;
extern NSString* const CIRCLE_MENU_BUTTON_BACKGROUND_ACTIVE;
extern NSString* const CIRCLE_MENU_BUTTON_BORDER;
extern NSString* const CIRCLE_MENU_OPENING_DELAY;
extern NSString* const CIRCLE_MENU_RADIUS;
extern NSString* const CIRCLE_MENU_MAX_ANGLE;
extern NSString* const CIRCLE_FIXED_INTERITEM_ANGLE;
extern NSString* const CIRCLE_MENU_DIRECTION;
extern NSString* const CIRCLE_MENU_DEPTH;
extern NSString* const CIRCLE_MENU_BUTTON_RADIUS;
extern NSString* const CIRCLE_MENU_BUTTON_BORDER_WIDTH;


typedef enum
{
    CircleMenuDirectionUp = 1,
    CircleMenuDirectionRight,
    CircleMenuDirectionDown,
    CircleMenuDirectionLeft
}
CircleMenuDirection;

@interface CircleMenuView : UIView

@property (weak, nonatomic) id<CircleMenuDelegate> delegate;
@property (strong, nonatomic) NSTimer * timer;

// Init the CircleMenuView with the center of the menu's circle, optional configuration (may be nil), and a dynamic list of images (nil-terminated!) to be used for the buttons (icon images should be 32x32 points (64x64 px for retina))
- (id)initAtOrigin:(CGPoint)centerPoint usingOptions:(NSDictionary*)optionsDictionary withImages:(UIImage*)anImage, ... NS_REQUIRES_NIL_TERMINATION;

// Init the CircleMenuView with the center of the menu's circle, optional configuration (may be nil), and an array of images to be used for the buttons (icon images should be 32x32 points (64x64 px for retina))
- (id)initAtOrigin:(CGPoint)centerPoint usingOptions:(NSDictionary*)optionsDictionary withImageArray:(NSArray*)imagesArray andLabelArray:(NSArray *)labelsArray;

// Open the menu with the buttons and settings specified in the init, passing the UILongPressGestureRecognizer that has been used to detect the long press. This recognizer will be used to track further drag gestures to select a button and to close the menu, once the gesture ends
- (void)openMenuWithRecognizer:(UIGestureRecognizer*)gestureRecognizer;

// Possibility to close the menu externally
- (void)closeMenu;

@end

@interface RoundView : UIView

@end

