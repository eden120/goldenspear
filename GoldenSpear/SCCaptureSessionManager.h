//
//  SCCaptureSessionManager.h
//  SnapInspectCamera
//
//  Created by Crane on 3/4/16.
//  Copyright © 2016 Osama Petran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SCDefines.h"
#import <UIKit/UIKit.h>
#define MAX_PINCH_SCALE_NUM   3.f
#define MIN_PINCH_SCALE_NUM   1.f

@protocol SCCaptureSessionManager;

typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);

@interface SCCaptureSessionManager : NSObject


@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;


@property (nonatomic, assign) id <SCCaptureSessionManager> delegate;



- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect;

- (void)takePicture:(DidCapturePhotoBlock)block;
- (void)switchCamera:(BOOL)isFrontCamera;
- (void)pinchCameraViewWithScalNum:(CGFloat)scale;
- (void)pinchCameraView:(UIPinchGestureRecognizer*)gesture;
- (void)switchFlashMode:(UIButton*)sender;
- (void)focusInPoint:(CGPoint)devicePoint;
- (void)stopSession;
@end


@protocol SCCaptureSessionManager <NSObject>

@optional
- (void)didCapturePhoto:(UIImage*)stillImage;

@end
