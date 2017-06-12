//
//  CustomCameraViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 12/08/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
//  BASED ON CustomCameraViewController: https://github.com/gobackspaces/CustomCameraViewController
//


#import "CustomCameraViewController.h"
#import "GrayscaleContrastFilter.h"

#define kStaticBlurSize 3.0f

static CGFloat const DEFAULT_MASK_ALPHA = 0.75;
static bool const square = NO;
float IMAGE_MIN_HEIGHT = 400;
float IMAGE_MIN_WIDTH = 400;

@implementation CustomCameraViewController
{
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageOutput<GPUImageInput> *blurFilter;
    GPUImageCropFilter *cropFilter;
    GPUImagePicture *staticPicture;
    UIImageOrientation staticPictureOriginalOrientation;
    BOOL isStatic;
    BOOL isRecording;
    BOOL hasBlur;
    int selectedFilter;
    dispatch_once_t showLibraryOnceToken;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isDirty = NO;
//    self.wantsFullScreenLayout = YES;

    _outputJPEGQuality = 1.0;
    _requestedImageSize = CGSizeZero;

    //Set background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:
                                 [UIImage imageNamed:@"micro_carbon"]];
    
    self.photoBar.backgroundColor = [UIColor colorWithPatternImage:
                                     [UIImage imageNamed:@"photo_bar"]];
    
    self.topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo_bar"]];
    
    [self.imageView setBlurred:YES];
    [self.imageView setAllowResizing:YES];
    [self.imageView setInitialClearAreaSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];

    
    //Button states
    [self.blurToggleButton setSelected:NO];
    [self.filtersToggleButton setSelected:NO];
    
    staticPictureOriginalOrientation = UIImageOrientationUp;
    
    self.focusView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus-crosshair"]];
    [self.view addSubview:self.focusView];
    self.focusView.alpha = 0;
    
    self.blurOverlayView = [[BlurOverlayView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                self.imageView.frame.size.width,
                                                                                self.imageView.frame.size.height)];
    
    self.blurOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurOverlayView.alpha = 0;
    [self.imageView addSubview:self.blurOverlayView];
    
    [self.imageView initViews];
    hasBlur = NO;
    
    [self loadFilters];
    
    //we need a crop filter for the live video
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)];
    
    filter = [[GPUImageFilter alloc] init];
    
    
    
    
    
    
    
    
    
    
    
//    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetMedium cameraPosition:AVCaptureDevicePositionBack];
//    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
//    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
//    
//    
//    [_videoCamera addTarget:cropFilter];
//    GPUImageView *filterView = (GPUImageView *)self.imageView;
//    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
//    _movieWriter.encodingLiveVideo = YES;
//    [filter addTarget:_movieWriter];
//    [filter addTarget:filterView];
//    
//    [_videoCamera startCameraCapture];
//    
    
    
    
    

    
    
    
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self setUpCamera];
    });
    
    if(!(self.editingImage == nil))
    {
        if (!isStatic)
        {
            // shut down camera
            [stillCamera stopCameraCapture];
            [self removeAllTargets];
            
            isStatic = YES;
        }
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [super viewWillAppear:animated];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!(self.editingImage == nil))
    {
        if (!isStatic)
        {
            // shut down camera
            [stillCamera stopCameraCapture];
            [self removeAllTargets];

            isStatic = YES;
        }
        
        [self.imageView initViews];
        
        [self prepareForEditImage:self.editingImage];
        
        staticPicture = [[GPUImagePicture alloc] initWithImage:self.editingImage smoothlyScaleOutput:YES];
        staticPictureOriginalOrientation = self.editingImage.imageOrientation;
        [self.cameraToggleButton setEnabled:NO];
        [self.flashToggleButton setEnabled:NO];
        [self.blurToggleButton setEnabled:NO];
        [self prepareStaticFilter];
        [self.retakeButton setHidden:NO];
        [self.photoCaptureButton setHidden:NO];
        [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
        [self.photoCaptureButton setEnabled:YES];
        
        if(![self.filtersToggleButton isSelected])
        {
            [self showFilters];
        }
    }
    else if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        dispatch_once(&showLibraryOnceToken, ^{
            [self switchToLibrary:nil];
        });
    }
}

-(void) loadFilters
{
    for(int i = 0; i < 10; i++)
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i + 1]] forState:UIControlStateNormal];
        button.frame = CGRectMake(10+i*(60+10), 5.0f, 60.0f, 60.0f);
        button.layer.cornerRadius = 7.0f;
        
        //use bezier path instead of maskToBounds on button.layer
        UIBezierPath *bi = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                                 byRoundingCorners:UIRectCornerAllCorners
                                                       cornerRadii:CGSizeMake(7.0,7.0)];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = button.bounds;
        maskLayer.path = bi.CGPath;
        button.layer.mask = maskLayer;
        
        button.layer.borderWidth = 1;
        button.layer.borderColor = [[UIColor blackColor] CGColor];
        
        [button addTarget:self
                   action:@selector(filterClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [button setTitle:@"✔︎" forState:UIControlStateSelected];
        
        if(i == 0)
        {
            [button setSelected:YES];
        }
        
        [self.filterScrollView addSubview:button];
    }
    
    [self.filterScrollView setContentSize:CGSizeMake(10 + 10*(60+10), 75.0)];
}


-(void) setUpCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        // Has camera
        
        stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:/*AVCaptureSessionPreset1280x720*/AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        
        stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        runOnMainQueueWithoutDeadlocking(^{
            [stillCamera startCameraCapture];
            if([stillCamera.inputCamera hasTorch]){
                [self.flashToggleButton setEnabled:YES];
            }else{
                [self.flashToggleButton setEnabled:NO];
            }
            [self prepareFilter];
        });
    }
    else
    {
        runOnMainQueueWithoutDeadlocking(^{
            // No camera awailable, hide camera related buttons and show the image picker
            self.cameraToggleButton.hidden = YES;
            self.photoCaptureButton.hidden = YES;
            self.flashToggleButton.hidden = YES;
            // Show the library picker
            //            [self switchToLibrary:nil];
            //            [self performSelector:@selector(switchToLibrary:) withObject:nil afterDelay:0.5];
            [self prepareFilter];
        });
    }
}

-(void) filterClicked:(UIButton *) sender
{
    // a filter has been applied, so the image has been modified
    self.isDirty = YES;
    
    for(UIView *view in self.filterScrollView.subviews)
    {
        if([view isKindOfClass:[UIButton class]])
        {
            [(UIButton *)view setSelected:NO];
        }
    }
    
    [sender setSelected:YES];
    [self removeAllTargets];
    
    selectedFilter = (int)sender.tag;
    
    [self setFilter:(int)sender.tag];
     
    [self prepareFilter];
}

-(void) setFilter:(int) index
{
    switch (index)
    {
        case 1:
        {
            filter = [[GPUImageContrastFilter alloc] init];
            [(GPUImageContrastFilter *) filter setContrast:1.75];

            break;
        }
        case 2:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"crossprocess"];
            
            break;
        }
        case 3:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"02"];
            
            break;
        }
        case 4:
        {
            filter = [[GrayscaleContrastFilter alloc] init];
            
            break;
        }
        case 5:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"17"];

            break;
        }
        case 6:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"aqua"];
            
            break;
        }
        case 7:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"yellow-red"];
            
            break;
        }
        case 8:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"06"];
            
            break;
        }
        case 9:
        {
            filter = [[GPUImageToneCurveFilter alloc] initWithACV:@"purple-green"];
            
             break;
        }
        default:
            
            filter = [[GPUImageFilter alloc] init];
            break;
    }
}

-(void) prepareFilter
{
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        isStatic = YES;
    }
    
    if (!isStatic)
    {
        [self prepareLiveFilter];
    }
    else
    {
        [self prepareStaticFilter];
    }
}

-(void) prepareLiveFilter
{
    [stillCamera addTarget:cropFilter];
    [cropFilter addTarget:filter];
    
    //blur is terminal filter
    if (hasBlur)
    {
        [filter addTarget:blurFilter];
        [blurFilter addTarget:self.imageView];
        //regular filter is terminal
    }
    else
    {
        [filter addTarget:self.imageView];
    }
    
    //[filter prepareForImageCapture];
    [filter useNextFrameForImageCapture];
    [filter imageFromCurrentFramebufferWithOrientation:staticPictureOriginalOrientation];
}

