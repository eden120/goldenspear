//
//  GSChangePasswordViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSChangePasswordViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"

#define kMinPasswordLength 8

@interface GSChangePasswordViewController ()

@end

@implementation GSChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
    for (UITextField* field in self.borderFields) {
        field.layer.borderColor = color.CGColor;
        field.layer.borderWidth= 1.0;
    }
}

- (BOOL)shouldCenterTitle{
    return YES;
}

- (IBAction)savePassword:(id)sender {
    User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;

    if (![self.oldPasswordField.text isEqualToString:theUser.passwordClear]){
        NSString * sMessage = NSLocalizedString(@"_OLD_PASSWORD_MISMATCH", nil);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:sMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return;
    }
    if (self.passwordField.text.length < kMinPasswordLength)
    {
        NSString * sMessage = [NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_MIN_CHAR", nil), kMinPasswordLength];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:sMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return;
    }
    
    if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PASSWORDS_MISMATCH", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return;
    }
    theUser.password = self.passwordField.text;
    theUser.delegate = self;
    [theUser updateUserToServerDBVerbose:YES];
}

- (void)userAccount:(User *)user didLogInSuccessfully:(BOOL)bLogInSuccess{
    user.delegate = nil;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) message:NSLocalizedString(@"_PASSWORD_CHANGED_SUCCESSFULLY_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    alertView.tag = 100;
    [alertView show];
}

- (void)userAccount:(User *)user didSignUpSuccessfully:(BOOL)bSignUpSuccess{
    User* theUser = ((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.passwordField.text forKey:@"Password"];
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOGIN_ACTV_MSG_", nil)];
        [theUser logInUserWithUsername:theUser.email andPassword:self.passwordField.text andVerbose:YES];
}

- (IBAction)cancelPushed:(id)sender {
    [self swipeRightAction];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 100){
        [self swipeRightAction];
    }
}

@end
