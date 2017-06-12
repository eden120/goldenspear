//
//  MagazineMoreViewController.h
//  GoldenSpear
//
//  Created by JCB on 9/7/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagazineMoreViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *containerVC;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;

@property (weak, nonatomic) IBOutlet UIView *firstMagazineView;
@property (weak, nonatomic) IBOutlet UIImageView *firstMagazineImage;
@property (weak, nonatomic) IBOutlet UILabel *firstMagazineCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstMagazineUserLabel;

@property (weak, nonatomic) IBOutlet UIView *secondMagazineView;
@property (weak, nonatomic) IBOutlet UIImageView *secondMagazineImage;
@property (weak, nonatomic) IBOutlet UILabel *secondMagazineCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondMagazineUserLabel;

@property (weak, nonatomic) IBOutlet UIView *thirdMagazineView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdMagazineImage;
@property (weak, nonatomic) IBOutlet UILabel *thirdMagazineCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdMagazineUserLabel;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property NSMutableArray *posts;

-(void)initView;

@end
