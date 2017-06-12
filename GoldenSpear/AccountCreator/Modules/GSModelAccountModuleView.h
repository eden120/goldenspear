//
//  GSSocialAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleView.h"

typedef enum{
    GSModelAccountOptionMale,
    GSModelAccountOptionFemale
}GSModelAccountOption;

@class GSModelAccountModuleView;

@protocol GSModelAccountModuleViewDelegate <NSObject>

- (void)modelViewPushed:(GSModelAccountModuleView*)module withOption:(GSModelAccountOption)modelOption;

@end

@interface GSModelAccountModuleView : GSAccountModuleView<UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (nonatomic, weak) id<GSModelAccountModuleViewDelegate> modelDelegate;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;

- (IBAction)malePushed:(UIButton *)sender;
- (IBAction)femalePushed:(UIButton *)sender;

@end
