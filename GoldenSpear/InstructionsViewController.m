//
//  InstructionsViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 14/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import "InstructionsViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+TopBarManagement.h"

#import "SearchBaseViewController.h"

@interface InstructionsViewController ()

@end

@implementation InstructionsViewController

- (void)viewDidLoad
{
    [self hideTopBar];
    [super viewDidLoad];
    
    // Load instructions in an HTML document
    [self loadWebInstructions];
 
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SPLASH_MESSAGE_", nil)];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopActivityFeedback];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Load instructions in an HTML document
- (void)loadWebInstructions
{
    // TODO: Consider localization to display instructions in the proper language
    
    //Load instructions from the web
    
    /*NSString *instructionsURL = @"http://www.google.com";
     
     NSURL *instURL = [NSURL URLWithString:instructionsURL];
     
     NSURLRequest *requestObj = [NSURLRequest requestWithURL:instURL];
     
     [_webviewInstructions loadRequest:requestObj];*/
    
    //Load instructions from a local HTML file
    
    NSString *instructionsLocalFile = [[NSBundle mainBundle] pathForResource:@"Instructions" ofType:@"html"];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:instructionsLocalFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *aPath = [[NSBundle mainBundle] bundlePath];
    
    NSURL *anURL = [NSURL fileURLWithPath:aPath];
    
    [_webViewInstructions loadHTMLString:htmlString baseURL:anURL];
    
    // Set in iOS defaults system that the view was already been shown once
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:TRUE forKey:@"InstructionsShown"];
    
    [defaults synchronize];
}


#pragma mark - Test Login

// User delegate: log in
// Peform an action once the user logs in
- (void)actionAfterLogIn
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currentUser.typeprofessionId==nil||[appDelegate.currentUser.typeprofessionId isEqualToString:@""]){
        UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
        [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(ACCOUNT_VC) stringValue]]];
        //[((BaseViewController*)appDelegate.window.rootViewController) actionAfterLogIn];
    }else{
        
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
    }
    /*
    UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]]];
    [((SearchBaseViewController*)appDelegate.window.rootViewController) actionAfterLogIn];
     */
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


// Peform an action once the user logs in
- (void)actionAfterLogInWithError
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]]];
    
    [((SearchBaseViewController*)appDelegate.window.rootViewController) actionAfterLogInWithError];
    
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    [appDelegate.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]]];
    
    [((SearchBaseViewController*)appDelegate.window.rootViewController) actionAfterLogOut];
}

@end