-(void) prepareStaticFilter
{
    
    [staticPicture addTarget:filter];
    
    // blur is terminal filter
    if (hasBlur)
    {
        [filter addTarget:blurFilter];
        [blurFilter addTarget:self.imageView];
        //regular filter is terminal
    }
    else
    {
        [filter addTarget:self.imageView];
    }
    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    
    switch (staticPictureOriginalOrientation)
    {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
            
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
            
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
            
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    
    // seems like atIndex is ignored by GPUImageView...
    [self.imageView setInputRotation:imageViewRotationMode atIndex:0];
    
    [staticPicture useNextFrameForImageCapture];
    
    [staticPicture processImage];
}

-(void) removeAllTargets
{
    [stillCamera removeAllTargets];
    [staticPicture removeAllTargets];
    [cropFilter removeAllTargets];
    
    //regular filter
    [filter removeAllTargets];
    
    //blur
    [blurFilter removeAllTargets];
}

-(IBAction)switchToLibrary:(id)sender
{
    if (!isStatic)
    {
        // shut down camera
        [stillCamera stopCameraCapture];
        [self removeAllTargets];
    }
    
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

-(IBAction)toggleFlash:(UIButton *)button
{
    [button setSelected:!button.selected];
}

-(IBAction) toggleBlur:(UIButton*)blurButton
{
    
    [self.blurToggleButton setEnabled:NO];
    [self removeAllTargets];
    
    if (hasBlur)
    {
        hasBlur = NO;
        [self showBlurOverlay:NO];
        [self.blurToggleButton setSelected:NO];
    }
    else
    {
        if (!blurFilter)
        {
            blurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setExcludeCircleRadius:80.0/320.0];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setExcludeCirclePoint:CGPointMake(0.5f, 0.5f)];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setBlurRadiusInPixels:kStaticBlurSize];
            [(GPUImageGaussianSelectiveBlurFilter*)blurFilter setAspectRatio:1.0f];
        }
        
        hasBlur = YES;
        CGPoint excludePoint = [(GPUImageGaussianSelectiveBlurFilter*)blurFilter excludeCirclePoint];
        CGSize frameSize = self.blurOverlayView.frame.size;
        self.blurOverlayView.circleCenter = CGPointMake(excludePoint.x * frameSize.width, excludePoint.y * frameSize.height);
        [self.blurToggleButton setSelected:YES];
        [self flashBlurOverlay];
    }
    
    [self prepareFilter];
    [self.blurToggleButton setEnabled:YES];
}

-(IBAction) switchCamera
{
    
    [self.cameraToggleButton setEnabled:NO];
    [stillCamera rotateCamera];
    [self.cameraToggleButton setEnabled:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && stillCamera)
    {
        if ([stillCamera.inputCamera hasFlash] && [stillCamera.inputCamera hasTorch])
        {
            [self.flashToggleButton setEnabled:YES];
        }
        else
        {
            [self.flashToggleButton setEnabled:NO];
        }
    }
}


-(void) prepareForEditImage:(UIImage *)image
{
    isStatic = YES;
    
    [self.libraryToggleButton setHidden:YES];
    [self.cameraToggleButton setEnabled:NO];
    [self.flashToggleButton setEnabled:NO];
    [self.blurToggleButton setEnabled:NO];

    [stillCamera.inputCamera unlockForConfiguration];
    [stillCamera stopCameraCapture];
    [self removeAllTargets];
    
    [self.imageView.topRightPoint setHidden:NO];
    [self.imageView.bottomRightPoint setHidden:NO];
    [self.imageView.topLeftPoint setHidden:NO];
    [self.imageView.bottomLeftPoint setHidden:NO];
    
    image = [image fixOrientation];
    
    [self.imageView InitAndSetImage:image];

    
    staticPicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:NO];
    
    staticPictureOriginalOrientation = image.imageOrientation;
    
    [self prepareFilter];
    [self.retakeButton setHidden:NO];
    [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
    [self.photoCaptureButton setEnabled:YES];
    
    if(![self.filtersToggleButton isSelected])
    {
        [self showFilters];
    }
}

-(void) prepareForCapture
{
    [stillCamera.inputCamera lockForConfiguration:nil];
    
    if(self.flashToggleButton.selected && [stillCamera.inputCamera hasTorch])
    {
        [stillCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
        [self performSelector:@selector(captureImage)
                   withObject:nil
                   afterDelay:0.25];
    }
    else
    {
        [self captureImage];
    }
}


-(void)captureImage
{
    self.isDirty = YES;

    void (^completion)(UIImage *, NSError *) = ^(UIImage *img, NSError *error) {
        
        [stillCamera.inputCamera unlockForConfiguration];
        [stillCamera stopCameraCapture];
        [self removeAllTargets];

        [self.imageView initViews];

        [self prepareForEditImage:img];
        
        staticPicture = [[GPUImagePicture alloc] initWithImage:img smoothlyScaleOutput:NO];

        staticPictureOriginalOrientation = img.imageOrientation;
        
        [self prepareFilter];
        [self.retakeButton setHidden:NO];
        [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
        [self.photoCaptureButton setEnabled:YES];
        
        if(![self.filtersToggleButton isSelected])
        {
            [self showFilters];
        }
    };
    
    
    AVCaptureDevicePosition currentCameraPosition = stillCamera.inputCamera.position;
    Class contextClass = NSClassFromString(@"GPUImageContext") ?: NSClassFromString(@"GPUImageOpenGLESContext");
    
    if ((currentCameraPosition != AVCaptureDevicePositionFront) || (![contextClass supportsFastTextureUpload]))
    {
        // Image full-resolution capture is currently possible just on the final (destination filter), so
        // create a new paralel chain, that crops and resizes our image
        [self removeAllTargets];
        
        GPUImageCropFilter *captureCrop = [[GPUImageCropFilter alloc] initWithCropRegion:cropFilter.cropRegion];
        [stillCamera addTarget:captureCrop];
        GPUImageFilter *finalFilter = captureCrop;
        
        if (!CGSizeEqualToSize(_requestedImageSize, CGSizeZero))
        {
            GPUImageFilter *captureResize = [[GPUImageFilter alloc] init];
            [captureResize forceProcessingAtSize:_requestedImageSize];
            [captureCrop addTarget:captureResize];
            finalFilter = captureResize;
        }
        
        //[finalFilter prepareForImageCapture];
        [finalFilter useNextFrameForImageCapture];
        [finalFilter imageFromCurrentFramebufferWithOrientation:staticPictureOriginalOrientation];
        
        [stillCamera capturePhotoAsImageProcessedUpToFilter:finalFilter withCompletionHandler:completion];
    }
    else
    {
        // A workaround inside capturePhotoProcessedUpToFilter:withImageOnGPUHandler: would cause the above method to fail,
        // so we just grap the current crop filter output as an aproximation (the size won't match trough)

        //UIImage *img = [cropFilter imageFromCurrentlyProcessedOutput];
        [cropFilter useNextFrameForImageCapture];
        UIImage* img = [cropFilter imageFromCurrentFramebuffer];
        
        completion(img, nil);
    }
}

-(IBAction) takePhoto:(id)sender
{
    [self.photoCaptureButton setEnabled:NO];
    
    if (!isStatic)
    {
        isStatic = YES;
        
        [self.libraryToggleButton setHidden:YES];
        [self.cameraToggleButton setEnabled:NO];
        [self.flashToggleButton setEnabled:NO];
        [self.blurToggleButton setEnabled:NO];
        [self prepareForCapture];
    }
    else
    {
        GPUImageOutput<GPUImageInput> *processUpTo;
        
        if (hasBlur)
        {
            processUpTo = blurFilter;
        }
        else
        {
            processUpTo = filter;
        }
        
        [staticPicture useNextFrameForImageCapture];
        
        [staticPicture processImage];
        
        //UIImage *currentFilteredVideoFrame = [processUpTo imageFromCurrentlyProcessedOutputWithOrientation:staticPictureOriginalOrientation];
        [processUpTo useNextFrameForImageCapture];
        UIImage* currentFilteredVideoFrame = [processUpTo imageFromCurrentFramebufferWithOrientation:staticPictureOriginalOrientation];
        
        UIImage *cropped = nil;
        
        if (currentFilteredVideoFrame != nil)
        {
            NSLog(@"width: %f, height: %f", [staticPicture outputImageSize].width, [staticPicture outputImageSize].height);
            
            CGRect originalCropRect = [self.imageView initialCropAreaInImage];
            
            CGRect CropRect = self.imageView.cropAreaInImage;
            // margin of 10%
            if (//(CropRect.origin.x <= (originalCropRect.origin.x*1.1)) && (CropRect.origin.y <= (originalCropRect.origin.y*1.1)) &&
                (CropRect.size.width >= (originalCropRect.size.width*0.9)) && (CropRect.size.height >= (originalCropRect.size.height*0.9)))
            {
                // no crop image
                cropped = currentFilteredVideoFrame;
            }
            else
            {
                self.isDirty = YES;
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([[currentFilteredVideoFrame  fixOrientation] CGImage], CropRect) ;
                cropped = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
        }
        
        staticPicture = nil;
        cropped = [[cropped fixOrientation] scaleToSizeKeepAspect:CGSizeMake(1280, 720)];
//        cropped = [cropped fixOrientation];
        
        
        
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                              cropped, @"data",
                              [NSNumber numberWithBool:self.isDirty], @"dirty", nil];
        [self.delegate imagePickerController:self didFinishPickingMediaWithInfo:info];
    }
}
- (IBAction)takeVideo:(UIButton *)sender
{
    if (!isRecording)
    {
        isRecording = YES;
        
        [self.libraryToggleButton setHidden:YES];
        [self.cameraToggleButton setEnabled:NO];
        [self.flashToggleButton setEnabled:NO];
        [self.blurToggleButton setEnabled:NO];
//        [self prepareForCapture];

        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];

        [self.photoCaptureButton setEnabled:YES];
    }
    else
    {
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
        
        [filter removeTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
        UISaveVideoAtPathToSavedPhotosAlbum(pathToMovie, nil, NULL, NULL);
        NSLog(@"Movie completed");
        
        isRecording = NO;
    }
}

-(IBAction) retakePhoto:(UIButton *)button
{
    [self.imageView initViews];
    [self.imageView.topRightPoint setHidden:YES];
    [self.imageView.bottomRightPoint setHidden:YES];
    [self.imageView.topLeftPoint setHidden:YES];
    [self.imageView.bottomLeftPoint setHidden:YES];
    
    if(!(self.editingImage == nil))
    {
        self.editingImage = nil;
    }
    
    [self.retakeButton setHidden:YES];
    [self.libraryToggleButton setHidden:NO];
    staticPicture = nil;
    staticPictureOriginalOrientation = UIImageOrientationUp;
    isStatic = NO;
    [self removeAllTargets];
    [stillCamera startCameraCapture];
    [self.cameraToggleButton setEnabled:YES];
    [self.blurToggleButton setEnabled:YES];
    
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] && stillCamera && [stillCamera.inputCamera hasTorch])
    {
        [self.flashToggleButton setEnabled:YES];
    }
    
    [self.photoCaptureButton setImage:[UIImage imageNamed:@"camera-icon"] forState:UIControlStateNormal];
    [self.photoCaptureButton setTitle:nil forState:UIControlStateNormal];
    
    if ([self.filtersToggleButton isSelected])
    {
        [self hideFilters];
    }
    
    [self setFilter:selectedFilter];
    [self prepareFilter];
}

