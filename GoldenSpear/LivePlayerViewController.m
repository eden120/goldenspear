//
//  LivePlayerViewController.m
//  GoldenSpear
//
//  Created by Crane on 8/30/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "LivePlayerViewController.h"
#import <MobileVLCKit/MobileVLCKit.h>

#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "UIButton+CustomCreation.h"
#import "UILabel+CustomCreation.h"
#import "MarqueeLabel.h"

#define TOPBAR_TRANSPARENT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]
#define MAX_TIME 180000 //(sec)
@interface LivePlayerViewController () <VLCMediaPlayerDelegate>
{
    VLCMediaPlayer *mediaPlayer;
    NSUInteger currentAudioTrack;
    BOOL muteAudio;
    NSTimer* fadeOutTimer;
    NSTimer* fadeOutPopView;
    NSTimer *videoPlayerTimer;
    MarqueeLabel *lengthyLabel;
    LiveStreaming *livestreaming;
    UIImage *profileImage;
}

@end

@implementation LivePlayerViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initActivityFeedback];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityLabel];
    [self shouldTopbarTransparent];
    
    [self setupTopView];
    
    _popView.layer.cornerRadius = 5.0f;
    _popView.hidden = YES;
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.topBarView addGestureRecognizer:doubleTapGesture];
    [self setupToolView];
    
    mediaPlayer = [[VLCMediaPlayer alloc] init];
    mediaPlayer.delegate = self;
    
    [mediaPlayer setDrawable: _playView];
    
//    [mediaPlayer setScaleFactor: _playView.bounds.size.width/_playView.bounds.size.height];

    
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerTimeChanged:) name:VLCMediaPlayerTimeChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerStateChanged:) name:VLCMediaPlayerStateChanged object:nil];
    
    UITapGestureRecognizer *TapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapGesture:)];
    [self.playView addGestureRecognizer:TapGesture];
}


- (void) viewDidAppear:(BOOL)animated{

    if (_liveStreamingID == nil || [_liveStreamingID isEqualToString:@""]) {
        [self unresponseVideo];
        return;
    }

    //connect to sever to get livestreaming object.
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    LiveStreaming * newLiveStreaming;
    
    newLiveStreaming = [[LiveStreaming alloc] initWithEntity:[NSEntityDescription entityForName:@"LiveStreaming" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
    
    
    [newLiveStreaming setIdLiveStreaming:_liveStreamingID];
    
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newLiveStreaming, nil];
    
    [self performRestGet:GET_LIVESTREAMING withParamaters:requestParameters];
    
 
    [super viewDidAppear:animated];

}

- (void)livePlay {
//    [mediaPlayer setMedia: [VLCMedia mediaWithURL: [NSURL URLWithString: @"rtmp://messaging.goldenspear.com/live/osama"]]];
    NSString *videoPath = livestreaming.path_video;
    
    if (videoPath == nil || [videoPath isEqualToString:@""]) return;
    
    [mediaPlayer setMedia: [VLCMedia mediaWithPath: videoPath]];
    muteAudio = NO;
    
    [mediaPlayer play];
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"", nil)];
    currentAudioTrack = mediaPlayer.currentAudioTrackIndex;
    
    _popView.hidden = NO;
    //    fadeOutPopView = [NSTimer scheduledTimerWithTimeInterval:3
    //                                                    target:self
    //                                                  selector:@selector(fadePopview)
    //                                                  userInfo:nil
    //                                                   repeats:NO];
    
    fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                    target:self
                                                  selector:@selector(fadeTools)
                                                  userInfo:nil
                                                   repeats:NO];
    
    videoPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:7
                                                        target:self
                                                      selector:@selector(unresponseVideo)
                                                      userInfo:nil
                                                       repeats:NO];
}

