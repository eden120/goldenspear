//
//  GSSocialAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSModelAccountModuleView.h"
#import "AppDelegate.h"

#define kGrayBackground [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0]

@implementation GSModelAccountModuleView

- (void)fillModule:(User*)theUser withAccountModule:(GSAccountModule *)module{
    [super fillModule:theUser withAccountModule:module];
    NSInteger gender = [theUser.gender integerValue];
    switch (gender) {
        case 1:
            self.maleButton.selected = YES;
            self.maleButton.backgroundColor = GOLDENSPEAR_COLOR;
            break;
        case 2:
            self.femaleButton.selected = YES;
            self.femaleButton.backgroundColor = GOLDENSPEAR_COLOR;
            break;
    }
}

- (IBAction)malePushed:(UIButton *)sender {
    sender.selected = YES;
    NSInteger gender = 1;
    self.maleButton.backgroundColor = GOLDENSPEAR_COLOR;
    self.femaleButton.selected = NO;
    self.femaleButton.backgroundColor = kGrayBackground;
    [self.modelDelegate modelViewPushed:self withOption:GSModelAccountOptionMale];
    moduleUser.gender = [NSNumber numberWithInteger:gender];
}

- (IBAction)femalePushed:(UIButton *)sender {
    sender.selected = YES;
    NSInteger gender = 2;
    self.femaleButton.backgroundColor = GOLDENSPEAR_COLOR;
    self.maleButton.selected = NO;
    self.maleButton.backgroundColor = kGrayBackground;
    [self.modelDelegate modelViewPushed:self withOption:GSModelAccountOptionFemale];
    moduleUser.gender = [NSNumber numberWithInteger:gender];
}

@end
