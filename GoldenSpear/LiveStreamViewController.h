//
//  LiveStreamViewController.h
//  GoldenSpear
//
//  Created by Crane on 8/27/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"



@interface LiveStreamViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolviewBottomMargin;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;

@property (weak, nonatomic) IBOutlet UIView *popview;
@property (weak, nonatomic) IBOutlet UIButton *viBtn;
@property (weak, nonatomic) IBOutlet UIButton *privacyBtn;
@property (weak, nonatomic) IBOutlet UILabel *privacyView;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UIView *seekbar;
@property (weak, nonatomic) IBOutlet UILabel *viewers;
@property (weak, nonatomic) IBOutlet UIScrollView *ctgScrollView;
@property (weak, nonatomic) IBOutlet UILabel *liveLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIView *labelView;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackerMove;
@property (weak, nonatomic) IBOutlet UIImageView *redDot;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollviewBottomMargin;
- (IBAction)hidePopupAction:(id)sender;
- (IBAction)torchAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *popupBGView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewBottomMargin;
- (IBAction)switchCam:(id)sender;
- (IBAction)recordAction:(id)sender;


@end
