//
//  InviteView.h
//  GoldenSpear
//
//  Created by Crane on 8/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteView : UIView
@property (weak, nonatomic) IBOutlet UITextField *userNameTxt;
@property (weak, nonatomic) IBOutlet UIButton *maleBtn;
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailTxt;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *tagBtn;
@property (weak, nonatomic) IBOutlet UILabel *resultLab;


@end
