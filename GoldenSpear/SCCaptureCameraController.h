//
//  SCCaptureCameraController.h
//  SnapInspectCamera
//
//  Created by Crane on 3/4/16.
//  Copyright © 2016 Osama Petran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCCaptureSessionManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BaseViewController.h"

@interface SCCaptureCameraController : BaseViewController

@property (nonatomic, assign) id delegate;

@property int iParamID;
@property int iInsItemID;
@property int iInsID;
@property (nonatomic, assign) CGRect previewRect;
@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;
@property (strong, atomic) ALAssetsLibrary* library;
@property UILabel *activityLabel;
@property UIActivityIndicatorView *activityIndicator;
- (void)reportPostedImage;
@end

@protocol SCCaptureCameraControllerDelegate
- (void)PostProcessPhotoID:(int)iPhotoID iInsItemID:(int)iInsItemID iParamID:(int)iParamID;
- (void)didTakePicture:(UIImage*)image;
- (void)dismissParentViewController;
@end


