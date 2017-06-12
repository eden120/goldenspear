//
//  GSImageTaggableView.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 22/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSImageTaggableView.h"

@interface GSTaggableView (Protected)

- (void)showTagList:(BOOL)showOrNot;

@end

@interface GSImageTaggableView (){
    AVPlayerViewController * player;
    BOOL playing;
    NSString *videourl;
    BOOL hasSound;
}

@end

@implementation GSImageTaggableView

- (void)dealloc{
    [player.player removeObserver:self forKeyPath:@"rate"];
    [player removeObserver:self forKeyPath:@"readyForDisplay"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    player = nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL isInside = NO;
    if(self.tapAbleView){
        isInside = [super pointInside:point withEvent:event];
    }else if(player){
        isInside = CGRectContainsPoint(self.audioButton.frame, point);
    }
    return isInside;
}

- (void)manageVideoPlay:(BOOL)playOrNot{
    if(playOrNot){
        if(player){
            [self.imageView.superview sendSubviewToBack:self.imageView];
            self.tagContainer.alpha = 0;
            [player.player play];
        }
    }else{
        if(playing&&player){
            [self.imageView.superview bringSubviewToFront:self.imageView];
            [player.player pause];
        }
    }
}

- (void)showTags:(BOOL)showOrNot{
    [self layoutSubviews];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.tagContainer.alpha = (showOrNot?1:0);
                     }];
    [self manageVideoPlay:!showOrNot];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (IBAction)tagContainerTapped:(UITapGestureRecognizer *)sender{
    if (self.tagListContainer.alpha==1.0) {
        [self showTagList:NO];
    }else{
        [self showTags:(self.tagContainer.alpha==0.0)];
    }
}
- (IBAction)imagePinched:(UIPinchGestureRecognizer *)sender {
    NSLog(@"Image Pinch : ");
    [self.viewDelegate pinchImage:_imageView.image];
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint location = [touch locationInView:self.backgroundContainer];
//    self.imageView.center = location;
//}
//
//-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self touchesBegan:touches withEvent:event];
//}

- (void)stopVideo{
    if(player){
        [self manageVideoPlay:NO];
        player.player.volume = 0;
        self.audioButton.selected = NO;
    }
}

- (void)startVideo{
    if(player){
        [self manageVideoPlay:YES];
    }
}

- (void)setVideoWithURL:(NSString*)videoURL currentTime:(CMTime)currentTime hasSound:(BOOL)sound {
    if (videoURL==nil) {
        [player.view removeFromSuperview];
        [player.player removeObserver:self forKeyPath:@"rate"];
        [player removeObserver:self forKeyPath:@"readyForDisplay"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        player = nil;
        self.audioButton.hidden = YES;
        [self.audioButton.superview sendSubviewToBack:self.audioButton];
    }else{
        videourl = videoURL;
        NSLog(@"Video URL : %@", videoURL);
        playing = NO;
        player = [[AVPlayerViewController alloc] init];
        
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: &_error];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        
        player.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoURL]];
        player.showsPlaybackControls = YES;
        player.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [player.player seekToTime:currentTime];
        
        player.view.frame = self.videoContainerView.bounds;

        int h = player.view.frame.size.height;
        
        UIView * pView = player.view;
        // Insert View into Post View
        [self.videoContainerView addSubview:pView];
        [pView.superview bringSubviewToFront:pView];
        [player.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
        [player addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[player.player currentItem]];
        
        self.audioButton.hidden = NO;
        [self.audioButton.superview bringSubviewToFront:self.audioButton];
        if (sound) {
            player.player.volume = 1;
        }
        else {
            player.player.volume = 0;
        }
        self.audioButton.selected = sound;
    }
}

- (IBAction)audioPushed:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        player.player.volume = 1;
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
    }else{
        player.player.volume = 0;
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: &_error];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([player.player rate]) {
            playing = YES;
        }else{
            playing = NO;
            [self manageVideoPlay:NO];
        }
    }else if ([keyPath isEqualToString:@"readyForDisplay"]) {
        if (player.readyForDisplay&&!playing)
        {
            [self manageVideoPlay:YES];
        }
    }
}

-(NSString*)getVideoURL {
    
    return videourl;
}

-(CMTime)getVideoPlayer {
    CMTime currentTime = player.player.currentItem.currentTime;
    [player.player pause];
    return currentTime;
}

-(BOOL)hasSoundNow {
    if (player.player.volume == 0) {
        return false;
    }
    return true;
}

-(void)setPlayer:(CMTime)videoPlayer hasSound:(BOOL)sound {
    [player.player seekToTime:videoPlayer];
    hasSound = sound;
}

@end
