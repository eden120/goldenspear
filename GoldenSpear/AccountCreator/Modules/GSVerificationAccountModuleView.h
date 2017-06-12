//
//  GSSocialAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleView.h"

@interface GSVerificationAccountModuleView : GSAccountModuleView

@property (weak, nonatomic) IBOutlet UILabel *verifiedLabel;
@property (weak, nonatomic) IBOutlet UILabel *becomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *verificationBox;
- (IBAction)verifyPushed:(UIButton *)sender;

@end