-(IBAction) cancel:(id)sender
{
    [self.delegate imagePickerControllerDidCancel:self];
}

-(IBAction) handlePan:(UIPanGestureRecognizer *) sender
{
    if(isStatic)
    {
        [self.imageView handleDrag:sender];
    }
    else if (!isStatic && hasBlur)
    {
        CGPoint tapPoint = [sender locationInView:_imageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
        (GPUImageGaussianSelectiveBlurFilter*)blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan)
        {
            [self showBlurOverlay:YES];
            [gpu setBlurRadiusInPixels:0.0f];
            
            if (isStatic)
            {
                [staticPicture useNextFrameForImageCapture];
                
                [staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged)
        {
            [gpu setBlurRadiusInPixels:0.0f];
            [self.blurOverlayView setCircleCenter:tapPoint];
            [gpu setExcludeCirclePoint:CGPointMake(tapPoint.x/320.0f, tapPoint.y/320.0f)];
        }
        
        if([sender state] == UIGestureRecognizerStateEnded)
        {
            [gpu setBlurRadiusInPixels:kStaticBlurSize];
            [self showBlurOverlay:NO];
            
            if (isStatic)
            {
                [staticPicture useNextFrameForImageCapture];
                
                [staticPicture processImage];
            }
        }
    }
}

- (IBAction) handleTapToFocus:(UITapGestureRecognizer *)tgr
{
    if (!isStatic && tgr.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [tgr locationInView:self.imageView];
        AVCaptureDevice *device = stillCamera.inputCamera;
        CGPoint pointOfInterest = CGPointMake(.5f, .5f);
        CGSize frameSize = [[self imageView] frame].size;
        
        if ([stillCamera cameraPosition] == AVCaptureDevicePositionFront)
        {
            location.x = frameSize.width - location.x;
        }
        
        pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            NSError *error;
            
            if ([device lockForConfiguration:&error])
            {
                [device setFocusPointOfInterest:pointOfInterest];
                
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
                {
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                
                self.focusView.center = [tgr locationInView:self.view];
                self.focusView.alpha = 1;
                
                [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
                    self.focusView.alpha = 0;
                } completion:nil];
                
                [device unlockForConfiguration];
            }
            else
            {
                NSLog(@"ERROR = %@", error);
            }
        }
    }
}

-(IBAction) handlePinch:(UIPinchGestureRecognizer *) sender
{
    if (!isStatic && hasBlur)
    {
        CGPoint midpoint = [sender locationInView:_imageView];
        GPUImageGaussianSelectiveBlurFilter* gpu =
        (GPUImageGaussianSelectiveBlurFilter*)blurFilter;
        
        if ([sender state] == UIGestureRecognizerStateBegan)
        {
            [self showBlurOverlay:YES];
            [gpu setBlurRadiusInPixels:0.0f];
            
            if (isStatic)
            {
                [staticPicture useNextFrameForImageCapture];
                
                [staticPicture processImage];
            }
        }
        
        if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged)
        {
            [gpu setBlurRadiusInPixels:0.0f];
            [gpu setExcludeCirclePoint:CGPointMake(midpoint.x/320.0f, midpoint.y/320.0f)];
            self.blurOverlayView.circleCenter = CGPointMake(midpoint.x, midpoint.y);
            CGFloat radius = MAX(MIN(sender.scale*[gpu excludeCircleRadius], 0.6f), 0.15f);
            self.blurOverlayView.radius = radius*320.f;
            [gpu setExcludeCircleRadius:radius];
            sender.scale = 1.0f;
        }
        
        if ([sender state] == UIGestureRecognizerStateEnded)
        {
            [gpu setBlurRadiusInPixels:kStaticBlurSize];
            [self showBlurOverlay:NO];
            
            if (isStatic)
            {
                [staticPicture useNextFrameForImageCapture];

                [staticPicture processImage];
            }
        }
    }
}

-(void) showFilters
{
    [self.filtersToggleButton setSelected:YES];
    self.filtersToggleButton.enabled = NO;
    CGRect imageRect = self.imageView.frame;
    imageRect.origin.y -= 34;
    CGRect sliderScrollFrame = self.filterScrollView.frame;
    sliderScrollFrame.origin.y -= self.filterScrollView.frame.size.height;
    CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
    sliderScrollFrameBackground.origin.y -=
    self.filtersBackgroundImageView.frame.size.height-3;
    
    self.filterScrollView.hidden = NO;
    self.filtersBackgroundImageView.hidden = NO;
    
//    [UIView animateWithDuration:0.10
//                          delay:0.05
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.imageView.frame = imageRect;
//                         self.filterScrollView.frame = sliderScrollFrame;
//                         self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
//                     }
//                     completion:^(BOOL finished){
//                         self.filtersToggleButton.enabled = YES;
//                     }];

    CGFloat constant = self.filterScrollViewBottomConstraint.constant;
    
    CGFloat newConstant = constant + 75;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.10
                          delay:0.05
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.filterScrollViewBottomConstraint.constant = newConstant;
                         self.filtersBackgroundImageViewBottomConstraint.constant = newConstant;
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                        self.filtersToggleButton.enabled = YES;
                         
                     }];
}

-(void) hideFilters
{
    [self.filtersToggleButton setSelected:NO];
    CGRect imageRect = self.imageView.frame;
    imageRect.origin.y += 34;
    CGRect sliderScrollFrame = self.filterScrollView.frame;
    sliderScrollFrame.origin.y += self.filterScrollView.frame.size.height;
    
    CGRect sliderScrollFrameBackground = self.filtersBackgroundImageView.frame;
    sliderScrollFrameBackground.origin.y += self.filtersBackgroundImageView.frame.size.height-3;
    
//    [UIView animateWithDuration:0.10
//                          delay:0.05
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         self.imageView.frame = imageRect;
//                         self.filterScrollView.frame = sliderScrollFrame;
//                         self.filtersBackgroundImageView.frame = sliderScrollFrameBackground;
//                     }
//                     completion:^(BOOL finished){
//                         
//                         self.filtersToggleButton.enabled = YES;
//                         self.filterScrollView.hidden = YES;
//                         self.filtersBackgroundImageView.hidden = YES;
//                     }];

    CGFloat constant = self.filterScrollViewBottomConstraint.constant;
    
    CGFloat newConstant = constant - 75;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.10
                          delay:0.05
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.filterScrollViewBottomConstraint.constant = newConstant;
                         self.filtersBackgroundImageViewBottomConstraint.constant = newConstant;
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         self.filtersToggleButton.enabled = YES;
                         self.filterScrollView.hidden = YES;
                         self.filtersBackgroundImageView.hidden = YES;
                         
                     }];
}

