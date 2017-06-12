//
//  TagView.h
//  GoldenSpear
//
//  Created by Crane on 8/2/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *starImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labWidth;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;

@end
