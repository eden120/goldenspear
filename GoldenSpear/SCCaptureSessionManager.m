//
//  SCCaptureSessionManager.m
//  SnapInspectCamera
//
//  Created by Crane on 3/4/16.
//  Copyright © 2016 Osama Petran. All rights reserved.
//

#import "SCCaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+Resize.h"

@interface SCCaptureSessionManager ()


@property (nonatomic, strong) UIView *preview;

@end

@implementation SCCaptureSessionManager {
    BOOL is_front;
}


#pragma mark -
#pragma mark configure
- (id)init {
    self = [super init];
    if (self != nil) {
        _scaleNum = 1.f;
        _preScaleNum = 1.f;
    }
    return self;
}

- (void)dealloc {
    [_session stopRunning];
    self.previewLayer = nil;
    self.session = nil;
    self.stillImageOutput = nil;
}

- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect {
    
    self.preview = parent;
    
    [self createQueue];
    
    [self addSession];
    
    //previewLayer
    [self addVideoPreviewLayerWithRect:preivewRect];
    [parent.layer addSublayer:_previewLayer];
    
    //set back camera
    [self addVideoInputFrontCamera:NO];
    
    //output
    [self addStillImageOutput];
    
    //set flash mode
    [self addFlashMode:FLASH_MODE];
}

- (void)createQueue {
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
}

- (void)addSession {
    AVCaptureSession *tmpSession = [[AVCaptureSession alloc] init];
    self.session = tmpSession;
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
}

- (void)addVideoPreviewLayerWithRect:(CGRect)previewRect {
    
    AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewRect;
    self.previewLayer = preview;
}

- (void)addVideoInputFrontCamera:(BOOL)front {
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }  else {
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            if ([_session canAddInput:frontFacingCameraDeviceInput]) {
                [_session addInput:frontFacingCameraDeviceInput];
                self.inputDevice = frontFacingCameraDeviceInput;
                is_front = YES;
            } else {
                SCDLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([_session canAddInput:backFacingCameraDeviceInput]) {
                [_session addInput:backFacingCameraDeviceInput];
                self.inputDevice = backFacingCameraDeviceInput;
                is_front = NO;
            } else {
                SCDLog(@"Couldn't add back facing video input");
            }
        }
    }
}

- (void)addFlashMode:(NSInteger)mode {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        if (mode == 0) {
            device.flashMode = AVCaptureFlashModeAuto;
        } else if (mode == 1) {
            device.flashMode = AVCaptureFlashModeOn;
        } else if (mode == 2) {
            device.flashMode = AVCaptureFlashModeOff;
        }
        
    } else {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device does not have flash." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];*/
    }
    [device unlockForConfiguration];
}

- (void)addStillImageOutput {
    
    AVCaptureStillImageOutput *tmpOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    tmpOutput.outputSettings = outputSettings;
    
    //    AVCaptureConnection *videoConnection = [self findVideoConnection];
    
    [_session addOutput:tmpOutput];
    
    self.stillImageOutput = tmpOutput;
}


#pragma mark - actions
- (void)takePicture:(DidCapturePhotoBlock)block {
    AVCaptureConnection *videoConnection = [self findVideoConnection];
    
    if (videoConnection == nil) return;
    
    [videoConnection setVideoScaleAndCropFactor:_scaleNum];
    
    SCDLog(@"about to request a capture from: %@", _stillImageOutput);
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
         if (imageDataSampleBuffer == nil) return;

        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        if (imageData == nil) return;
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        SCDLog(@"OriginImage:%@", [NSValue valueWithCGSize:image.size]);
        
        CGFloat scalewidth = SC_PHOTO_SIZE;
        CGFloat scaleHeight = image.size.height/image.size.width * scalewidth;
        CGSize size = CGSizeMake(scalewidth, scaleHeight);
        
        UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:size interpolationQuality:kCGInterpolationHigh];
        SCDLog(@"scaledImage:%@", [NSValue valueWithCGSize:scaledImage.size]);

