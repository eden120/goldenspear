//
//  UserForgotPasswordController.m
//  GoldenSpear
//
//  Created by Alberto Seco on 8/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UserForgotPasswordController.h"
#import "NSString+ValidateEMail.h"
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import <objc/runtime.h>
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"

#import "SearchBaseViewController.h"

#define kMinPasswordLength 8

@implementation UserForgotPasswordController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // border color gray of textfields
    UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
    self.emailForgot.layer.borderColor = color.CGColor;
    self.emailForgot.layer.borderWidth= 1.0f;
    
    self.txtCode.layer.borderColor = color.CGColor;
    self.txtCode.layer.borderWidth= 1.0f;
    self.txtPassword.layer.borderColor = color.CGColor;
    self.txtPassword.layer.borderWidth= 1.0f;
    self.txtPasswordConfirm.layer.borderColor = color.CGColor;
    self.txtPasswordConfirm.layer.borderWidth= 1.0f;
    
    self.viewNewPassword.hidden = YES;
}

-(void) retrievePasswordForEmail:(NSString *)email andVerbose:(BOOL) bVerbose
{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_RETRIEVINGPWD_USER_ACTV_MSG_", nil)];
    
// Setup request to upload user information
    NSString * sPath = [NSString stringWithFormat:@"/forgot_password_get_code"];
    
//    NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:nil
//                                                                                            method:RKRequestMethodPOST
//                                                                                              path:sPath
//                                                                                        parameters:nil
//                                                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
//                                    {
//                                        /* DOESN'T WORK!! :-( */
//                                    }];
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithObject:nil
                                                                               method:RKRequestMethodPOST
                                                                                 path:sPath
                                                                           parameters:nil];
    
    // Check that the request is properly created
    if (request == nil)
    {
        
        if (bVerbose)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_FORGOTPWD_ERROR_QUERY_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
        }
    }
    
    // Construct the request body, appending image to upload
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"{\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"email\": \"%@\",\n",email] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\"locale\": \"%@\"\n",@"en-us"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"}"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setTimeoutInterval:20];
    
    RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
                                                  {
                                                      [self successGettingCodeWithMapping:mappingResult andVerbose:bVerbose];
                                                  }
                                                                                                     failure:^(RKObjectRequestOperation *operation, NSError *error)
                                                  {
                                                      [self errorGettingCodeInOperation:operation withError:error andVerbose:bVerbose];
                                                  }];
    
    // Enqueue operation
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

-(void) errorGettingCodeInOperation:(RKObjectRequestOperation *)operation withError:(NSError *)error andVerbose:(BOOL) bVerbose
{
    // If upload failed, cancel identification process
    NSLog(@"Ooops! logInUserWithUsername error: %@ *** Response: %@ ***", error, operation.HTTPRequestOperation.responseString);
    
    if (bVerbose)
    {
        NSString * message = NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) ;
        if ((operation.HTTPRequestOperation.responseString != nil) && (![operation.HTTPRequestOperation.responseString  isEqualToString: @""]))
            message = NSLocalizedString(operation.HTTPRequestOperation.responseString,nil);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        
        [alertView show];
    }
    
    [self stopActivityFeedback];
}

-(void) successGettingCodeWithMapping:(RKMappingResult *) mappingResult andVerbose:(BOOL) bVerbose
{
    // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
    
    __block NSInteger downloadResult = -1;
    
    if (mappingResult == nil)
    {
        // No mapping
        downloadResult = -1;
    }
    else if (!(mappingResult.count > 0))
    {
        // No mapping
        downloadResult = -1;
    }
    else
    {
        // The answer didn't provide the expected information (but something was mapped, actually)
        // Then assume that the only mapped information was the "code" feedback
        if (downloadResult < 0)
        {
            NSNumber * code = [[mappingResult firstObject] valueForKey:@"code"];
            downloadResult = code.intValue;
        }
    }
    
    NSLog(@"RetrievePassword succeed! Code ID: %ld", (long)downloadResult);
    
    //   Code = -2 or -1 if something went wrong with the identification process
    //   Code = 0 if the identification process was correct.
    
    if (downloadResult >=0)
    {
        [self showViewNewPassword];
    }
    else
    {
        [self hideViewNewPassword];
        
    }
    
    [self stopActivityFeedback];
}

-(void) submitNewPassword:(NSString*) password forEmail:(NSString *)email withCode:(NSString*) code
{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_RETRIEVINGPWD_USER_ACTV_MSG_", nil)];
    
    // Setup request to upload user information
    NSString * sPath = [NSString stringWithFormat:@"/forgot_password_with_code"];
    
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithObject:nil
                                                                               method:RKRequestMethodPOST
                                                                                 path:sPath
                                                                           parameters:nil];
    
    // Check that the request is properly created
    if (request != nil)
    {
        // Construct the request body, appending image to upload
        NSMutableData *body = [NSMutableData data];
        
        [body appendData:[[NSString stringWithFormat:@"{\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\"email\": \"%@\",\n",email] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\"code\": \"%@\",\n",code] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\"password\": \"%@\"\n",password] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"}"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setTimeoutInterval:20];
        
        RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request
                                                                                                         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
                                               {
                                                   [self successSubmitNewPassword:mappingResult andVerbose:YES];
                                               }
                                                                                                         failure:^(RKObjectRequestOperation *operation, NSError *error)
                                               {
                                                   [self errorSubmitNewPassword:operation withError:error andVerbose:YES];
                                               }];
        
        // Enqueue operation
        [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
    }
    else
    {
        // TODO: show error message creating request
    }

}

