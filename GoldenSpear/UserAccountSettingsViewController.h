//
//  UserAccountViewController.h
//  GoldenSpear
//
//  Created by Alberto Seco on 26/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface UserAccountSettingsViewController : BaseViewController <MFMailComposeViewControllerDelegate> //, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *btnEditProfile;
- (IBAction)btnEditProfileClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAccountSettings;
- (IBAction)btnAccountSettingsClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSupport;
- (IBAction)btnSupportClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPrivacySecurity;
- (IBAction)btnPrivacySecurityClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnTermsConditions;
- (IBAction)btnTermsConditions:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnFashionistaAccount;
- (IBAction)btnFashionistaClick:(UIButton*)sender;

@property (weak, nonatomic) IBOutlet UITextField *fashionistaName;
@property (weak, nonatomic) IBOutlet UITextField *fashionistaWeb;

@property (weak, nonatomic) IBOutlet UITextField *fashionistaAccountName;
@property (weak, nonatomic) IBOutlet UITextField *fashionistaAccountWeb;

- (IBAction)btnApplyNow:(UIButton *)sender;
- (IBAction)btnSubmitApply:(UIButton *)sender;

- (IBAction)btnLogoutClick:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *viewWebView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *viewFashionistaApplyForm;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *viewFashionista;
@property (weak, nonatomic) IBOutlet UIView *viewNewFashionista;

@property (weak, nonatomic) IBOutlet UITableView *tableviewFashionistaPages;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceSupportFashionistaConstraint;

@end
