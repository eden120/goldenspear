//
//  VisualSearchViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 30/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "VisualSearchViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "SearchBaseViewController.h"
#import "FashionistaPostViewController.h"
#import "FashionistaProfileViewController.h"
#import "UIButton+CustomCreation.h"

#define UPLOADED_IMAGE_MAX_DIMENSION 1000.0


@interface VisualSearchViewController ()

@end

@implementation VisualSearchViewController

BOOL bPerformingSearch = NO;
BOOL bSendingImageForIdentification = NO;
BOOL bGettingImageFromCameraRoll = NO;
BOOL bSwipingRight = NO;
UIImageView *cameraRollImageView = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the capture manager
    [self setupCapture];
    
    // Setup the camera roll image
    [self setupCameraRollImage];

    // Setup the viewfinder image
    //[self setupViewfinder];

    bSwipingRight = NO;

    // Setup the fullscreen button to launch the visual search
    [self setupLaunchVisualSearchButton];
    
    // Setup the fullscreen button to launch the visual search
    [self setupSelectSearchTypeButton];
    
    // Make sure that the Top bar and the Bottom controls are on top
    [self bringTopBarToFront];
    [self bringBottomControlsToFront];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(!(bGettingImageFromCameraRoll))
    {
        // Hide camera roll image
        [self hideCameraRollImage];
        
        // Start capture manager
        [self startCapture];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop capture manager
    [self stopCapture];
}

- (BOOL)shouldCreateHintButton{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Setup and show the capture manager
-(void) setupCapture
{
    [self setCaptureManager:[[CaptureManager alloc] init]];
    
    if ([_captureManager addVideoInput])
    {
        [_captureManager addVideoPreviewLayer];
        
        CGRect layerRect = [[[self view] layer] bounds];
        
        [[_captureManager previewLayer] setBounds:layerRect];
        
        [[_captureManager previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
        
        [self.view.layer insertSublayer:[_captureManager previewLayer] atIndex:0];
        
        [_captureManager addStillImageOutput];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performIdentification) name:@"imageCapturedSuccessfully" object:nil];
//        
//        [[[self captureManager] captureSession] startRunning];
    }
}

// Stop the capture manager
-(void)startCapture
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageCapturedSuccessfully" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performIdentification) name:@"imageCapturedSuccessfully" object:nil];
    
    [[[self captureManager] captureSession] startRunning];
}

// Stop the capture manager
-(void)stopCapture
{
    [[[self captureManager] captureSession] stopRunning];

//    [[_captureManager previewLayer] removeFromSuperlayer];
//    [_captureManager setPreviewLayer:nil];
//
//    [[[self captureManager] captureSession] stopRunning];
//    [[self captureManager] setCaptureSession:nil];
//    
//    [self setCaptureManager:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"imageCapturedSuccessfully" object:nil];
}

//Setup camera roll image
- (void) setupCameraRollImage
{
    cameraRollImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    
    // View appearance
    [cameraRollImageView setBackgroundColor:[UIColor clearColor]];
    [cameraRollImageView setAlpha:1.00];
    [cameraRollImageView setClipsToBounds:YES];
    [cameraRollImageView setContentMode:UIViewContentModeScaleAspectFill];

    [cameraRollImageView setHidden:YES];

    [self.view addSubview:cameraRollImageView];
}

//Show camera roll image
- (void) showCameraRollImage
{
    [cameraRollImageView setImage:_identificationImage];
    [cameraRollImageView setHidden:NO];
}

//Hide camera roll image
- (void) hideCameraRollImage
{
    [cameraRollImageView setImage:nil];
    [cameraRollImageView setHidden:YES];
}

//Setup viewfinder image
- (void) setupViewfinder
{
    UIImageView *viewfinderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    
    // View appearance
    [viewfinderView setBackgroundColor:[UIColor clearColor]];
    [viewfinderView setAlpha:0.15];
    [viewfinderView setClipsToBounds:YES];
    [viewfinderView setImage:[UIImage imageNamed:@"Viewfinder.png"]];
    
    [self.view addSubview:viewfinderView];

//    UIImageView *checkerView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width)*0.10, (self.view.frame.size.height)*0.20, 256, 256)];
//    
//    // View appearance
//    [checkerView setBackgroundColor:[UIColor blueColor]];
//    [checkerView setAlpha:0.5];
//    [checkerView setClipsToBounds:YES];
//    
//    [self.view addSubview:checkerView];
}

