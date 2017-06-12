//
//  UserAccountViewController.m
//  GoldenSpear
//
//  Created by Alberto Seco on 29/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UserSignUpViewController.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "NSString+ValidateEMail.h"
#import "NSString+ValidatePhone.h"
#import "NSString+CheckWhiteSpaces.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "User+Manage.h"

#define kMinPasswordLength 8
#define kMinUsernameLength 3

@implementation UserSignUpViewController
{
    
    BOOL bChangingBackgroundAd;
}

BOOL bPictureDirty;
NSArray * _pickerGender;
NSDate * birthDate;
AppDelegate *appDelegate;
BOOL editingUser;
BOOL goingAway;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.companyName.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [self.companyName.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.companyName.layer setShadowRadius:1.0];
    [self.companyName.layer setShadowOpacity:1.0];
    [self.companyName.layer setMasksToBounds:NO];
    //    [self.companyName.layer setShouldRasterize:YES];
    
    [self.logo.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [self.logo.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.logo.layer setShadowRadius:1.0];
    [self.logo.layer setShadowOpacity:1.0];
    [self.logo.layer setMasksToBounds:NO];
    //    [self.logo.layer setShouldRasterize:YES];
    
    //  Operation queue initialization
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    
    
    bChangingBackgroundAd = NO;
    
    self.viewTermsConditions.hidden = YES;
    
    // border color gray of textfields
    UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
    [self borderTextEdit:self.usernameTextEdit withColor:color withBorder:1.0f];
    [self borderTextEdit:self.emailTextEdit withColor:color withBorder:1.0f];
    [self borderTextEdit:self.passwordTextEdit withColor:color withBorder:1.0f];
    [self borderTextEdit:self.retypePasswordTextEdit withColor:color withBorder:1.0f];
    
    /// OLD STUFF
    //    // data for gender picker
    //    _pickerGender = @[NSLocalizedString(@"_MALE_",nil), NSLocalizedString(@"_FEMALE_",nil), NSLocalizedString(@"_COMPLICATED_",nil)];
    
    //    [self borderTextEdit:self.phoneNumberTextEdit withColor:color withBorder:1.0f];
    //    [self borderTextEdit:self.locationTextEdit withColor:color withBorder:1.0f];
    //    [self borderTextEdit:self.genderTextEdit withColor:color withBorder:1.0f];
    //    [self borderTextEdit:self.birthdateTextEdit withColor:color withBorder:1.0f];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    goingAway = YES;
    [self.view endEditing:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    goingAway = NO;
    [self getBackgroundAdForCurrentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(IS_IPHONE_4_OR_LESS)
    {
        _usernameToTopSpaceConstraint.constant = 20;
        
    }
}

// Custom animation to dismiss view controller
- (void)dismissViewController
{
    if (self.viewTermsConditions != nil)
    {
        if (self.viewTermsConditions.hidden == NO)
        {
            [self hideTermsConditions];
            return;
        }
    }
    
    [super dismissViewController];
}

#pragma mark - Background Ad

// Set a specific image as background
-(void) setBackgroundImage
{
    if(bChangingBackgroundAd)
    {
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!(appDelegate.nextFullscreenBackgroundAd == nil))
    {
        if(!([appDelegate.nextFullscreenBackgroundAd imageURL ] == nil))
        {
            if(!([[appDelegate.nextFullscreenBackgroundAd imageURL] isEqualToString:@""]))
            {
                if(!([_backgroundAdImageView image] == nil))
                {
                    if(!(_currentBackgroundAd == nil))
                    {
                        if(!(_currentBackgroundAd.imageURL == nil))
                        {
                            if(!([_currentBackgroundAd.imageURL isEqualToString:@""]))
                            {
                                if([[appDelegate.nextFullscreenBackgroundAd imageURL] isEqualToString:_currentBackgroundAd.imageURL])
                                {
                                    return;
                                }
                            }
                        }
                    }
                }
                
                bChangingBackgroundAd = YES;
                
                _currentBackgroundAd = appDelegate.nextFullscreenBackgroundAd;
                
                NSString *backgroundImageURL = [_currentBackgroundAd imageURL];
                
                if ([UIImage isCached:backgroundImageURL])
                {
                    UIImage * image = [UIImage cachedImageWithURL:backgroundImageURL];
                    
                    if(image == nil)
                    {
                        return;//image = nil;//[UIImage imageNamed:@"Splash_Background.png"];
                    }
                    
                    [UIView animateWithDuration:1.0
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^ {
                                         
                                         [_backgroundAdImageView setAlpha:0.01];
                                         
                                         [self.view setBackgroundColor:[UIColor whiteColor]];
                                     }
                                     completion:^(BOOL finished) {
                                         
                                         [_backgroundAdImageView setImage:image];
                                         
                                         [UIView animateWithDuration:1.0
                                                               delay:0
                                                             options:UIViewAnimationOptionCurveEaseOut
                                                          animations:^ {
                                                              
                                                              [_backgroundAdImageView setAlpha:1.0];
                                                              
                                                              [self.view setBackgroundColor:[UIColor lightGrayColor]];
                                                              
                                                              [self showBackgroundAdLabel];
                                                          }
                                                          completion:^(BOOL finished) {
                                                              
                                                              bChangingBackgroundAd = NO;
                                                              
                                                          }];
                                     }];
                }
                else
                {
                    // Load image in the background
                    
                    __weak UserSignUpViewController *weakSelf = self;
                    
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        
                        UIImage * image = [UIImage cachedImageWithURL:backgroundImageURL];
                        
                        if(image == nil)
                        {
                            return;//image = nil;//[UIImage imageNamed:@"Splash_Background.png"];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // Then set them via the main queue if the cell is still visible.
                            
                            [UIView animateWithDuration:1.0
                                                  delay:0
                                                options:UIViewAnimationOptionCurveEaseOut
                                             animations:^ {
                                                 
                                                 [weakSelf.backgroundAdImageView setAlpha:0.01];
                                                 
                                                 [weakSelf.view setBackgroundColor:[UIColor whiteColor]];
                                             }
                                             completion:^(BOOL finished) {
                                                 
                                                 [weakSelf.backgroundAdImageView setImage:image];
                                                 
                                                 [UIView animateWithDuration:1.0
                                                                       delay:0
                                                                     options:UIViewAnimationOptionCurveEaseOut
                                                                  animations:^ {
                                                                      
                                                                      [weakSelf.backgroundAdImageView setAlpha:1.0];
                                                                      
                                                                      [weakSelf.view setBackgroundColor:[UIColor lightGrayColor]];
                                                                      
                                                                      [self showBackgroundAdLabel];
                                                                  }
                                                                  completion:^(BOOL finished) {
                                                                      
                                                                      bChangingBackgroundAd = NO;
                                                                      
                                                                  }];
                                             }];
                        });
                    }];
                    
                    operation.queuePriority = NSOperationQueuePriorityHigh;
                    
                    [self.imagesQueue addOperation:operation];
                }
                
                return;
            }
        }
    }
    
    [_backgroundAdImageView setImage:nil];
    [self hideBackgroundAdLabel];
}

