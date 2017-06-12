//
//  UserAccountViewController.m
//  GoldenSpear
//
//  Created by Alberto Seco on 26/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UserAccountSettingsViewController.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "FashionistaPageCell.h"

@import MessageUI;

// Core Data Classes
#import "User+Manage.h"

#define kSpaceConstraintSupportWithOutFashionista -40
#define kSpaceConstraintSupportWithFashionista 20

@interface UserAccountSettingsViewController ()

@end

@implementation UserAccountSettingsViewController
{
    User * currentUser;
    NSMutableArray * fashionistaPages;
    FashionistaPage * _selectedPageToDelete;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser = nil;
    // Do any additional setup after loading the view.
    // get the user data
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser == nil)
    {
        [self dismissViewController];
    }
    else
    {
        currentUser = appDelegate.currentUser;
        [self loadDataInViewUser: currentUser];
    }
    
    [self borderButtons];
    
    fashionistaPages = nil;
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser == nil)
    {
        [self dismissViewController];
    }
    else{
        [self loadDataInViewUser: appDelegate.currentUser];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Custom animation to dismiss view controller
- (void)dismissViewController
{
    [self swipeLeftAction];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - visualization function
-(void) borderButtons
{
    UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
    [self borderTextEdit:self.btnEditProfile withColor:color withBorder:1.0f];
    [self borderTextEdit:self.btnAccountSettings withColor:color withBorder:1.0f];
    [self borderTextEdit:self.btnPrivacySecurity withColor:color withBorder:1.0f];
    [self borderTextEdit:self.btnSupport withColor:color withBorder:1.0f];
    [self borderTextEdit:self.btnTermsConditions withColor:color withBorder:1.0f];
    [self borderTextEdit:self.btnFashionistaAccount withColor:color withBorder:1.0f];
    
}

-(void) borderTextEdit:(UIControl *) _control withColor:(UIColor *)_color withBorder:(float) _fBorderWith
{
    _control.layer.borderColor = _color.CGColor;
    _control.layer.borderWidth= _fBorderWith;
    
}

-(void) showView:(UIView *) view
{
    view.hidden = NO;
    view.alpha = 0.0;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

-(void) hideView:(UIView *) view
{
    view.alpha = 1.0;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         view.hidden = YES;
                     }];
}

#pragma mark - Bottom buttons actions
/*
// Left action
- (void)leftAction:(UIButton *)sender
{
    if (self.viewWebView.hidden == NO)
    {
        NSURL *websiteUrl = [NSURL URLWithString:@"about:blank"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [self.webView loadRequest:urlRequest];
        
        [self hideView:self.viewWebView];
    }
    else if (self.viewFashionista.hidden ==NO)
    {
        [self hideFashionistaAccount];
    }
    else if (self.viewFashionistaApplyForm.hidden == NO)
    {
        [self hideApplyForm];
    }
    else if (self.viewNewFashionista.hidden == NO)
    {
        [self hideNewFashionista];
    }
    else
    {
        // cancel
        [super dismissViewController];
    }
}

// Right action
- (void)rightAction:(UIButton *)sender
{
    
}
*/
#pragma mark - Load user data
-(void) loadDataInViewUser:(User *) user
{
    NSString * fullName;
    if (user.lastname != nil)
    {
       fullName =  [NSString stringWithFormat:@"%@ %@", user.name, user.lastname];
    }
    else
    {
        fullName =  [NSString stringWithFormat:@"%@", user.name];
    }
    
    self.usernameLabel.text = fullName;
    self.subtitleLabel.text = fullName;
    
    if ([user.isFashionista boolValue])
    {
        self.btnFashionistaAccount.hidden = YES;//NO;
        //self.spaceSupportFashionistaConstraint.constant = kSpaceConstraintSupportWithFashionista;
        if (self.viewFashionista.hidden == NO)
        {
            [self loadFashionistaPages];
        }
    }
    else
    {
        self.btnFashionistaAccount.hidden = YES;
        //self.spaceSupportFashionistaConstraint.constant = kSpaceConstraintSupportWithOutFashionista;
        
    }
}

#pragma mark - Logout
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    return;
    //[self dismissViewController];
    
    //[self transitionToViewController:SIGNIN_VC withParameters:nil fromViewController:self.fromViewController];
}


#pragma mark - Show email app to send and email
- (void)showEmail
{
    // Get the Global Mail Composer
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([MFMailComposeViewController canSendMail])
    {
        [appDelegate cycleGlobalMailComposer];
        
        // Compose Email
        [appDelegate.globalMailComposer setSubject:NSLocalizedString(@"_SUPPORT_EMAIL_TITLE_", nil)];
        
        [appDelegate.globalMailComposer setToRecipients:[NSArray arrayWithObject:@"support@goldenspear.com"]];
        
        // Present mail view controller on screen
        appDelegate.globalMailComposer.mailComposeDelegate = self;
        
        [self presentViewController:appDelegate.globalMailComposer animated:YES completion:NULL];
        
    }
    else
    {
        /*
        // Operation couldn't be performed!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorLbl", nil) message:NSLocalizedString(@"ArchiveEmailErrorMsg", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"CancelLbl", nil) otherButtonTitles: nil];
        
        [alertView show];
        */
        [appDelegate cycleGlobalMailComposer];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Fashionista
- (void) showFashionista
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.currentUser == nil)
    {
        [self dismissViewController];
    }
    else
    {
//        appDelegate.currentUser
        if ([currentUser.isFashionista boolValue])
        {
            [self showFashionistaAccount];
        }
        else
        {
            // you are not a fashionista
            [self showNewFashionista];
            
        }
    }
}

