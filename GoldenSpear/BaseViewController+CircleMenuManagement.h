//
//  BaseViewController+CircleMenuManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 15/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController (CircleMenuManagement) <CircleMenuDelegate>

@property NSNumber *bPressedLeftButton;
- (void)setupLeftCircleMenuDefaults;

-(void) actionForLeftFirstCircleMenuEntry;
-(void) actionForLeftSecondCircleMenuEntry;

@property NSNumber *bPressedRightButton;
- (void)setupRightCircleMenuDefaults;

-(void) actionForRightFirstCircleMenuEntry;
-(void) actionForRightSecondCircleMenuEntry;

@property NSNumber *bPressedMainButton;
- (void)setupMainCircleMenuDefaults;

-(void) actionForMainFirstCircleMenuEntry;
-(void) actionForMainSecondCircleMenuEntry;
-(void) actionForMainThirdCircleMenuEntry;
-(void) actionForMainFourthCircleMenuEntry;

@end
