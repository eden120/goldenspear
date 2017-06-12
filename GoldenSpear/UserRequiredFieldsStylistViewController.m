//
//  UserEditProfileViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UserRequiredFieldsStylistViewController.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "NSString+ValidateEMail.h"
#import "NSString+ValidatePhone.h"
#import "NSString+CheckWhiteSpaces.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "User+Manage.h"

#import "PickerViewButtons.h"

#define kMinPasswordLength 8
#define kMinUsernameLength 3

@implementation UserRequiredFieldsStylistViewController
{
    UITextField * textFieldEditing;
    NSMutableArray * arElementsPickerView;
    NSString * sOldElementsSelectedInMultiSelectView;
    NSInteger iIdxElementSelectedInPickerView;
    NSInteger iIdxOldElementSelectedInPickerView;
    
    UIAlertController* alertGender;
    
    BOOL bPictureDirty;
    NSArray * _pickerGender;
    NSDate * birthDate;
    NSDate * oldBirthDate;
    AppDelegate *appDelegate;
    
    CGFloat kTopConstraintPhonenumber;
    
    PickerFilteredViewButtons *pickerFilteredPickerView;

    NSMutableArray * arCountries;
    NSMutableArray * arCountriesCallingCodes;
    BOOL bLoadingCountries;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bLoadingCountries = NO;
    
    kTopConstraintPhonenumber = self.topPhoneConstraint.constant;
    
    // add delegat for keyboard
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    bPictureDirty = NO;
    // data for gender picker
    _pickerGender = @[NSLocalizedString(@"_MALE_",nil), NSLocalizedString(@"_FEMALE_",nil), NSLocalizedString(@"_COMPLICATED_",nil), NSLocalizedString(@"_PREFER_NO_SAY_",nil)];
    
    // border color gray of textfields
    UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
    [self setupBorderTextFieldsFor:self.basicSubview withColor:color];
//    [self disabledFields:self.locationSubview];

    
    [self setupMandatoryTextFieldsFor:self.basicSubview ];
    
    [self setupHideKeyboard:self.basicSubview ];
    
    
    // personalize bottom button
    //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) ];
//    [self setLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andImage:[UIImage imageNamed:@"left_arrow.png"]];
//    [self setRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) andImage:[UIImage imageNamed:@"_MENUENTRY_50B_.png"]];
//    
    // si usuario esta logueado mostramos la informacion
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser != nil)
    {
        [self loadDataForUser:appDelegate.currentUser];
        appDelegate.currentUser.delegate = self;
    }
    
    [self loadCountriesFromServer];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (appDelegate.currentUser != nil)
    {
        [self loadDataForUser:appDelegate.currentUser];
    }
}

// Custom animation to dismiss view controller
- (void)dismissViewController
{
    [super dismissViewController];
}

-(void) setupBorderTextFieldsFor:(UIView *)view withColor:(UIColor * ) color
{
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            [self borderTextEdit:(UITextField *)viewChild withColor:color withBorder:1.0f];
        }
    }
}

-(void) setupMandatoryTextFieldsFor:(UIView *)view
{
    UIFont * fontOptional = [UIFont fontWithName:@"Avenir-Medium" size:16];
    UIFont * fontMandatory = [UIFont fontWithName:@"Avenir-Black" size:16];
    
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UILabel class]])
        {
            UILabel * lbl = ((UILabel *)viewChild);
            if (lbl.tag == 1)
            {
                if ([lbl.text containsString:@"*"] == NO)
                {
                    lbl.text = [lbl.text stringByAppendingString:@" *"];
                }
                [lbl setFont:fontMandatory];
            }
            else if (lbl.tag == 0)
            {
                [lbl setFont:fontOptional];
            }
            
        }
    }
}

-(void) disabledFields:(UIView *) view
{
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            UITextField * lbl = ((UITextField *)viewChild);
            lbl.enabled = NO;
        }
    }
}

