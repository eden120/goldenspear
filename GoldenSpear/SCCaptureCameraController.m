//
//  SCCaptureCameraController.m
//  SnapInspectCamera
//
//  Created by Crane on 3/4/16.
//  Copyright © 2016 Osama Petran. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "GSTaggingViewController.h"
#import "LiveStreamViewController.h"
#import "SCCaptureCameraController.h"
#import "CoreMotion/CoreMotion.h"
#import "LivePlayerViewController.h"
#import "GSTaggingViewController.h"

#import "SCSlider.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"

#define SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE      0
#define SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA   1

//height
#define THUMBNAIL_VIEW_HEIGHT   80  //thumbnail

//focus
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   0.7f
#define HIGH_ALPHA  1.0f
#define kScreenPortionForActivityIndicatorVerticalCenter 0.35
#define kActivityLabelBackgroundColor grayColor
#define kActivityLabelAlpha 0.1
#define kFontInActivityLabel "Avenir-Light"
#define kFontSizeInActivityLabel 16

@interface SCCaptureCameraController () <UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    int alphaTimes;
    CGPoint currTouchPoint;
    BOOL showTaggingView;
    UIImage *takeImage;
}

@property (nonatomic, strong) SCCaptureSessionManager *captureManager;

@property (nonatomic, strong) UIView *topContainerView;
@property (nonatomic, strong) UILabel *topLbl;

@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) UIView *cameraMenuView;
@property (nonatomic, strong) NSMutableSet *cameraBtnSet;

@property (nonatomic, strong) UIView *doneCameraUpView;
@property (nonatomic, strong) UIView *doneCameraDownView;

@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic, strong) SCSlider *scSlider;
@end

@implementation SCCaptureCameraController {

    BOOL doubleTouch;
    UILabel* modeLab;
}

@synthesize iParamID, iInsID, iInsItemID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alphaTimes = -1;
        currTouchPoint = CGPointZero;
        
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //navigation bar
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = YES;
    }    
    
    //set orientation
     [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    
    //status bar
    _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    //notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:kNotificationOrientationChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(FailedProductTagReceiver:)
                                                     name:@"finishNotification"
                                                   object:nil];

    //session manager
    SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
    
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, SC_APP_SIZE.width, SC_APP_SIZE.height);
    }
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    self.captureManager = manager;
    
    [self addTopViewWithText];
    [self addbottomContainerView];
    [self addCameraMenuView];
    [self addFocusView];
    [self addPinchGesture];
    
//    [_captureManager.session startRunning];
    
    CMMotionManager *cmManager = [[CMMotionManager alloc] init];
    if ([cmManager isDeviceMotionAvailable]) {
        cmManager.deviceMotionUpdateInterval = 0.2;
        [cmManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:
         ^(CMDeviceMotion *motion, NSError *error) {
             [self outputAccelertionData:motion.userAcceleration];
        }];
    }
    
    [self initActivityFeedback];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityLabel];
    [self hideTopBar];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.taggingCameraImage = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [_captureManager.session startRunning];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    if (acceleration.z > 0.5 ||
        acceleration.z < - 0.5) {
        CGPoint centerPoint = CGPointMake(SC_APP_SIZE.width/2, SC_APP_SIZE.width/2 + CAMERA_TOPVIEW_HEIGHT);
        [_captureManager focusInPoint:centerPoint];
        [_focusImageView setCenter:centerPoint];
        _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
        
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
        [UIView animateWithDuration:0.1f animations:^{
            _focusImageView.alpha = HIGH_ALPHA;
            _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [self showFocusInPoint:centerPoint];
        }];
#else
        [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 1.f;
            _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                _focusImageView.alpha = 0.f;
            } completion:nil];
        }];
#endif
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    if (!self.navigationController) {
        if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device removeObserver:self forKeyPath:ADJUSTINT_FOCUS context:nil];
    }
#endif
    
    self.captureManager = nil;
}