//Setup 'Select search type' button
- (void) setupSelectSearchTypeButton
{
    UISegmentedControl *searchTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: NSLocalizedString(@"_SEARCH_PRODUCTS_", nil), NSLocalizedString(@"_SEARCH_LOOKS_", nil), nil]];

    // Control appearance
    [searchTypeSegmentedControl addTarget:self action:@selector(searchTypeSegmentedControlAction:) forControlEvents: UIControlEventValueChanged];
    [searchTypeSegmentedControl setFrame:CGRectMake(20, self.view.frame.size.height - ((60) + (20) + (10) + (30)), self.view.frame.size.width - 40, 30)];
    [searchTypeSegmentedControl setTintColor:[UIColor whiteColor]];
    
    [searchTypeSegmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvantGarde-Book" size:13.0f]} forState:UIControlStateNormal];

    self.currentVisualSearchContext = PRODUCT_VISUAL_SEARCH;
    
    if(!(self.fromViewController == nil))
    {
        if([self.fromViewController isKindOfClass:[SearchBaseViewController class]])
        {
            if(([((SearchBaseViewController *) self.fromViewController) searchContext] == FASHIONISTAPOSTS_SEARCH) || ([((SearchBaseViewController *) self.fromViewController) searchContext] == FASHIONISTAS_SEARCH))
            {
                self.currentVisualSearchContext = FASHIONISTAPOSTS_VISUAL_SEARCH;
            }
        }
        else if (([self.fromViewController isKindOfClass:[FashionistaProfileViewController class]]) || ([self.fromViewController isKindOfClass:[FashionistaPostViewController class]]))
        {
            self.currentVisualSearchContext = FASHIONISTAPOSTS_VISUAL_SEARCH;
        }
    }

    [searchTypeSegmentedControl setSelectedSegmentIndex:self.currentVisualSearchContext];
    [self.view addSubview:searchTypeSegmentedControl];
}

// 'Select search type' button action
- (void)searchTypeSegmentedControlAction:(UISegmentedControl *)segment
{
    self.currentVisualSearchContext = (visualSearchContext)segment.selectedSegmentIndex;
}