-(void) setupHideKeyboard:(UIView *)view
{
    for (UIView * viewChild in view.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            UITextField * textfield = ((UITextField *)viewChild);
            
            [textfield removeTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [textfield addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
            
        }
    }
}
-(void) hideKeyboardInView:(UIView *)view
{
    for (UIView * viewChild in view.subviews)
    {
        [viewChild resignFirstResponder];
    }
}

#pragma mark - Bottom buttons actions
/*
// Left action
- (void)leftAction:(UIButton *)sender
{
    if (appDelegate.currentUser != nil)
    {
        appDelegate.currentUser.delegate = self;
        
        [appDelegate.currentUser logOut];
        
        [self showMainMenu:nil];
    }
//    if (!([self fromViewController] == nil))
//    {
//        [self dismissViewController];
//    }
}

// Right action
- (void)rightAction:(UIButton *)sender
{
    if ([self checkFieldsBasic])
    {
        [self updateUser];
        
        NSString * key = [NSString stringWithFormat:@"HIGHLIGHTFINISH_%d", [self.restorationIdentifier intValue]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Save into defaults if doesn't already exists
        if (!([defaults objectForKey:key]))
        {
            [defaults setInteger:1 forKey:key];
            
            [defaults synchronize];
        }
        else
        {
            int iNumHighlights = (int)[defaults integerForKey:key];
            
            [defaults setInteger:(iNumHighlights+1) forKey:key];
            
            [defaults synchronize];
        }
    }
    // Hide keyboard
    [self.view endEditing:YES];
}
*/
// Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    [super swipeRightAction];
}


#pragma mark - Load User data
-(void) loadDataForUser:(User * ) user
{
    self.firstNameTextEdit.text = user.name;
    self.lastNameTextEdit.text = user.lastname;
    self.phoneNumberTextEdit.text = user.phone;
    self.prefixPhoneNumberTextEdit.text = user.phonecallingcode;
    _iGenderSelected = [user.gender intValue];
    self.genderTextEdit.text = [user sGetTextGender];
    birthDate = user.birthdate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:user.birthdate];
    
    NSString * fullName;
    if (user.lastname != nil)
    {
        fullName =  [NSString stringWithFormat:@"%@ %@", user.name, user.lastname];
    }
    else
    {
        fullName =  [NSString stringWithFormat:@"%@", user.name];
    }
    self.titleLabel.text = [NSLocalizedString(@"_EDIT_PROFILE_", nil) uppercaseString];
    self.subtitleLabel.text = fullName;
    
    self.professionTextEdit.text = [user sGetTextProfession];
    
}

#pragma mark - Birthdate
// Set birthdate using a UIDatePicker
- (IBAction)editBirthdate:(UITextField *)sender
{
    
    CGRect frame = self.view.frame;
    DatePickerViewButtons *datePicker = [[DatePickerViewButtons alloc] initWithFrame:frame ];
    [datePicker updateFrame:self.view.frame];
    [datePicker setDate:birthDate];
    oldBirthDate = birthDate;
    datePicker.delegate = self;
    
    self.birthdateTextEdit.inputView = datePicker;
}

// Update Birthdate text field
-(void)updateBirthdate:(id)sender
{
    DatePickerViewButtons *datePicker = (DatePickerViewButtons*) self.birthdateTextEdit.inputView;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:datePicker.pickerView.date];
    birthDate = datePicker.pickerView.date;
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView changeDate:(NSDate *)date
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:date];
    birthDate = datePickerView.pickerView.date;
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView didButtonClick:(BOOL)bOk withDate:(NSDate *)date
{
    if (bOk == YES)
    {
        birthDate = datePickerView.pickerView.date;
    }
    else
    {
        birthDate = oldBirthDate;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:birthDate];
    
    [self.view endEditing:YES];
}

#pragma mark - Gender