#pragma mark -------------UI---------------
- (void)addTopViewWithText
{
    if (!_topContainerView) {
        CGRect topFrame = CGRectMake(0, 0, SC_APP_SIZE.width, CAMERA_TOPVIEW_HEIGHT);
        
        UIView *tView = [[UIView alloc] initWithFrame:topFrame];
        tView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        [self.view addSubview:tView];
        self.topContainerView = tView;
        
        //Camera Post
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((topFrame.size.width - 150) / 2, (topFrame.size.height - 30) / 2, 150, 30)];
        NSString *title = NSLocalizedString(@"_POST_LOOK_", nil);
        titleLab.textColor = [UIColor whiteColor];
        [titleLab setFont:[UIFont fontWithName:@"Helvetica" size:20]];
        titleLab.text = title;
        titleLab.textAlignment = NSTextAlignmentCenter;
        [tView addSubview:titleLab];
        
        //Mode
//        modeLab = [[UILabel alloc] initWithFrame:CGRectMake((topFrame.size.width - 120) / 2, 28 , 120, 28)];
//        modeLab.textAlignment = NSTextAlignmentCenter;
//        modeLab.textColor = [UIColor whiteColor];
//        [modeLab setFont:[UIFont fontWithName:@"Helvetica" size:12]];
//        [tView addSubview:modeLab];
//        
//        [self setModeText:YES];
        
        UIButton *cancelBtn = [self buildButton:CGRectMake(20, (topFrame.size.height - 25)/2, 25, 25)
                                 normalImgStr:@"closeWhite.png"
                              highlightImgStr:@""
                               selectedImgStr:@""
                                       action:@selector(dismissBtnPressed:)
                                   parentView:_topContainerView];
    }
}

- (void)setModeText:(BOOL)flag
{
    NSString *mode = flag ? NSLocalizedString(@"_CAMEARA_MODE_", nil) : NSLocalizedString(@"_VIDEO_MODE_", nil);
    modeLab.text = mode;
    modeLab.textAlignment = NSTextAlignmentCenter;
}

- (void)addbottomContainerView {
    CGRect bottomFrame = CGRectMake(0, SC_APP_SIZE.height- 160, SC_APP_SIZE.width, 160);
    
    UIView *view = [[UIView alloc] initWithFrame:bottomFrame];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self.view addSubview:view];
    self.bottomContainerView = view;
}

- (void)addCameraMenuView {
    CGFloat cameraBtnLength = THUMBNAIL_VIEW_HEIGHT;
    //flashBtn
    NSString *flash_mode = @"";
    if (FLASH_MODE == 0)
        flash_mode = @"flash-auto.png";
    else if (FLASH_MODE == 1)
        flash_mode = @"flash.png";
    else
        flash_mode = @"flash-off.png";
    
    UIButton *btn;

    
    //Add Shutter button
    CGFloat x, y, topSpace;
    x = (SC_APP_SIZE.width - cameraBtnLength) / 2;
    y = topSpace = 10;
    UIButton *shutBtn = [self buildButton:CGRectMake(x, y , cameraBtnLength, cameraBtnLength)
                             normalImgStr:@"recordBtn.png"
                          highlightImgStr:@""
                           selectedImgStr:@""
                                   action:@selector(takePictureBtnPressed:)
                               parentView:_bottomContainerView];
    [_cameraBtnSet addObject:shutBtn];
    //FlashBtn
    y = y + (cameraBtnLength - 30)/2;

    btn= [self buildButton:CGRectMake(40,  y , 30, 30)
              normalImgStr:flash_mode
           highlightImgStr:@""
            selectedImgStr:@""
                    action:@selector(flashBtnPressed:)
                parentView:_bottomContainerView];
    //SwitchBtn
    btn = [self buildButton:CGRectMake(SC_APP_SIZE.width - 75, y, 35, 30)
               normalImgStr:@"flipCamera.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(switchCameraBtnPressed:)
                 parentView:_bottomContainerView];
    
//Upload Btn
    CGFloat space = (_bottomContainerView.frame.size.width - 80) / 3;
    y = topSpace + cameraBtnLength + 10;
    btn = [self buildButton:CGRectMake(30, y, 40, 30)
               normalImgStr:@"uploadWhiteVideo.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(uploadVideo:)
                 parentView:_bottomContainerView];
//Video Btn
    btn = [self buildButton:CGRectMake(30 + space, y+1, 40, 35)
               normalImgStr:@"video.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(swichMode:)
                 parentView:_bottomContainerView];
//spearthePic Btn
    btn = [self buildButton:CGRectMake(30 + space * 2, y+5, 25, 25)
               normalImgStr:@"spearthePic.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(spearthePicPressed:)
                 parentView:_bottomContainerView];
//liveStream Btn
    btn = [self buildButton:CGRectMake(20 + space * 3, y+2, 30, 30)
               normalImgStr:@"liveStream.png"
            highlightImgStr:@""
             selectedImgStr:@""
                     action:@selector(liveStreaming:)
                 parentView:_bottomContainerView];
    

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

- (void)addFocusView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus-crosshair.png"]];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device addObserver:self forKeyPath:ADJUSTINT_FOCUS options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
}

