//
//  BlurOverlayView.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 12/08/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
//  BASED ON DLCImagePickerController: https://github.com/gobackspaces/DLCImagePickerController
//

#import <UIKit/UIKit.h>

@interface BlurOverlayView : UIView

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGPoint circleCenter;

@end