- (IBAction)genderEdit:(UITextField *)sender
{
    textFieldEditing = self.genderTextEdit;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    iIdxElementSelectedInPickerView = -1;
    
    iIdxOldElementSelectedInPickerView = -1;
    
    NSArray * objs = [appDelegate.config valueForKey:@"gender_types"];
    
    for (int i = 0; i < objs.count; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString([objs objectAtIndex:i],nil)];
    }
    
    iIdxOldElementSelectedInPickerView = appDelegate.currentUser.gender.intValue;
    
    
    CGRect frame = self.view.frame;
    
    PickerViewButtons *myPickerView = [[PickerViewButtons alloc] initWithFrame:frame];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    if (iIdxOldElementSelectedInPickerView != -1)
    {
        [myPickerView.pickerView selectRow:iIdxOldElementSelectedInPickerView inComponent:0 animated:YES];
    }
    
    textFieldEditing.inputView = myPickerView;
}


- (IBAction)btnGender:(UIButton *)sender {
    [self.view endEditing:YES];
    [sender resignFirstResponder];
    [self editGender:self.genderTextEdit];
}


- (IBAction)editGender:(UITextField *)sender
{
    //    [self.genderTextEdit resignFirstResponder];
    //    [self.view endEditing:YES];
    
    alertGender = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_GENDER_",nil)
                                                                   message:NSLocalizedString(@"_SELECT_GENDER_", nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_CANCEL_BTN_",nil) style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              [self.view endEditing:YES];
                                                              [sender resignFirstResponder];
                                                          }];
    
    UIAlertAction* maleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_MALE_",nil) style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           _iGenderSelected = 1;
                                                           sender.text = _pickerGender[0];
                                                           [self.view endEditing:YES];
                                                       }];
    UIAlertAction* femaleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_FEMALE_",nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             _iGenderSelected = 2;
                                                             sender.text = _pickerGender[1];
                                                             [self.view endEditing:YES];
                                                         }];
    UIAlertAction* itsComplicated = [UIAlertAction actionWithTitle:NSLocalizedString(@"_COMPLICATED_",nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               _iGenderSelected = 3;
                                                               sender.text = _pickerGender[2];
                                                               [self.view endEditing:YES];
                                                           }];
    UIAlertAction* preferNotSay = [UIAlertAction actionWithTitle:NSLocalizedString(@"_PREFER_NO_SAY_",nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               _iGenderSelected = 4;
                                                               sender.text = _pickerGender[3];
                                                               [self.view endEditing:YES];
                                                           }];
    [alertGender addAction:maleAction];
    [alertGender addAction:femaleAction];
    [alertGender addAction:itsComplicated];
    [alertGender addAction:preferNotSay];
    [alertGender addAction:defaultAction];
    [self presentViewController:alertGender animated:YES completion:nil];
    
}

#pragma mark - calling code

-(void) loadCountriesFromServer
{
    NSLog(@"Loading all countries info");
    bLoadingCountries = YES;
    
    // get all product categories
    [self performRestGet:GET_ALLCOUNTRIES withParamaters:nil];
    
}

-(void) getCountriesFromServer:(NSArray *)mappingResult
{
    if (arCountriesCallingCodes != nil)
    {
        [arCountriesCallingCodes removeAllObjects];
    }
    else
    {
        arCountriesCallingCodes = [[NSMutableArray alloc] init];
    }
    
    
    if (arCountries != nil)
    {
        [arCountries removeAllObjects];
    }
    
    NSMutableArray * arTemp = [[NSMutableArray alloc] init];
    for (Country *country in mappingResult)
    {
        if([country isKindOfClass:[Country class]])
        {
            Country * c = (Country *)country;
            [arTemp addObject:c];
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    arCountries = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingDescriptors:sortDescriptors]];
    
    for(Country * c in arCountries)
    {
        NSArray * arCallingCodes = [c getCallingCodes];
        for(NSString * sCallingCode in arCallingCodes)
        {
            [arCountriesCallingCodes addObject:sCallingCode];
        }
    }
    
    
    bLoadingCountries = NO;
    
    //    arCountries = [[NSMutableArray alloc] initWithArray:[arTemp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
}

