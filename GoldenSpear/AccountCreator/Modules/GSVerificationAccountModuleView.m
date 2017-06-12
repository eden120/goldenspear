//
//  GSSocialAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSVerificationAccountModuleView.h"
#import "AppDelegate.h"

@implementation GSVerificationAccountModuleView

- (id)init{
    if((self=[super init])){
        
            self.verificationBox.layer.borderColor = [UIColor blackColor].CGColor;
            self.verificationBox.layer.borderWidth= 1.0;
        
    }
    return self;
}

- (void)fillModule:(User*)theUser withAccountModule:(GSAccountModule *)module{
    [super fillModule:theUser withAccountModule:module];
    if ([theUser.validatedprofile boolValue]) {
        self.becomeLabel.hidden = YES;
        self.verifiedLabel.hidden = NO;
        self.verificationBox.hidden = YES;
    }
    if (theUser.datequeryvalidateprofile) {
        self.verificationBox.selected = YES;
    }
}

- (IBAction)verifyPushed:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        moduleUser.datequeryvalidateprofile = [NSDate new];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ACCOUNT_VERIFY_TITLE_", nil)
                                                        message:NSLocalizedString(@"_ACCOUNT_VERIFY_MESSAGE_", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"_OK_", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        moduleUser.datequeryvalidateprofile = nil;
    }
}

@end
