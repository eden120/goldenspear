//
//  GSImageTaggableView.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 22/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTaggableView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface GSImageTaggableView : GSTaggableView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;

- (void)setVideoWithURL:(NSString*)videoURL currentTime:(CMTime)currentTime hasSound:(BOOL)sound;
- (IBAction)audioPushed:(UIButton *)sender;
- (void)stopVideo;
- (void)startVideo;
- (NSString*)getVideoURL;
- (CMTime)getVideoPlayer;
- (void)setPlayer:(CMTime)videoPlayer hasSound:(BOOL)sound;
-(BOOL)hasSoundNow;
@end