// Set the proper title to the background ad button
-(NSString *)getBackgroundAdTitle
{
    if(!(_currentBackgroundAd == nil))
    {
        //        if(!(_currentBackgroundAd.userId == nil))
        //        {
        //            if(!([_currentBackgroundAd.userId isEqualToString:@""]))
        //            {
        NSString * backgroundAdText = nil;
        
        if(!(_currentBackgroundAd.secondaryInformation == nil))
        {
            if(!([_currentBackgroundAd.secondaryInformation isEqualToString:@""]))
            {
                backgroundAdText = _currentBackgroundAd.secondaryInformation;
            }
        }
        
        if(!(_currentBackgroundAd.mainInformation == nil))
        {
            if(!([_currentBackgroundAd.mainInformation isEqualToString:@""]))
            {
                if(!(backgroundAdText == nil))
                {
                    backgroundAdText = [backgroundAdText stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"_BACKGROUNDAD_SEPARATOR_", nil), _currentBackgroundAd.mainInformation]];
                }
                else
                {
                    backgroundAdText = _currentBackgroundAd.mainInformation;
                }
            }
        }
        
        if(!(_currentBackgroundAd.userId == nil))
        {
            if(!([_currentBackgroundAd.userId isEqualToString:@""]))
            {
                if(!(backgroundAdText == nil))
                {
                    backgroundAdText = [backgroundAdText stringByAppendingString:[NSString stringWithFormat:@"  |  %@", NSLocalizedString(@"_BACKGROUNDAD_PREACTION_MODEL_", nil)]];
                }
                else
                {
                    backgroundAdText = NSLocalizedString(@"_BACKGROUNDAD_PREACTION_MODEL_", nil);
                }
            }
        }
        
        return backgroundAdText;
        //            }
        //
        //        }
        // CHECK OTHER AD TYPES...
        //        else if(...)
        //        {
        //
        //        }
    }
    
    return nil;
}

