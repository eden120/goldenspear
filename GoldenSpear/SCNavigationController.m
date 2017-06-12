//
//  SCNavigationController.m
//  SnapInspectCamera
//
//  Created by Crane on 3/4/16.
//  Copyright © 2016 Osama Petran. All rights reserved.
//

#import "SCNavigationController.h"
#import "SCCaptureCameraController.h"

@interface SCNavigationController ()

@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;

@end

@implementation SCNavigationController {
    SCCaptureCameraController *conCam;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)dealloc {
    //status bar
    if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
        [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)prefersStatusBarHidden {
    return YES;
}
#pragma mark - pop
- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    BOOL shouldToDismiss = YES;
    if ([self.scNaigationDelegate respondsToSelector:@selector(willDismissNavigationController:)]) {
        shouldToDismiss = [self.scNaigationDelegate willDismissNavigationController:self];
    }
    if (shouldToDismiss) {
        [super dismissModalViewControllerAnimated:animated];
    }
}
- (void)reportPostImage {
    [conCam reportPostedImage];
}
#pragma mark - action(s)
- (void)showCameraWithParentController:(UIViewController*)parentController {
    conCam = [[SCCaptureCameraController alloc] init];
    [self setViewControllers:[NSArray arrayWithObjects:conCam, nil]];
    conCam.iParamID = self.iParamID;
    conCam.iInsID = self.iInsID;
    conCam.iInsItemID = self.iInsItemID;
    conCam.delegate = parentController;

    [parentController presentModalViewController:self animated:YES];
}

- (void)takeCamera:(UIImage*)image
{
    
}

#define CAN_ROTATE  0

#pragma mark -------------rotate---------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
#if CAN_ROTATE
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
#else
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
#endif
}


- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
#if CAN_ROTATE
    return YES;
#else
    return NO;
#endif
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}


@end
