//
//  MagazineRelationViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/8/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "MagazineRelationViewController.h"
#import "BaseViewController+RestServicesManagement.h"
#import "UIImageView+WebCache.h"

@interface MagazineRelationViewController()

@end

@implementation MagazineRelationViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onTapMore:(id)sender {
}

-(void)initView {
    if ([_posts count] > 3) {
        _moreButton.hidden = NO;
    }
    else {
        _moreButton.hidden = YES;
    }
    if ([_posts count] > 0) {
        _noResultLabel.hidden = YES;
        _containerVC.hidden = NO;
        
        FashionistaPost *firstPost = [_posts objectAtIndex:0];
        [_firstMagazineImage sd_setImageWithURL:[NSURL URLWithString:firstPost.preview_image]];
        _firstMagazineCategoryLabel.text = firstPost.magazineCategory;
        _firstMagazineUserLabel.text = firstPost.author.name;
        
        if ([_posts count] > 1) {
            _secondMagazineView.hidden = NO;
            FashionistaPost *firstPost = [_posts objectAtIndex:1];
            [_secondMagazineImage sd_setImageWithURL:[NSURL URLWithString:firstPost.preview_image]];
            _secondMagazineCategoryLabel.text = firstPost.magazineCategory;
            _secondMagazineUserLabel.text = firstPost.author.name;
            
            if ([_posts count] > 2) {
                _thirdMagazineView.hidden = NO;
                FashionistaPost *firstPost = [_posts objectAtIndex:2];
                [_thirdMagazineImage sd_setImageWithURL:[NSURL URLWithString:firstPost.preview_image]];
                _thirdMagazineCategoryLabel.text = firstPost.magazineCategory;
                _thirdMagazineUserLabel.text = firstPost.author.name;
            }
            else {
                _thirdMagazineView.hidden = YES;
            }
        }
        else {
            _secondMagazineView.hidden = YES;
            _thirdMagazineView.hidden = YES;
        }
    }
    else {
        _noResultLabel.hidden = NO;
        _containerVC.hidden = YES;
    }
}

@end