//Setup 'Launch visual search' button
- (void) setupLaunchVisualSearchButton
{
    UIButton * launchVisualSearchButton = [UIButton createButtonWithOrigin:CGPointMake(15,80)
                                                                   andSize:CGSizeMake(self.view.frame.size.width-30, self.view.frame.size.height-160)
                                                            andBorderWidth:0.0
                                                            andBorderColor:[UIColor clearColor]
                                                                   andText:@""
                                                                   andFont:nil
                                                              andFontColor:[UIColor clearColor]
                                                            andUppercasing:NO
                                                              andAlignment:UIControlContentHorizontalAlignmentCenter
                                                                  andImage:nil
                                                              andImageMode:UIViewContentModeScaleAspectFit
                                                        andBackgroundImage:nil];

    [launchVisualSearchButton addTarget:self action:@selector(captureAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:launchVisualSearchButton];
}

// Crop image to the desired area
- (UIImage *)cropImage:(UIImage *)image toSize:(CGSize)newSize withPosition:(NSString *)position
{
    CGRect cropRect;
    
    // Define the position of the crop area
    
    if ([position  isEqualToString: @"topleft"])
    {
        cropRect= CGRectMake(0, 0, newSize.width, newSize.height);
    }
    else if ([position  isEqualToString: @"center"])
    {
        cropRect= CGRectMake(((image.size.width/2) - (newSize.width/2)), ((image.size.height/2)-(newSize.height/2)), newSize.width, newSize.height);
    }
    else if ([position  isEqualToString: @"topright"])
    {
        cropRect= CGRectMake(image.size.width-newSize.width, 0, newSize.width, newSize.height);
    }
    else if ([position  isEqualToString: @"bottomleft"])
    {
        cropRect= CGRectMake(0, (image.size.height-newSize.width), newSize.width, newSize.height);
    }
    else if ([position  isEqualToString: @"bottomright"])
    {
        cropRect= CGRectMake(image.size.width-newSize.width, image.size.height-newSize.height, newSize.width, newSize.height);
    }
    else if ([position  isEqualToString: @"fittorect"])
    {
        // Use the helper label to determine the crop area
        
        CGRect captureFrame = CGRectMake((self.view.frame.size.width)*0.10, (self.view.frame.size.height)*0.20, (self.view.frame.size.width)*0.80, (self.view.frame.size.width)*0.80);
        
        CGPoint upleft = [self.view convertPoint:captureFrame.origin toView:nil];
        
        CGPoint downright = [self.view convertPoint:CGPointMake((captureFrame.origin.x+captureFrame.size.width), (captureFrame.origin.y+captureFrame.size.height)) toView:nil];
        
        CGPoint newOrigin = CGPointMake((image.size.width * (upleft.x/self.view.frame.size.width)), (image.size.height * (upleft.y/self.view.frame.size.height)));
        
        newSize = CGSizeMake((image.size.width * ((downright.x - upleft.x)/self.view.frame.size.width)), (image.size.height * ((downright.y - upleft.y)/self.view.frame.size.height)));
        
        cropRect = CGRectMake(newOrigin.x, newOrigin.y, newSize.width, newSize.height);
    }
    
    UIImage *normalizedImage = image;
    
    if (!image.imageOrientation == UIImageOrientationUp)
    {
        //Start a new context, with scale factor 0.0 so retina displays get high quality image
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        
        [image drawInRect:(CGRect){0, 0, image.size}];
        
        normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    // Create bitmap image from original image data, using rectangle to specify desired crop area
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([normalizedImage CGImage], cropRect);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    // Set maximun quiality in order to get the best possible image
    
    NSData *imageData = UIImageJPEGRepresentation(croppedImage , 1.0f);
    
    UIImage *processedImage = [UIImage imageWithData:imageData];
    
    return processedImage;
}

// Scale image to the desired resolution
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    double ratio;
    double delta;
    CGPoint offset;
    
    // Figure out if the picture is landscape or portrait, then calculate scale factor and offset
    if (image.size.width > image.size.height)
    {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
        
    }
    else
    {
        ratio = newSize.height / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    // OJO!!!!!! Esto nos interesará arreglarlo algún día para poder escalar imagenes
    // Con diferentes aspect ratios
    
    // Make the final clipping rect based on the calculated values
/*CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
*/
    CGRect clipRect = CGRectMake(0,0,
                                 newSize.width,
                                 newSize.height);

    
    //Start a new context, with scale factor 0.0 so retina displays get high quality image
    /*if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    }
    else*/
    {
        UIGraphicsBeginImageContext(newSize);
    }
    
    UIRectClip(clipRect);
    
    [image drawInRect:clipRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Set maximun quiality in order to get the best possible image
    NSData *imageData = UIImageJPEGRepresentation(newImage, 1.0f);
 
    UIImage *processedImage = [UIImage imageWithData:imageData];
    
    
    return processedImage;
}

// Perform identification itself
- (void)performIdentification
{
    // Once the capture manager gets the image, take it and prepare for identification
    [self getCapturedImage];
    
    // Once the image is prepared, upload it to the GS server
    [self uploadImage];
}

// Take and process the image captured by capture manager
- (void)getCapturedImage
{
    // Get image
    UIImage *CapturedImage = [[self captureManager] stillImage];
    
    // Crop it to select only the desired area
    //UIImage *croppedImage = [self cropImage:CapturedImage toSize:CGSizeMake(CapturedImage.size.width/1.5,CapturedImage.size.width/1.5) withPosition:@"fittorect"];
    
    // Scale it to the desired resolution
    float fW = CapturedImage.size.width;
    float fH = CapturedImage.size.height;
    
    float ffW = UPLOADED_IMAGE_MAX_DIMENSION;
    float ffH = UPLOADED_IMAGE_MAX_DIMENSION;
    
    if(fW > fH)
    {
        ffW = UPLOADED_IMAGE_MAX_DIMENSION;
        ffH = UPLOADED_IMAGE_MAX_DIMENSION * fH / fW;
    }
    else
    {
        ffH = UPLOADED_IMAGE_MAX_DIMENSION;
        ffW = UPLOADED_IMAGE_MAX_DIMENSION * fW / fH;
    }
    
    _identificationImage = [self scaleImage:CapturedImage toSize:CGSizeMake(ffW, ffH)];
    
    // Save it to camera roll
    UIImageWriteToSavedPhotosAlbum(_identificationImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// Check if saving an image to camera roll succeed
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    /*if (error != NULL)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Image couldn't be saved", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        
        [alertView show];
    }*/
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

// Upload image to the GS server
-(void) uploadImage
{
    if(bSendingImageForIdentification)
    {
        return;
    }
    
    // Check that there is actually an image to upload
    if (_identificationImage == nil)
    {
        // If there's no image to upload, cancel identification process

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_IMAGENOTCAPTURED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];

        [self stopActivityFeedback];
        
        [alertView show];
        
        bPerformingSearch = NO;
        bSendingImageForIdentification = NO;
        bGettingImageFromCameraRoll = NO;
        
        // Hide camera roll image
        [self hideCameraRollImage];

        return;
    }
    
    bSendingImageForIdentification = YES;
    
    // Update feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGIMG_ACTV_MSG_", nil)];

    // Post image to be identified
    NSArray * requestParameters = [NSArray arrayWithObject:_identificationImage];
    
    [self performRestGet:PERFORM_VISUAL_SEARCH withParamaters:requestParameters];
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    __block SearchQuery *searchQuery;
    
    __block NSString * notSuccessfulTerms = @"";
    NSMutableArray *foundResultsGroups = [[NSMutableArray alloc] init];
    NSMutableArray *foundResults = [[NSMutableArray alloc] init];
    NSMutableArray *successfulTerms = nil;
    
    switch (connection)
    {
         case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_VISUALRESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];

            [self stopActivityFeedback];
            
            [self startCapture];
            
            bPerformingSearch = NO;
            bSendingImageForIdentification = NO;
            bGettingImageFromCameraRoll = NO;
            
            // Hide camera roll image
            [self hideCameraRollImage];

            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            // Get the number of total results that were provided
            // and the string of terms that didn't provide any results
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if (searchQuery.numresults > 0)
            {
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if (!([group.idResultsGroup isEqualToString:@""]))
                            {
                                if(!([foundResultsGroups containsObject:group]))
                                {
                                    [foundResultsGroups addObject:group];
                                }
                            }
                        }
                    }
                }
                
                // Get the list of results that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.idGSBaseElement == nil))
                        {
                            if  (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([foundResults containsObject:result.idGSBaseElement]))
                                {
                                    [foundResults addObject:result.idGSBaseElement];
                                }
                            }
                        }
                    }
                }
                
                // Get the keywords that provided results
                for (Keyword *keyword in mappingResult)
                {
                    if([keyword isKindOfClass:[Keyword class]])
                    {
                        if (successfulTerms == nil)
                        {
                            successfulTerms = [[NSMutableArray alloc] init];
                        }
                        
                        if(!(keyword.name == nil))
                        {
                            if (!([keyword.name isEqualToString:@""]))
                            {
                                NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                                pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                                if (!([successfulTerms containsObject:pene]))
                                {
                                    // Add the term to the set of terms
                                    [successfulTerms addObject:pene];
                                }
                            }
                        }
                        
                    }
                }
                
                // Paramters for next VC (ResultsViewController)
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, successfulTerms, notSuccessfulTerms, nil];

                [self stopActivityFeedback];
                
                [self startCapture];

                if ([foundResults count] > 0)
                {
                    if(self.currentVisualSearchContext == FASHIONISTAPOSTS_VISUAL_SEARCH)
                    {
                        [self transitionToViewController:FASHIONISTAPOSTS_VC withParameters:parametersForNextVC];
                    }
                    else
                    {
                        [self transitionToViewController:SEARCH_VC withParameters:parametersForNextVC];
                    }
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                }
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }
            
            bPerformingSearch = NO;
            bSendingImageForIdentification = NO;
            bGettingImageFromCameraRoll = NO;
            
            // Hide camera roll image
            [self hideCameraRollImage];
            
            break;
        }
            
        default:
            break;
    }
}


