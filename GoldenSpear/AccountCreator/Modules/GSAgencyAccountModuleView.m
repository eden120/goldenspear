//
//  GSSocialAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAgencyAccountModuleView.h"
#import "AppDelegate.h"

@implementation GSAgencyAccountModuleView{
    NSMutableArray* fieldsData;
    NSInteger editingField;
}

- (void)dealloc{
    fieldsData = nil;
}

- (id)init{
    if((self=[super init])){
        fieldsData = [NSMutableArray new];
        [fieldsData addObject:[NSMutableArray new]];
    }
    return self;
}

- (void)fillTextBoxes:(GSAccountModule*)module withUser:(User*)theUser{
    NSString* lastText;
    if (!module.caption||[module.caption isEqualToString:@""]) {
        module.caption = @"AGENCY";
        module.numElements = 0;
    }
    if (module.numElements==1) {
        self.addButton.hidden = YES;
        [self.addButton.superview sendSubviewToBack:self.addButton];
        lastText = theUser.agencies;
    }else{
        fieldsArray = [NSMutableArray new];
        NSString* keyCollection = theUser.agencies;
        NSArray* agenciesTexts = [keyCollection componentsSeparatedByString:@"#"];
        for (int i = 0 ; i<[agenciesTexts count]-1; i++) {
            NSArray* fieldTexts = [[agenciesTexts objectAtIndex:i] componentsSeparatedByString:@","];
            [self addField:nil];
            UITextField* theField = [fieldsArray lastObject];
            NSString* theText = [fieldTexts firstObject];
            theField.text = theText;
            [fieldsData insertObject:[NSMutableArray arrayWithArray:fieldTexts] atIndex:theField.tag];
        }
        lastText = [agenciesTexts lastObject];
    }
    
    if (lastText&&![lastText isEqualToString:@""]) {
        NSArray* fieldTexts = [lastText componentsSeparatedByString:@","];
        lastText = [fieldTexts firstObject];
        [fieldsData replaceObjectAtIndex:[fieldsData count]-1 withObject:[NSMutableArray arrayWithArray:fieldTexts]];
    }
    self.mainTextField.text = (lastText?lastText:@"");
    self.mainTextField.placeholder = [module.caption uppercaseString];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    editingField = textField.tag;
    if([fieldsData count]==editingField){
        [fieldsData addObject:[NSMutableArray new]];
    }
    [self.agencyDelegate agencyViewPushed:self withData:[fieldsData objectAtIndex:textField.tag] andPosition:textField.center];
    return NO;
}

- (void)setAgencyDataForEditingField:(NSArray*)theData{
    BOOL isEmpty = YES;
    for (int i =0; i<[theData count]&&isEmpty; i++) {
        if(![[theData objectAtIndex:i] isEqualToString:@""]){
            isEmpty = NO;
        }
    }
    if(!isEmpty){
        NSString* text = [theData firstObject];
        [fieldsData replaceObjectAtIndex:editingField withObject:[NSMutableArray arrayWithArray:theData]];
        UITextField* theField = self.mainTextField;
        if (editingField<[fieldsArray count]) {
            theField = [fieldsArray objectAtIndex:editingField];
        }
        theField.text = text;
    }else{
        [fieldsData replaceObjectAtIndex:editingField withObject:[NSMutableArray new]];
        UITextField* theField = self.mainTextField;
        if (editingField<[fieldsArray count]) {
            theField = [fieldsArray objectAtIndex:editingField];
        }
        theField.text = @"";
    }
    [self setAgenciesInUser];
}

- (void)setAgenciesInUser{
    NSMutableString* finalString = [NSMutableString stringWithString:@""];
    for(NSArray* agency in fieldsData){
        if([agency count]>0){
            if([finalString length]>0){
                [finalString appendString:@"#"];
            }
            for (int i =0 ; i< [agency count];i++) {
                NSString* elem = [agency objectAtIndex:i];
                if (i>0) {
                    [finalString appendString:@","];
                }
                [finalString appendString:elem];
            }
        }
    }
    moduleUser.agencies = finalString;
}

@end