-(IBAction) toggleFilters:(UIButton *)sender
{
    sender.enabled = NO;
    
    if (sender.selected)
    {
        [self hideFilters];
    }
    else
    {
        [self showFilters];
    }
    
}

-(void) showBlurOverlay:(BOOL)show
{
    if(show)
    {
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
            self.blurOverlayView.alpha = 0.6;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            self.blurOverlayView.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


-(void) flashBlurOverlay
{
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        
        self.blurOverlayView.alpha = 0.6;
        
    }
    completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.35 delay:0.2 options:0 animations:^{
            
            self.blurOverlayView.alpha = 0;
            
        }
        completion:^(BOOL finished) {
            
        }];
    }];
}

-(void) dealloc
{
    [self removeAllTargets];
    stillCamera = nil;
    cropFilter = nil;
    filter = nil;
    blurFilter = nil;
    staticPicture = nil;
    self.blurOverlayView = nil;
    self.focusView = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [stillCamera stopCameraCapture];
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}


#pragma mark - UIImagePickerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.isDirty = NO;
    
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil)
    {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (outputImage)
    {
        outputImage = [outputImage scaleToSizeKeepAspect:CGSizeMake(1280, 720)];
        
        [self.imageView initViews];
        
        [self prepareForEditImage:outputImage];
        
        staticPicture = [[GPUImagePicture alloc] initWithImage:outputImage smoothlyScaleOutput:YES];
        staticPictureOriginalOrientation = outputImage.imageOrientation;
        isStatic = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.cameraToggleButton setEnabled:NO];
        [self.flashToggleButton setEnabled:NO];
        [self.blurToggleButton setEnabled:NO];
        [self prepareStaticFilter];
        [self.retakeButton setHidden:NO];
        [self.photoCaptureButton setHidden:NO];
        [self.photoCaptureButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.photoCaptureButton setImage:nil forState:UIControlStateNormal];
        [self.photoCaptureButton setEnabled:YES];
        
        
        if(![self.filtersToggleButton isSelected])
        {
            [self showFilters];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (!isStatic)
    {
        [self retakePhoto:nil];
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return YES;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#endif

@end


#pragma mark - ControlPointView implementation

@interface ControlPointView ()

@end

@implementation ControlPointView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.color = [UIColor colorWithRed:18.0/255.0 green:173.0/255.0 blue:251.0/255.0 alpha:1];
        self.opaque = NO;
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGFloat r,g,b,a;
    [_color getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBFillColor(context, r,g,b,a);
    CGContextFillEllipseInRect(context, rect);
}

@end


#pragma mark - MaskView implementation


@implementation ShadeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        //self.blurredImageView = [[UIImageView alloc] init];
    }
    return self;
}

- (void)setCropBorderColor:(UIColor *)color
{
    _cropBorderColor = color;
    [self setNeedsDisplay];
}



- (void)setCropArea:(CGRect)_clearArea
{
    _cropArea = _clearArea;
    [self setNeedsDisplay];
}



- (void)setShadeAlpha:(CGFloat)_alpha
{
    _shadeAlpha = _alpha;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
  
    //UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
   CGContextRef ctx = UIGraphicsGetCurrentContext();
    //Fill the background with gray:
    //CGContextSetRGBFillColor(ctx, 0.5, 0.5, 0.5, 1);
    //CGContextFillRect(ctx, rect);
    //CGContextAddRect(ctx, rect);
    //Add some rectangles:
    //CGContextAddRect(ctx, CGRectMake(10, 10, 100, 100));
    //CGContextAddRect(ctx, CGRectMake(120, 120, 50, 100));
    
    
//    CGContextAddRect(ctx, self.cropArea);
    CGContextAddRect(ctx, CGRectMake(rect.origin.x, rect.origin.y, self.cropArea.origin.x, rect.size.height));
    CGContextAddRect(ctx, CGRectMake(self.cropArea.origin.x, rect.origin.y, rect.size.width-self.cropArea.origin.x, self.cropArea.origin.y));
    
    
    CGContextAddRect(ctx, CGRectMake(self.cropArea.origin.x+self.cropArea.size.width, self.cropArea.origin.y, rect.size.width-(self.cropArea.origin.x+self.cropArea.size.width), rect.size.height-self.cropArea.origin.y));
    CGContextAddRect(ctx, CGRectMake(self.cropArea.origin.x, self.cropArea.origin.y+self.cropArea.size.height, self.cropArea.size.width, rect.size.height-(self.cropArea.origin.y+self.cropArea.size.height)));
    
    //Clip:
    CGContextEOClip(ctx);
    //Fill the entire bounds with red:
    [self.blurredImage drawInRect:rect];
    
    //UIGraphicsEndImageContext();
    /*
    CALayer* layer = self.blurredImageView.layer;
   
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    //CGContextClearRect(c, rect);
    CGContextAddRect(c, self.cropArea);
    CGContextAddRect(c, rect);
    CGContextEOClip(c);
    CGContextSetFillColorWithColor(c, [UIColor redColor].CGColor);
    CGContextFillRect(c, rect);
    UIImage* maskim;
    //UIImage* maskim = UIGraphicsGetImageFromCurrentImageContext();
//    if(self.normalImageView.image)
//        maskim = self.normalImageView.image;
//    else
        maskim = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    CALayer* mask = [CALayer layer];
    mask.frame = rect;
    mask.contents = (id)maskim.CGImage;
    layer.mask = mask;*/
}

@end


#pragma mark - MaskImageView implementation


static CGFloat const DEFAULT_CONTROL_POINT_SIZE = 8;

CGRect SquareCGRectAtCenter(CGFloat centerX, CGFloat centerY, CGFloat size)
{
    CGFloat x = centerX - size / 2.0;
    CGFloat y = centerY - size / 2.0;
    return CGRectMake(x, y, size, size);
}

@interface ImageCropView ()

@end

@implementation ImageCropView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame blurOn:(BOOL)blurOn allowResize:(BOOL)allowResize withInitialClearAreaSize:(CGSize)initialClearArea
{
    self = [super initWithFrame:frame];
    if (self) {
        self.blurred = blurOn;
        self.allowResizing = allowResize;
        self.initialClearAreaSize = initialClearArea;
        [self initViews];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder])
    {
        //[self initViews];
    }
    
    return self;
}

- (void)initViews
{
    CGRect subviewFrame = self.bounds;
    
    // First clean previous instance
    if(self.shadeView)
    {
        [self.shadeView removeFromSuperview];
        self.shadeView = nil;
    }
    if(self.imageView)
    {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    if(self.cropAreaView)
    {
        [self.cropAreaView removeFromSuperview];
        self.cropAreaView = nil;
    }
    if(self.topLeftPoint)
    {
        [self.topLeftPoint removeFromSuperview];
        self.topLeftPoint = nil;
        [self.bottomLeftPoint removeFromSuperview];
        self.bottomLeftPoint = nil;
        [self.bottomRightPoint removeFromSuperview];
        self.bottomRightPoint = nil;
        [self.topRightPoint removeFromSuperview];
        self.topRightPoint = nil;
    }
    
    
    //the shade
    self.shadeView = [[ShadeView alloc] initWithFrame:subviewFrame];
    
    //the image
    self.imageView = [[UIImageView alloc] initWithFrame:subviewFrame];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //if((self.initialClearAreaSize.width == 0) || (self.initialClearAreaSize.height == 0))
    {
        self.initialClearAreaSize = CGSizeMake(screenRect.size.width, screenRect.size.height);
    }
    
    //control points
    [self initControlPointSize:DEFAULT_CONTROL_POINT_SIZE];

    CGPoint centerInView = CGPointMake(screenRect.size.width / 2, screenRect.size.height / 2);
    self.topLeftPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x - (self.initialClearAreaSize.width/2),
                                                                   centerInView.y - (self.initialClearAreaSize.height/2),
                                                                   self.controlPointSize)];
    self.initialTopLeftPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x - (self.initialClearAreaSize.width/2),
                                                                               centerInView.y - (self.initialClearAreaSize.height/2),
                                                                               self.controlPointSize)];
    
    self.bottomLeftPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x - (self.initialClearAreaSize.width/2),
                                                                      centerInView.y + (self.initialClearAreaSize.height/2),
                                                                      self.controlPointSize)];
    self.initialBottomLeftPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x - (self.initialClearAreaSize.width/2),
                                                                                  centerInView.y + (self.initialClearAreaSize.height/2),
                                                                                  self.controlPointSize)];
    
    self.bottomRightPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x + (self.initialClearAreaSize.width/2),
                                                                       centerInView.y + (self.initialClearAreaSize.height/2), self.controlPointSize) ];
    self.initialBottomRightPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x + (self.initialClearAreaSize.width/2),
                                                                                   centerInView.y + (self.initialClearAreaSize.height/2), self.controlPointSize) ];
    
    self.topRightPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x + (self.initialClearAreaSize.width/2),
                                                                    centerInView.y - (self.initialClearAreaSize.height/2), self.controlPointSize)];
    self.initialTopRightPoint = [self createControlPointAt:SquareCGRectAtCenter(centerInView.x + (self.initialClearAreaSize.width/2),
                                                                                centerInView.y - (self.initialClearAreaSize.height/2), self.controlPointSize)];

    
    [self setAllControlsColor:[UIColor colorWithRed:(244/255.0) green:(206/255.0) blue:(118/255.0) alpha:1.0f]];

    //the "hole"
    CGRect cropArea = [self clearAreaFromControlPoints];
    self.cropAreaView = [[UIView alloc] initWithFrame:cropArea];
    self.cropAreaView.opaque = NO;
    self.cropAreaView.backgroundColor = [UIColor clearColor];
    