- (IBAction)btnPrefixPhoneNumber:(UIButton *)sender {
    if (bLoadingCountries == YES)
    {
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOADING_COUNTRIES_", nil)];
        return;
    }
    
    NSMutableArray * objs = [[NSMutableArray alloc] init];
    int iIdx = 0;
    int iIdxSelected = -1;
    for(Country * c in arCountries)
    {
        NSArray * arCallingCodes = [c getCallingCodes];
        for(NSString * sCallingCode in arCallingCodes)
        {
            NSString *sCountryCallingCode = [NSString stringWithFormat:@"%@ [+%@]", c.name, sCallingCode];
            [objs addObject:sCountryCallingCode];
            NSString * sCallingCodePlus = [NSString stringWithFormat:@"+%@", sCallingCode];
            if ([self.prefixPhoneNumberTextEdit.text isEqualToString:@""])
            {
                if ([sCallingCodePlus isEqualToString:appDelegate.currentUser.phonecallingcode])
                {
                    iIdxSelected = iIdx;
                }
            }
            else
            {
                if ([sCallingCodePlus isEqualToString:self.prefixPhoneNumberTextEdit.text])
                {
                    iIdxSelected = iIdx;
                }
            }
            iIdx++;
        }
    }
    
    [self initPickerFilteredViewWithElements:objs forTextField:self.prefixPhoneNumberTextEdit withElementSelected:iIdxSelected];
}


#pragma mark - updateUser
// Save user profile
- (void)updateUser
{
    // Hide keyboard if the user press the 'Create' button
    [self.view endEditing:YES];
    
    if ([self checkFieldsBasic])
    {
        User * originalUser = appDelegate.currentUser;
        User * updateUser;
        NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        //        newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:currentContext];
        updateUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
        
        
        [self getDataUserForUser:updateUser originalUser:originalUser];
        
        [updateUser setDelegate:self];
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
        [updateUser updateUserToServerDBVerbose:YES];
    }
}

-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser
{
    // Get UUID from iOS defaults system
    // Get UUID from iOS defaults system
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [user setUserWithUUID:[defaults objectForKey:@"UUID"]
                andUserID:originalUser.idUser
                  andName:self.firstNameTextEdit.text
               andSurname:self.lastNameTextEdit.text
                 andEmail:originalUser.email
              andPassword:originalUser.password
                 andPhone:self.phoneNumberTextEdit.text
             andBirthdate:birthDate
                andGender:[NSNumber numberWithInteger:_iGenderSelected]
          andPicpermision:YES
               andPicPath:originalUser.picture
                   andPic:nil
             andWardrobes:originalUser.wardrobes
               andReviews:originalUser.reviews
               andCountry:originalUser.country
                 andState:originalUser.addressState
                  andCity:originalUser.addressCity
              andAddress1:originalUser.address1
              andAddress2:originalUser.address2
            andPostalCode:originalUser.addressPostalCode
              andUserName:originalUser.fashionistaName
               andWebsite:originalUser.fashionistaBlogURL
                   andBio:originalUser.fashionistaTitle];
    
    user.phonecallingcode = self.prefixPhoneNumberTextEdit.text;
    
    user.passwordClear = originalUser.passwordClear;
    
    user.typeprofession = originalUser.typeprofession;
    user.validatedprofile = originalUser.validatedprofile;
    user.datequeryvalidateprofile = originalUser.datequeryvalidateprofile;
    user.datevalidatedprofile = originalUser.datevalidatedprofile;
}


