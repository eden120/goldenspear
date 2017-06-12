//
//  CaptureManager.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 03/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface CaptureManager : NSObject

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;

- (void)addVideoPreviewLayer;
- (BOOL)addVideoInput;

@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;

- (void)addStillImageOutput;
- (void)captureStillImage;

@end