//  PanGestureRecognizer not used here, will use the Controller's one
//
//    UIPanGestureRecognizer* dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
//    dragRecognizer.view.multipleTouchEnabled = YES;
//    dragRecognizer.minimumNumberOfTouches = 1;
//    dragRecognizer.maximumNumberOfTouches = 2;
//    [self.viewForBaselineLayout addGestureRecognizer:dragRecognizer];
    //self.shadeView.normalImageView = self.imageView;
    [self addSubview:self.imageView];
    [self addSubview:self.shadeView];
    //[self addSubview:self.shadeView.blurredImageView];
    [self addSubview:self.cropAreaView];
    [self addSubview:self.topRightPoint];
    [self addSubview:self.bottomRightPoint];
    [self addSubview:self.topLeftPoint];
    [self addSubview:self.bottomLeftPoint];

    [self.topRightPoint setHidden:YES];
    [self.bottomRightPoint setHidden:YES];
    [self.topLeftPoint setHidden:YES];
    [self.bottomLeftPoint setHidden:YES];
    
    self.PointsArray = [[NSArray alloc] initWithObjects:self.topRightPoint, self.bottomRightPoint, self.self.topLeftPoint, self.bottomLeftPoint, nil];
    [self.shadeView setCropArea:cropArea];
    
    self.maskAlpha = DEFAULT_MASK_ALPHA;
    
    self.imageFrameInView = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    self.imageView.frame = self.imageFrameInView;
    
    self.imageView.hidden = YES;
    self.cropAreaView.hidden = YES;
}

- (ControlPointView*)createControlPointAt:(CGRect)frame
{
    ControlPointView* point = [[ControlPointView alloc] initWithFrame:frame];
    return point;
}

- (CGRect)clearAreaFromControlPoints
{
    CGFloat width = self.topRightPoint.center.x - self.topLeftPoint.center.x;
    CGFloat height = self.bottomRightPoint.center.y - self.topRightPoint.center.y;
    CGRect hole = CGRectMake(self.topLeftPoint.center.x, self.topLeftPoint.center.y, width, height);
    return hole;
}

- (CGRect)initialClearAreaFromControlPoints
{
    CGFloat width = self.initialTopRightPoint.center.x - self.initialTopLeftPoint.center.x;
    CGFloat height = self.initialBottomRightPoint.center.y - self.initialTopRightPoint.center.y;
    CGRect hole = CGRectMake(self.initialTopLeftPoint.center.x, self.initialTopLeftPoint.center.y, width, height);
    return hole;
}


- (CGRect)controllableAreaFromControlPoints
{
    CGFloat width = self.topRightPoint.center.x - self.topLeftPoint.center.x - self.controlPointSize;
    CGFloat height = self.bottomRightPoint.center.y - self.topRightPoint.center.y - self.controlPointSize;
    CGRect hole = CGRectMake(self.topLeftPoint.center.x + self.controlPointSize / 2, self.topLeftPoint.center.y + self.controlPointSize / 2, width, height);
    return hole;
}

- (void)boundingBoxForTopLeft:(CGPoint)topLeft bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight topRight:(CGPoint)topRight
{
    CGRect box = CGRectMake(topLeft.x - self.controlPointSize / 2, topLeft.y - self.controlPointSize / 2 , topRight.x - topLeft.x + self.controlPointSize , bottomRight.y - topRight.y + self.controlPointSize );
    
    //If not square - crop cropView =-)
    if (!square)
    {
        box = CGRectIntersection(self.imageFrameInView, box);
    }
    
    if (CGRectContainsRect(self.imageFrameInView, box))
    {
        self.bottomLeftPoint.center = CGPointMake(box.origin.x + self.controlPointSize / 2, box.origin.y + box.size.height - self.controlPointSize / 2);
        self.bottomRightPoint.center = CGPointMake(box.origin.x + box.size.width - self.controlPointSize / 2, box.origin.y + box.size.height - self.controlPointSize / 2);;
        self.topLeftPoint.center = CGPointMake(box.origin.x + self.controlPointSize / 2, box.origin.y + self.controlPointSize / 2);
        self.topRightPoint.center = CGPointMake(box.origin.x + box.size.width - self.controlPointSize / 2, box.origin.y + self.controlPointSize / 2);
    }
}

- (void)boundingBoxForTopLeftInitial:(CGPoint)topLeft bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight topRight:(CGPoint)topRight
{
    CGRect box = CGRectMake(topLeft.x - self.controlPointSize / 2, topLeft.y - self.controlPointSize / 2 , topRight.x - topLeft.x + self.controlPointSize , bottomRight.y - topRight.y + self.controlPointSize );
    
    //If not square - crop cropView =-)
    if (!square)
    {
        box = CGRectIntersection(self.imageFrameInView, box);
    }
    
    if (CGRectContainsRect(self.imageFrameInView, box))
    {
        self.initialBottomLeftPoint.center = CGPointMake(box.origin.x + self.controlPointSize / 2, box.origin.y + box.size.height - self.controlPointSize / 2);
        self.initialBottomRightPoint.center = CGPointMake(box.origin.x + box.size.width - self.controlPointSize / 2, box.origin.y + box.size.height - self.controlPointSize / 2);;
        self.initialTopLeftPoint.center = CGPointMake(box.origin.x + self.controlPointSize / 2, box.origin.y + self.controlPointSize / 2);
        self.initialTopRightPoint.center = CGPointMake(box.origin.x + box.size.width - self.controlPointSize / 2, box.origin.y + self.controlPointSize / 2);
    }
}

- (UIView*)  checkHit:(CGPoint)point
{
    UIView* view = self.cropAreaView;
    for (int i =0; i < self.PointsArray.count; i++) {
        if (sqrt(pow((point.x-view.center.x),2) + pow((point.y-view.center.y),2))>sqrt(pow((point.x- [self.PointsArray[i] center].x),2) + pow((point.y- [self.PointsArray[i] center].y),2)))
            view = self.PointsArray[i];
    }
    
    return view;
}

// Overriding this method to create a larger touch surface area without changing view
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect frame = CGRectInset(self.cropAreaView.frame, -30, -30);
    return CGRectContainsPoint(frame, point) ? self.cropAreaView : nil;
}

- (void)handleDrag:(UIPanGestureRecognizer*)recognizer
{
    NSUInteger count = [recognizer numberOfTouches];
    if (recognizer.state == UIGestureRecognizerStateBegan || self.multiDragPoint.lastCount != count)
    {
        if (count > 1)
            [self prepMultiTouchPan:recognizer withCount:count];
        else
            [self prepSingleTouchPan:recognizer];
        
        MultiDragPoint point = self.multiDragPoint;
        point.lastCount = count;
        self.multiDragPoint = point;
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        return; // no-op
    }
    
    if (count > 1)
    {
        // Transforms crop box based on the two dragPoints.
        for (int i = 0; i < count; i++)
        {
            self.dragPoint = i == 0 ? self.multiDragPoint.mainPoint : self.multiDragPoint.optionalPoint;
            [self beginCropBoxTransformForPoint:[recognizer locationOfTouch:i inView:self] atView:(i == 0 ? self.dragViewOne : self.dragViewTwo)];
            // Assign point centers that could have changed in previous transform
            MultiDragPoint mpoint = self.multiDragPoint;
            DragPoint point = mpoint.optionalPoint;
            
            point.topLeftCenter = self.topLeftPoint.center;
            point.bottomLeftCenter = self.bottomLeftPoint.center;
            point.bottomRightCenter = self.bottomRightPoint.center;
            point.topRightCenter = self.topRightPoint.center;
            point.clearAreaCenter = self.cropAreaView.center;
            
            mpoint.optionalPoint = point;
            self.multiDragPoint = mpoint;
        }
    }
    else
    {
        [self beginCropBoxTransformForPoint:[recognizer locationInView:self] atView:self.dragViewOne];
    }
    
    // Used to reset multiDragPoint when changing from 1 to 2 touches.
    MultiDragPoint point = self.multiDragPoint;
    point.lastCount = count;
    self.multiDragPoint = point;
}