-(void) showNewFashionista
{
    [self showView:self.viewNewFashionista];
}

-(void) hideNewFashionista
{
    [self hideView:self.viewNewFashionista];
}

-(void) showFashionistaAccount
{
    [self loadFashionistaPages];
    
    self.fashionistaAccountName.text = currentUser.fashionistaName;
    self.fashionistaAccountWeb.text = currentUser.fashionistaBlogURL;
    
    // download the fashionista pages
    
    [self showView:self.viewFashionista];
}

-(void) hideFashionistaAccount
{
    [self hideView:self.viewFashionista];
}

-(void) showApplyForm
{
    self.fashionistaName.text = self.subtitleLabel.text;
    [self showView:self.viewFashionistaApplyForm];
}

-(void) hideApplyForm
{
    self.viewNewFashionista.hidden = YES;
    [self hideView:self.viewFashionistaApplyForm];
    
}

-(void)applyFashionista
{
    // Hide keyboard if the user press the 'Create' button
    currentUser.isFashionista = [NSNumber numberWithBool:YES];
    currentUser.fashionistaBlogURL = self.fashionistaWeb.text;
    currentUser.fashionistaName = self.fashionistaName.text;
    
    [currentUser setDelegate:self];
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
    [currentUser updateUserToServerDBVerbose:NO];
    
}

- (void)actionAfterSignUp
{
    [super actionAfterSignUp];
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FASHIONISTA_", nil) message:NSLocalizedString(@"_APPLY_FASHIONISTA_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    */
    
    [self hideApplyForm];
}

- (void)actionAfterSignUpWithError
{
    [super actionAfterSignUpWithError];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FASHIONISTA_", nil) message:NSLocalizedString(@"_ERROR_APPLY_FASHIONISTA_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

- (IBAction)onTapNewPage:(UIButton *)sender
{
    //Here your coding.
    NSLog(@"Click in create new page");
    
    // Paramters for next VC (ResultsViewController)
    NSArray * parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], nil];
    
    [self transitionToViewController:FASHIONISTAMAINPAGE_VC withParameters:parametersForNextVC];
}


#pragma mark - Download
// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSManagedObjectContext *currentContext;

    switch (connection)
    {
        case GET_FASHIONISTAPAGES:
        {
            NSLog(@"Num pages %ld", currentUser.fashionistaPages.count);
            fashionistaPages = [NSMutableArray arrayWithArray:[[currentUser.fashionistaPages allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]]];
            
            [self.tableviewFashionistaPages reloadData];
            break;
        }
        case DELETE_FASHIONISTA_PAGE:
        {
            // Get the product that was provided
            [fashionistaPages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[FashionistaPage class]]))
                 {
                     if([[((FashionistaPage *) obj) idFashionistaPage] isEqualToString:[_selectedPageToDelete idFashionistaPage]])
                     {
                         [fashionistaPages removeObject:obj];
                         // Stop the enumeration
                         *stop = YES;
                         
                     }
                 }
             }];

            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            [currentContext deleteObject:_selectedPageToDelete];
            
            NSError * error = nil;
            if (![currentContext save:&error])
            {
                NSLog(@"Error saving context! %@", error);
            }
            
            
            _selectedPageToDelete = nil;
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            if (!(appDelegate.currentUser == nil))
            {
                [self loadDataInViewUser: appDelegate.currentUser];
            }
            
            [self stopActivityFeedback];
            
            break;
        }
            
        default:
            break;
    }
}

// Rest answer not reached
- (void)processRestConnection:(connectionType)connection WithErrorMessage:(NSArray*)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    
    [super processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
}

#pragma mark - get fashionista data from server

-(void) loadFashionistaPages
{
    
    if (fashionistaPages != nil)
        [fashionistaPages removeAllObjects];
    fashionistaPages = nil;
    
    // get all product categories
    NSArray * requestParameters = [NSArray arrayWithObject:currentUser.idUser];
    [self performRestGet:GET_FASHIONISTAPAGES withParamaters:requestParameters];
}

