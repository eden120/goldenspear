//
//  UserLoginViewController.m
//  GoldenSpear
//
//  Created by Alberto Seco on 29/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UserLoginViewController.h"
#import "NSString+ValidateEMail.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"

#import "SearchBaseViewController.h"

#define kSignInTranslation ((IS_IPHONE_4_OR_LESS) ? (180) : (140))

@interface UserLoginViewController ()

@end

CGFloat initialConstraint;


@implementation UserLoginViewController
{
    BOOL bChangingBackgroundAd;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    // check if the user is alredy signed
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    if (appDelegate.currentUser != nil)
    //    {
    //        [appDelegate.currentUser setDelegate:self];
    //
    //        [appDelegate.currentUser logOut];
    //
    ////        // if it is, then sign out. Because of the menu, is sign out
    ////        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign Out", nil) message:NSLocalizedString(@"Are you sure to sign out?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    ////
    ////        [alertView show];
    ////
    ////        // show white view
    //
    //    }
    
    // if not continue with the process login
    
    //  Operation queue initialization
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    
    bChangingBackgroundAd = NO;

    
    [self.logo.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [self.logo.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.logo.layer setShadowRadius:1.0];
    [self.logo.layer setShadowOpacity:1.0];
    [self.logo.layer setMasksToBounds:NO];
//    [self.logo.layer setShouldRasterize:YES];

    initialConstraint = _topAlreadyAMemberConstraint.constant;
    
    
    // Do any additional setup after loading the view.
    CGFloat isRetina = ([UIScreen mainScreen].scale == 2.0)?YES:NO;
    
    
    // border color gray of textfields
    self.usernameTextEdit.layer.borderColor = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0].CGColor;
    self.usernameTextEdit.layer.borderWidth= 1.0f;
    self.passwordTextEdit.layer.borderColor = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0].CGColor;
    self.passwordTextEdit.layer.borderWidth= 1.0f;
    
    if (isRetina)
    {
        self.heightSeparator.constant = 0.5;
    }
    
    // get if already there is a user signed
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser != nil)
    {
        [self dismissViewController];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"eMail"])
    {
        if(!([[defaults objectForKey:@"eMail"] isEqualToString:@""]))
        {
            self.usernameTextEdit.text = [defaults objectForKey:@"eMail"];
        }
    }
    if([defaults objectForKey:@"Password"])
    {
        if(!([[defaults objectForKey:@"Password"] isEqualToString:@""]))
        {
            self.passwordTextEdit.text = [defaults objectForKey:@"Password"];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getBackgroundAdForCurrentUser];
    
    [self loadDataFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
                    
                    __weak UserLoginViewController *weakSelf = self;
                    
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

- (IBAction)onEditingUsernameBegin:(UITextField *)sender
{
    if(!(self.topAlreadyAMemberConstraint.constant == initialConstraint))
    {
        return;
    }
    
    CGFloat newConstant = self.topAlreadyAMemberConstraint.constant - kSignInTranslation;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.topAlreadyAMemberConstraint.constant = newConstant;
                         
                         [_notMemberLabel setAlpha:0.0];
                         [_createAccountButton setAlpha:0.0];
                         [_separatorLineView setAlpha:0.0];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)onEditingUsernameEnd:(UITextField *)sender
{
    
}

- (IBAction)onExitUsername:(UITextField *)sender
{
    if(!([self.usernameTextEdit.text isEqualToString:@""]))
    {
        [_passwordTextEdit becomeFirstResponder];
    }
    else
    {
        if(self.topAlreadyAMemberConstraint.constant == initialConstraint)
        {
            return;
        }

        CGFloat newConstant = self.topAlreadyAMemberConstraint.constant + kSignInTranslation;
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             
                             self.topAlreadyAMemberConstraint.constant = newConstant;
                             
                             [_notMemberLabel setAlpha:1.0];
                             [_createAccountButton setAlpha:1.0];
                             [_separatorLineView setAlpha:1.0];
                             
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (IBAction)onEditingPasswordBegin:(UITextField *)sender
{
    if(!(self.topAlreadyAMemberConstraint.constant == initialConstraint))
    {
        return;
    }
    
    CGFloat newConstant = self.topAlreadyAMemberConstraint.constant - kSignInTranslation;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.topAlreadyAMemberConstraint.constant = newConstant;
                         
                         [_notMemberLabel setAlpha:0.0];
                         [_createAccountButton setAlpha:0.0];
                         [_separatorLineView setAlpha:0.0];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)onEditingPasswordEnd:(UITextField *)sender
{
    
}

- (IBAction)onExitPassword:(UITextField *)sender
{
    if((!([self.usernameTextEdit.text isEqualToString:@""])) && (!([self.passwordTextEdit.text isEqualToString:@""])))
    {
        [self siginButton:nil];
    }
    else
    {
        if(self.topAlreadyAMemberConstraint.constant == initialConstraint)
        {
            return;
        }

        CGFloat newConstant = self.topAlreadyAMemberConstraint.constant + kSignInTranslation;
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             
                             self.topAlreadyAMemberConstraint.constant = newConstant;
                             
                             [_notMemberLabel setAlpha:1.0];
                             [_createAccountButton setAlpha:1.0];
                             [_separatorLineView setAlpha:1.0];
                             
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if(  (([self.usernameTextEdit isFirstResponder]) && (self.usernameTextEdit != touch.view))  ||
       (([self.passwordTextEdit isFirstResponder]) && (self.passwordTextEdit != touch.view)))
    {
        if(!(self.topAlreadyAMemberConstraint.constant == initialConstraint))
        {
            CGFloat newConstant = self.topAlreadyAMemberConstraint.constant + kSignInTranslation;
            
            [self.view layoutIfNeeded];
            
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^ {
                                 
                                 [self.view endEditing:YES];
                                 
                                 self.topAlreadyAMemberConstraint.constant = newConstant;
                                 
                                 [_notMemberLabel setAlpha:1.0];
                                 [_createAccountButton setAlpha:1.0];
                                 [_separatorLineView setAlpha:1.0];
                                 
                                 [self.view layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {

                             }];
        }
    }
}

- (IBAction)siginButton:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    // check if there is already a user signin
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"Validation Code : %@", appDelegate.currentUser.emailvalidatedcode);
    User *newuser = appDelegate.currentUser;
    if (appDelegate.currentUser == nil)
    {
        NSString * usernameString;
        NSString * passwordString;
        
        usernameString = self.usernameTextEdit.text;
        passwordString = self.passwordTextEdit.text;
        
        if ([NSString validateEmail:usernameString])
        {
            User * loginUSer;
            NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            loginUSer = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
            [loginUSer setDelegate:self];
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOGIN_ACTV_MSG_", nil)];
            [loginUSer logInUserWithUsername:usernameString andPassword:passwordString andVerbose:YES];
        }
        else{
            // show error invalid format email.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_SIGN_IN_", nil) message:NSLocalizedString(@"_INCORRECT_EMAIL_FORMAT_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles: nil];
            
            alertView.alertViewStyle = UIAlertViewStyleDefault;//LoginAndPasswordInput;
            
            [alertView show];
        }
    }
    else{
        /*
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign In", nil) message:NSLocalizedString(@"User alredy signed in.\nPlease sign out before sign in again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
         
         [alertView show];
         */
    }
    
    if(!(self.topAlreadyAMemberConstraint.constant == initialConstraint))
    {
        CGFloat newConstant = self.topAlreadyAMemberConstraint.constant + kSignInTranslation;
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             
                             self.topAlreadyAMemberConstraint.constant = newConstant;
                             
                             [_notMemberLabel setAlpha:1.0];
                             [_createAccountButton setAlpha:1.0];
                             [_separatorLineView setAlpha:1.0];
                             
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (IBAction)forgotButton:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser == nil)
    {
        [self transitionToViewController:FORGOTPWD_VC withParameters:nil];
    }
    else{
        /*
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign In", nil) message:NSLocalizedString(@"User alredy signed in.\nPlease sign out before sign in again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
         
         [alertView show];
         */
    }
}

- (IBAction)createAccountButton:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser == nil)
    {
        //[self transitionToViewController:WHO_ARE_YOU_VC withParameters:nil];
        [self transitionToViewController:SIGNUP_VC withParameters:nil ];
    }
    else{
        /*
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign In", nil) message:NSLocalizedString(@"User alredy signed in.\nPlease sign out before sign in again.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
         
         [alertView show];
         */
    }
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
        default:
        {
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            
            break;
        }
    }
}

#pragma mark delegate alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"Yes", nil)])
    {
        NSLog(@"User confirms Sign Out!");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setBool:FALSE forKey:@"UserSignedIn"];
        
        // Save to device defaults
        [defaults synchronize];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate setDefaults];
        
        [self initMainMenu];
        
        [self actionAfterLogOut];
    }
}

