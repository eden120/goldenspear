//
//  CustomCameraViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 12/08/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
//  BASED ON DLCImagePickerController: https://github.com/gobackspaces/DLCImagePickerController
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "BlurOverlayView.h"
#import "FXBlurView.h"


#pragma mark - ControlPointView interface


@interface ControlPointView : UIView

@property (nonatomic, retain) UIColor* color;

@end


#pragma mark - ShadeView interface


@interface ShadeView : UIView

@property (nonatomic, retain) UIColor* cropBorderColor;
@property (nonatomic) CGRect cropArea;
@property (nonatomic) CGFloat shadeAlpha;
@property (nonatomic,strong) UIImage * blurredImage;
//@property (nonatomic, strong) UIImageView *blurredImageView;
//@property (nonatomic, weak) UIImageView * normalImageView;

@end

CGRect SquareCGRectAtCenter(CGFloat centerX, CGFloat centerY, CGFloat size);

UIView* dragView;

typedef struct
{
    CGPoint dragStart;
    CGPoint topLeftCenter;
    CGPoint bottomLeftCenter;
    CGPoint bottomRightCenter;
    CGPoint topRightCenter;
    CGPoint clearAreaCenter;
    
} DragPoint;

// Used when working with multiple dragPoints
typedef struct
{
    DragPoint mainPoint;
    DragPoint optionalPoint;
    NSUInteger lastCount;
    
} MultiDragPoint;


#pragma mark - ImageCropView interface


@interface ImageCropView : GPUImageView

- (void)initViews;
- (id)initWithFrame:(CGRect)frame blurOn:(BOOL)blurOn allowResize:(BOOL)allowResize withInitialClearAreaSize:(CGSize)initialClearArea;
- (ControlPointView*)createControlPointAt:(CGRect)frame;
- (CGRect)clearAreaFromControlPoints;
- (void)handleDrag:(UIPanGestureRecognizer*)recognizer;
- (void)InitAndSetImage:(UIImage *)image;

@property (nonatomic) CGFloat controlPointSize;
@property (nonatomic) CGSize initialClearAreaSize;
@property (strong, nonatomic) ControlPointView* topLeftPoint;
@property (strong, nonatomic) ControlPointView* bottomLeftPoint;
@property (strong, nonatomic) ControlPointView* bottomRightPoint;
@property (strong, nonatomic) ControlPointView* topRightPoint;
@property (strong, nonatomic) ControlPointView* initialTopLeftPoint;
@property (strong, nonatomic) ControlPointView* initialBottomLeftPoint;
@property (strong, nonatomic) ControlPointView* initialBottomRightPoint;
@property (strong, nonatomic) ControlPointView* initialTopRightPoint;
@property (strong, nonatomic) NSArray *PointsArray;
@property (strong, nonatomic) UIView* cropAreaView;
@property (strong, nonatomic) UIImage* image;
@property (nonatomic) CGRect cropAreaInView;
@property (nonatomic) CGRect cropAreaInImage;
- (CGRect)initialCropAreaInImage;

@property (nonatomic) CGFloat imageScale;
@property (nonatomic) CGFloat maskAlpha;
@property (strong, nonatomic) UIColor* controlColor;
@property (strong, nonatomic) ShadeView* shadeView;
@property (nonatomic) BOOL blurred;
@property (nonatomic) BOOL allowResizing;

@property (strong, nonatomic) UIImageView* imageView;
@property (nonatomic) CGRect imageFrameInView;
@property (nonatomic) DragPoint dragPoint;
@property (nonatomic) MultiDragPoint multiDragPoint;
@property (strong, nonatomic) UIView* dragViewOne;
@property (strong, nonatomic) UIView* dragViewTwo;

@end


#pragma mark CustomCameraViewController interface


@class CustomCameraViewController;


@protocol CustomCameraViewControllerDelegate <NSObject>

@optional

- (void)imagePickerController:(CustomCameraViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(CustomCameraViewController *)picker;

@end


@interface CustomCameraViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property UIImage * editingImage;

@property GPUImageVideoCamera *videoCamera;
//@property GPUImageOutput<GPUImageInput> *filter;
@property GPUImageMovieWriter *movieWriter;

@property (nonatomic, weak) IBOutlet ImageCropView *imageView;
@property (nonatomic, weak) id <CustomCameraViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *photoCaptureButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *videoCaptureButton;

@property (nonatomic, weak) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *blurToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *filtersToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *libraryToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *flashToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *retakeButton;

@property (nonatomic, weak) IBOutlet UIScrollView *filterScrollView;
@property (nonatomic, weak) IBOutlet UIImageView *filtersBackgroundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterScrollViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filtersBackgroundImageViewBottomConstraint;
@property (nonatomic, weak) IBOutlet UIView *photoBar;
@property (nonatomic, weak) IBOutlet UIView *topBar;
@property (nonatomic, strong) BlurOverlayView *blurOverlayView;
@property (nonatomic, strong) UIImageView *focusView;

@property (nonatomic, assign) CGFloat outputJPEGQuality;
@property (nonatomic, assign) CGSize requestedImageSize;

@property (nonatomic) BOOL blurredBackground;
@property (nonatomic) CGSize initialClearAreaSize;
@property (nonatomic) BOOL allowResizing;
@property (nonatomic, retain) ImageCropView* cropView;

@property (nonatomic) BOOL isDirty;

@end


@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;

@end

@interface UIImage (scaleToSizeKeepAspect)

- (UIImage *)scaleToSizeKeepAspect:(CGSize)size;

@end

