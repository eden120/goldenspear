//
//  GSAccountModuleVaryingHeightView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModuleView.h"

@interface GSAccountModuleVaryingHeightView : GSAccountModuleView

@property (weak, nonatomic) IBOutlet UIScrollView *mainContent;
@property (weak, nonatomic) NSLayoutConstraint *moduleHeightConstraint;

@end
