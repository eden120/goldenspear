//
//  UserProfileViewController.m
//  GoldenSpear
//
//  Created by Alberto Seco on 9/7/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UserProfileViewController.h"
#import "BaseViewController+TopBarManagement.h"

#define kAnimationTime 1

#define kHeightNoFashionista 1080
#define kHeightFashionistaData 1300
#define kHeightFashionistaSubmit 1360

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController
{
    User * currentUser;
    BOOL submitFashionista;
}

- (void)viewDidLoad {
    submitFashionista = NO;
    [super viewDidLoad];
    // border color gray of textfields
    UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
    [self borderTextEdit:self.fashionistaBlogURL withColor:color withBorder:1.0f];
    [self borderTextEdit:self.fashionistaNameTextEdit withColor:color withBorder:1.0f];
    [self borderTextEdit:self.fashionistaTitle withColor:color withBorder:1.0f];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    currentUser = appDelegate.currentUser;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // in viewDidAppear in order to be sure that the view has the correct size of the frame, and in this way show correctly the fashionista section
    if (currentUser != nil)
    {
        //        appDelegate.currentUser
        if ([currentUser.isFashionista boolValue])
        {
            [self showFashionistaData];
            
            [self showFashionistaAccountAnimated:NO];
        }
        else
        {
            self.fashionistaNameTextEdit.text = self.subtitleLabel.text;
            
            [self hideFashionistaFormAnimated:NO];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark  - Fashionista View

-(void) showFashionistaAccountAnimated:(BOOL) bAnimated
{
    self.fashionistaNameTextEdit.text = currentUser.fashionistaName;
    self.fashionistaBlogURL.text = currentUser.fashionistaBlogURL;
    self.btnFashionistaSubmit.hidden = YES;

    float fDuration = (bAnimated) ? kAnimationTime: 0;
    //    [self.viewNoFashionista layoutIfNeeded];
    [self.mainView layoutIfNeeded];
    [UIView animateWithDuration:fDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         //                         self.viewNoFashionistaHeightConstraint.constant = kHeightNoFashionistaView;
                         //                         self.mainViewHeightConstraint.constant = kHeightFashionistaSubmit;
                         //                         [self.viewNoFashionista layoutIfNeeded];
                         CGRect frame = self.mainView.frame;
                         frame.size.height = kHeightFashionistaData;
                         self.mainView.frame = frame ;
                         ((UIScrollView *) self.mainView.superview).contentSize = self.mainView.frame.size;
                         [self.mainView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

-(void) showFashionistaFormAnimated:(BOOL) bAnimated
{
    float fDuration = (bAnimated) ? kAnimationTime: 0;
    self.viewFashionista.hidden = NO;
    self.btnFashionistaSubmit.hidden = NO;
    [self.mainView layoutIfNeeded];
    [UIView animateWithDuration:fDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         CGRect frame = self.mainView.frame;
                         frame.size.height = kHeightFashionistaSubmit;
                         self.mainView.frame = frame ;
                         ((UIScrollView *) self.mainView.superview).contentSize = self.mainView.frame.size;
                         [self.mainView layoutIfNeeded];
                         // position the scrollview
                         CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
                         [self.scrollView setContentOffset:bottomOffset animated:YES];
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

-(void) hideFashionistaFormAnimated:(BOOL) bAnimated
{
    float fDuration = (bAnimated) ? kAnimationTime: 0;
    [self.mainView layoutIfNeeded];
    [UIView animateWithDuration:fDuration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         CGRect frame = self.mainView.frame;
                         frame.size.height = kHeightNoFashionista;
                         self.mainView.frame = frame ;
                         ((UIScrollView *) self.mainView.superview).contentSize = self.mainView.frame.size;
                         [self.mainView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.viewFashionista.hidden = YES;
                         self.btnFashionistaSubmit.hidden = YES;
                     }];
}

-(void) showFashionistaData
{
    self.fashionistaNameTextEdit.text = currentUser.fashionistaName;
    self.fashionistaBlogURL.text = currentUser.fashionistaBlogURL;
    self.fashionistaSwitch.on = [currentUser.isFashionista boolValue];
    self.fashionistaTitle.text = currentUser.fashionistaTitle;
}

#pragma mark -

-(void)applyFashionista
{
    // Hide keyboard if the user press the 'Create' button
    currentUser.isFashionista = [NSNumber numberWithBool:YES];
    currentUser.fashionistaBlogURL = self.fashionistaBlogURL.text;
    currentUser.fashionistaName = self.fashionistaNameTextEdit.text;
    currentUser.fashionistaTitle = self.fashionistaTitle.text;
    
    [currentUser setDelegate:self];
    
    [currentUser updateUserToServerDBVerbose:NO];
    
}

- (void)actionAfterSignUp
{
    [super actionAfterSignUp];
    
    if (submitFashionista)
    {
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FASHIONISTA_", nil) message:NSLocalizedString(@"_APPLY_FASHIONISTA_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        */
        
        [self showFashionistaData];
        
        [self showFashionistaAccountAnimated:YES];
        
        submitFashionista = NO;
    }
    else
    {
    //[super actionAfterSignUp];
    }
}

- (void)actionAfterSignUpWithError
{
    [super actionAfterSignUpWithError];
    
    if (submitFashionista)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FASHIONISTA_", nil) message:NSLocalizedString(@"_ERROR_APPLY_FASHIONISTA_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        [self showFashionistaData];
        
        submitFashionista = NO;
    }
    else
    {
        //[super actionAfterSignUpWithError];
    }
    
    return;
}

-(void) getDataUserForUser:(User*) user originalUser:(User*)originalUser
{
    [super getDataUserForUser:user originalUser:originalUser];
    user.fashionistaName = self.fashionistaNameTextEdit.text;
    user.fashionistaBlogURL = self.fashionistaBlogURL.text;
    user.isFashionista = [NSNumber numberWithBool:self.fashionistaSwitch.on];
}


#pragma mark - Events

- (IBAction)switchFashionista:(UISwitch *)sender {
    if (self.fashionistaSwitch.on)
    {
        [self showFashionistaFormAnimated:YES];
    }
    else
    {
        [self hideFashionistaFormAnimated:YES];
    }
}

- (IBAction)btnSubmitFashionista:(UIButton *)sender {
    submitFashionista = YES;
    [self applyFashionista];
}

@end