#pragma mark Login actions

// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![self checkUserMandatoryInfo:appDelegate.currentUser]) {
        [self showProfileErrorMessage];
        
        UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
        [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(ACCOUNT_VC) stringValue]]];
        [((BaseViewController*)appDelegate.window.rootViewController) actionAfterLogIn];
    }
    else {
        UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:nil];
        
        appDelegate.completeUser = YES;
        NSLog(@"Profession ID : %@", appDelegate.currentUser.typeprofessionId);
        [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(NEWSFEED_VC) stringValue]]];
        [((BaseViewController*)appDelegate.window.rootViewController) actionAfterLogIn];
    }
    
    return;
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    return;
}

- (void)swipeLeftAction
{
    return;
}

- (void)swipeRightAction
{
    return;
}

-(BOOL)checkUserMandatoryInfo:(User*)user {
    
    //    return YES;
    
    if (user.name == nil || [user.name isEqualToString:@""]) {
        return NO;
    }
    if (user.lastname == nil || [user.lastname isEqualToString:@""]) {
        return NO;
    }
    if (user.email == nil || [user.email isEqualToString:@""]) {
        return NO;
    }
    //    if (user.phone == nil || [user.phone isEqualToString:@""]) {
    //        return NO;
    //    }
    if (user.birthdate == nil) {
        return NO;
    }
    return YES;
}

-(void)showProfileErrorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                    message:NSLocalizedString(@"_PROFILE_ERROR_MSG",nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                          otherButtonTitles:nil];
    [alert show];
}

@end

