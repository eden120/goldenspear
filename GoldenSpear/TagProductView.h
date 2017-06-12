//
//  TagProductView.h
//  GoldenSpear
//
//  Created by Crane on 8/13/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagProductView : UIView
@property (weak, nonatomic) IBOutlet UILabel *tagNameLab;
@property (weak, nonatomic) IBOutlet UIButton *deleteTagBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagLabWidth;
@property (weak, nonatomic) IBOutlet UIView *separateView;

@end
