//
//  GSSocialAccountModuleView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSwitchAccountModuleView.h"
#import "AppDelegate.h"

#define kContainerInnerXMargin 5
#define kGrayBackground [UIColor colorWithRed:(184.0/255.0) green:(184.0/255.0) blue:(184.0/255.0) alpha:1.0]

@implementation GSSwitchAccountModuleView{
    //NSMutableArray* optionsArray;
    NSMutableArray* selectedOptionsArray;
    
    SlideButtonView *slideButton;
}

- (id)init{
    if((self=[super init])){
        //optionsArray = [NSMutableArray new];
        selectedOptionsArray = [NSMutableArray new];
        UIColor * color = kGrayBackground;
        self.mainContent.layer.borderColor = color.CGColor;
        self.mainContent.layer.borderWidth= 1.0;
        
        slideButton = [SlideButtonView new];
        [self.optionsContainer addSubview:slideButton];
        slideButton.bMultiselect = YES;
        slideButton.bUnselectWithClick = YES;
        slideButton.frame = self.optionsContainer.bounds;
        slideButton.delegate = self;
        slideButton.typeSelection = HIGHLIGHT_TYPE;
        slideButton.spaceBetweenButtons = 5;
        //slideButton.colorSelectedTextButtons = GOLDENSPEAR_COLOR;
        slideButton.colorBackgroundButtons = kGrayBackground;
        slideButton.colorBackgroundSelectedButtons = GOLDENSPEAR_COLOR;
        slideButton.bButtonsCentered = YES;
        [slideButton setSNameButtonImageHighlighted:@"termListButtonBackground.png"];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect theFrame = slideButton.frame;
    theFrame.size.width = MIN(theFrame.size.width, self.optionsContainer.frame.size.width-2*kContainerInnerXMargin);
    slideButton.frame = theFrame;
    [slideButton updateButtons];
    //Adjust width after autolayout resizing
    /*
    for (UIButton* b in optionsArray) {
        CGRect theFrame = b.frame;
        theFrame.size.width = MIN(theFrame.size.width, self.optionsContainer.frame.size.width-2*kContainerInnerXMargin);
        b.frame = theFrame;
    }
     */
}

- (void)fillModule:(User*)theUser withAccountModule:(GSAccountModule *)module{
    [super fillModule:theUser withAccountModule:module];
    [self.mainContent layoutIfNeeded];
    
    NSString* selectedString = [theUser valueForKey:module.userkey];
    [selectedOptionsArray addObjectsFromArray:[selectedString componentsSeparatedByString:@","]];
    
    for (NSString* option in module.values) {
        [self addOption:option];
    }
    if (![module.caption isEqualToString:@""]) {
        self.titleCaption.text = [module.caption capitalizedString];
    }
}

- (void)setupOptions{
    NSMutableString* finalString = [NSMutableString stringWithString:@""];
    for (NSString* option in selectedOptionsArray) {
        if([finalString length]>0){
            [finalString appendFormat:@",%@",option];
        }else{
            [finalString appendString:option];
        }
    }
    
    [moduleUser setValue:finalString forKey:self.theModule.userkey];
}

- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry{
    if([slideButtonView isSelected:buttonEntry]){
        if(![selectedOptionsArray containsObject:[slideButton sGetNameButtonByIdx:buttonEntry]])
        {
            [selectedOptionsArray addObject:[slideButton sGetNameButtonByIdx:buttonEntry]];
        }
    }else{
        [selectedOptionsArray removeObject:[slideButton sGetNameButtonByIdx:buttonEntry]];
    }
    [self setupOptions];
}

- (void)addOption:(NSString*)option {
    SlideButtonProperties* properties = [SlideButtonProperties new];
    
    properties.colorSelectedTextButtons = GOLDENSPEAR_COLOR;
    properties.colorTextButtons = [UIColor blackColor];
    
    [slideButton addButton:option withProperties:properties];
    
    if([selectedOptionsArray containsObject:option]){
        [slideButton selectButton:(int)[slideButton count]-1];
    }
}

/*
- (void)optionPush:(UIButton*)button{
    button.selected = !button.selected;
    NSString* key = [self.theModule.values objectAtIndex:button.tag];
    if (button.selected) {
        button.backgroundColor = GOLDENSPEAR_COLOR;
        [selectedOptionsArray addObject:key];
    }else{
        button.backgroundColor = kGrayBackground;
        [selectedOptionsArray removeObject:key];
    }
    [self setupOptions];
}

 - (void)addOption:(NSString*)option {
    UIButton* aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect theFrame = CGRectMake(0, self.optionsHeight.constant, 10, 30);
    aButton.frame = theFrame;
    [aButton setTitle:[option uppercaseString] forState:UIControlStateNormal];
    [aButton sizeToFit];
    aButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:15];
    [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if([selectedOptionsArray containsObject:option]){
        aButton.selected = YES;
        aButton.backgroundColor = GOLDENSPEAR_COLOR;
    }else{
        aButton.selected = NO;
        aButton.backgroundColor = kGrayBackground;
    }
    aButton.tag = [optionsArray count];
    [aButton addTarget:self action:@selector(optionPush:) forControlEvents:UIControlEventTouchUpInside];
    [self.optionsContainer addSubview:aButton];
    
    [optionsArray addObject:aButton];
    
    CGFloat oldHeight = self.mainContent.contentSize.height;
    self.optionsHeight.constant = [optionsArray count]*(30+10);
    [self.mainContent layoutIfNeeded];
    
    if(oldHeight!=self.mainContent.contentSize.height){
        CGFloat variation = self.mainContent.contentSize.height-oldHeight;
        self.moduleHeightConstraint.constant += variation;
        [self.delegate module:self increasedItsSize:variation];
    }
}
*/
@end
