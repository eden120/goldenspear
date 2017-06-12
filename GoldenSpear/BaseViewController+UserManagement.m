//
//  BaseViewController+UserManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+UserManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+TopBarManagement.h"


@implementation BaseViewController (UserManagement)


#pragma mark - User management

- (void)userAccount:(User *)user updateFinishedWithError:(NSString *)errorString{
    
}

// User delegate: log in
- (void)userAccount:(User *)user didLogInSuccessfully:(BOOL)bLogInSuccess
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self stopActivityFeedback];
    
    if (bLogInSuccess)
    {
        [appDelegate setCurrentUser:user];
        
        [appDelegate getCurrentUserInitialData];        
        
        [self initMainMenu];
                
        [self actionAfterLogIn];
    }
    else
    {
        //[self mainMenuView:nil selectionDidChange:ACCOUNT_VC];
        //[appDelegate setDefaults];
        
        [appDelegate setCurrentUser:nil];
        
        [self initMainMenu];
        
        // go to SIGN IN Controller
        [self transitionToViewController:SIGNIN_VC withParameters:nil];

        [self actionAfterLogInWithError];
    }
    appDelegate.bAutoLogin = NO;
}

// User delegate: log out
- (void)userAccount:(User *)user didLogOut:(BOOL)bLogOutSuccess;
{
    //[self stopActivityFeedback];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate closeCurrentServerSession];
    
    [appDelegate setDefaults];
    
    [appDelegate setCurrentUser:nil];
    
    [self initMainMenu];
    
    [self actionAfterLogOut];
}

// User delegate: sign up
- (void)userAccount:(User *)user didSignUpSuccessfully:(BOOL)bSignUpSuccess
{
    if (bSignUpSuccess)
    {
          NSString *previousUserId = nil;
        
//        if ([user saveUserToSystemDefaults])
//        {
            // assign the user to the currentUser variable in AppDelegate
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appDelegate.currentUser != nil)
            {
                previousUserId = appDelegate.currentUser.idUser;

                if (appDelegate.currentUser != user)
                {
                    // remove the user from the coredata
                    NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                    [currentContext deleteObject:appDelegate.currentUser];
                    NSError * error = nil;
                    if (![currentContext save:&error])
                    {
                        NSLog(@"Error saving context! %@", error);
                    }
                }
            }
            [appDelegate setCurrentUser:user];
            
            [appDelegate getCurrentUserInitialData];
            
            [self initMainMenu];
        
//            if((previousUserId == nil) || (!([previousUserId isEqualToString:appDelegate.currentUser.idUser])))
//            {
//                [self showMessageWithImageNamed:@"HINT_stylist-approval.jpg"];
//            }
//            else
            {
                [self actionAfterSignUp];
            }
//        }
    }
    else
    {
        //[self mainMenuView:nil selectionDidChange:ACCOUNT_VC];
    }

    [self stopActivityFeedback];
}
// User delegate: GetUserInfo with Email
-(void) userAccount:(User*)user results:(NSArray*)results {
    User* __block currentUser = nil;
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (([obj isKindOfClass:[User class]]))
         {
             currentUser = (User *)obj;
             
             // Stop the enumeration
             *stop = YES;
         }
     }];
    
    [self stopActivityFeedback];
    
    if (currentUser) {

        if (![currentUser.emailvalidated boolValue])
        {
            NSLog(@"Email not yet validated!");

            [self transitionToViewController:EMAILVERIFY_VC withParameters:nil];

            NSLog(@"User Password : %@", currentUser.password);
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.currentUser = currentUser;
        }
        else
        {
            NSLog(@"Email already validated! Login error might come from a wrong password?");

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ERROR_LOGIN_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            
            [self transitionToViewController:SIGNIN_VC withParameters:nil];
        }
        
        
    }
    else
    {
        NSLog(@"Username doesn't exist!");

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ERROR_LOGIN_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];

        [self transitionToViewController:SIGNIN_VC withParameters:nil];
    }
}
-(void) showMessageWithImageNamed:(NSString *)imageName
{
    if(self.hintBackgroundView.hidden == NO)
        return;
    
    self.hintBackgroundView.hidden = NO;
    
    [self.view endEditing:YES];

    self.updatingHint = [NSNumber numberWithBool:NO];
    
    [self.hintView setImage:[UIImage imageNamed:imageName/*@"HINT_stylist-approval.jpg"*/]];
    
    self.hintLabel.text = NSLocalizedString(@"_POSTANDBEVALIDATED_", nil);
    
    self.hintPrev.hidden = YES;
    self.hintNext.hidden = YES;
    
    self.hintBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.hintBackgroundView.alpha = 0.0;
    [self.view bringSubviewToFront:self.hintBackgroundView];
    
    self.hintView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //self.hintView.userInteractionEnabled = YES;
    self.hintView.alpha = 0.0;
    self.hintView.hidden = NO;
    [self.view bringSubviewToFront:self.hintView];
    
    
    float fNewW = self.view.frame.size.width * 0.8;
    float fNewH = self.view.frame.size.height * 0.8;
    float fOffX = self.view.frame.size.width * 0.1;
    float fOffY = self.view.frame.size.height * 0.1;
    self.hintLabel.userInteractionEnabled = YES;
    self.hintLabel.alpha = 0.0;
    self.hintLabel.frame = CGRectMake(fOffX, fOffY-40, fNewW, 40);
    self.hintNext.frame = CGRectMake(fNewW - 30, 8, 25, 25);
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.hintView.frame = CGRectMake(fOffX, fOffY, fNewW, fNewH);
                         self.hintView.alpha = 1.0;
                         self.hintBackgroundView.alpha = 1.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.3
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^ {
                                              self.hintLabel.alpha = 1.0;
                                              
                                          } completion:^(BOOL finished) {
                                              
                                              
                                          }];
                         
                     }];
}