// Setup and show the background Ad button
-(void) showBackgroundAdLabel
{
    if(!(_currentBackgroundAd == nil))
    {
        NSString * backgroundAdTitle = [self getBackgroundAdTitle];
        
        if(!(backgroundAdTitle == nil))
        {
            if(!([backgroundAdTitle isEqualToString:@""]))
            {
                [self.backgroundAdLabel setText:[backgroundAdTitle uppercaseString]];
                
                [self.backgroundAdLabel setHidden:NO];
                
                return;
            }
        }
    }
    
    [self.backgroundAdLabel setHidden:YES];
}

// Reset and hide the background Ad buttton
-(void)hideBackgroundAdLabel
{
    [self.backgroundAdLabel setText:[NSLocalizedString(@"_BACKGROUNDAD_TEXT_DEFAULT_", nil) uppercaseString]];
    
    [self.backgroundAdLabel setHidden:YES];
}

// Request the BackgroundAd to be shown to the user
- (void) getBackgroundAdForCurrentUser
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                [self performRestGet:GET_FULLSCREENBACKGROUNDAD withParamaters:requestParameters];
                
                return;
            }
        }
    }
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"", nil];
    
    [self performRestGet:GET_FULLSCREENBACKGROUNDAD withParamaters:requestParameters];
}


// Action to perform once an answer is succesfully processed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    switch (connection)
    {
        case GET_FULLSCREENBACKGROUNDAD:
        {
            [self setBackgroundImage];
            
            break;
        }
        case GET_FASHIONISTAWITHMAIL:
        case GET_FASHIONISTAWITHNAME:
        {
            User* __block currentUser = nil;
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     currentUser = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            if(currentUser){
                NSString* errorString = NSLocalizedString(@"_ERROR_03_02_", nil);
                UITextField* theField = self.usernameTextEdit;
                if(connection == GET_FASHIONISTAWITHMAIL){
                    errorString = NSLocalizedString(@"_ERROR_03_00_", nil);
                    theField = self.emailTextEdit;
                }
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                                message:errorString
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"_OK_", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                [theField becomeFirstResponder];
            }
            
            [self stopActivityFeedback];
            
        }
        default:
            
            break;
    }
}


#pragma mark - Bottom buttons actions


