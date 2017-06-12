//
//  GSTextEditViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 6/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTextEditViewController.h"
#import "BaseViewController+StoryboardManagement.h"

@interface GSTextEditViewController ()

@end

@implementation GSTextEditViewController{
    CGFloat oldConstant;
    CGFloat keyboardHeight;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    oldConstant = self.bottomDistanceConstraint.constant;
    keyboardHeight = 0;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.controllerTitle.superview.layer.borderColor = [UIColor blackColor].CGColor;
    self.controllerTitle.superview.layer.borderWidth= 1;
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self animateTextViewFrameForVerticalHeight:oldConstant];
    return YES;
}

- (IBAction)acceptPushed:(id)sender {
    [self.textDelegate commitEditionWithString:self.textEdit.text];
}

- (IBAction)cancelButtonPushed:(id)sender {
    [self.currentPresenterViewController dismissControllerModal];
}

- (void)animateTextViewFrameForVerticalHeight:(CGFloat)height{
    if (oldConstant<height+20) {
        height = height+20;
        self.bottomDistanceConstraint.constant = MAX(height,oldConstant);
        [self.view layoutIfNeeded];
    }
}

// Calculate the vertical increase when keyboard appears
- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification
{
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    
    return keyboardVerticalIncrease;
}

- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset
{
    CGFloat constant = self.bottomDistanceConstraint.constant;
    if(constant<=oldConstant+20){
        constant = 0;
    }
    CGFloat newConstant = constant + offset;// + 50;
    [self animateTextViewFrameForVerticalHeight:newConstant];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:oldConstant];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    [self animateTextViewFrameForVerticalHeight:keyboardHeight];
}

- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification
{
    // Calculate vertical increase
    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
    keyboardHeight += keyboardVerticalIncrease;
    // Properly animate Add Terms text box
    [self animateTextViewFrameForVerticalOffset:keyboardVerticalIncrease];
}

@end
