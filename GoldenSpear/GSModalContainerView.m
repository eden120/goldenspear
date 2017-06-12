//
//  GSModalContainerView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 2/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSModalContainerView.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"

@implementation GSModalContainerView

- (id)init{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                          owner:nil
                                                        options:nil];
    int i = 0;
    while(i<[arrayOfViews count]){
        if([[arrayOfViews objectAtIndex:i] isKindOfClass:[self class]]){
            self = [arrayOfViews objectAtIndex:i];
            self.layer.masksToBounds = YES;
            self.layer.borderWidth = 2;
            self.layer.borderColor = [[UIColor colorWithWhite:0.89 alpha:1] CGColor];
            return self;
        }
        i++;
    }
    return nil;
}

- (IBAction)closePushed:(id)sender {
    [self.callingController dismissControllerModal];
}

- (void)hideHeader:(BOOL)hideOrNot{
    self.headerView.hidden = hideOrNot;
    if(hideOrNot){
        self.headerViewHeigthConstraint.constant = 0;
        self.backgroundView.layer.borderWidth = 0;
    }else{
        self.headerViewHeigthConstraint.constant = 44;
        self.backgroundView.layer.borderWidth = 1;
        self.backgroundView.layer.borderColor = [UIColor blackColor].CGColor;
    }
    [self layoutIfNeeded];
}

- (void)setContainedController:(UIViewController*)viewcontroller{
    for(UIView* v in self.controllerContainer.subviews){
        [v removeFromSuperview];
    }
    [self.controllerContainer addSubview:viewcontroller.view];
    [self setupAutolayoutToEqualParent:viewcontroller.view];
    //[self setupAutolayoutForContained:viewcontroller.view];
    if ([viewcontroller isKindOfClass:[BaseViewController class]]) {
        [(BaseViewController*)viewcontroller hideTopBar];
    }
    
    [self.controllerContainer layoutIfNeeded];
}

- (void)setupAutolayout{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupAutolayoutToEqualParent:self];
}

- (void)setupAutolayoutToEqualParent:(UIView*)theView{
    //Height
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:theView.superview
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Center Vert
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Width
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Center Hori
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
}

- (void)setupAutolayoutForContained:(UIView*)theView{
    //Height
    NSLayoutConstraint* aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:theView.superview
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];
    [theView.superview addConstraint:aConstraint];
    
    //Center Vert
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1
                                                constant:0];
    [theView.superview addConstraint:aConstraint];
    
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1
                                                constant:0];
    aConstraint.priority = UILayoutPriorityDefaultHigh;
    [theView.superview addConstraint:aConstraint];
    
    
    aConstraint = [NSLayoutConstraint constraintWithItem:theView
                                               attribute:NSLayoutAttributeWidth
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:theView.superview
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1
                                                constant:0];
    aConstraint.priority = UILayoutPriorityDefaultHigh;
    [theView.superview addConstraint:aConstraint];
}

@end