- (IBAction)onTapSignUp:(UIButton *)sender
{
    if(!(self.locationScrollView == nil))
    {
        if(!(self.locationScrollView.isHidden))
        {
            [self.view endEditing:YES];
            // save the data in the CUser class
            self.locationTextEdit.text = [self sGetTextLocation];
            [UIView animateWithDuration:1
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^ {
                                 self.topConstraintLocation.constant = (self.view.frame.size.height + 50);
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 self.locationScrollView.hidden = YES;
                             }];
            
            return;
        }
    }
    
    if (appDelegate.currentUser != nil)
    {
        // ask if the user wants to modify the data
        [self updateUser];
    }
    else
    {
        if ([self checkFields])
        {
            if (self.viewTermsConditions.hidden == YES)
            {
                [self showTermsConditions];
            }
            else
            {
                [self hideTermsConditions];
                [self createUser];// sign up
            }
        }
    }
    // Hide keyboard
    [self.view endEditing:YES];
}
/*
 // Left action
 - (void)leftAction:(UIButton *)sender
 {
 // Cancel
 if (self.locationScrollView.hidden)
 {
 //        if ([self isKindOfClass:[UserProfileViewController class]])
 //        {
 //            if (!([self fromViewController] == nil))
 //            {
 //                [self dismissViewController];
 //            }
 //        }
 //        else
 //        {
 if (self.viewTermsConditions != nil)
 {
 if (self.viewTermsConditions.hidden == NO)
 {
 [self hideTermsConditions];
 return;
 }
 }
 
 if (!([self fromViewController] == nil))
 {
 [self dismissViewController];
 }
 //        }
 
 }
 else
 {
 // It's canccel action, we don't save the data in CUser class
 self.address1TextEdit.text = @"";
 self.address2TextEdit.text = @"";
 self.countryTextEdit.text = @"";
 self.stateTextEdit.text = @"";
 self.cityTextEdit.text = @"";
 self.postalTextEdit.text = @"";
 [self.view endEditing:YES];
 [UIView animateWithDuration:1
 delay:0
 options:UIViewAnimationOptionCurveEaseOut
 animations:^ {
 self.topConstraintLocation.constant = (self.view.frame.size.height+50);
 [self.view layoutIfNeeded];
 // change text buttons
 // personalize bottom button
 if (appDelegate.currentUser != nil)
 {
 //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) ];
 [self setLeftTitle:NSLocalizedString(@"_CANCEL", nil) andImage:[UIImage imageNamed:@"close.png"]];
 [self setRightTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) andImage:[UIImage imageNamed:@"ok.png"]];
 }
 else
 {
 //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) ];
 [self setLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andImage:[UIImage imageNamed:@"close.png"]];
 [self setRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) andImage:[UIImage imageNamed:@"ok.png"]];
 }
 }
 completion:^(BOOL finished) {
 self.locationScrollView.hidden = YES;
 }];
 }
 }
 
 // Right action
 - (void)rightAction:(UIButton *)sender
 {
 if (self.locationScrollView.hidden)
 {
 if (appDelegate.currentUser != nil)
 {
 // ask if the user wants to modify the data
 [self updateUser];
 
 NSString * key = [NSString stringWithFormat:@"HIGHLIGHTUPDATEACCOUNT_%d", [self.restorationIdentifier intValue]];
 
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
 else
 {
 if ([self checkFields])
 {
 if (self.viewTermsConditions.hidden == YES)
 {
 [self showTermsConditions];
 }
 else
 {
 [self hideTermsConditions];
 [self createUser];// sign up
 
 NSString * key = [NSString stringWithFormat:@"HIGHLIGHTSIGNUP_%d", [self.restorationIdentifier intValue]];
 
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
 // Hide keyboard
 [self.view endEditing:YES];
 }
 else{
 [self.view endEditing:YES];
 // save the data in the CUser class
 self.locationTextEdit.text = [self sGetTextLocation];
 [UIView animateWithDuration:1
 delay:0
 options:UIViewAnimationOptionCurveEaseOut
 animations:^ {
 self.topConstraintLocation.constant = (self.view.frame.size.height + 50);
 [self.view layoutIfNeeded];
 // change text buttons
 // personalize bottom button
 if (appDelegate.currentUser != nil)
 {
 //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) ];
 [self setLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andImage:[UIImage imageNamed:@"close.png"]];
 [self setRightTitle:NSLocalizedString(@"_UPDATE_ACCOUNT_", nil) andImage:[UIImage imageNamed:@"ok.png"]];
 }
 else
 {
 //[self setBottomControlsLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) ];
 [self setLeftTitle:NSLocalizedString(@"_CANCEL_", nil) andImage:[UIImage imageNamed:@"close.png"]];
 [self setRightTitle:NSLocalizedString(@"_SIGN_UP_", nil) andImage:[UIImage imageNamed:@"ok.png"]];
 }
 }
 completion:^(BOOL finished) {
 self.locationScrollView.hidden = YES;
 }];
 }
 
 }
 */

