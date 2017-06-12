//
//  GSSocialAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleVaryingHeightView.h"

@interface GSTextAccountModuleView : GSAccountModuleVaryingHeightView<UITextFieldDelegate>{
    NSMutableArray* fieldsArray;
}

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UIView *mainTextFieldView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITextField *mainTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *extraFieldsHeight;
@property (weak, nonatomic) IBOutlet UIView *extraFieldsContainer;

- (IBAction)addField:(id)sender;

@end
