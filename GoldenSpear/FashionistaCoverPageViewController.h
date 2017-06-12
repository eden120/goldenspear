//
//  FashionistaCoverPageViewController.h
//  GoldenSpear
//
//  Created by JCB on 9/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "StoryViewController.h"

@class StoryViewController;

@interface FashionistaCoverPageViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSArray* postParameters;
@property StoryViewController *storyVC;

@end