// Hide the hints view
- (void)hideMessage
{
    if(self.hintView.hidden)
        return;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.hintView.alpha = 0.0;
                         self.hintBackgroundView.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         self.hintView.hidden = YES;
                         self.hintBackgroundView.hidden = YES;
                         
                         [self actionAfterSignUp];

                     }];
}

//// Swap user status: log in or log out
//- (void)changeUserLogInStatus
//{
//    [self stopActivityFeedback];
//    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_LOGIN_ACTV_MSG_", nil)];
//
//    //Log In or Log Out depending on the current user status
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    if ([defaults boolForKey:@"UserSignedIn"])
//    {
//        // Get the current user
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        
//        if (!(appDelegate.currentUser == nil))
//        {
//            [appDelegate.currentUser setDelegate:self];
//            [appDelegate.currentUser LogOut];
//        }
//    }
//    else
//    {
//        // Create User
//        CUser *logInUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
//        
//        if (!(logInUser == nil))
//        {
//            [logInUser setDelegate:self];
//            [logInUser LogIn];
//        }
//    }
//}

- (void)updateUsernameLabel
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        NSString * fullName;
        
        if (appDelegate.currentUser.lastname != nil)
        {
            fullName =  [NSString stringWithFormat:@"%@ %@", appDelegate.currentUser.name, appDelegate.currentUser.lastname];
        }
        else
        {
            fullName =  [NSString stringWithFormat:@"%@", appDelegate.currentUser.name];
        }
        
        self.usernameLabel.text = fullName;
    }
    else
    {
        self.usernameLabel.text = @"";
    }
}

// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    [self updateUsernameLabel];
    
    [self transitionToViewController:NEWSFEED_VC withParameters:nil fromViewController:nil];
    
    return;
}

// Peform an action once the user logs in
- (void)actionAfterLogInWithError
{
    [self updateUsernameLabel];
    return;
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [self updateUsernameLabel];
//    [self dismissViewController];
    [self transitionToViewController:SIGNIN_VC withParameters:nil fromViewController:nil];
    
    return;
}

// Peform an action once the user sign up
- (void)actionAfterSignUp
{
   [self updateUsernameLabel];
    
    [self transitionToViewController:NEWSFEED_VC withParameters:nil fromViewController:nil];
    return;
}

// Peform an action once the user sign up
- (void)actionAfterSignUpWithError
{
    [self updateUsernameLabel];
    return;
}
@end