#pragma mark - createUser
- (void)actionAfterSignUp
{
    [super actionAfterSignUp];
    
    if ([appDelegate.currentUser isUserComplete] == NO)
    {
        [self loadDataForUser:appDelegate.currentUser];
    }
}

#pragma mark - Login actions

// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    [super actionAfterLogIn];
    if ([appDelegate.currentUser isUserComplete] == NO)
    {
        [self loadDataForUser:appDelegate.currentUser];
    }
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
}


#pragma mark - Events to control when the keyboard appears, and adapt the constraint to it
//- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification {
////    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
////    [self animateTextViewFrameForVerticalOffset:keyboardVerticalIncrease];
//}

- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification {
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    return keyboardVerticalIncrease;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
    
}

#pragma mark - ProtectedFunctions
-(void) borderTextEdit:(UITextField *) _textField withColor:(UIColor *)_color withBorder:(float) _fBorderWith
{
    _textField.layer.borderColor = _color.CGColor;
    _textField.layer.borderWidth= _fBorderWith;
    
}

#pragma mark - PrivateFunctions
// Provides the path for a given file
- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}


- (IBAction)hideKeyboard:(id)sender
{
    if (sender == self.phoneNumberTextEdit)
    {
        NSLog(@"Validate Phone %@", [NSString validatePhone:self.phoneNumberTextEdit.text] ? @"OK" : @"KO");
    }
    
    if (alertGender != nil)
    {
        [alertGender dismissViewControllerAnimated:NO completion:nil];
        alertGender = nil;
    }
    [self.view endEditing:YES];
    [sender resignFirstResponder];
}

-(BOOL) checkFieldsMandatoryInView:(UIView *)viewToCheck
{
    for(UIView * viewChild in viewToCheck.subviews)
    {
        if ([viewChild isKindOfClass:[UITextField class]])
        {
            UITextField * textToCheck = (UITextField *)viewChild;
            
            if ((textToCheck.tag == 1) && (textToCheck.hidden == NO))
            {
                if ([textToCheck.text isEqualToString:@""])
                {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}


#pragma mark - Alert views management


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"_AREYOUSURE_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_COMPLETE_FORM_", nil)])
        {
        }
        else if([title isEqualToString:NSLocalizedString(@"_CONTINUE_", nil)])
        {
            // Hide keyboard if the user press the 'Create' button
            [self.view endEditing:YES];

            User * originalUser = appDelegate.currentUser;
            User * updateUser;
            NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            //        newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:currentContext];
            updateUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
            
            
            [self getDataUserForUser:updateUser originalUser:originalUser];
            
            [updateUser setDelegate:self];
            
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
            [updateUser updateUserToServerDBVerbose:YES];
            
            NSString * key = [NSString stringWithFormat:@"HIGHLIGHTFINISH_%d", [self.restorationIdentifier intValue]];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // Save into defaults if doesn't already exists
            if (!([defaults objectForKey:key]))
            {
                [defaults setInteger:1 forKey:key];
                
                [defaults synchronize];
            }
            else
            {
                int iNumHighlights = (int)[defaults integerForKey:key];
                
                [defaults setInteger:(iNumHighlights+1) forKey:key];
                
                [defaults synchronize];
            }
        }
    }
}

