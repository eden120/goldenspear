//
//  UserSignUpViewController.h
//  GoldenSpear
//
//  Created by Alberto Seco on 29/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "BaseViewController+UserManagement.h"
#import "BaseViewController+MainMenuManagement.h"

#import "DatePickerViewButtons.h"

#import "TPKeyboardAvoidingScrollView.h"

#import "CustomCameraViewController.h"

@interface UserSignUpViewController : BaseViewController<CustomCameraViewControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, DatePickerViewButtonsDelegate>


// Current Ad shown
@property BackgroundAd * currentBackgroundAd;

// Background Ad
@property (weak, nonatomic) IBOutlet UIImageView *backgroundAdImageView;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;
@property (weak, nonatomic) IBOutlet UILabel *backgroundAdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *companyName;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

// User login info
@property (weak, nonatomic) IBOutlet UITextField *usernameTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *emailTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *retypePasswordTextEdit;

// Terms & Conditions
@property (weak, nonatomic) IBOutlet UIView *viewTermsConditions;
@property (weak, nonatomic) IBOutlet UIWebView *webViewTermsConditions;

- (IBAction)hideKeyboard:(id)sender;

// Protected functions
-(void) borderTextEdit:(UITextField *) _textField withColor:(UIColor *)_color withBorder:(float) _fBorderWith;
-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameToTopSpaceConstraint;


// OLD STUFF
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *locationTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *genderTextEdit;
@property (nonatomic) long iGenderSelected;
@property (weak, nonatomic) IBOutlet UITextField *birthdateTextEdit;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *locationScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintLocation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSlideConstraint;

@property (weak, nonatomic) IBOutlet UITextField *countryTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *stateTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *address1TextEdit;
@property (weak, nonatomic) IBOutlet UITextField *address2TextEdit;
@property (weak, nonatomic) IBOutlet UITextField *cityTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *postalTextEdit;


- (IBAction)btnGender:(UIButton *)sender;

@end