#pragma mark - Load User data
-(void) loadDataForUser:(User * ) user
{
    self.usernameTextEdit.text = user.fashionistaName;
    self.emailTextEdit.text = user.email;
    self.phoneNumberTextEdit.text = user.phone;
    _iGenderSelected = [user.gender intValue];
    self.genderTextEdit.text = [user sGetTextGender];
    birthDate = user.birthdate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:user.birthdate];
    self.address1TextEdit.text = user.address1;
    self.address2TextEdit.text = user.address2;
    self.countryTextEdit.text = user.country;
    self.stateTextEdit.text = user.addressState;
    self.postalTextEdit.text = user.addressPostalCode;
    self.cityTextEdit.text = user.addressCity;
    self.locationTextEdit.text = [user sGetTextLocation];
    self.passwordTextEdit.text = user.passwordClear;
    self.retypePasswordTextEdit.text = user.passwordClear;
    
    NSString * fullName;
    if (user.lastname != nil)
    {
        fullName =  [NSString stringWithFormat:@"%@ %@", user.name, user.lastname];
    }
    else
    {
        fullName =  [NSString stringWithFormat:@"%@", user.name];
    }
}

#pragma mark - Birthdate

// Set birthdate using a UIDatePicker
- (IBAction)editBirthdate:(UITextField *)sender
{
    /*
     UIDatePicker *datePicker = [[UIDatePicker alloc]init];
     
     // TODO: Set actual [defaults objectForKey:@"Birthdate"] to datePicker if already set in text field (problems converting to NSDate)!!
     
     [datePicker setDate:[NSDate date]];
     
     [datePicker setMaximumDate:[NSDate date]];
     
     [datePicker setDatePickerMode:UIDatePickerModeDate];
     
     [datePicker addTarget:self action:@selector(updateBirthdate:) forControlEvents:UIControlEventValueChanged];
     
     self.birthdateTextEdit.inputView = datePicker;
     */
    
    CGRect frame = self.view.frame;
    DatePickerViewButtons *datePicker = [[DatePickerViewButtons alloc] initWithFrame:frame ];
    [datePicker updateFrame:self.view.frame];
    [datePicker setDate:birthDate];
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
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView changeDate:(NSDate *)date
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:date];
}

-(void) datePickerButtonView:(DatePickerViewButtons *)datePickerView didButtonClick:(BOOL)bOk withDate:(NSDate *)date
{
    if (bOk == YES)
    {
        
        birthDate = datePickerView.pickerView.date;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.birthdateTextEdit.text = [dateFormatter stringFromDate:birthDate];
    
    [self.view endEditing:YES];
}

#pragma mark - Location
- (IBAction)btnLocation:(UIButton *)sender {
    [self.view endEditing:YES];
    self.topConstraintLocation.constant = (self.view.frame.size.height+50);
    self.locationScrollView.hidden = NO;
    [self.view layoutIfNeeded];
    
    //self.verticalSpaceConstraint.constant = kVerticalConstraintWithAdvancedSearchh;
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.topConstraintLocation.constant = 60;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

#pragma mark - Gender

- (IBAction)btnGender:(UIButton *)sender {
    [self.view endEditing:YES];
    [sender resignFirstResponder];
    [self editGender:self.genderTextEdit];
}


- (IBAction)editGender:(UITextField *)sender
{
    //    [self.genderTextEdit resignFirstResponder];
    //    [self.view endEditing:YES];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_GENDER_",nil)
                                                                   message:NSLocalizedString(@"_SELECT_GENDER_", nil)
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_CANCEL_BTN_",nil) style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              [self.view endEditing:YES];
                                                          }];
    
    UIAlertAction* maleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_MALE_",nil) style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           _iGenderSelected = 1;
                                                           self.genderTextEdit.text = _pickerGender[0];
                                                           [self.view endEditing:YES];
                                                       }];
    UIAlertAction* femaleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_FEMALE_",nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             _iGenderSelected = 2;
                                                             self.genderTextEdit.text = _pickerGender[1];
                                                             [self.view endEditing:YES];
                                                         }];
    UIAlertAction* itsComplicated = [UIAlertAction actionWithTitle:NSLocalizedString(@"_COMPLICATED_",nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               _iGenderSelected = 3;
                                                               self.genderTextEdit.text = _pickerGender[2];
                                                               [self.view endEditing:YES];
                                                           }];
    UIAlertAction* preferNotSay = [UIAlertAction actionWithTitle:NSLocalizedString(@"_PREFER_NO_SAY_",nil) style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             _iGenderSelected = 4;
                                                             sender.text = _pickerGender[3];
                                                             [self.view endEditing:YES];
                                                         }];
    [alert addAction:maleAction];
    [alert addAction:femaleAction];
    [alert addAction:itsComplicated];
    [alert addAction:preferNotSay];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - updateUser