-(BOOL) checkFieldsBasic
{
    if ([self checkFieldsMandatoryInView:self.basicSubview] == NO)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PLEASE_FILL_MANDATORY_FIELDS_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }

    // Check if telephone has a correct format
    if (![self.phoneNumberTextEdit.text  isEqualToString: @""])
    {
        if(![NSString validatePhone:self.phoneNumberTextEdit.text])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_ENTER_VALID_PHONE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
            
            [alertView show];
            
            return NO;
            
        }
    }
    
    // Check if gender and/or birthdate has been filled
    if (([self.genderTextEdit.text  isEqualToString: @""]) && ([self.birthdateTextEdit.text  isEqualToString: @""]))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_AREYOUSURE_", nil) message:NSLocalizedString(@"_ENTER_GENDER_AND_BIRTHDATE_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_COMPLETE_FORM_", nil) otherButtonTitles: NSLocalizedString(@"_CONTINUE_", nil), nil];
        
        [alertView show];
        
        return NO;
    }
    else if (([self.genderTextEdit.text  isEqualToString: @""]) && (!([self.birthdateTextEdit.text  isEqualToString: @""])))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_AREYOUSURE_", nil) message:NSLocalizedString(@"_ENTER_GENDER_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_COMPLETE_FORM_", nil) otherButtonTitles: NSLocalizedString(@"_CONTINUE_", nil), nil];
        
        [alertView show];
        
        return NO;
    }
    else if ((!([self.genderTextEdit.text  isEqualToString: @""])) && ([self.birthdateTextEdit.text  isEqualToString: @""]))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_AREYOUSURE_", nil) message:NSLocalizedString(@"_ENTER_BIRTHDATE_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_COMPLETE_FORM_", nil) otherButtonTitles: NSLocalizedString(@"_CONTINUE_", nil), nil];
        
        [alertView show];
        
        return NO;
    }

    return YES;
}

#pragma mark - Select profession

- (IBAction)professionEdit:(UITextField *)sender {
    textFieldEditing = self.professionTextEdit;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    iIdxElementSelectedInPickerView = -1;
    
    iIdxOldElementSelectedInPickerView = -1;
    
    NSArray * objs = [appDelegate.config valueForKey:@"profession_stylist"];

    for (int i = 0; i < objs.count; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString([objs objectAtIndex:i],nil)];
    }
    
    iIdxOldElementSelectedInPickerView = appDelegate.currentUser.typeprofession.intValue;

    
    CGRect frame = self.view.frame;
    
    PickerViewButtons *myPickerView = [[PickerViewButtons alloc] initWithFrame:frame];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    if (iIdxOldElementSelectedInPickerView != -1)
    {
        [myPickerView.pickerView selectRow:iIdxOldElementSelectedInPickerView inComponent:0 animated:YES];
    }
    
    textFieldEditing.inputView = myPickerView;
}

#pragma mark - Picker Management

-(void) initPickerViewWithMaxElements:(NSInteger) iNumElements andWithLocalizedString:(NSString *)sString forTextField:(UITextField *)uitextfield withElementSelected:(NSInteger) iIdxSelected
{
    textFieldEditing = uitextfield;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    iIdxElementSelectedInPickerView = -1;
    
    iIdxOldElementSelectedInPickerView = iIdxSelected;
    
    for (int i = 0; i < iNumElements; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString(([NSString stringWithFormat:sString,i]), nil)];
    }
    
    
    CGRect frame = self.view.frame;
    
    PickerViewButtons *myPickerView = [[PickerViewButtons alloc] initWithFrame:frame];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    if (iIdxSelected != -1)
    {
        [myPickerView.pickerView selectRow:iIdxOldElementSelectedInPickerView inComponent:0 animated:YES];
    }
    
    textFieldEditing.inputView = myPickerView;
}
-(void) initPickerViewWithElements:(NSArray *) arElements forTextField:(UITextField *)uitextfield withElementSelected:(NSInteger) iIdxSelected
{
    textFieldEditing = uitextfield;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    iIdxElementSelectedInPickerView = -1;
    
    iIdxOldElementSelectedInPickerView = iIdxSelected;
    
    for (int i = 0; i < arElements.count; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString([arElements objectAtIndex:i],nil)];
    }
    
    
    CGRect frame = self.view.frame;
    
    PickerViewButtons *myPickerView = [[PickerViewButtons alloc] initWithFrame:frame];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    if (iIdxSelected != -1)
    {
        [myPickerView.pickerView selectRow:iIdxOldElementSelectedInPickerView inComponent:0 animated:YES];
    }
    
    textFieldEditing.inputView = myPickerView;
}

