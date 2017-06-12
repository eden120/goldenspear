//
//  LivePlayerViewController.h
//  GoldenSpear
//
//  Created by Crane on 8/30/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LivePlayerViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *popView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *playStart;
@property (weak, nonatomic) IBOutlet UIImageView *playTrack;
@property (weak, nonatomic) IBOutlet UILabel *timerLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackOffsetWidth;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIView *seekBar;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UIView *scrollerView;
@property (weak, nonatomic) IBOutlet UIView *toolBtnView;
@property (weak, nonatomic) IBOutlet UIView *labelView;
@property (nonatomic) NSString *liveStreamingID;

- (IBAction)shareAction:(id)sender;
- (IBAction)chatAction:(id)sender;
- (IBAction)openChat:(id)sender;
- (IBAction)favoriteAction:(id)sender;

@end