#pragma mark -------------touch to focus---------------
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];

        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}

- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    alphaTimes = -1;

    UITouch *touch = [touches anyObject];
    currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_captureManager.previewLayer.bounds, currTouchPoint) == NO) {
        return;
    }
    
    if (currTouchPoint.y < CAMERA_TOPVIEW_HEIGHT) return;
    if (currTouchPoint.y > SC_APP_SIZE.height / 3 * 2) return;
    if (doubleTouch) return;
    
    [_captureManager focusInPoint:currTouchPoint];
    
    [_focusImageView setCenter:currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    [UIView animateWithDuration:0.1f animations:^{
        _focusImageView.alpha = HIGH_ALPHA;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self showFocusInPoint:currTouchPoint];
    }];
#else
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
#endif
}

#pragma mark -------------button actions---------------
- (void)takePictureBtnPressed:(UIButton*)sender {
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert;
        alert =[[UIAlertView alloc]initWithTitle:@"Error!" message:@"Device does not support the camera." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
#endif
    
    sender.userInteractionEnabled = NO;
    
//    WEAKSELF_SC
    [_captureManager takePicture:^(UIImage *stillImage) {
        [_captureManager stopSession];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.taggingCameraImage = stillImage;
        
        sender.userInteractionEnabled = YES;
        showTaggingView = [self taggingViewController];
    }];
}

//- (void)reportPostedImage {
//    [self stopActivityFeedback];
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void) FailedProductTagReceiver:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"finishNotification"]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


- (void)saveImageToPhotoAlbum:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to save" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        SCDLog(@"Save successfully");
    }
}

#ifndef ORIG_CAMERA_PART
-(UIImage *)addText:(UIImage *)img text:(NSString *)text1{
    
    int w = img.size.width;
    int h = img.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    char* text= (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
    CGContextSelectFont(context, "Arial",30, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 255, 0, 0, 1);
    CGContextShowTextAtPoint(context,10,10,text, strlen(text));
    CGImageRef imgCombined = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *retImage = [UIImage imageWithCGImage:imgCombined];
    CGImageRelease(imgCombined);
    
    return retImage;
}

- (UIImage *) processImage_Thumb:(UIImage *)image { //process captured image, crop, resize and rotate
    
    UIImage *smallImage = [self imageWithImage:image scaledToWidth:80.0f]; //UIGraphicsGetImageFromCurrentImageContext();
    
    CGRect cropRect = CGRectMake(0, 0, 80,80 );
    CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
    
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    
    CGImageRelease(imageRef);
    return croppedImage;
}

- (UIImage*)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#endif

- (void)tmpBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissBtnPressed:(id)sender {
//    if ([self.delegate respondsToSelector:@selector(dismissParentViewController)])
//    {
        [self dismissViewControllerAnimated:YES completion:nil];
//        [self.delegate dismissParentViewController];
//    }
}

- (void)switchCameraBtnPressed:(UIButton*)sender {
    sender.selected = !sender.selected;
    [_captureManager switchCamera:sender.selected];
}

- (void)flashBtnPressed:(UIButton*)sender {
    [_captureManager switchFlashMode:sender];
}

- (void)uploadVideo:(UIButton*)sender {
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc]init];
    // Check if image access is authorized
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // Use delegate methods to get result of photo library -- Look up UIImagePicker delegate methods
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:true completion:nil];
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image != nil) {
        [_captureManager stopSession];
        [picker dismissViewControllerAnimated:YES completion:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.taggingCameraImage = image;
//        dispatch_async(dispatch_get_main_queue(), ^{
        showTaggingView = [self taggingViewController];
    }
}
- (void)swichMode:(UIButton*)sender {
    NSString* destinationStoryboard = @"FashionistaContents";
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:destinationStoryboard bundle:nil];
    
    if (nextStoryboard != nil)
    {
        LivePlayerViewController *vc = [nextStoryboard instantiateViewControllerWithIdentifier:[@(LIVEPLAYER_VC) stringValue]];
        CATransition* transition = [CATransition animation];
        transition.duration = 0.2;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        [self presentViewController:vc animated:NO completion:nil];
    }
}
- (void)spearthePicPressed:(UIButton*)sender {
    
}
- (void)liveStreaming:(UIButton*)sender {
    NSString* destinationStoryboard = @"FashionistaContents";
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:destinationStoryboard bundle:nil];
    
    if (nextStoryboard != nil)
    {
        [_captureManager stopSession];
        LiveStreamViewController *vc = [nextStoryboard instantiateViewControllerWithIdentifier:[@(BROADCAST_VC) stringValue]];
        CATransition* transition = [CATransition animation];
        transition.duration = 0.2;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        [self presentViewController:vc animated:NO completion:nil];
//        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//        [self.navigationController pushViewController:vc animated:NO];
    }
}
//#pragma mark -------------save image to local---------------
//- (void)saveImageToPhotoAlbum:(UIImage*)image {
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//}
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    if (error != NULL) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Can not save" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [alert show];
//    } else {
//    }
//}