-(void) pickerButtonView:(PickerViewButtons *)pickerView changeSelected:(NSInteger) iRow
{
    textFieldEditing.text = [arElementsPickerView objectAtIndex:iRow];
    [self setFieldOfUserFromPickerViewWinIndex:iRow];
}

- (void) pickerButtonView:(PickerViewButtons *)pickerView didButtonClick:(BOOL)bOk withindex:(NSInteger) iRow
{
    if (bOk)
    {
        [self setFieldOfUserFromPickerViewWinIndex:iRow];
    }
    else
    {
        if (iIdxOldElementSelectedInPickerView != -1)
        {
            [self setFieldOfUserFromPickerViewWinIndex:iIdxOldElementSelectedInPickerView];
            textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxOldElementSelectedInPickerView];
        }
    }
    // hide the picker view
    [textFieldEditing resignFirstResponder];
}

-(void) setFieldOfUserFromPickerViewWinIndex:(NSInteger) iRow
{
    if (iRow > -1)
    {
        textFieldEditing.text = [arElementsPickerView objectAtIndex:iRow];
        if (textFieldEditing == self.professionTextEdit)
        {
            appDelegate.currentUser.typeprofession = [NSNumber numberWithLong:iRow];
            
            if (appDelegate.currentUser.typeprofession.intValue >= 17)
            {
//                self.btnGender.hidden = YES;
                self.genderLabel.hidden = YES;
                self.genderTextEdit.hidden = YES;
                
                self.topPhoneConstraint.constant =10;
                
                self.birthdateLabel.text = NSLocalizedString(@"_ESTABLISHEDDATE_", nil);
                if (self.birthdateLabel.tag == 1)
                    self.birthdateLabel.text = [NSString stringWithFormat:@"%@ *", self.birthdateLabel.text];
            }
            else
            {
                self.genderTextEdit.hidden = NO;
//                self.btnGender.hidden = NO;
                self.genderLabel.hidden = NO;
                
                self.topPhoneConstraint.constant = kTopConstraintPhonenumber;
                
                self.birthdateLabel.text = NSLocalizedString(@"_BIRTHDATE_", nil);
                if (self.birthdateLabel.tag == 1)
                    self.birthdateLabel.text = [NSString stringWithFormat:@"%@ *", self.birthdateLabel.text];
            }
        }
        else if (textFieldEditing == self.genderTextEdit)
        {
            _iGenderSelected = iRow;
            appDelegate.currentUser.gender = [NSNumber numberWithLong:iRow];
        }
        else if (textFieldEditing == self.prefixPhoneNumberTextEdit)
        {
            NSString * sCallingCodePlus = [NSString stringWithFormat:@"+%@", [arCountriesCallingCodes objectAtIndex:iRow]];
            textFieldEditing.text = sCallingCodePlus;
        }
    }
    else
    {
        if (textFieldEditing == self.prefixPhoneNumberTextEdit)
        {
            self.prefixPhoneNumberTextEdit.text = @"";
        }
    }
}
#pragma mark - Picker Filtered Management

