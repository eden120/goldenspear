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
#import "MultiSelectViewButtons.h"
#import "PickerFilteredViewButtons.h"

#import "TPKeyboardAvoidingScrollView.h"

#import "CustomCameraViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "GSUserWhoAreYouViewController.h"
#import "GSAccountDetailViewController.h"

@interface UserEditProfileViewController : BaseViewController<CustomCameraViewControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, DatePickerViewButtonsDelegate, PickerViewButtonsDelegate, MultiSelectViewButtonsDelegate, CLLocationManagerDelegate,  GSUserWhoAreYouDelegate,GSAccountDetailViewControllerDelegate,UIAlertViewDelegate>

-(void) loadCitiesFromServer:(Country *) country andState:(StateRegion *)state skip:(int)iSkip limit:(int)iLimit;
-(void) loadCitiesFromServerFiltering:(NSString *) filter;
-(void) loadNextCitiesFromServer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistanceConstraint;
@property (nonatomic) BOOL bLoadingCities;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *basicView;
@property (weak, nonatomic) IBOutlet UIView *basicSubview;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *locationView;
@property (weak, nonatomic) IBOutlet UIView *locationSubview;
@property (weak, nonatomic) IBOutlet UIButton *btnLocateMe;
- (IBAction)locateMeClick:(UIButton *)sender;
- (IBAction)locationStateRegionButton:(UIButton *)sender;
- (IBAction)locationCityButton:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *emailTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *locationTextEdit;
@property (nonatomic) long iGenderSelected;
@property (weak, nonatomic) IBOutlet UITextField *birthdateTextEdit;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *locationScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintLocation;
@property (weak, nonatomic) IBOutlet UISwitch *publicButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSlideConstraint;


@property (weak, nonatomic) IBOutlet UITextField *countryTextEdit;
- (IBAction)countryButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *stateTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *address1TextEdit;
@property (weak, nonatomic) IBOutlet UITextField *address2TextEdit;
@property (weak, nonatomic) IBOutlet UITextField *cityTextEdit;
@property (weak, nonatomic) IBOutlet UITextField *postalTextEdit;

- (IBAction)hideKeyboard:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *professionTextEdit;
- (IBAction)professionEdit:(UITextField *)sender;

//protected functions
-(void) borderTextEdit:(UITextField *) _textField withColor:(UIColor *)_color withBorder:(float) _fBorderWith;
-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser;

//NEW PROFILE

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;

- (IBAction)saveProfile:(id)sender;
- (IBAction)hideLocationView:(id)sender;
- (IBAction)saveLocation:(id)sender;
- (IBAction)cancelProfile:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
