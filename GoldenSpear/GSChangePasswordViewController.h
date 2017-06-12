//
//  GSChangePasswordViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "User+Manage.h"

@interface GSChangePasswordViewController : BaseViewController<UITextFieldDelegate,UserDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *borderFields;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordField;
- (IBAction)savePassword:(id)sender;
- (IBAction)cancelPushed:(id)sender;

@end
