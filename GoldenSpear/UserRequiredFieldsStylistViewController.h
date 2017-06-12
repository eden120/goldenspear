//
//  UserEditProfileViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "BaseViewController+UserManagement.h"
#import "BaseViewController+MainMenuManagement.h"

#import "DatePickerViewButtons.h"
#import "PickerViewButtons.h"
#import "PickerFilteredViewButtons.h"

#import "TPKeyboardAvoidingScrollView.h"

#import <CoreLocation/CoreLocation.h>

@interface UserRequiredFieldsStylistViewController : BaseViewController<UINavigationControllerDelegate,UIActionSheetDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, DatePickerViewButtonsDelegate, PickerViewButtonsDelegate, PickerFilteredViewButtonsDelegate>

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *basicView;
@property (weak, nonatomic) IBOutlet UIView *basicSubview;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *prefixPhoneNumberTextEdit;
- (IBAction)btnPrefixPhoneNumber:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UITextField *genderTextEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnGender;
@property (nonatomic) long iGenderSelected;
@property (weak, nonatomic) IBOutlet UITextField *birthdateTextEdit;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPhoneConstraint;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)btnGender:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextField *professionTextEdit;
- (IBAction)professionEdit:(UITextField *)sender;
- (IBAction)genderEdit:(UITextField *)sender;

//protected functions
-(void) borderTextEdit:(UITextField *) _textField withColor:(UIColor *)_color withBorder:(float) _fBorderWith;
-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser;

@end
