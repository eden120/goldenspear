//
//  GSSocialAccountModuleView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleVaryingHeightView.h"
#import "SlideButtonView.h"

@interface GSSwitchAccountModuleView : GSAccountModuleVaryingHeightView<SlideButtonViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleCaption;
@property (weak, nonatomic) IBOutlet UIView *optionsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionsHeight;

@end