/**
 * Records current values and points for multi-finger pan gestures
 * @params recognizer The pan gesuture with current point values
 * @params count The number of touches on view
 */
- (void)prepMultiTouchPan:(UIPanGestureRecognizer*)recognizer withCount:(NSUInteger)count
{
    for (int i = 0; i < count; i++)
    {
        if (i == 0)
        {
            self.dragViewOne = [self checkHit:[recognizer locationOfTouch:i inView:self]];
            MultiDragPoint mpoint = self.multiDragPoint;
            mpoint.mainPoint.dragStart = [recognizer locationOfTouch:i inView:self];
            self.multiDragPoint = mpoint;
        }
        else
        {
            self.dragViewTwo = [self checkHit:[recognizer locationOfTouch:i inView:self]];
            MultiDragPoint mpoint = self.multiDragPoint;
            mpoint.optionalPoint.dragStart = [recognizer locationOfTouch:i inView:self];
            self.multiDragPoint = mpoint;
        }
    }
    
    MultiDragPoint mpoint = self.multiDragPoint;
    
    mpoint.mainPoint.topLeftCenter = self.topLeftPoint.center;
    mpoint.mainPoint.bottomLeftCenter = self.bottomLeftPoint.center;
    mpoint.mainPoint.bottomRightCenter = self.bottomRightPoint.center;
    mpoint.mainPoint.topRightCenter = self.topRightPoint.center;
    mpoint.mainPoint.clearAreaCenter = self.cropAreaView.center;
    
    self.multiDragPoint = mpoint;
}

/**
 * Records current values and points for single finger pan gestures
 * @params recognizer The pan gesuture with current point values
 */
- (void)prepSingleTouchPan:(UIPanGestureRecognizer*)recognizer
{
    self.dragViewOne = [self checkHit:[recognizer locationInView:self]];
    
    DragPoint point = self.dragPoint;
    
    point.dragStart = [recognizer locationInView:self];
    point.topLeftCenter = self.topLeftPoint.center;
    point.bottomLeftCenter = self.bottomLeftPoint.center;
    point.bottomRightCenter = self.bottomRightPoint.center;
    point.topRightCenter = self.topRightPoint.center;
    point.clearAreaCenter = self.cropAreaView.center;
    
    self.dragPoint = point;
}

- (void)beginCropBoxTransformForPoint:(CGPoint)location atView:(UIView*)view
{
    if (view == self.topLeftPoint)
    {
        [self handleDragTopLeft:location];
    }
    else if (view == self.bottomLeftPoint)
    {
        [self handleDragBottomLeft:location];
    }
    else if (view == self.bottomRightPoint)
    {
        [self handleDragBottomRight:location];
    }
    else if (view == self.topRightPoint)
    {
        [self handleDragTopRight:location];
    }
    else if (view == self.cropAreaView)
    {
        [self handleDragClearArea:location];
    }
    
    CGRect clearArea = [self clearAreaFromControlPoints];
    self.cropAreaView.frame = clearArea;
    
    // Create offset to make frame within imageView
    clearArea.origin.y = clearArea.origin.y - self.imageFrameInView.origin.y;
    clearArea.origin.x = clearArea.origin.x - self.imageFrameInView.origin.x;
    [self.shadeView setCropArea:clearArea];
}

- (CGSize)deriveDisplacementFromDragLocation:(CGPoint)dragLocation draggedPoint:(CGPoint)draggedPoint oppositePoint:(CGPoint)oppositePoint
{
    CGFloat dX = dragLocation.x - self.dragPoint.dragStart.x;
    CGFloat dY = dragLocation.y - self.dragPoint.dragStart.y;
    CGPoint tempDraggedPoint = CGPointMake(draggedPoint.x + dX, draggedPoint.y + dY);
    CGFloat width = (tempDraggedPoint.x - oppositePoint.x);
    CGFloat height = (tempDraggedPoint.y - oppositePoint.y);
    CGFloat size = fabs(width)>=fabs(height) ? width : height;
    CGFloat xDir = draggedPoint.x<=oppositePoint.x ? 1 : -1;
    CGFloat yDir = draggedPoint.y<=oppositePoint.y ? 1 : -1;
    CGFloat newX = 0, newY = 0;
    
    if (xDir>=0)
    {
        //on the right
        if(square)
            newX = oppositePoint.x - fabs(size);
        else
            newX = oppositePoint.x - fabs(width);
    }
    else
    {
        //on the left
        if(square )
            newX = oppositePoint.x + fabs(size);
        else
            newX = oppositePoint.x + fabs(width);
    }
    
    if (yDir>=0)
    {
        //on the top
        if(square)
            newY = oppositePoint.y - fabs(size);
        else
            newY = oppositePoint.y - fabs(height);
    }
    else
    {
        //on the bottom
        if(square)
            newY = oppositePoint.y + fabs(size);
        else
            newY = oppositePoint.y + fabs(height);
    }
    
    CGSize displacement = CGSizeMake(newX - draggedPoint.x, newY - draggedPoint.y);
    return displacement;
}

- (void)handleDragTopLeft:(CGPoint)dragLocation
{
    if(!self.allowResizing)
        return;
    
    CGSize disp = [self deriveDisplacementFromDragLocation:dragLocation draggedPoint:self.dragPoint.topLeftCenter oppositePoint:self.dragPoint.bottomRightCenter];
    CGPoint topLeft = CGPointMake(self.dragPoint.topLeftCenter.x + disp.width, self.dragPoint.topLeftCenter.y + disp.height);
    CGPoint topRight = CGPointMake(self.dragPoint.topRightCenter.x, self.dragPoint.topLeftCenter.y + disp.height);
    CGPoint bottomLeft = CGPointMake(self.dragPoint.bottomLeftCenter.x + disp.width, self.dragPoint.bottomLeftCenter.y);
    
    // Make sure that the new cropping area will not be smaller than the minimum image size
    CGFloat width = topRight.x - topLeft.x;
    CGFloat height = bottomLeft.y - topLeft.y;
    width = width * self.imageScale;
    height = height * self.imageScale;
    
    // If the crop area is too small, set the points at the minimum spacing.
    CGRect cropArea = [self clearAreaFromControlPoints];
    
    if (width >= IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        topLeft.y = cropArea.origin.y + (((cropArea.size.height * self.imageScale) - IMAGE_MIN_HEIGHT) / self.imageScale);
        topRight.y = topLeft.y;
    }
    else if (width < IMAGE_MIN_WIDTH && height >= IMAGE_MIN_HEIGHT)
    {
        topLeft.x = cropArea.origin.x + (((cropArea.size.width * self.imageScale) - IMAGE_MIN_WIDTH) / self.imageScale);
        bottomLeft.x = topLeft.x;
    }
    else if (width < IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        topLeft.x = cropArea.origin.x + (((cropArea.size.width * self.imageScale) - IMAGE_MIN_WIDTH) / self.imageScale);
        topLeft.y = cropArea.origin.y + (((cropArea.size.height * self.imageScale) - IMAGE_MIN_HEIGHT) / self.imageScale);
        topRight.y = topLeft.y;
        bottomLeft.x = topLeft.x;
    }
    
    [self boundingBoxForTopLeft:topLeft bottomLeft:bottomLeft bottomRight:self.dragPoint.bottomRightCenter topRight:topRight];
}
- (void)handleDragBottomLeft:(CGPoint)dragLocation
{
    if(!self.allowResizing)
        return;
    
    CGSize disp = [self deriveDisplacementFromDragLocation:dragLocation draggedPoint:self.dragPoint.bottomLeftCenter oppositePoint:self.dragPoint.topRightCenter];
    CGPoint bottomLeft = CGPointMake(self.dragPoint.bottomLeftCenter.x + disp.width, self.dragPoint.bottomLeftCenter.y + disp.height);
    CGPoint topLeft = CGPointMake(self.dragPoint.topLeftCenter.x + disp.width, self.dragPoint.topLeftCenter.y);
    CGPoint bottomRight = CGPointMake(self.dragPoint.bottomRightCenter.x, self.dragPoint.bottomRightCenter.y + disp.height);
    
    // Make sure that the new cropping area will not be smaller than the minimum image size
    CGFloat width = bottomRight.x - bottomLeft.x;
    CGFloat height = bottomLeft.y - topLeft.y;
    width = width * self.imageScale;
    height = height * self.imageScale;
    
    // If the crop area is too small, set the points at the minimum spacing.
    CGRect cropArea = [self clearAreaFromControlPoints];
    
    if (width >= IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        bottomLeft.y = cropArea.origin.y + (IMAGE_MIN_HEIGHT / self.imageScale);
        bottomRight.y = bottomLeft.y;
    }
    else if (width < IMAGE_MIN_WIDTH && height >= IMAGE_MIN_HEIGHT)
    {
        bottomLeft.x = cropArea.origin.x + (((cropArea.size.width * self.imageScale) - IMAGE_MIN_WIDTH) / self.imageScale);
        topLeft.x = bottomLeft.x;
    }
    else if (width < IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        bottomLeft.x = cropArea.origin.x + (((cropArea.size.width * self.imageScale) - IMAGE_MIN_WIDTH) / self.imageScale);
        bottomLeft.y = cropArea.origin.y + (IMAGE_MIN_HEIGHT / self.imageScale);
        topLeft.x = bottomLeft.x;
        bottomRight.y = bottomLeft.y;
    }
    
    [self boundingBoxForTopLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:self.dragPoint.topRightCenter];
}