-(void) errorSubmitNewPassword:(RKObjectRequestOperation *)operation withError:(NSError *)error andVerbose:(BOOL) bVerbose
{
    // If upload failed, cancel identification process
    NSLog(@"Ooops! logInUserWithUsername error: %@ *** Response: %@ ***", error, operation.HTTPRequestOperation.responseString);
    
    if (bVerbose)
    {
        NSString * message = NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) ;
        if ((operation.HTTPRequestOperation.responseString != nil) && (![operation.HTTPRequestOperation.responseString  isEqualToString: @""]))
            message = NSLocalizedString(operation.HTTPRequestOperation.responseString,nil);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        
        [alertView show];
    }
    
    [self stopActivityFeedback];
}

-(void) successSubmitNewPassword:(RKMappingResult *) mappingResult andVerbose:(BOOL) bVerbose
{
    // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
    
    __block NSInteger downloadResult = -1;
    
    if (mappingResult == nil)
    {
        // No mapping
        downloadResult = -1;
    }
    else if (!(mappingResult.count > 0))
    {
        // No mapping
        downloadResult = -1;
    }
    else
    {
        // The answer didn't provide the expected information (but something was mapped, actually)
        // Then assume that the only mapped information was the "code" feedback
        if (downloadResult < 0)
        {
            NSNumber * code = [[mappingResult firstObject] valueForKey:@"code"];
            downloadResult = code.intValue;
        }
    }
    
    NSLog(@"RetrievePassword succeed! Code ID: %ld", (long)downloadResult);
    
    //   Code = -2 or -1 if something went wrong with the identification process
    //   Code = 0 if the identification process was correct.
    
    if (downloadResult >=0)
    {
        [self login];
    }
    else
    {
        [self stopActivityFeedback];
        // Something went wrong with the request process...

        NSLog(@"Ooops! email not found.");

        if (bVerbose)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_FORGOTPWD_ERROR_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];

            [alertView show];
        }
        
    }
    
}

-(void) login
{
    NSString * usernameString;
    NSString * passwordString;
    
    passwordString = self.txtPassword.text;
    usernameString = self.emailForgot.text;

    User * loginUser;
    NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    loginUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
    [loginUser setDelegate:self];
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOGIN_ACTV_MSG_", nil)];
    [loginUser logInUserWithUsername:usernameString andPassword:passwordString andVerbose:YES];
    
}


- (IBAction)btnForgot:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSString * email = self.emailForgot.text;
    if ([NSString validateEmail:email]){
        [self retrievePasswordForEmail:email andVerbose:YES];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"Incorrect e-mail format", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        
        [alertView show];
    }
}

- (IBAction)finishEditing:(UITextField *)sender {
    [self btnForgot:nil];
}

- (IBAction)finishEditingHideKeyboard:(UITextField *)sender {
    [self becomeFirstResponder];
}

- (IBAction)btnNewPassword:(UIButton *)sender;
{
    if ([self checkFields])
    {
        [self submitNewPassword:self.txtPassword.text forEmail:self.emailForgot.text withCode:self.txtCode.text];
    }
}

-(void) showViewNewPassword
{
    if (self.viewNewPassword.hidden == NO)
    {
        self.lblExplanation.text = NSLocalizedString(@"_LBL_EXPLANATION_AGAIN_FORGOT_PWD_", nil);
    }
    else
    {
        self.lblExplanation.text = NSLocalizedString(@"_LBL_EXPLANATION_FORGOT_PWD_", nil);
    }
    
    self.viewNewPassword.hidden = NO;
}

-(void) hideViewNewPassword
{
    self.lblExplanation.text = NSLocalizedString(@"_LBL_EXPLANATION_FORGOT_PWD_", nil);
    self.viewNewPassword.hidden = YES;
}

-(BOOL) checkFields
{
    if (self.txtCode.text.length <= 0)
    {
        NSString * sMessage = [NSString stringWithFormat:NSLocalizedString(@"_PLEASE_FILL_MANDATORY_FIELDS_", nil), kMinPasswordLength];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:sMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    // Check if passwords match
    if (self.txtPassword.text.length < kMinPasswordLength)
    {
        NSString * sMessage = [NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_MIN_CHAR", nil), kMinPasswordLength];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:sMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    if (![self.txtPassword.text isEqualToString:self.txtPasswordConfirm.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PASSWORDS_MISMATCH", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

#pragma mark Login actions

// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    [super actionAfterLogIn];
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
}

- (void)swipeLeftAction
{
    return;
}


@end