-(void) initPickerFilteredViewWithElements:(NSArray *) arElements forTextField:(UITextField *)uitextfield withElementSelected:(NSInteger) iIdxSelected
{
    // split the string by coma
    NSMutableArray * arSelected = [[NSMutableArray alloc] init];
    if ((iIdxSelected >= 0) && (iIdxSelected < arElements.count))
    {
        [arSelected addObject:[NSIndexPath indexPathForRow:iIdxSelected inSection:0]];
    }
    
    textFieldEditing = uitextfield;
    if (arElementsPickerView == nil)
    {
        arElementsPickerView = [[NSMutableArray alloc] init];
    }
    [arElementsPickerView removeAllObjects];
    iIdxElementSelectedInPickerView = -1;
    
    iIdxOldElementSelectedInPickerView = iIdxSelected;
    
    for (int i = 0; i < arElements.count; i++)
    {
        [arElementsPickerView addObject:NSLocalizedString([arElements objectAtIndex:i],nil)];
    }
    
    
    CGRect frame2 = CGRectMake(0.0, 60, self.view.frame.size.width, self.view.frame.size.height - 60);
    PickerFilteredViewButtons *myPickerView = [[PickerFilteredViewButtons alloc] initWithFrame:frame2];
    myPickerView.delegate = self;
    [myPickerView setElements:arElementsPickerView];
    [myPickerView setElementsSelected:arSelected];
    
    pickerFilteredPickerView = myPickerView;
    [self.view addSubview:pickerFilteredPickerView];
    [self.view bringSubviewToFront:pickerFilteredPickerView];
    
    self.leftButton.hidden = YES;
    self.middleLeftButton.hidden = YES;
    self.homeButton.hidden = YES;
    self.middleRightButton.hidden = YES;
    self.rightButton.hidden =YES;
    
}

-(void) pickerFilteredButtonView:(PickerFilteredViewButtons *)pickerView changeSelection:(NSArray *)arSelected
{
    long iIdxCountrySelected = 0;
    if (arSelected.count > 0)
    {
        NSIndexPath * index = (NSIndexPath *)([arSelected objectAtIndex:0]);
        iIdxCountrySelected = (long)index.row;
    }
    
    if (textFieldEditing == self.prefixPhoneNumberTextEdit)
    {
        textFieldEditing.text = [arCountriesCallingCodes objectAtIndex:iIdxCountrySelected];
    }
    else
    {
        textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxCountrySelected];
    }
    [self setFieldOfUserFromPickerViewWinIndex:iIdxCountrySelected];
}

-(void) pickerFilteredButtonView:(PickerFilteredViewButtons *)pickerView didButtonClick:(BOOL)bOk withSelected:(NSArray *)arSelected
{
    pickerFilteredPickerView = nil;
    self.leftButton.hidden = NO;
    self.middleLeftButton.hidden = NO;
    self.homeButton.hidden = NO;
    self.middleRightButton.hidden = NO;
    self.rightButton.hidden = NO;
    if (bOk)
    {
        long iIdxElementSelected = -1;
        if (arSelected.count > 0)
        {
            NSIndexPath * index = (NSIndexPath *)([arSelected objectAtIndex:0]);
            iIdxElementSelected = (long)index.row;
        }
        
        [self setFieldOfUserFromPickerViewWinIndex:iIdxElementSelected];
    }
    else
    {
        if (iIdxOldElementSelectedInPickerView != -1)
        {
            [self setFieldOfUserFromPickerViewWinIndex:iIdxOldElementSelectedInPickerView];
            if (textFieldEditing == self.prefixPhoneNumberTextEdit)
            {
                NSString * sCallingCodePlus = [NSString stringWithFormat:@"+%@", [arCountriesCallingCodes objectAtIndex:iIdxOldElementSelectedInPickerView]];
                
                textFieldEditing.text = sCallingCodePlus;
            }
            else
            {
                textFieldEditing.text = [arElementsPickerView objectAtIndex:iIdxOldElementSelectedInPickerView];
            }
        }
        else
        {
            textFieldEditing.text = @"";
        }
    }
}

#pragma mark - Rest Services call
// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (connection)
    {
        case GET_ALLCOUNTRIES:
        {
            [self getCountriesFromServer:mappingResult];
            [self stopActivityFeedback];
            break;
        }
            
        default:
            break;
    }
}

-(void) processRestConnection:(connectionType)connection WithErrorMessage:(NSArray *)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    [super processRestConnection:connection WithErrorMessage:errorMessage forOperation:operation];
    
    switch (connection)
    {
        case GET_ALLCOUNTRIES:
        {
            bLoadingCountries = NO;
            break;
        }
        default:
            break;
    }
}


@end
