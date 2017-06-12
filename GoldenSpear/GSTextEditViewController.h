//
//  GSTextEditViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 6/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@protocol GSTextEditViewControllerDelegate

- (void)commitEditionWithString:(NSString*)textString;

@end

@interface GSTextEditViewController : BaseViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *controllerTitle;
@property (weak, nonatomic) IBOutlet UITextField *textEdit;
@property (weak, nonatomic) id<GSTextEditViewControllerDelegate> textDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistanceConstraint;

- (IBAction)acceptPushed:(id)sender;
- (IBAction)cancelButtonPushed:(id)sender;

@end
