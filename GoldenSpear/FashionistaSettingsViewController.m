//
//  FashionistaSettingsViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FashionistaSettingsViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"

@interface FashionistaSettingsViewController ()

@end

@implementation FashionistaSettingsViewController
{
    User * currentUser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    // Get the current user
    currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];

    // Setup textfields appearance
    [self setupTextFields];
    
    [self setBottomControlsLeftTitle:NSLocalizedString(@"_BACK_BTN_", nil) andRightTitle:NSLocalizedString(@"_FINISH_BTN_", nil) ];

    if (!(currentUser == nil))
    {
        if(!(currentUser.idUser == nil))
        {
            if(!([currentUser.idUser isEqualToString:@""]))
            {
                if([currentUser.isFashionista boolValue])
                {

                }
                else
                {
                    
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Profile information views management


-(void) setupTextFields
{
    [self.fashionistaName.layer setBorderColor:[UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0].CGColor];
    [self.fashionistaName.layer setBorderWidth:1.0f];
    [self.fashionistaName setDelegate:self];

    [self.fashionistaBlogURL.layer setBorderColor:[UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0].CGColor];
    [self.fashionistaBlogURL.layer setBorderWidth:1.0f];
    [self.fashionistaBlogURL setDelegate:self];
    
    [self.fashionistaMessage.layer setBorderColor:[UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0].CGColor];
    [self.fashionistaMessage.layer setBorderWidth:1.0f];
    [self.fashionistaMessage setDelegate:self];
    
    if (!(currentUser == nil))
    {
        if(!(currentUser.idUser == nil))
        {
            if(!([currentUser.idUser isEqualToString:@""]))
            {
                if([currentUser.isFashionista boolValue])
                {
                    self.fashionistaName.text = (((!(currentUser.fashionistaName == nil)) && (!([currentUser.fashionistaName isEqualToString:@""]))) ? currentUser.fashionistaName : [NSString stringWithFormat:@"%@ %@", currentUser.name, currentUser.lastname]);
                    self.fashionistaBlogURL.text = currentUser.fashionistaBlogURL;
                    self.fashionistaMessage.text = currentUser.fashionistaTitle;
                }
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

#pragma mark - Alert views management


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"_CANCELSTYLISTEDITING_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            [self swipeRightAction];
        }
    }
}


#pragma mark - Profile information updates management


- (void)actionAfterSignUp
{
    [super actionAfterSignUp];

    // Update the current user
    currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
    
    // Setup textfields appearance
    [self setupTextFields];
    
    [self swipeRightAction];
}

- (void)actionAfterSignUpWithError
{
    [super actionAfterSignUpWithError];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FASHIONISTA_", nil) message:NSLocalizedString(@"_ERROR_APPLY_FASHIONISTA_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
}


#pragma mark - Storyboard management


// OVERRIDE: Left action
- (void)leftAction:(UIButton *)sender
{
    if((!([currentUser.fashionistaName isEqualToString:self.fashionistaName.text])) ||
       (!([currentUser.fashionistaBlogURL isEqualToString:self.fashionistaBlogURL.text])) ||
       (!([currentUser.fashionistaTitle isEqualToString:self.fashionistaMessage.text]))
      )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELSTYLISTEDITING_", nil) message:NSLocalizedString(@"_CANCELSTYLISTEDITING_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_BACK_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        
        [alertView show];
    }
    else
    {
        [self swipeRightAction];
    }
}

// OVERRIDE: Right action
- (void)rightAction:(UIButton *)sender
{
    BOOL changesMade = NO;
    
    if (!([self.fashionistaName.text length] > 0))
    {
        currentUser.fashionistaName = [NSString stringWithFormat:@"%@ %@", currentUser.name, currentUser.lastname];
        changesMade = YES;
    }
    else
    {
        if(!([currentUser.fashionistaName isEqualToString:self.fashionistaName.text]))
        {
            currentUser.fashionistaName = self.fashionistaName.text;
            changesMade = YES;
        }
    }

    if(!([currentUser.fashionistaBlogURL isEqualToString:self.fashionistaBlogURL.text]))
    {
        currentUser.fashionistaBlogURL = self.fashionistaBlogURL.text;
        changesMade = YES;
    }

    if(!([currentUser.fashionistaTitle isEqualToString:self.fashionistaMessage.text]))
    {
        currentUser.fashionistaTitle = self.fashionistaMessage.text;
        changesMade = YES;
    }

    if(changesMade)
    {
        currentUser.isFashionista = [NSNumber numberWithBool:YES];
        
        [currentUser setDelegate:self];
        
        [currentUser updateUserToServerDBVerbose:NO];
    }
    else
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_CHANGESTOUPLOAD_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
//        
//        [alertView show];
        
        [self swipeRightAction];
    }
}

@end
