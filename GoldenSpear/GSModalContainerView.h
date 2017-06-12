//
//  GSModalContainerView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface GSModalContainerView : UIView
@property (weak, nonatomic) IBOutlet UILabel *modalTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *controllerContainer;
@property (weak,nonatomic) BaseViewController* callingController;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeigthConstraint;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

- (IBAction)closePushed:(id)sender;

- (void)hideHeader:(BOOL)hideOrNot;
- (void)setupAutolayout;

- (void)setContainedController:(UIViewController*)viewcontroller;

@end
