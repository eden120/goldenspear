//
//  WardrobeViewController.h
//  GoldenSpear
//
//  Created by JAVIER CASTAN SANCHEZ on 3/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface WardrobeViewController : BaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *WardrobeBinView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WardrobeBinViewHeightConstraint;
@property (nonatomic, strong) NSMutableArray * wardrobeBinItems;
@property (weak, nonatomic) IBOutlet UIButton *removeWardrobeBinItemsButton;

@property (weak, nonatomic) IBOutlet UITextField *wardrobeNewName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraints;

@property BOOL bEditionMode;

@end
