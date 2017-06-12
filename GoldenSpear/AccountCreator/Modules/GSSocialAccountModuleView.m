//
//  GSSocialAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialAccountModuleView.h"
#import "AppDelegate.h"

@implementation GSSocialAccountModuleView

- (id)init{
    if((self=[super init])){
        UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
        for (UITextField* field in _textFields) {
            field.layer.borderColor = color.CGColor;
            field.layer.borderWidth= 1.0;
        }
    }
    return self;
}

- (void)fillModule:(User*)theUser withAccountModule:(GSAccountModule*)module{
    [super fillModule:theUser withAccountModule:module];
    if (theUser.fashionistaBlogURL) {
        _websiteField.text = theUser.fashionistaBlogURL;
    }
    if (theUser.twitter_id) {
        _twitterField.text = theUser.twitter_url;
    }
    if (theUser.facebook_id) {
        _facebookField.text = theUser.facebook_url;
    }
    if (theUser.instagram_id) {
        _instagramField.text = theUser.instagram_url;
    }
    if (theUser.linkedin_id) {
        _linkedinField.text = theUser.linkedin_url;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField==self.websiteField){
        moduleUser.fashionistaBlogURL = textField.text;
    }
    if(textField==self.twitterField){
        moduleUser.twitter_url = textField.text;
    }
    if(textField==self.facebookField){
        moduleUser.facebook_url = textField.text;
    }
    if(textField==self.linkedinField){
        moduleUser.linkedin_url = textField.text;
    }
    if(textField==self.instagramField){
        moduleUser.instagram_url = textField.text;
    }
}

@end
