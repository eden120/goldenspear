//
//  GSEthnyView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 9/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSEthnyView.h"
#import "AppDelegate.h"

#define kNameKey    @"name"
#define kGroupKey   @"group"
#define kIdKey      @"id"
#define kOtherKey   @"other"
#define kEthnicityKey   @"ethnicity"

@interface GSEthnyView (){
    NSArray* ethnies;
    NSMutableDictionary* selectedEthnies;
    BOOL settingUpSelected;
    SlideButtonView *slideButton;
}

@end

@implementation GSEthnyView

- (void)dealloc{
    ethnies = nil;
    selectedEthnies = nil;
    slideButton = nil;
}

- (id)init{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                          owner:nil
                                                        options:nil];
    int i = 0;
    while(i<[arrayOfViews count]){
        if([[arrayOfViews objectAtIndex:i] isKindOfClass:[self class]]){
            self = [arrayOfViews objectAtIndex:i];
            slideButton = [SlideButtonView new];
            [self.slideButtonContainer addSubview:slideButton];
            slideButton.bMultiselect = YES;
            slideButton.bUnselectWithClick = YES;
            slideButton.frame = self.slideButtonContainer.bounds;
            slideButton.delegate = self;
            slideButton.typeSelection = HIGHLIGHT_TYPE;
            slideButton.colorSelectedTextButtons = GOLDENSPEAR_COLOR;
            [slideButton setSNameButtonImageHighlighted:@"termListButtonBackground.png"];
            self.translatesAutoresizingMaskIntoConstraints = NO;
            return self;
        }
        i++;
    }
    return nil;
}

- (void)setEthnyGroupCollection:(NSArray*)lEthnies{
    selectedEthnies = [NSMutableDictionary new];
    ethnies = [NSArray arrayWithArray:lEthnies];
    SlideButtonProperties* properties = [SlideButtonProperties new];
    properties.colorSelectedTextButtons = GOLDENSPEAR_COLOR;
    properties.colorTextButtons = [UIColor blackColor];
    for (NSDictionary* ethny in ethnies) {
        self.ethnyGroup.text = [ethny objectForKey:kGroupKey];
        //Add to slideButton
        if(!([[[ethny objectForKey:kNameKey]lowercaseString] isEqualToString:@"other"])){
            [slideButton addButton:[ethny objectForKey:kNameKey] withProperties:properties];
        }
    }
}

- (void)addSelectedEthny:(NSDictionary*)ethny{
    settingUpSelected = YES;
    for (int i =0; i<[ethnies count]; i++) {
        NSDictionary* eth = [ethnies objectAtIndex:i];
        if ([[eth objectForKey:kIdKey] isEqualToString:[ethny objectForKey:kEthnicityKey]]) {
            [selectedEthnies setObject:ethny forKey:[ethny objectForKey:kIdKey]];
            id other = [ethny objectForKey:kOtherKey];
            if(other){
                if(![other isEqualToString:@""]){
                    self.otherField.text = other;
                }
            }else{
                [slideButton selectButton:i];
            }
            break;
        }
    }
    settingUpSelected = NO;
}

- (void)selectEthny:(NSDictionary*)ethny {
    settingUpSelected = YES;
    for (int i =0; i<[ethnies count]; i++) {
        NSDictionary* eth = [ethnies objectAtIndex:i];
        if ([[eth objectForKey:kIdKey] isEqualToString:[ethny objectForKey:kIdKey]]) {
            [selectedEthnies setObject:ethny forKey:[ethny objectForKey:kIdKey]];
            id other = [ethny objectForKey:kOtherKey];
            if(other){
                if(![other isEqualToString:@""]){
                    self.otherField.text = other;
                }
            }else{
                [slideButton selectButton:i];
            }
            break;
        }
    }
    settingUpSelected = NO;
}
- (void)resetSelectedEthny:(NSDictionary*)ethny{
    settingUpSelected = YES;
    for (int i =0; i<[ethnies count]; i++) {
        NSDictionary* eth = [ethnies objectAtIndex:i];
        if ([[eth objectForKey:kIdKey] isEqualToString:[ethny objectForKey:kIdKey]]) {
            [selectedEthnies setObject:ethny forKey:[ethny objectForKey:kIdKey]];
            id other = [ethny objectForKey:kOtherKey];
            if(other){
               // if(![other isEqualToString:@""]){
                    self.otherField.text = @"";
               // }
            }else{
                [slideButton selectButton:i];
            }
            break;
        }
    }
    settingUpSelected = NO;
}

- (void)setSelectedEthnies:(NSArray*)lEthnies{
    settingUpSelected = YES;
    for (NSDictionary* ethny in lEthnies) {
        for (int i =0; i<[ethnies count]; i++) {
            NSDictionary* eth = [ethnies objectAtIndex:i];
            if ([[eth objectForKey:kNameKey] isEqualToString:[ethny objectForKey:kNameKey]]) {
                [selectedEthnies setObject:ethny forKey:[ethny objectForKey:kNameKey]];
                [slideButton selectButton:i];
                continue;
            }
        }
    }
    settingUpSelected = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    NSMutableDictionary* other = nil;
    for (NSDictionary* ethny in ethnies) {
        if(([[[ethny objectForKey:kNameKey]lowercaseString] isEqualToString:@"other"])){
            other = [ethny mutableCopy];
            break;
        }
    }
    if(other){
        [other setObject:textField.text forKey:kOtherKey];
        if (![textField.text isEqualToString:@""]) {
            [self.delegate addNewEthny:other];
            [selectedEthnies setObject:other forKey:[other objectForKey:kNameKey]];
        }else{
            [self.delegate deleteEthny:other];
            [selectedEthnies removeObjectForKey:[other objectForKey:kNameKey]];
        }
    }
}

- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry{
    if (!settingUpSelected) {
        if([slideButtonView isSelected:buttonEntry]){
            NSDictionary* ethny =[ethnies objectAtIndex:buttonEntry];
            [self.delegate addNewEthny:ethny];
            [selectedEthnies setObject:ethny forKey:[ethny objectForKey:kIdKey]];
        }else{
            NSDictionary* ethny =[ethnies objectAtIndex:buttonEntry];
            [self.delegate deleteEthny:ethny];
            [selectedEthnies removeObjectForKey:[ethny objectForKey:kIdKey]];
        }
    }
}

- (void)fixLayout{
    slideButton.frame = self.slideButtonContainer.bounds;
    [slideButton updateButtons];
}

@end
