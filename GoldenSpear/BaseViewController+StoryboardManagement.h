//
//  BaseViewController+StoryboardManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController (StoryboardManagement)

// ViewController navigation
@property BaseViewController *fromViewController;
- (void)initGestureRecognizer;
- (void)swipeRightAction;
- (void)swipeLeftAction;
- (void)swipeUpAction;
- (void)swipeDownAction;
- (void)setFromViewController:(BaseViewController *)fromViewController;
- (void)prepareViewController: (BaseViewController*)nextViewController withParameters:(NSArray*)parameters;
- (void)transitionToViewController:(int) destinationVC withParameters:(NSArray *)parameters;
- (void)transitionToViewController:(int) destinationVC withParameters:(NSArray *)parameters fromViewController:(BaseViewController *) fromViewController;
//- (void)dismissAllViewControllers:(NSNotification *)notification;
- (void)dismissViewController;
- (void)showViewControllerModal:(UIViewController*)destinationVC;
- (void)showViewControllerModal:(UIViewController*)destinationVC withTopBar:(BOOL)topBarOrNot;
- (void)dismissControllerModal;

- (BaseViewController *)currentPresenterViewController;
- (void)setTitleForModal:(NSString*)theTitle;

- (void)showSuggestedUsersController;
- (void)panGesture:(UIPanGestureRecognizer *)sender;

@end
