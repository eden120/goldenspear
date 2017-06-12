//
//  SlideViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/3/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "SlideViewController.h"
#import "UIImageView+WebCache.h"
#import "FashionistaProfileViewController.h"
#import "ProductSheetViewController.h"

@interface SlideViewController()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet UIView *fullCaptionView;
@property (weak, nonatomic) IBOutlet UILabel *aheadLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aheadLabelHeightConstraint;

@end

@implementation SlideViewController {
    NSMutableArray *imageViews;
    NSInteger currentIndex;
    NSTimer *timer;
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    imageViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_images count]; i ++) {
        NSString *str = (NSString*)[_images objectAtIndex:i];
        if (str != nil) {
            UIImageView *view = [[UIImageView alloc] init];
            [view sd_setImageWithURL:[NSURL URLWithString:str]];
            view.frame = CGRectMake(0, 0, self.slideView.frame.size.width, self.slideView.frame.size.height);
            view.contentMode = UIViewContentModeScaleAspectFit;
            
            [imageViews addObject:view];
        }
    }
    
    UIImageView *firstView = (UIImageView*)[imageViews objectAtIndex:0];
    [self.slideView addSubview:firstView];

    _aheadLabel.text = _aheadStr;
    
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width, FLT_MAX);
    
    CGSize aheadLabelExpectedSize = [_aheadStr sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] constrainedToSize:maximumLabelSize lineBreakMode:_aheadLabel.lineBreakMode];
    
    _aheadLabelHeightConstraint.constant = aheadLabelExpectedSize.height;
    
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.slideView addGestureRecognizer:rightGesture];
    
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.slideView addGestureRecognizer:leftGesture];
    
    currentIndex = 0;
    
    _fullCaptionView.clipsToBounds = YES;
    _fullCaptionView.layer.cornerRadius = 10;
    
    CGRect frame = _fullCaptionView.frame;
    frame.origin.x = 20;
    _fullCaptionView.frame = frame;
    
    if (_aheadStr == nil || [_aheadStr isEqualToString:@""]) {
        _fullCaptionView.hidden = YES;
    }
    else {
        _fullCaptionView.hidden = NO;
    }
    
    [self startTimer];
}

- (IBAction)hideFullCaptionView:(id)sender {
    CGRect frame = _fullCaptionView.frame;
    frame.origin.x = self.view.frame.size.width;
    
    [UIView animateWithDuration:0.6
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         _fullCaptionView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         _fullCaptionView.hidden = YES;
                     }];
    _isHideFullCaption = YES;
}
- (IBAction)onTapClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onSwipeGesture:(UISwipeGestureRecognizer*)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@" *** Swipe Left ***");
        if (currentIndex < [imageViews count] - 1) {
            [self slideImageView:currentIndex + 1 isLeft:YES];
        }
        else if (currentIndex == [imageViews count] - 1) {
            [self slideImageView:0 isLeft:YES];
        }
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@" *** Swipe Right *** ");
        if (currentIndex > 0) {
            [self slideImageView:currentIndex - 1 isLeft:NO];
        }
        else if (currentIndex == 0) {
            NSInteger index = [imageViews count] - 1;
            [self slideImageView:index isLeft:NO];
        }
    }
}

-(void)slideImageView:(NSInteger)index isLeft:(BOOL)isLeft{
    UIImageView *fromView = (UIImageView*)[imageViews objectAtIndex:currentIndex];
    UIImageView *toView = (UIImageView*)[imageViews objectAtIndex:index];
    
    if (isLeft) {
        CGRect fromFrame = fromView.frame;
        CGRect toFrame = toView.frame;
        
        toFrame.origin.x = toView.frame.size.width;
        toView.frame = toFrame;
        toFrame.origin.x = 0;
        fromFrame.origin.x = -fromView.frame.size.width;
        
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             [fromView setFrame:fromFrame];
                             [toView setFrame:toFrame];
                         }
                         completion:^(BOOL finished){
                         }];
        [self.slideView addSubview:toView];
    }
    else {
        CGRect fromFrame = fromView.frame;
        CGRect toFrame = toView.frame;
        
        toFrame.origin.x = -toView.frame.size.width;
        toView.frame = toFrame;
        toFrame.origin.x = 0;
        fromFrame.origin.x = fromView.frame.size.width;
        
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             [fromView setFrame:fromFrame];
                             [toView setFrame:toFrame];
                         }
                         completion:^(BOOL finished){
                         }];
        [self.slideView addSubview:toView];
    }
    
    currentIndex = index;
}

-(void)stopTimer {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}

-(void)startTimer {
    [self stopTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideTopView) userInfo:nil repeats:NO];
}
-(void)hideTopView {
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.topView setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self stopTimer];
                     }];
}

-(void)showTopView {
    
    self.topView.hidden = NO;
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.topView setAlpha:1];
                     }
                     completion:^(BOOL finished){
                         [self startTimer];
                     }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    if (location.y < 50) {
        [self showTopView];
    }
}

- (IBAction)pinchImage:(UIPinchGestureRecognizer *)sender {
    NSLog(@"Pinch Image");
    
    NYTExamplePhotoProd *selectedPhoto = nil;
    
    NSMutableArray *photos = [NSMutableArray new];
    
    for (int i = 0; i < [_images count]; i ++) {
        NYTExamplePhotoProd *photo = [[NYTExamplePhotoProd alloc] init];
        NSString *str = (NSString*)[_images objectAtIndex:i];
        photo.image = [UIImage cachedImageWithURL:str];
        
        if (currentIndex == i) {
            selectedPhoto = photo;
        }
        
        [photos addObject:photo];
    }
    
    if(selectedPhoto)
    {
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos initialPhoto:selectedPhoto];
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
    else
    {
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
}


@end