- (void)handleDragBottomRight:(CGPoint)dragLocation
{
    if(!self.allowResizing)
        return;
    
    CGSize disp = [self deriveDisplacementFromDragLocation:dragLocation draggedPoint:self.dragPoint.bottomRightCenter oppositePoint:self.dragPoint.topLeftCenter];
    CGPoint bottomRight = CGPointMake(self.dragPoint.bottomRightCenter.x + disp.width, self.dragPoint.bottomRightCenter.y + disp.height);
    CGPoint topRight = CGPointMake(self.dragPoint.topRightCenter.x + disp.width, self.dragPoint.topRightCenter.y);
    CGPoint bottomLeft = CGPointMake(self.dragPoint.bottomLeftCenter.x, self.dragPoint.bottomLeftCenter.y + disp.height);
    
    // Make sure that the new cropping area will not be smaller than the minimum image size
    CGFloat width = bottomRight.x - bottomLeft.x;
    CGFloat height = bottomRight.y - topRight.y;
    width = width * self.imageScale;
    height = height * self.imageScale;
    
    // If the crop area is too small, set the points at the minimum spacing.
    CGRect cropArea = [self clearAreaFromControlPoints];
    
    if (width >= IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        bottomRight.y = cropArea.origin.y + (IMAGE_MIN_HEIGHT / self.imageScale);
        bottomLeft.y = bottomRight.y;
    }
    else if (width < IMAGE_MIN_WIDTH && height >= IMAGE_MIN_HEIGHT)
    {
        bottomRight.x = cropArea.origin.x + (IMAGE_MIN_WIDTH / self.imageScale);
        topRight.x = bottomRight.x;
    }
    else if (width < IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        bottomRight.x = cropArea.origin.x + (IMAGE_MIN_WIDTH / self.imageScale);
        bottomRight.y = cropArea.origin.y + (IMAGE_MIN_HEIGHT / self.imageScale);
        topRight.x = bottomRight.x;
        bottomLeft.y = bottomRight.y;
    }
    
    [self boundingBoxForTopLeft:self.dragPoint.topLeftCenter bottomLeft:bottomLeft bottomRight:bottomRight topRight:topRight];
}

- (void)handleDragTopRight:(CGPoint)dragLocation
{
    if(!self.allowResizing)
        return;
    
    CGSize disp = [self deriveDisplacementFromDragLocation:dragLocation draggedPoint:self.dragPoint.topRightCenter oppositePoint:self.dragPoint.bottomLeftCenter];
    CGPoint topRight = CGPointMake(self.dragPoint.topRightCenter.x + disp.width, self.dragPoint.topRightCenter.y + disp.height);
    CGPoint topLeft = CGPointMake(self.dragPoint.topLeftCenter.x, self.dragPoint.topLeftCenter.y + disp.height);
    CGPoint bottomRight = CGPointMake(self.dragPoint.bottomRightCenter.x + disp.width, self.dragPoint.bottomRightCenter.y);
    
    // Make sure that the new cropping area will not be smaller than the minimum image size
    CGFloat width = topRight.x - topLeft.x;
    CGFloat height = bottomRight.y - topRight.y;
    width = width * self.imageScale;
    height = height * self.imageScale;
    
    // If the crop area is too small, set the points at the minimum spacing.
    CGRect cropArea = [self clearAreaFromControlPoints];
    
    if (width >= IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        topRight.y = cropArea.origin.y + (((cropArea.size.height * self.imageScale) - IMAGE_MIN_HEIGHT) / self.imageScale);
        topLeft.y = topRight.y;
    }
    else if (width < IMAGE_MIN_WIDTH && height >= IMAGE_MIN_HEIGHT)
    {
        topRight.x = cropArea.origin.x + (IMAGE_MIN_WIDTH / self.imageScale);
        bottomRight.x = topRight.x;
    }
    else if (width < IMAGE_MIN_WIDTH && height < IMAGE_MIN_HEIGHT)
    {
        topRight.x = cropArea.origin.x + (IMAGE_MIN_WIDTH / self.imageScale);
        topRight.y = cropArea.origin.y + (((cropArea.size.height * self.imageScale) - IMAGE_MIN_HEIGHT) / self.imageScale);
        topLeft.y = topRight.y;
        bottomRight.x = topRight.x;
    }
    
    [self boundingBoxForTopLeft:topLeft bottomLeft:self.dragPoint.bottomLeftCenter bottomRight:bottomRight topRight:topRight];
}

- (void)handleDragClearArea:(CGPoint)dragLocation
{
    CGFloat dX = dragLocation.x - self.dragPoint.dragStart.x;
    CGFloat dY = dragLocation.y - self.dragPoint.dragStart.y;
    
    CGPoint newTopLeft = CGPointMake(self.dragPoint.topLeftCenter.x + dX, self.dragPoint.topLeftCenter.y + dY);
    CGPoint newBottomLeft = CGPointMake(self.dragPoint.bottomLeftCenter.x + dX, self.dragPoint.bottomLeftCenter.y + dY);
    CGPoint newBottomRight = CGPointMake(self.dragPoint.bottomRightCenter.x + dX, self.dragPoint.bottomRightCenter.y + dY);
    CGPoint newTopRight = CGPointMake(self.dragPoint.topRightCenter.x + dX, self.dragPoint.topRightCenter.y + dY);
    
    CGFloat clearAreaWidth = self.dragPoint.topRightCenter.x - self.dragPoint.topLeftCenter.x;
    CGFloat clearAreaHeight = self.dragPoint.bottomLeftCenter.y - self.dragPoint.topLeftCenter.y;
    
    CGFloat halfControlPointSize = self.controlPointSize / 2;
    CGFloat minX = self.imageFrameInView.origin.x + halfControlPointSize;
    CGFloat maxX = self.imageFrameInView.origin.x + self.imageFrameInView.size.width - halfControlPointSize;
    CGFloat minY = self.imageFrameInView.origin.y + halfControlPointSize;
    CGFloat maxY = self.imageFrameInView.origin.y + self.imageFrameInView.size.height - halfControlPointSize;
    
    if (newTopLeft.x<minX)
    {
        newTopLeft.x = minX;
        newBottomLeft.x = minX;
        newTopRight.x = newTopLeft.x + clearAreaWidth;
        newBottomRight.x = newTopRight.x;
    }
    
    if(newTopLeft.y<minY)
    {
        newTopLeft.y = minY;
        newTopRight.y = minY;
        newBottomLeft.y = newTopLeft.y + clearAreaHeight;
        newBottomRight.y = newBottomLeft.y;
    }
    
    if (newBottomRight.x>maxX)
    {
        newBottomRight.x = maxX;
        newTopRight.x = maxX;
        newTopLeft.x = newBottomRight.x - clearAreaWidth;
        newBottomLeft.x = newTopLeft.x;
    }
    
    if (newBottomRight.y>maxY)
    {
        newBottomRight.y = maxY;
        newBottomLeft.y = maxY;
        newTopRight.y = newBottomRight.y - clearAreaHeight;
        newTopLeft.y = newTopRight.y;
    }
    
    self.topLeftPoint.center = newTopLeft;
    self.bottomLeftPoint.center = newBottomLeft;
    self.bottomRightPoint.center = newBottomRight;
    self.topRightPoint.center = newTopRight;
    
}