//        
        CGRect cropFrame = CGRectMake(0, CAMERA_TOPVIEW_HEIGHT, size.width, size.height - 50);
        SCDLog(@"cropFrame:%@", [NSValue valueWithCGRect:cropFrame]);
        UIImage *croppedImage = [scaledImage croppedImage:cropFrame];
        SCDLog(@"croppedImage:%@", [NSValue valueWithCGSize:croppedImage.size]);
//
        if (block) {
            block(scaledImage);
        } else if ([_delegate respondsToSelector:@selector(didCapturePhoto:)]) {
            [_delegate didCapturePhoto:scaledImage];
        }
    }];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}
- (void)stopSession
{
    [_session stopRunning];
    
}
- (void)switchCamera:(BOOL)isFrontCamera {
    if (!_inputDevice) {
        return;
    }
    [_session beginConfiguration];
    
    [_session removeInput:_inputDevice];
    
    [self addVideoInputFrontCamera:isFrontCamera];
    
    [_session commitConfiguration];
}

- (void)pinchCameraViewWithScalNum:(CGFloat)scale {
    _scaleNum = scale;
    if (_scaleNum < MIN_PINCH_SCALE_NUM) {
        _scaleNum = MIN_PINCH_SCALE_NUM;
    } else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
        _scaleNum = MAX_PINCH_SCALE_NUM;
    }
    [self doPinch];
    _preScaleNum = scale;
}

- (void)pinchCameraView:(UIPinchGestureRecognizer *)gesture {
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [gesture numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [gesture locationOfTouch:i inView:_preview];
        CGPoint convertedLocation = [_previewLayer convertPoint:location fromLayer:_previewLayer.superlayer];
        if ( ! [_previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        _scaleNum = _preScaleNum * gesture.scale;
        
        if (_scaleNum < MIN_PINCH_SCALE_NUM) {
            _scaleNum = MIN_PINCH_SCALE_NUM;
        } else if (_scaleNum > MAX_PINCH_SCALE_NUM) {
            _scaleNum = MAX_PINCH_SCALE_NUM;
        }
        
        [self doPinch];
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded ||
        [gesture state] == UIGestureRecognizerStateCancelled ||
        [gesture state] == UIGestureRecognizerStateFailed) {
        _preScaleNum = _scaleNum;
        SCDLog(@"final scale: %f", _scaleNum);
    }
}

- (void)doPinch {
    //    AVCaptureStillImageOutput* output = (AVCaptureStillImageOutput*)[_session.outputs objectAtIndex:0];
    //    AVCaptureConnection *videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
    
    AVCaptureConnection *videoConnection = [self findVideoConnection];
    
    CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
    
    if (_scaleNum > maxScale) {
        _scaleNum = maxScale;
    }
    
    //    videoConnection.videoScaleAndCropFactor = _scaleNum;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [_previewLayer setAffineTransform:CGAffineTransformMakeScale(_scaleNum, _scaleNum)];
    [CATransaction commit];
}

- (void)switchFlashMode:(UIButton*)sender {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (!captureDeviceClass) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device does not have camera." delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSString *imgStr = @"";
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeAuto;
            imgStr = @"flash-auto.png";
            
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeOff;
            imgStr = @"flash-off.png";
            
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOn;
            imgStr = @"flash.png";
            
        }
        
        if (sender) {
            [sender setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        }
        
    } else {
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device does not have camera." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];*/
    }
    [device unlockForConfiguration];
}

- (void)focusInPoint:(CGPoint)devicePoint {
    devicePoint = [self convertToPointOfInterestFromViewCoordinates:devicePoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    dispatch_async(_sessionQueue, ^{
        AVCaptureDevice *device = [_inputDevice device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            SCDLog(@"%@", error);
        }
    });
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _previewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.previewLayer;
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for(AVCaptureInputPort *port in [[self.session.inputs lastObject]ports]) {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}


#pragma mark ---------------private--------------
- (AVCaptureConnection*)findVideoConnection {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    return videoConnection;
}

@end
