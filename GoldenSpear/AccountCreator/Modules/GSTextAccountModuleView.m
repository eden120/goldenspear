//
//  GSSocialAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTextAccountModuleView.h"
#import "AppDelegate.h"

@implementation GSTextAccountModuleView

- (void)dealloc{
    fieldsArray = nil;
}

- (id)init{
    if((self=[super init])){
        UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
        for (UITextField* field in _textFields) {
            field.layer.borderColor = color.CGColor;
            field.layer.borderWidth= 1.0;
        }
        fieldsArray = [NSMutableArray new];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //Adjust width after autolayout resizing
    for (UITextField* f in fieldsArray) {
        CGRect theFrame = f.frame;
        theFrame.size = self.mainTextField.frame.size;
        f.frame = theFrame;
    }
}

- (void)fillTextBoxes:(GSAccountModule*)module withUser:(User*)theUser{
    NSString* lastText = nil;
    if (module.numElements==1) {
        self.addButton.hidden = YES;
        [self.addButton.superview sendSubviewToBack:self.addButton];
        lastText = [theUser valueForKey:module.userkey];
    }else{
        fieldsArray = [NSMutableArray new];
        NSString* keyCollection = [theUser valueForKey:module.userkey];
        NSArray* fieldTexts = [keyCollection componentsSeparatedByString:@","];
        if(fieldTexts){
            for (int i = 0 ; i<[fieldTexts count]-1; i++) {
                [self addField:nil];
                UITextField* theField = [fieldsArray lastObject];
                theField.text = [fieldTexts objectAtIndex:i];
            }
        }
        lastText = [fieldTexts lastObject];
        self.mainTextField.text = (lastText?lastText:@"");
        self.mainTextField.tag = [fieldsArray count];
    }
    self.mainTextField.text = (lastText?lastText:@"");
    self.mainTextField.placeholder = [module.caption uppercaseString];
}

- (void)fillModule:(User*)theUser withAccountModule:(GSAccountModule*)module{
    [super fillModule:theUser withAccountModule:module];
    [self.mainContent layoutIfNeeded];
    [self fillTextBoxes:module withUser:theUser];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString* fieldString = self.mainTextField.text;
    if (self.theModule.numElements!=1) {
        NSMutableString* finalString = [NSMutableString new];
        for (UITextField* field in fieldsArray) {
            NSString* theString = field.text;
            if (![theString isEqualToString:@""]) {
                if([finalString length]>0){
                    [finalString appendFormat:@",%@",theString];
                }else{
                    [finalString appendString:theString];
                }
            }
        }
        NSString* theString = self.mainTextField.text;
        if (![theString isEqualToString:@""]) {
            if([finalString length]>0){
                [finalString appendFormat:@",%@",theString];
            }else{
                [finalString appendString:theString];
            }
        }
        fieldString = finalString;
    }
    [moduleUser setValue:fieldString forKey:self.theModule.userkey];
}

- (IBAction)addField:(id)sender {
    if((self.theModule.numElements==0||self.theModule.numElements>[fieldsArray count])&&(![self.mainTextField.text isEqualToString:@""]||sender==nil)){
        
        [self endEditing:YES];
        UITextField* aField = [UITextField new];
        CGRect theFrame = self.mainTextField.bounds;
        theFrame.origin.x = 20;
        theFrame.origin.y = 10+self.extraFieldsHeight.constant;
        aField.frame = theFrame;
        aField.font = self.mainTextField.font;
        aField.tag = [fieldsArray count];
        aField.placeholder = [self.theModule.caption uppercaseString];
        [self.extraFieldsContainer addSubview:aField];
        UIColor * color = [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0];
        aField.layer.borderColor = color.CGColor;
        aField.layer.borderWidth= 1.0;
        aField.text = self.mainTextField.text;
        self.mainTextField.text = @"";
        aField.delegate = self;
        [fieldsArray addObject:aField];
        
        self.mainTextField.tag = [fieldsArray count];
        
        CGFloat oldHeight = self.mainContent.contentSize.height;
        self.extraFieldsHeight.constant = [fieldsArray count]*(40+10);
        [self.mainContent layoutIfNeeded];
        
        if(oldHeight!=self.mainContent.contentSize.height){
            CGFloat variation = self.mainContent.contentSize.height-oldHeight;
            self.moduleHeightConstraint.constant += variation;
            [self.delegate module:self increasedItsSize:variation];
        }
    }
}

@end