// Save user profile
- (void)updateUser
{
    // Hide keyboard if the user press the 'Create' button
    [self.view endEditing:YES];
    
    if ([self checkFields])
    {
        User * originalUser = appDelegate.currentUser;
        User * updateUser;
        NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        //        newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:currentContext];
        updateUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
        
        
        // To save user profile pic
        //        NSData *imageData = UIImagePNGRepresentation(self.avatarImage.image);
        //        NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image_user.jpg"]];
        //        [imageData writeToFile:imagePath atomically:YES];
        
        // TODO: Properly convert from (NSString *) [defaults objectForKey:@"Birthdate"] to NSDate!!
        [self getDataUserForUser:updateUser originalUser:originalUser];
        
        updateUser.passwordClear = self.passwordTextEdit.text;
        
        [updateUser setDelegate:self];
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
        [updateUser updateUserToServerDBVerbose:YES];
    }
}

-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser
{
    // Get UUID from iOS defaults system
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [user setUserWithUUID:[defaults objectForKey:@"UUID"]
                andUserID:originalUser.idUser
                  andName:@""
               andSurname:@""
                 andEmail:self.emailTextEdit.text
              andPassword:self.passwordTextEdit.text
                 andPhone:self.phoneNumberTextEdit.text
             andBirthdate:birthDate
                andGender:[NSNumber numberWithInteger:_iGenderSelected]
          andPicpermision:YES
               andPicPath:originalUser.picture
                   andPic:nil
             andWardrobes:originalUser.wardrobes
               andReviews:originalUser.reviews
               andCountry:self.countryTextEdit.text
                 andState:self.stateTextEdit.text
                  andCity:self.cityTextEdit.text
              andAddress1:self.address1TextEdit.text
              andAddress2:self.address2TextEdit.text
            andPostalCode:self.postalTextEdit.text
              andUserName:[self.usernameTextEdit.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]
               andWebsite:@""
                   andBio:@""];
}


#pragma mark - createUser
-(void) showTermsConditions
{
    if (self.viewTermsConditions.hidden)
    {
        NSURL *websiteUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terms_conditions" ofType:@"html"]];
        
        //NSURL *websiteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/terms_conditions.html",IMAGESBASEURL]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [self.webViewTermsConditions loadRequest:urlRequest];
        
        self.viewTermsConditions.layer.cornerRadius = 6.0;
        self.viewTermsConditions.layer.borderWidth = 1.0;
        self.viewTermsConditions.layer.borderColor = [UIColor blackColor].CGColor;
        self.viewTermsConditions.clipsToBounds = YES;
        
        self.viewTermsConditions.hidden = NO;
        self.viewTermsConditions.alpha = 0.0;
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             self.viewTermsConditions.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

-(void) hideTermsConditions
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         self.viewTermsConditions.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.viewTermsConditions.hidden = YES;
                     }];
}

