//
//  BaseViewController+BottomControlsManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


// Frameworks
#import <Social/Social.h>
#import "SCNavigationController.h"

#import "BaseViewController.h"

@interface BaseViewController (BottomControlsManagement) <UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, SCNavigationControllerDelegate>

// Bottom controls management
@property UIButton *leftButton;
@property UIButton *middleLeftButton;
@property UIButton *middleRightButton;
@property UIButton *rightButton;
@property UIButton *homeButton;
@property UIImageView *notificationImage;

@property UIScrollView *bottomControlsView;
@property UIView *bottomBarView;

@property UIButton *searchBackgroundAdButton;

@property UIDocumentInteractionController * docController;
@property Share * currentSharedObject;
@property UIImage * currentPreviewImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomControlsHeightConstraint;

- (void)createBottomControls;
- (void)addExtraButtons;

- (void)setNavigationButtons;
- (void)bringBottomControlsToFront;
- (void)onTapBackgroundAdButton:(UIButton *)sender;
- (UIImage *)getScreenCapture;
- (void) socialShareActionWithShareObject: (Share *)sharedObject andPreviewImage:(UIImage *) previewImage;
- (void)hideHints:(UIButton *)sender;
- (void)selectTheButton:(UIButton*)sender;

- (void) performSocialShareWithCurrentInfo;
- (void)setupNotificationsLabel;
- (void)addExtraButton:(NSString*)iconName withHandler:(SEL)handler;
- (BOOL)shouldCreateBottomButtons;
- (BOOL)shouldCreateMenuButton;
- (BOOL)shouldCreateTopBar;
- (void)moveScrollBar;
- (BOOL)taggingViewController;
- (void)taggingCameraViewController;

-(void) afterSharedIn:(NSString *) sSocialNetwork;

@end
