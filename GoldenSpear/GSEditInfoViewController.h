//
//  GSEditInfoViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 8/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "DatePickerViewButtons.h"
#import "PickerViewButtons.h"
#import "MultiSelectViewButtons.h"

@interface GSEditInfoViewController : BaseViewController<UITextViewDelegate,GSRelatedViewControllerDelegate,DatePickerViewButtonsDelegate,PickerViewButtonsDelegate,MultiSelectViewButtonsDelegate,UserDelegate>

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *framedViews;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (weak, nonatomic) IBOutlet UITextView *bioView;
@property (weak, nonatomic) IBOutlet UILabel *charCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *birthDateField;
@property (weak, nonatomic) IBOutlet UISwitch *birthdayVisible;
@property (weak, nonatomic) IBOutlet UITextField *genderField;
@property (weak, nonatomic) IBOutlet UISwitch *genderVisible;
@property (weak, nonatomic) IBOutlet UITextField *hometownField;
@property (weak, nonatomic) IBOutlet UISwitch *hometownVisible;
@property (weak, nonatomic) IBOutlet UITextField *relationshipField;
@property (weak, nonatomic) IBOutlet UISwitch *relationshipVisible;
@property (weak, nonatomic) IBOutlet UITextField *interestsField;
@property (weak, nonatomic) IBOutlet UISwitch *interestsVisible;
@property (weak, nonatomic) IBOutlet UITextField *politicalViewField;
@property (weak, nonatomic) IBOutlet UISwitch *politicalViewVisible;
@property (weak, nonatomic) IBOutlet UITextField *politicalPartyField;
@property (weak, nonatomic) IBOutlet UISwitch *politicalPartyVisible;
@property (weak, nonatomic) IBOutlet UITextField *religionField;
@property (weak, nonatomic) IBOutlet UISwitch *religionVisible;
@property (weak, nonatomic) IBOutlet UITextField *ethnicityField;
@property (weak, nonatomic) IBOutlet UISwitch *ethnicityVisible;
@property (weak, nonatomic) IBOutlet UIView *ethnicityContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ethnicityCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottomDistanceConstraint;

- (IBAction)genderPushed:(id)sender;
- (IBAction)relationshipPushed:(id)sender;
- (IBAction)interestsPushed:(id)sender;
- (IBAction)ethinicityPushed:(id)sender;
- (IBAction)savePushed:(id)sender;
- (IBAction)birthDatePushed:(id)sender;

@end
