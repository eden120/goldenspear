//
//  FullVideoViewController.h
//  GoldenSpear
//
//  Created by JCB on 8/16/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@protocol FullVideoViewDelegate <NSObject>

-(void)setPlayer:(CMTime)player hasSound:(BOOL)sound;

@end

@interface FullVideoViewController : UIViewController

@property (weak) id<FullVideoViewDelegate> delegate;
@property (nonatomic) NSString* videoURL;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (nonatomic) NSInteger orientation;

@property (nonatomic) CMTime currentTime;
@property BOOL isSound;

-(void)closeView;
@property (nonatomic) BOOL isPresented;
@end

