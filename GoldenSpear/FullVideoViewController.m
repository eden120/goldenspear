//
//  FullVideoViewController.m
//  GoldenSpear
//
//  Created by JCB on 8/16/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "AppDelegate.h"
#import "FullVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface FullVideoViewController()

@end


@implementation FullVideoViewController {
    AVPlayerViewController *player;
    MPMoviePlayerController *moviePlayer;
    BOOL playing;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player.player currentItem]];
    [player.player removeObserver:self forKeyPath:@"rate"];
    [player removeObserver:self forKeyPath:@"readyForDisplay"];
    [player.view removeFromSuperview];
    player = nil;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundImageView.hidden = YES;
    self.isPresented = YES;
    
    [self setupVideoWithUrl:[NSURL URLWithString:_videoURL]];
   // [self setupMultiVideoWithURL:_videoURL];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];

}
-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void)manageVideoPlay:(BOOL)playOrNot{
    if(playOrNot){
        if(player){
            [player.player play];
        }
    }else{
        if(playing&&player){
            [player.player pause];
        }
    }
}

-(void)setupMultiVideoWithURL:(NSString*)videoURL {
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];

    AVURLAsset* firstAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoURL] options:nil];
    AVURLAsset * secondAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoURL] options:nil];
    
    AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration);
    
    AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
    CGAffineTransform Scale = CGAffineTransformMakeScale(0.7f,0.7f);
    CGAffineTransform Move = CGAffineTransformMakeTranslation(400,400);
    CGAffineTransform Rotate = CGAffineTransformMakeRotation(M_PI_2);
//    [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale,Move) atTime:kCMTimeZero];
//    [FirstlayerInstruction setTransform:Rotate atTime:kCMTimeZero];
    [FirstlayerInstruction setTransform:CGAffineTransformRotate(CGAffineTransformConcat(Scale, Move), M_PI_2) atTime:kCMTimeZero];
    
    AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
    CGAffineTransform SecondScale = CGAffineTransformMakeScale(1.2f,1.5f);
    CGAffineTransform SecondMove = CGAffineTransformMakeTranslation(160,240);
//    [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondScale,SecondMove) atTime:kCMTimeZero];
    [SecondlayerInstruction setTransform:CGAffineTransformRotate(CGAffineTransformConcat(SecondScale, SecondMove), M_PI_2) atTime:kCMTimeZero];
    
    MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1, 30);
    MainCompositionInst.renderSize = CGSizeMake(640, 480);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:@"overlapVideo.mov"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
        [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
    }
    
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    [exporter setVideoComposition:MainCompositionInst];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:exporter];
         });
     }];
}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    NSLog(@"export did finish...");
    NSLog(@"%li", (long)session.status);
    NSLog(@"%@", session.error);
    NSURL *outputURL = session.outputURL;
    [self setupVideoWithUrl:outputURL];
}

- (void) setMoviePlayer:(NSURL*)overlapVideoURL
{
    playing = NO;
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:overlapVideoURL];
    moviePlayer.view.hidden = NO;
    
    moviePlayer.view.frame = CGRectMake(0, 0, _videoView.frame.size.width, _videoView.frame.size.height);
    moviePlayer.view.backgroundColor = [UIColor clearColor];
    moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    
    moviePlayer.fullscreen = NO;
    [moviePlayer prepareToPlay];
    [moviePlayer readyForDisplay];
    [moviePlayer setControlStyle:MPMovieControlStyleDefault];
    [moviePlayer addObserver:self forKeyPath:@"readyForPlay" options:0 context:nil];
    moviePlayer.shouldAutoplay = YES;
    
    [_videoView addSubview:moviePlayer.view];
}


- (void)setupVideoWithUrl:(NSURL*)videoURL{
    
    
    playing = NO;
    player = [[AVPlayerViewController alloc] init];
    
    NSError *_error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: &_error];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    player.player = [AVPlayer playerWithURL:videoURL];
    [player.player seekToTime:_currentTime];
    
    player.showsPlaybackControls = YES;
    player.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;

    self.playButton.selected = YES;
    
    
    player.view.frame = self.videoView.bounds;
    UIView * pView = player.view;
    pView.backgroundColor = [UIColor clearColor];
    
    AVAsset *asset = [player.player currentItem].asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(1, 1);
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    self.backgroundImageView.image = thumbnail;
    self.backgroundImageView.hidden = NO;
    
    NSLog(@"Video URL : %@",videoURL);
    
    // Insert View into Post View
    
    [self.videoView addSubview:pView];
    [pView.superview bringSubviewToFront:pView];
    
    [player.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [player addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player.player currentItem]];
    
    self.audioButton.hidden = NO;
    [self.audioButton.superview bringSubviewToFront:self.audioButton];
    if (_isSound) {
        player.player.volume = 1;
        [self.audioButton setImage:[UIImage imageNamed:@"unmute_icon.png"] forState:UIControlStateNormal];
    }
    else {
        player.player.volume = 0;
        [self.audioButton setImage:[UIImage imageNamed:@"mute_icon.png"] forState:UIControlStateNormal];
    }
    self.audioButton.selected = _isSound;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

-(void)closeView {
    self.isPresented = NO;
    [_delegate setPlayer:player.player.currentItem.currentTime hasSound:_isSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)videoPlay:(id)sender {
    if (player) {
        if (playing) {
            [player.player pause];
        }else{
            [player.player play];
        }
    }
}

- (IBAction)audioPushed:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        _isSound = YES;
        player.player.volume = 1;
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
        [sender setImage:[UIImage imageNamed:@"unmute_icon.png"] forState:UIControlStateNormal];
    }else{
        _isSound = NO;
        player.player.volume = 0;
        NSError *_error = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: &_error];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [sender setImage:[UIImage imageNamed:@"mute_icon.png"] forState:UIControlStateNormal];
    }
}

@end
