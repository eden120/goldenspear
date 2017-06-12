//
//  GSSocialAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleView.h"

@interface GSSocialAccountModuleView : GSAccountModuleView<UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UITextField *websiteField;
@property (weak, nonatomic) IBOutlet UITextField *twitterField;
@property (weak, nonatomic) IBOutlet UITextField *facebookField;
@property (weak, nonatomic) IBOutlet UITextField *instagramField;
@property (weak, nonatomic) IBOutlet UITextField *linkedinField;

@end