- (void)initControlPointSize:(CGFloat)pointSize
{
    self.controlPointSize = pointSize;
    CGFloat halfSize = self.controlPointSize;
    CGRect topLeftPointFrame = CGRectMake(self.topLeftPoint.center.x - halfSize, self.topLeftPoint.center.y - halfSize, self.controlPointSize, self.controlPointSize);
    CGRect bottomLeftPointFrame = CGRectMake(self.bottomLeftPoint.center.x - halfSize, self.bottomLeftPoint.center.y - halfSize, self.controlPointSize, self.controlPointSize);
    CGRect bottomRightPointFrame = CGRectMake(self.bottomRightPoint.center.x - halfSize, self.bottomRightPoint.center.y - halfSize, self.controlPointSize, self.controlPointSize);
    CGRect topRightPointFrame = CGRectMake(self.topRightPoint.center.x - halfSize, self.topRightPoint.center.y - halfSize, self.controlPointSize, self.controlPointSize);
    
    self.topLeftPoint.frame = topLeftPointFrame;
    self.bottomLeftPoint.frame = bottomLeftPointFrame;
    self.bottomRightPoint.frame = bottomRightPointFrame;
    self.topRightPoint.frame = topRightPointFrame;
    
    self.initialTopLeftPoint.frame = topLeftPointFrame;
    self.initialBottomLeftPoint.frame = bottomLeftPointFrame;
    self.initialBottomRightPoint.frame = bottomRightPointFrame;
    self.initialTopRightPoint.frame = topRightPointFrame;
    
    [self setNeedsDisplay];
}

- (void)setMaskAlpha:(CGFloat)alpha
{
    self.shadeView.shadeAlpha = alpha;
}

- (CGFloat)maskAlpha
{
    return self.shadeView.shadeAlpha;
}

- (CGRect)cropAreaInImage
{
    CGRect _clearArea = self.cropAreaInView;
    CGRect r = CGRectMake((int)((_clearArea.origin.x - self.imageFrameInView.origin.x) * self.imageScale),
                          (int)((_clearArea.origin.y - self.imageFrameInView.origin.y) * self.imageScale),
                          (int)(_clearArea.size.width * self.imageScale),
                          (int)(_clearArea.size.height * self.imageScale));
    return r;
}

- (CGRect)initialCropAreaInImage
{
    CGRect _clearArea = [self initialCropAreaInView];
    CGRect r = CGRectMake((int)((_clearArea.origin.x - self.imageFrameInView.origin.x) * self.imageScale),
                          (int)((_clearArea.origin.y - self.imageFrameInView.origin.y) * self.imageScale),
                          (int)(_clearArea.size.width * self.imageScale),
                          (int)(_clearArea.size.height * self.imageScale));
    return r;
}

- (void)setCropAreaInImage:(CGRect)_clearAreaInImage
{
    CGRect r = CGRectMake(_clearAreaInImage.origin.x + self.imageFrameInView.origin.x,
                          _clearAreaInImage.origin.y + self.imageFrameInView.origin.y,
                          _clearAreaInImage.size.width,
                          _clearAreaInImage.size.height);
    [self setCropAreaInView:r];
}

- (CGRect)cropAreaInView
{
    CGRect area = [self clearAreaFromControlPoints];
    return area;
}

- (CGRect)initialCropAreaInView
{
    CGRect area = [self initialClearAreaFromControlPoints];
    return area;
}

- (void)setCropAreaInView:(CGRect)area
{
    CGPoint topLeft = area.origin;
    CGPoint bottomLeft = CGPointMake(topLeft.x, topLeft.y + area.size.height);
    CGPoint bottomRight = CGPointMake(bottomLeft.x + area.size.width, bottomLeft.y);
    CGPoint topRight = CGPointMake(topLeft.x + area.size.width, topLeft.y);
    self.topLeftPoint.center = topLeft;
    self.bottomLeftPoint.center = bottomLeft;
    self.bottomRightPoint.center = bottomRight;
    self.topRightPoint.center = topRight;
    self.shadeView.cropArea = area;
    [self setNeedsDisplay];
}

- (void)InitAndSetImage:(UIImage *)image
{
    
    self.image = image;
    CGFloat frameWidth = self.frame.size.width;
    CGFloat frameHeight = self.frame.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    BOOL isPortrait = imageHeight / frameHeight > imageWidth/frameWidth;
    int x, y;
    int scaledImageWidth, scaledImageHeight;
    
    if (isPortrait)
    {
        self.imageScale = imageHeight / frameHeight;
        scaledImageWidth = imageWidth / self.imageScale;
        scaledImageHeight = frameHeight;
        x = (frameWidth - scaledImageWidth) / 2;
        y = 0;
    }
    else
    {
        self.imageScale = imageWidth / frameWidth;
        scaledImageWidth = frameWidth;
        scaledImageHeight = imageHeight / self.imageScale;
        x = 0;
        y = (frameHeight - scaledImageHeight) / 2;
    }
    
    self.imageFrameInView = CGRectMake(x, y, scaledImageWidth, scaledImageHeight);
    self.imageView.frame = self.imageFrameInView;

// Here we don't want to show this image, will se the GPUView's
//
//    imageView.image = image;
    
    /* prepare imageviews and their frame */
    self.shadeView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.shadeView.clipsToBounds = YES;
    
    CGRect blurFrame;
    if (self.imageFrameInView.origin.x < 0 && (self.imageFrameInView.size.width - fabs(self.imageFrameInView.origin.x) >= 320)) {
        blurFrame = self.frame;
    } else {
        blurFrame = self.imageFrameInView;
    }
    self.imageView.frame = self.imageFrameInView;
    
    // blurredimageview is on top of shadeview so shadeview needs the same frame as imageView.
    self.shadeView.frame = self.imageFrameInView;
    self.shadeView.frame = blurFrame;
    
    // perform image blur
    UIImage *blur;
    if (self.blurred)
    {
        blur = [image blurredImageWithRadius:30 iterations:1 tintColor:[UIColor blackColor]];
    }
    else
    {
        blur = [image blurredImageWithRadius:0 iterations:1 tintColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
    }
    
    [self.shadeView setBlurredImage:blur];
   // self.shadeView.normalImageView.image = image;
    
    //Special fix. If scaledImageWidth or scaledImageHeight < clearArea.width of clearArea.Height.
    [self boundingBoxForTopLeft:self.topLeftPoint.center bottomLeft:self.bottomLeftPoint.center bottomRight:self.bottomRightPoint.center topRight:self.topRightPoint.center];
    
    [self boundingBoxForTopLeftInitial:self.initialTopLeftPoint.center bottomLeft:self.initialBottomLeftPoint.center bottomRight:self.initialBottomRightPoint.center topRight:self.initialTopRightPoint.center];
    
    CGRect clearArea = [self clearAreaFromControlPoints];
    self.cropAreaView.frame = clearArea;
    clearArea.origin.y = clearArea.origin.y - self.imageFrameInView.origin.y;
    clearArea.origin.x = clearArea.origin.x - self.imageFrameInView.origin.x;
    [self.shadeView setCropArea:clearArea];
    
}

- (void)setAllControlsColor:(UIColor *)_color
{
    self.controlColor = _color;
    self.shadeView.cropBorderColor = _color;
    self.topLeftPoint.color = _color;
    self.bottomLeftPoint.color = _color;
    self.bottomRightPoint.color = _color;
    self.topRightPoint.color = _color;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    
    if (!userInteractionEnabled)
    {
        [self.topLeftPoint setHidden:YES];
        [self.bottomLeftPoint setHidden:YES];
        [self.bottomRightPoint setHidden:YES];
        [self.topRightPoint setHidden:YES];
    }
    
    [super setUserInteractionEnabled:userInteractionEnabled];
}

@end

@implementation UIImage (scaleToSizeKeepAspect)
/*
- (UIImage*)scaleToSizeKeepAspect:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    CGFloat ws = size.width/self.size.width;
    CGFloat hs = size.height/self.size.height;
    
    if (ws > hs) {
        ws = hs/ws;
        hs = 1.0;
    } else {
        hs = ws/hs;
        ws = 1.0;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(size.width/2-(size.width*ws)/2,
                                           size.height/2-(size.height*hs)/2, size.width*ws,
                                           size.height*hs), self.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
*/
- (UIImage*)scaleToSizeKeepAspect:(CGSize)size
{
    float fmax = size.height;
    
    if(self.size.width > self.size.height)
        fmax = size.width;
    
    float oldWidth = self.size.width;
    float scaleFactor = fmax / oldWidth;
    
    float newHeight = self.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end


@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
