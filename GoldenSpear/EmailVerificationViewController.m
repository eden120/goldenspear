//
//  EmailVerificationViewController.m
//  GoldenSpear
//
//  Created by JCB on 8/18/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "EmailVerificationViewController.h"

#define kEmailTranslation ((IS_IPHONE_4_OR_LESS) ? (180) : (140))

@interface EmailVerificationViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ExplainTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet UITextField *codeTextFeild;

@end

@implementation EmailVerificationViewController {
    CGFloat initialConstraint;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    initialConstraint = _ExplainTopSpaceConstraint.constant;
    self.codeTextFeild.delegate = self;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!(self.ExplainTopSpaceConstraint.constant == initialConstraint)) {
        return;
    }
    
    CGFloat newConstant = self.ExplainTopSpaceConstraint.constant - kEmailTranslation;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.ExplainTopSpaceConstraint.constant = newConstant;
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    CGFloat newConstant = self.ExplainTopSpaceConstraint.constant + kEmailTranslation;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.ExplainTopSpaceConstraint.constant = newConstant;
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}
- (IBAction)onTapSubmit:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    User *newUser = appDelegate.currentUser;
    NSLog(@"Validation Code : %@", newUser.emailvalidatedcode);
    if ([_codeTextFeild.text isEqualToString:newUser.emailvalidatedcode]) {
        newUser.emailvalidated = [NSNumber numberWithBool:YES];
        [newUser setDelegate:self];
        [newUser updateUserToServerDBVerbose:YES];
    }
    else {
        
    }
}

-(void)actionAfterSignUp {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
    [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(ACCOUNT_VC) stringValue]]];
    appDelegate.bAutoLogin = NO;
    return;
}

- (IBAction)onTapResend:(id)sender {
    
}
- (IBAction)onTapSignIn:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = nil;
    
    [self transitionToViewController:SIGNIN_VC withParameters: nil];
    
}

-(void)swipeRightAction {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentUser = nil;
    
    [super swipeRightAction];
}

@end