#pragma mark - TableView Fashionista Pages delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//   return currentUser.fashionista_pages.count;
    if (fashionistaPages != nil)
        return fashionistaPages.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the fashionista page data
    // show the cell with the page data, name and show 3 buttons (View, Edit, Delete)
    static NSString *simpleTableIdentifier = @"FashionistaPageCell";

    FashionistaPageCell * currentCell = (FashionistaPageCell*) [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (currentCell == nil) {
        currentCell = (FashionistaPageCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSUInteger iIdx = [indexPath indexAtPosition:1];
    FashionistaPage * page = [fashionistaPages objectAtIndex:iIdx];
    currentCell.fashionistaPageTitleLabel.text = page.title;
    currentCell.btnDelete.tag = iIdx;
    [currentCell.btnDelete addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    currentCell.btnEdit.tag = iIdx;
    [currentCell.btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    currentCell.btnView.tag = iIdx;
    [currentCell.btnView addTarget:self action:@selector(btnViewClicked:) forControlEvents:UIControlEventTouchUpInside];

    currentCell.layer.borderWidth = 0.5;
    currentCell.layer.borderColor = [UIColor blackColor].CGColor;
    
    return currentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // click on the cell
}

-(void)btnViewClicked:(UIButton*)sender
{
    //Here your coding.
    NSLog(@"Click in view %ld", sender.tag);
    
    FashionistaPage * tmpFashionistaPage = [fashionistaPages objectAtIndex:sender.tag];

    if (!(tmpFashionistaPage == nil))
    {
        if (!(tmpFashionistaPage.idFashionistaPage == nil))
        {
            if (!([tmpFashionistaPage.idFashionistaPage isEqualToString:@""]))
            {
                // Paramters for next VC (ResultsViewController)
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: tmpFashionistaPage, [NSNumber numberWithBool:NO], nil];
                
                [self transitionToViewController:FASHIONISTAMAINPAGE_VC withParameters:parametersForNextVC];
            }
        }
    }
}

-(void)btnEditClicked:(UIButton*)sender
{
    //Here your coding.
    NSLog(@"Click in view %ld", sender.tag);
    
    FashionistaPage * tmpFashionistaPage = [fashionistaPages objectAtIndex:sender.tag];
    
    if (!(tmpFashionistaPage == nil))
    {
        if (!(tmpFashionistaPage.idFashionistaPage == nil))
        {
            if (!([tmpFashionistaPage.idFashionistaPage isEqualToString:@""]))
            {
                // Paramters for next VC (ResultsViewController)
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: tmpFashionistaPage, [NSNumber numberWithBool:YES], nil];
                
                [self transitionToViewController:FASHIONISTAMAINPAGE_VC withParameters:parametersForNextVC];
            }
        }
    }
}

-(void)btnDeleteClicked:(UIButton*)sender
{
    //Here your coding.
    NSLog(@"Click in delete %ld", sender.tag);
    
    _selectedPageToDelete = [fashionistaPages objectAtIndex:sender.tag];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEPAGE_", nil) message:NSLocalizedString(@"_REMOVEPAGE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEPAGE_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_CANCEL_", nil)])
        {
            if(!(_selectedPageToDelete == nil))
            {
                _selectedPageToDelete = nil;
            }
        }
        else if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            if (_selectedPageToDelete != nil)
            {
                [self deletePage:_selectedPageToDelete];
            }
        }
    }
}


// Delete Page
- (void)deletePage:(FashionistaPage *)page
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        NSLog(@"Deleting page: %@", page.title);
        
        // Check that the id is valid
        
        if (!(page == nil))
        {
            if (!(page.idFashionistaPage == nil))
            {
                if (!([page.idFashionistaPage isEqualToString:@""]))
                {
                    // Perform request to delete
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DELETINGPAGE_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:page, nil];
                    
                    [self performRestDelete:DELETE_FASHIONISTA_PAGE withParamaters:requestParameters];
                    
                }
            }
        }
    }
}

#pragma mark - Events

- (IBAction)btnEditProfileClick:(UIButton *)sender {
    // open UserSignUP ViewController
    //[self transitionToViewController:EDITPROFILE_VC withParameters:nil ];
    [self transitionToViewController:USERPROFILE_VC withParameters:nil ];
}

- (IBAction)btnAccountSettingsClick:(UIButton *)sender {
}

- (IBAction)btnSupportClick:(UIButton *)sender {
    [self showEmail];
}

- (IBAction)btnPrivacySecurityClick:(UIButton *)sender {
    return;
//    // Do any additional setup after loading the view.
//    NSURL *websiteUrl = [NSURL URLWithString:@"http://www.google.com"];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
//    [self.webView loadRequest:urlRequest];
//
//    [self showView:self.viewWebView];
}
- (IBAction)btnTermsConditions:(UIButton *)sender {
    NSURL *websiteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/terms_conditions.html",IMAGESBASEURL]];
//    NSURL *websiteUrl = [NSURL URLWithString:@"http://209.133.201.250/terms_conditions.html"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [self.webView loadRequest:urlRequest];
    [self showView:self.viewWebView];
}

- (IBAction)btnFashionistaClick:(UIButton*)sender {
    [self showFashionista];
}

- (IBAction)btnApplyNow:(UIButton *)sender {
    [self showApplyForm];
}

- (IBAction)btnSubmitApply:(UIButton *)sender {
    [self applyFashionista];
}

- (IBAction)btnLogoutClick:(UIButton *)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.currentUser.delegate = self;
    
    [appDelegate.currentUser logOut];
    
    [self showMainMenu:nil];
}

@end
