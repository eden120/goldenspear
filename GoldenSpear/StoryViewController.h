//
//  StoryViewController.h
//  GoldenSpear
//
//  Created by JCB on 9/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ShareViewController.h"
#import "MagazineMoreViewController.h"
#import "MagazineRelationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface StoryViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
    ShareViewController *shareVC;
    MagazineMoreViewController *magazineMoreVC;
    MagazineRelationViewController *magazineRelatedVC;
}

@property (strong, nonatomic) NSArray* postParameters;
@property (weak, nonatomic) IBOutlet UITableView *contentList;
@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property NSMutableArray *moreMagazines;
@property NSMutableArray *relatedMagazines;

@end

@interface textContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *storyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storyLabelHeightConstraint;

@end

@interface imageContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *preview_image;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;
@property (weak, nonatomic) IBOutlet UIView *fullCaptionView;
@property (weak, nonatomic) IBOutlet UILabel *aheadLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aheadLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeFullViewButton;
@property (weak, nonatomic) IBOutlet UIButton *showFullViewButton;

@end

@interface slideContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *preview_image;
@property (weak, nonatomic) IBOutlet UIButton *showSlideButton;

@end

@interface videoContentCell : UITableViewCell {
    AVPlayerViewController *player;
    BOOL playing;
    NSString *videoURL;
    BOOL hasSound;
}

@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;

@end