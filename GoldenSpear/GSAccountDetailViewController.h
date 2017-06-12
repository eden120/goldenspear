//
//  GSAccountDetailViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 18/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSAccountModuleView.h"
#import "GSImageAccountModuleView.h"
#import "CustomCameraViewController.h"
#import "GSAgencyAccountModuleView.h"
#import "GSModelAccountModuleView.h"
#import "PickerViewButtons.h"

typedef enum{
    GSAccountDetailModalModeNone,
    GSAccountDetailModalModeModelMale,
    GSAccountDetailModalModeModelFemale,
    GSAccountDetailModalModeAgency
}GSAccountDetailModalMode;

@protocol GSAccountDetailViewControllerDelegate <NSObject>

- (void)commitSave;

@end

@interface GSAccountDetailViewController : BaseViewController<GSAccountModuleViewDelegate,GSImageAccountModuleViewDelegate,CustomCameraViewControllerDelegate,GSAgencyAccountModuleViewDelegate,GSModelAccountModuleViewDelegate,UITextFieldDelegate,PickerViewButtonsDelegate>

@property (weak, nonatomic) id<GSAccountDetailViewControllerDelegate> accountDelegate;
@property (weak, nonatomic) IBOutlet UIView *moduleContainer;

@property (weak,nonatomic) User* editingUser;

- (IBAction)saveData:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containterHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@property (weak, nonatomic) IBOutlet UIView *modalViewShow;
- (IBAction)closeModal:(id)sender;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *modalViews;

//Model
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *heightFields;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *hairColorFields;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *eyeColorFields;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *waistFields;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *shoeFields;

//Male
@property (weak, nonatomic) IBOutlet UIView *maleModelView;
@property (weak, nonatomic) IBOutlet UITextField *suitSizeField;
@property (weak, nonatomic) IBOutlet UITextField *inseamField;
@property (weak, nonatomic) IBOutlet UITextField *shirtField;

//Female
@property (weak, nonatomic) IBOutlet UIView *femaleModelView;
@property (weak, nonatomic) IBOutlet UITextField *bustField;
@property (weak, nonatomic) IBOutlet UITextField *hipsField;

//Agency
@property (weak, nonatomic) IBOutlet UIView *agencyView;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *agencyFields;

- (IBAction)hairColorStartEdit:(UITextField *)sender;
- (IBAction)eyeColorStartEdit:(UITextField *)sender;
- (IBAction)suitSizeStartEdit:(UITextField *)sender;
- (IBAction)shirtSizeStatEdit:(UITextField *)sender;
- (IBAction)showSizeStartEdit:(UITextField *)sender;
- (IBAction)cancelPushed:(id)sender;

@end
