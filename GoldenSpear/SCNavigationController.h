//
//  SCNavigationController.h
//  SnapInspectCamera
//
//  Created by Crane on 3/4/16.
//  Copyright © 2016 Osama Petran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDefines.h"

@protocol SCNavigationControllerDelegate;

@interface SCNavigationController : UINavigationController


- (void)showCameraWithParentController:(UIViewController*)parentController;

@property (nonatomic, assign) id <SCNavigationControllerDelegate> scNaigationDelegate;
@property int iParamID;
@property int iInsItemID;
@property int iInsID;
- (void)reportPostImage;
- (void)takeCamera:(UIImage*)image;
@end

@protocol SCNavigationControllerDelegate <NSObject>
@optional
- (BOOL)willDismissNavigationController:(SCNavigationController*)navigatonController;

- (void)didTakePicture:(SCNavigationController*)navigationController image:(UIImage*)image;

@end