//
//  CustomAlertView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 01/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol CustomAlertViewDelegate

- (void)customAlertViewButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomAlertView : UIView <CustomAlertViewDelegate>

// Dialog's container view
@property (nonatomic, retain) UIView *dialogView;
 // Container within the dialog (place ui elements here)
@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, assign) id<CustomAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(CustomAlertView *alertView, int buttonIndex) ;

- (id)init;

- (void)show;
- (void)close;

- (IBAction)customAlertViewButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(CustomAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

@end