// OVERRIDE: Rest answer not reached, to make sure that the captureManager is restarted
- (void)processRestConnection:(connectionType)connection WithErrorMessage:(NSArray *)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    [super processRestConnection:connection WithErrorMessage:errorMessage forOperation:operation];
    
    [self stopActivityFeedback];
    
    [self startCapture];
    
    bPerformingSearch = NO;
    bSendingImageForIdentification = NO;
    bGettingImageFromCameraRoll = NO;
    
    // Hide camera roll image
    [self hideCameraRollImage];
}


// OVERRIDE: Hint action
- (void)hintAction:(UIButton *)sender
{
    if (!([[self activityLabel] isHidden]))
    {
        return;
    }
    
    [super hintAction:sender];
}

// OVERRIDE: Main Menu button action
- (void)showMainMenu:(UIButton *)sender
{
    if (!([[self activityLabel] isHidden]))
    {
        return;
    }
    
    [super showMainMenu:sender];
}

/*
// Left action
- (void)leftAction:(UIButton *)sender
{
    if (!([[self activityLabel] isHidden]))
    {
        return;
    }

    //[super leftAction:sender];

    [self stopCapture];
    
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    
    bGettingImageFromCameraRoll = YES;
    
    [self presentViewController:imagePickerController animated:YES completion:NULL];
}

// OVERRIDE: Home action
- (void)homeAction:(UIButton *)sender
{
    if (!([[self activityLabel] isHidden]))
    {
        return;
    }
    
    [super homeAction:sender];
}
*/
// OVERRIDE: Right action
- (void)captureAction:(UIButton *)sender
{
    if (!([[self activityLabel] isHidden]))
    {
        return;
    }
    
    if(bSwipingRight)
    {
        return;
    }
    
    if(bPerformingSearch)
    {
        return;
    }
    
    bPerformingSearch = YES;
    
    // Capture the current image
    [[self captureManager] captureStillImage];
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_CAPTURING_ACTV_MSG_", nil)];
}