-(void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    [self stopActivityFeedback];

    videoPlayerTimer = nil;
    videoPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:7
                                                        target:self
                                                      selector:@selector(unresponseVideo)
                                                      userInfo:nil
                                                       repeats:NO];
    
    VLCMediaPlayer *player = [aNotification object];
    VLCTime *currentTime = player.time;
    
    _timerLbl.text = [NSString stringWithFormat:@"%@ min", currentTime];
    
    CGFloat moveX = _seekBar.bounds.size.width/MAX_TIME * currentTime.intValue / 1000;
    
    CGFloat tmp = _trackOffsetWidth.constant;
    
    if (tmp < _seekBar.bounds.size.width)
        _trackOffsetWidth.constant = tmp + moveX;
    else {
        _trackOffsetWidth.constant = 1.0f;
    }
}

- (void)showMarqueeLabel
{
    if (lengthyLabel != nil) {
        [lengthyLabel removeFromSuperview];
    }
    lengthyLabel = [[MarqueeLabel alloc] initWithFrame:_labelView.bounds duration:10.0 andFadeLength:5.0f];
    lengthyLabel.textColor = [UIColor whiteColor];
    lengthyLabel.text = NSLocalizedString(@"_LIVE_BROADCASTING_TITLE_", nil);
    lengthyLabel.marqueeType = MLContinuous;
    [_labelView addSubview:lengthyLabel];
    
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    VLCMediaPlayer *player = [aNotification object];
    
    VLCMediaPlayerState state = player.state;
    switch (state) {
        case VLCMediaPlayerStateOpening:
            NSLog(@"VLCMediaPlayerStateOpening");
            break;
        case VLCMediaPlayerStateBuffering:
            [self showMarqueeLabel];
            NSLog(@"VLCMediaPlayerStateBuffering");

            break;
        case VLCMediaPlayerStateEnded:
            NSLog(@"VLCMediaPlayerStateEnded");
            [self dismissMe];
            break;
        case VLCMediaPlayerStateError:
            [self stopActivityFeedback];
            [self dismissMe];

            NSLog(@"VLCMediaPlayerStateError");

            break;
        case VLCMediaPlayerStatePlaying:
            [self stopActivityFeedback];

            NSLog(@"VLCMediaPlayerStatePlaying");

            break;
        case VLCMediaPlayerStatePaused:
            NSLog(@"VLCMediaPlayerStatePaused");

            break;
        default:

            break;
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    
    if ([mediaPlayer isPlaying]) {
        [mediaPlayer stop];
        [mediaPlayer setDrawable: nil];
        mediaPlayer = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
    
}
- (void)setupToolView
{
    CGRect scrRect = [[UIScreen mainScreen]bounds];
    
    UIButton *btn;
    CGFloat space = (scrRect.size.width - 40 - 35 * 4)/3;
    CGFloat x = 20;
    CGFloat height = 47;//_toolView.frame.size.height;
    btn = [self buildButton:CGRectMake(x, (height - 35)/2, 40, 35)
               normalImgStr:@"live_share.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(liveShareAction:)
                 parentView:_toolBtnView];
    
    x += 40 + space;
    btn = [self buildButton:CGRectMake(x, (height - 35)/2, 35, 35)
               normalImgStr:@"live_comment.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(liveCommentAction:)
                 parentView:_toolBtnView];
    
    x += 35 + space;
    btn = [self buildButton:CGRectMake(x, (height - 35)/2, 35, 35)
               normalImgStr:@"live_chat.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(liveChatAction:)
                 parentView:_toolBtnView];
    
    x += 35 + space;
    btn = [self buildButton:CGRectMake(x, (height - 35)/2, 30, 35)
               normalImgStr:@"live_like.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(liveLikeAction:)
                 parentView:_toolBtnView];
}
- (void)liveShareAction:(UIButton*)sender
{
    //
    NSLog(@"liveShareAction");
}

- (void)liveLikeAction:(UIButton*)sender
{
    NSLog(@"liveCategoryAction");
}

- (void)liveCommentAction:(UIButton*)sender
{
    NSLog(@"liveCommentAction");
}
- (void)liveChatAction:(UIButton*)sender
{
    NSLog(@"liveChatAction");
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:normalImgStr] forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}

- (void)cancelFadeArrow{
    [fadeOutTimer invalidate];
    fadeOutTimer = nil;
}
- (void)fadePopview
{
    _popView.hidden = YES;
}

- (void)fadeTools{
    [self fadeTools:NO];
}
-(void)unresponseVideo {
    if (mediaPlayer != nil) {
        [mediaPlayer stop];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_ERROR_", nil)
                                                                             message:NSLocalizedString(@"_LIVE_STREAMING_FAILED_", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_OK_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissMe];
        
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showTools{
    self.topBarView.hidden = NO;
    self.scrollerView.hidden = NO;
    self.toolView.hidden = NO;
    
    fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                    target:self
                                                  selector:@selector(fadeTools)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)fadeTools:(BOOL)appear{
    if (!appear) {
        CGFloat alphaValue = 0.4;
        [UIView animateWithDuration:1
                             animations:^{
                                 self.topBarView.alpha = alphaValue;
                                 self.scrollerView.alpha = alphaValue;
                                 self.toolView.alpha = alphaValue;
                             }
                             completion:^(BOOL finished) {
                                 self.topBarView.alpha = 1.0f;
                                 self.scrollerView.alpha = 1.0f;
                                 self.toolView.alpha = 1.0f;

                                 self.topBarView.hidden = YES;
                                 self.scrollerView.hidden = YES;
                                 self.toolView.hidden = YES;

                             }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldCreateBottomButtons
{
    return YES;
}
- (BOOL)shouldTopbarTransparent{
    return YES;
}
- (BOOL)shouldCenterTitle{
    return NO;
}
- (BOOL)shouldCreateMenuButton
{
    return NO;
}

- (UIImage*) titleImage
{
    if (profileImage != nil) {
        return profileImage;
    }
    
    return [UIImage imageNamed:@"profile_image.png"];
}

- (void) setupTopView
{
    if (livestreaming != nil) {
        NSString *title = livestreaming.owner_username;
        NSString *subTitle = livestreaming.location;
        [self setTopBarTitle:title andSubtitle:subTitle];
        NSURL *imageURL = [NSURL URLWithString:livestreaming.owner_picture];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                profileImage = [UIImage imageWithData:imageData];
                [self titleImage];
            });
        });
        
    } else {
        NSString *title = @"PEOPLE";
        NSString *subTitle = @"Los Angeles, CA";
        [self setTopBarTitle:title andSubtitle:subTitle];
    }
}

- (BOOL)shouldCreateBackButton{
    return YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        [self showArrows];
    }
}
- (void)screenTapGesture:(UITapGestureRecognizer *)sender
{
    [self showTools];
}
// OVERRIDE: (Just to prevent from being at 'Zoomed Image View' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{

    [self dismissMe];
}

-(void) dismissMe {
    if (mediaPlayer != nil) {
        [mediaPlayer stop];
        [mediaPlayer setDrawable: nil];
        mediaPlayer = nil;
    }
    [self stopActivityFeedback];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    
    // NSLog(@"%s: controller.view.window=%@", _func_, controller.view.window);
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    __block LiveStreaming *liveStreamingObj;

    switch (connection)
    {
        case GET_LIVESTREAMING:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[LiveStreaming class]]))
                 {
                     liveStreamingObj = obj;
                     
                     // Stop enumeration
                     *stop = YES;
                 }
             }];
            
            
            NSLog([NSString stringWithFormat:@"LiveStreaming successfully uploaded! Retrieved Id: %@", liveStreamingObj.idLiveStreaming]);
            
            livestreaming = liveStreamingObj;
            [self setupTopView];
            [self livePlay];
            [self stopActivityFeedback];
            break;
        }
        
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

#pragma mark - Avoid user leave post creation unless cancelled or finished

- (void)leftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleLeftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)homeAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleRightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)rightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}
@end