// Save user profile
- (void)createUser
{
    // Hide keyboard if the user press the 'Create' button
    [self.view endEditing:YES];
    
    if([self checkFields])
    {
        // Create User
        User *newUser;
        NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        //        newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:currentContext];
        newUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
        
        // Get UUID from iOS defaults system
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [newUser setUserWithUUID:[defaults objectForKey:@"UUID"]
                       andUserID: nil
                         andName:@""
                      andSurname:@""
                        andEmail:self.emailTextEdit.text
                     andPassword:self.passwordTextEdit.text
                        andPhone:self.phoneNumberTextEdit.text
                    andBirthdate:birthDate
                       andGender:[NSNumber numberWithInteger:_iGenderSelected]
                 andPicpermision:YES
                      andPicPath:@""
                          andPic:nil
                    andWardrobes:nil
                      andReviews:nil
                      andCountry:self.countryTextEdit.text
                        andState:self.stateTextEdit.text
                         andCity:self.cityTextEdit.text
                     andAddress1:self.address1TextEdit.text
                     andAddress2:self.address2TextEdit.text
                   andPostalCode:self.postalTextEdit.text
                     andUserName:[self.usernameTextEdit.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]
                      andWebsite:@""
                          andBio:@""];
        
        
        newUser.passwordClear = self.passwordTextEdit.text;
        
        [newUser setDelegate:self];
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SIGNUP_ACTV_MSG_", nil)];
        [newUser saveUserToServerDB];
    }
}

- (void)actionAfterSignUp
{
    
    [self transitionToViewController:EMAILVERIFY_VC withParameters: nil];
    return;
    //[self transitionToViewController:ACCOUNT_VC withParameters:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
    [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(ACCOUNT_VC) stringValue]]];
    appDelegate.bAutoLogin = NO;
    return;
    
    [super actionAfterSignUp];
    
    return;
    
    
    if (!([self fromViewController] == nil))
    {
        if (!([[self fromViewController].restorationIdentifier isEqualToString:([@(SIGNIN_VC) stringValue])]))
        {
            [self dismissViewController];
        }
        else
        {
            // By default, go to Home View Controller
            BaseViewController * fromViewController = self.fromViewController;
            [self transitionToViewController:HOME_VC withParameters:nil fromViewController:fromViewController];
        }
    }
    else
    {
        // By default, go to Home View Controller
        BaseViewController * fromVC = self.fromViewController;
        [self transitionToViewController:HOME_VC withParameters:nil fromViewController:fromVC];
    }
}

#pragma mark - Login actions

// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    [super actionAfterLogIn];
    return;
    
    if (!([self fromViewController] == nil))
    {
        if (!([[self fromViewController].restorationIdentifier isEqualToString:([@(SIGNIN_VC) stringValue])]))
        {
            [[self fromViewController] actionAfterLogIn];
            [self dismissViewController];
        }
        else
        {
            // By default, go to Home View Controller
            [self transitionToViewController:HOME_VC withParameters:nil];
        }
    }
    else
    {
        // By default, go to Home View Controller
        [self transitionToViewController:HOME_VC withParameters:nil];
    }
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    return;
    // only if we are editing the user
    if (editingUser)
    {
        [super dismissViewController];
        [self transitionToViewController:SEARCH_VC withParameters:nil fromViewController:self.fromViewController];
    }
    //    return;
}


#pragma mark - Events to control when the keyboard appears, and adapt the constraint to it

- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification {
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    return keyboardVerticalIncrease;
}

- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset {
    CGFloat constant = self.bottomSlideConstraint.constant;
    CGFloat newConstant = constant + offset + 50;
    if (offset > 0)
        newConstant = constant + offset - 50;
    
    self.bottomSlideConstraint.constant = newConstant;
    [self.view layoutIfNeeded];
}

- (void)checkUsername:(NSString*)username{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:username, nil];
    
    [self performRestGet:GET_FASHIONISTAWITHNAME withParamaters:requestParameters];
}

