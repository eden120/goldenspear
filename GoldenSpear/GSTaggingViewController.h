//
//  GSTaggingViewController.h
//  GoldenSpear
//
//  Created by Crane on 7/31/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FashionistaPostViewController.h"
#import "SearchBaseViewController.h"
#import "SCNavigationController.h"
#import "SCCaptureCameraController.h"
#import "GSTaggingLocationSearchViewController.h"

@interface GSTaggingViewController : FashionistaPostViewController <FashionistaPostDelegate, SearchBaseViewDelegate,LocationSearchtDelegate, SCCaptureCameraControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic)UIImage *tagImg;
@property (weak, nonatomic) IBOutlet UIImageView *tagImgView;
@property (weak, nonatomic) IBOutlet UIScrollView *btnScrollView;
- (IBAction)uploadAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ToolView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolViewBottomMargin;

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIScrollView *ImgViewScrollView;
@property (weak, nonatomic) IBOutlet UILabel *tagLab;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIView *drawView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainer;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCBackground;
@property (weak, nonatomic) IBOutlet UIView *productSearchToolView;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *userTagButton;
@property (weak, nonatomic) IBOutlet UIButton *productTagButton;
@property (weak, nonatomic) IBOutlet UIButton *addNewBtn;
@property (weak, nonatomic) IBOutlet UIButton *tagBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveTagBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextTagBtn;
@property (weak, nonatomic) IBOutlet UIView *tagBtnView;
@property (weak, nonatomic) IBOutlet UIButton *editTagBtn;
@property (weak, nonatomic) IBOutlet UIView *tagActionView;
@property (weak, nonatomic) IBOutlet UIView *commentActionView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIView *editToolView;
@property (weak, nonatomic) IBOutlet UIButton *editCancelbtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopMargin;


- (IBAction)seePostImageAction:(id)sender;

- (IBAction)cancelEditAction:(id)sender;
- (IBAction)submitEditAction:(id)sender;

- (IBAction)searchProduct:(id)sender;
- (IBAction)nextTagAction:(id)sender;
- (IBAction)saveTagAction:(id)sender;
- (IBAction)editTagAction:(id)sender;

- (IBAction)cancelAction:(id)sender;
- (IBAction)editAction:(id)sender;

- (IBAction)addTag:(id)sender;
- (IBAction)userAction:(id)sender;
- (IBAction)productAction:(id)sender;
- (IBAction)closeAction:(id)sender;
- (IBAction)undoAction:(id)sender;
- (IBAction)redoAction:(id)sender;
@end