- (void)addPinchGesture {

        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self.view addGestureRecognizer:pinch];
        
        //    CGFloat width = _previewRect.size.width - 100;
        //    CGFloat height = 40;
        //    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake((SC_APP_SIZE.width - width) / 2, SC_APP_SIZE.width + CAMERA_MENU_VIEW_HEIGH - height, width, height)];

        CGFloat width = 40;
        CGFloat height = _previewRect.size.height - 100;
//        SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(20, bottomY - height, width, height) direction:SCSliderDirectionVertical];
        SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(_previewRect.size.width - width, CAMERA_TOPVIEW_HEIGHT + 20, width, height) direction:SCSliderDirectionVertical];
        slider.alpha = 0.f;
        slider.minValue = MIN_PINCH_SCALE_NUM;
        slider.maxValue = MAX_PINCH_SCALE_NUM;
        
        WEAKSELF_SC
        [slider buildDidChangeValueBlock:^(CGFloat value) {
            [weakSelf_SC.captureManager pinchCameraViewWithScalNum:value];
        }];
        [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
            [weakSelf_SC setSliderAlpha:isTouchEnd];
        }];
        
//        [self.view addSubview:slider];
    
        self.scSlider = slider;
}

void c_slideAlpha() {
    
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}

#pragma mark ------------notification-------------
- (void)orientationDidChange:(NSNotification*)noti {
 //rotate all buttons on camera view
    if (!_cameraBtnSet || _cameraBtnSet.count <= 0) {
        return;
    }
    [_cameraBtnSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *btn = ([obj isKindOfClass:[UIButton class]] ? (UIButton*)obj : nil);
        if (!btn) {
            *stop = YES;
            return ;
        }
        
        btn.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait://1
            {
                transform = CGAffineTransformMakeRotation(0);
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown://2
            {
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
            }
            case UIDeviceOrientationLandscapeLeft://3
            {
                transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            }
            case UIDeviceOrientationLandscapeRight://4
            {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
            }
            default:
                break;
        }
        [UIView animateWithDuration:0.3f animations:^{
            btn.transform = transform;
        }];
    }];
}

#pragma mark -------------pinch camera---------------
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    
    [_captureManager pinchCameraView:gesture];
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        [_scSlider setValue:_captureManager.scaleNum shouldCallBack:NO];
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            doubleTouch = NO;
            [self setSliderAlpha:YES];
        } else {
            doubleTouch = YES;
            [self setSliderAlpha:NO];
        }
    }
}

#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
//<iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//iOS6+
- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    //    return [UIApplication sharedApplication].statusBarOrientation;
	return UIInterfaceOrientationPortrait;
}
#endif

@end