- (void)checkMail:(NSString*)email{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:email, nil];
    
    [self performRestGet:GET_FASHIONISTAWITHMAIL withParamaters:requestParameters];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(!goingAway){
        if(textField==self.usernameTextEdit){
            [self checkUsername:self.usernameTextEdit.text];
        }
        if(textField==self.emailTextEdit){
            [self checkMail:self.emailTextEdit.text];
        }
    }
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
    
    UITouch *touch = [[event allTouches] anyObject];
    if (([self.usernameTextEdit isFirstResponder] && (self.usernameTextEdit != touch.view)) ||
        ([self.passwordTextEdit isFirstResponder] && (self.passwordTextEdit != touch.view)) ||
        ([self.retypePasswordTextEdit isFirstResponder] && (self.retypePasswordTextEdit != touch.view)) ||
        ([self.emailTextEdit isFirstResponder] && (self.emailTextEdit != touch.view)) ||
        ([self.phoneNumberTextEdit isFirstResponder] && (self.phoneNumberTextEdit != touch.view)) ||
        ([self.locationTextEdit isFirstResponder] && (self.locationTextEdit != touch.view)) ||
        ([self.genderTextEdit isFirstResponder] && (self.genderTextEdit != touch.view)) ||
        ([self.birthdateTextEdit isFirstResponder] && (self.birthdateTextEdit != touch.view)))
    {
        //        [self.view endEditing:YES];
    }
    
    
}

#pragma mark - PrrotectedFunctions
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
    [sender resignFirstResponder];
}

-(NSString *) sGetTextLocation
{
    NSString * sLocation = @"";
    
    if (self.address1TextEdit.text)
    {
        if (![self.address1TextEdit.text  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@"%@", self.address1TextEdit.text];
    }
    if (self.cityTextEdit.text)
    {
        if (![self.cityTextEdit.text  isEqualToString: @""])
            sLocation = [sLocation stringByAppendingFormat:@" (%@)", self.cityTextEdit.text];
    }
    
    if ([sLocation isEqualToString: @""])
    {
        if (self.stateTextEdit.text)
        {
            if (![self.stateTextEdit.text  isEqualToString: @""])
                sLocation = [sLocation stringByAppendingFormat:@"%@", self.stateTextEdit.text];
        }
        if (self.countryTextEdit.text)
        {
            if (![self.countryTextEdit.text  isEqualToString: @""])
                sLocation = [sLocation stringByAppendingFormat:@" (%@)", self.countryTextEdit.text];
        }
    }
    
    if ([sLocation isEqualToString: @""])
        sLocation = NSLocalizedString(@"_INCORRECT_LOCATION", nil);
    
    
    return sLocation;
}

-(BOOL) checkFields
{
    // Check if there's any empty field
    if (([self.usernameTextEdit.text isEqualToString: @""]) || ([self.emailTextEdit.text isEqualToString: @""]) || ([self.passwordTextEdit.text isEqualToString: @""]) || ([self.retypePasswordTextEdit.text isEqualToString: @""]))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PLEASE_FILL_MANDATORY_FIELDS_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    // Check if username has a minimum length
    if ([[self.usernameTextEdit.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] < kMinUsernameLength)
    {
        NSString * sMessage = [NSString stringWithFormat:NSLocalizedString(@"_USERNAME_MIN_CHAR", nil), kMinUsernameLength];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:sMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    // Check if usernam has a correct format (without internal white spaces)
    if([NSString hasWhiteSpaces:[self.usernameTextEdit.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_ENTER_VALID_USERNAME_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
        
    }
    
    // Check if passwords match
    if (self.passwordTextEdit.text.length < kMinPasswordLength)
    {
        NSString * sMessage = [NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_MIN_CHAR", nil), kMinPasswordLength];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:sMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    if (![self.passwordTextEdit.text isEqualToString:self.retypePasswordTextEdit.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_PASSWORDS_MISMATCH", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
    }
    
    // Check if email has a correct format
    if(![NSString validateEmail:self.emailTextEdit.text])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_ENTER_VALID_EMAIL_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
        
        [alertView show];
        
        return NO;
        
    }
    
    // Check if telephone has a correct format
    if(!(self.phoneNumberTextEdit == nil))
    {
        if (![self.phoneNumberTextEdit.text  isEqualToString: @""])
        {
            if(![NSString validatePhone:self.phoneNumberTextEdit.text])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_ENTER_VALID_PHONE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                
                [alertView show];
                
                return NO;
                
            }
        }
    }
    
    return YES;
}


@end