// OVERRIDE: Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    if (!([[self activityLabel] isHidden]))
    {
        return;
    }
    
    if(!(self.hintBackgroundView == nil))
    {
        if(!([self.hintBackgroundView isHidden]))
        {
            [self hintPrevAction:nil];
            
            return;
        }
    }
    
    if (self.fromViewController != nil)
    {
        bSwipingRight = YES;
        
        [self dismissViewController];
    }
}


#pragma mark - UIImagePickerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (outputImage == nil)
    {
        outputImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (outputImage)
    {
        // Prepare image for identification

        // Crop it to select only the desired area
        //UIImage *croppedImage = [self cropImage:outputImage toSize:CGSizeMake(outputImage.size.width/1.5,outputImage.size.width/1.5) withPosition:@"fittorect"];
        
        // Scale it to the desired resolution
        float fW = outputImage.size.width;
        float fH = outputImage.size.height;
        
        float ffW = UPLOADED_IMAGE_MAX_DIMENSION;
        float ffH = UPLOADED_IMAGE_MAX_DIMENSION;
        
        if(fW > fH)
        {
            ffW = UPLOADED_IMAGE_MAX_DIMENSION;
            ffH = UPLOADED_IMAGE_MAX_DIMENSION * fH / fW;
        }
        else
        {
            ffH = UPLOADED_IMAGE_MAX_DIMENSION;
            ffW = UPLOADED_IMAGE_MAX_DIMENSION * fW / fH;
        }
        
        _identificationImage = [self scaleImage:outputImage toSize:CGSizeMake(ffW, ffH)];
        
        // Show camera roll image
        [self showCameraRollImage];

        // Once the image is prepared, upload it to the GS server
        [self uploadImage];
    }
    else
    {
        bGettingImageFromCameraRoll = NO;
        
        // Hide camera roll image
        [self hideCameraRollImage];

        [self startCapture];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];

    bGettingImageFromCameraRoll = NO;
    
    // Hide camera roll image
    [self hideCameraRollImage];
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

@end

