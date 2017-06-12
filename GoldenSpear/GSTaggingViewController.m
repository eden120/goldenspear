//
//  GSTaggingViewController.m
//  GoldenSpear
//
//  Created by Crane on 7/31/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSTaggingViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "GSTaggingScrollBtnView.h"
#import "GSTaggingUserSearchViewController.h"
#import "TagView.h"
#import "TagProductView.h"
#import "SCCaptureCameraController.h"
#import "BBXView.h"

#define LIMIT_WIDTH 150

enum TaggingStatus{
    TAG_ADD = 1,
    TAG_MOVE,
    TAG_DELETE
};

@interface GSTaggingViewController ()

@end

@implementation GSTaggingViewController {
    NSArray *btnArray;
    NSArray *btnImgArray;
    NSMutableArray *ToolBtnArray;
    NSArray *btnInactImgArray;
    UIButton *currToolBtn;
    UIButton *currTagBtn;
    BOOL isUserToggled;
    BOOL isProuctToggled;
    BOOL isCommentToggled;
    BOOL isLocationToggled;
    CGPoint currPoint;
    NSMutableArray *userTaggingArray;
    NSMutableArray *redoUserArray;
    NSMutableArray *undoUserArray;
    
    NSMutableArray *productTaggingArray;
    NSMutableArray *redoProductArray;
    NSMutableArray *undoProductArray;
    NSMutableArray *undoCommentArry;
    NSMutableArray *redoCommentArry;
    NSMutableArray *undoLocationArry;
    NSMutableArray *redoLocationArry;
    NSMutableArray *colorArray;
    FashionistaPostViewController *fPostViewController;
    SearchBaseViewController *searchBaseVC;
    BOOL availableNextTag;
    UIView *productTagView;
    //touches
    NSDictionary *touchedDic;
    TagView *touchedView;
    CGRect previousRect;
    CGFloat touchOffSet;
    UIView *touchedBoundingView;
    CGPoint beginPoint;
    CGPoint fixedPoint;
    bool isMoved;
    bool isAdded;
    CGFloat offX;
    CGFloat offY;
    bool addedWardrobe;
    bool removeUndoAct;
    CGFloat ToolViewFirstPointY;
    CGFloat ToolViewLastPointY;
    //Product Tag
    TagProductView *activeProductView;
    TagView *activeUserView;
    bool savedTag; //saveTag = true, edittag = false;
    GSBaseElement *selectedProduct;
    NSString *selectedWardrobeID;
    NSString *commentStr;
    NSString *locationStr;
    POI *selectedPoi;
    BOOL showCam;
    SCCaptureCameraController *conCam;
    BOOL isPosting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    super.fashionistaPostDelegate = self;
    availableNextTag = YES;
    addedWardrobe = NO;
    showCam = NO;
    isPosting = NO;
    
    btnArray = @[@"LAYOUT", @"SWATCHES", @"EDIT IMAGE", @"TAG", @"COMMENT", @"LOCATION"];
    btnInactImgArray = @[@"LayoutInact", @"SwatchesInact", @"EditImageInact", @"TagInact", @"ChatInact", @"LocationInact"];
    btnImgArray = @[@"Layout", @"Swatches", @"EditImage", @"Tag", @"Chat", @"Location"];
    
    ToolBtnArray = [[NSMutableArray alloc] init];
    userTaggingArray = [[NSMutableArray alloc] init];
    undoUserArray = [[NSMutableArray alloc] init];
    redoUserArray = [[NSMutableArray alloc] init];
    
    productTaggingArray = [[NSMutableArray alloc] init];
    redoProductArray = [[NSMutableArray alloc] init];
    undoProductArray = [[NSMutableArray alloc] init];
    
    undoCommentArry = [[NSMutableArray alloc]init];
    redoCommentArry = [[NSMutableArray alloc]init];
    
    undoLocationArry = [[NSMutableArray alloc]init];
    redoLocationArry = [[NSMutableArray alloc]init];
    
    colorArray = [[NSMutableArray alloc] initWithObjects:[UIColor blueColor], [UIColor yellowColor], [UIColor greenColor], [UIColor redColor], [UIColor purpleColor], [UIColor orangeColor], nil];
    
    touchOffSet = 10;
    
    [self initActivityFeedback];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityLabel];
    [self hideTopBar];
    
    self.tagLab.hidden = YES;
    self.actionView.hidden = YES;
    
    [self setBtnOnScrollView];
    _searchBtn.layer.borderColor = [UIColor blackColor].CGColor;
    _searchBtn.layer.borderWidth = 1.0f;
    _addNewBtn.layer.borderColor = [UIColor blackColor].CGColor;
    _addNewBtn.layer.borderWidth = 1.0f;
    _tagBtn.enabled = NO;

    _editCancelbtn.layer.borderColor = [UIColor blackColor].CGColor;
    _editCancelbtn.layer.borderWidth = 1.0f;
    _textView.delegate = self;
    [_textView setEditable:NO];
    
    CGRect scrRect = [[UIScreen mainScreen]bounds];
    
    [self getCurrentLocation];
    
    ToolViewFirstPointY = scrRect.size.height - _ToolView.frame.size.height - 60;
    ToolViewLastPointY = scrRect.size.height - 60;
    NSLog(@"toolviewfirstPoint %f", ToolViewFirstPointY);
    NSLog(@"toolviewlastPoint %f", ToolViewLastPointY);
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
//    singleTap.numberOfTapsRequired = 1;
//    [self.tagImgView setUserInteractionEnabled:YES];
//    [self.tagImgView addGestureRecognizer:singleTap];

    
    commentStr = @"";
    self.tagImg = nil;
 }

- (void) AddUserTagReceiver:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"AddUserTagNotification"]) {
        [self addUserTag];
    }
}



-(void)tapDetected:(CGPoint)point {
    if (!isUserToggled) return;
    
    CGPoint touchPoint = point;
    currPoint = touchPoint;
    NSLog(@"single Tap on imageview   %f -----  %f", touchPoint.x, touchPoint.y);
    
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    GSTaggingUserSearchViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(TAGGINGUSERSEARCH_VC) stringValue]];
    
    [self prepareViewController:nextViewController withParameters:nil];
    [nextViewController setSearchContext:FASHIONISTAS_SEARCH];
    nextViewController.userListMode = SUGGESTED;
    [self showViewControllerModal:nextViewController];
    [self setTitleForModal:@"TAGGING USERS"];
}

- (void)viewWillAppear:(BOOL)animated
{
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AddUserTagReceiver:)
                                                 name:@"AddUserTagNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FailedProductTagReceiver:)
                                                 name:@"FailedItemToWardrobeNotification"
                                               object:nil];

}

- (void) FailedProductTagReceiver:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"FailedItemToWardrobeNotification"]) {
        [self stopActivityFeedback];
        if (isPosting) {
            isPosting = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.taggingCameraImage != nil) {
        self.tagImgView.image = appDelegate.taggingCameraImage;
        [self uploadImageFashionstaContent:appDelegate.taggingCameraImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddUserTagNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FailedItemToWardrobeNotification" object:nil];

}

- (void)didTakePicture:(UIImage *)chosenImg {
    self.tagImg = chosenImg;
    
    [self uploadImageFashionstaContent:chosenImg];
    

}

- (void)addUserTag {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"UsernameKey"];
    NSString *userID = [defaults objectForKey:@"UserIDKey"];
    if (username != nil && ![username isEqualToString:@""] && userID != nil) {
        for (NSDictionary *dic in userTaggingArray) {
            NSString *name = dic[@"UserName"];
            if ([username isEqualToString:name])
                return;
        }
        
        TagView *tagView = [[[NSBundle mainBundle] loadNibNamed:@"TagView" owner:self options:nil] objectAtIndex:0];
        
        CGFloat width =  [username sizeWithFont:[UIFont fontWithName:@"AvantGarde-Book" size:10 ]].width;
        
        tagView.labWidth.constant = width;
        tagView.nameLab.text = username;
        CGFloat tagViewWidth = 25 + width;
        CGFloat tagViewHeight = 40;
        
        NSLog(@"point %f    %f", currPoint.x, currPoint.y);
        CGFloat px = (currPoint.x + tagViewWidth) > self.drawView.frame.size.width ? currPoint.x - tagViewWidth : currPoint.x;
        CGFloat py = (currPoint.y + tagViewHeight) > self.drawView.frame.size.height ? currPoint.x - tagViewHeight : currPoint.y;
        
        tagView.frame = CGRectMake(px, py, tagViewWidth, tagViewHeight);
        [self.drawView addSubview:tagView];
        
        [self addUserTagIntoArray:userID UserName:username TaggingView:tagView undoFlag:YES];
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser:)];
//        singleTap.numberOfTapsRequired = 1;
//        [tagView setUserInteractionEnabled:YES];
//        [tagView addGestureRecognizer:singleTap];

        tagView.btnView.hidden = YES;
    }
    
    [defaults setObject:@"" forKey:@"UsernameKey"];
    [defaults setObject:@"" forKey:@"UserIDKey"];
    [defaults synchronize];

}

//- (void) tapUser: (UIGestureRecognizer *) gesture {
- (void)tapUser:(TagView*)tagView {
    if (activeUserView != nil) {
        activeUserView.btnView.hidden = YES;
    }
    
    //if (activeUserView == (TagView*)gesture.view) {
    if (activeUserView == tagView) {
        for (NSDictionary *dic in userTaggingArray) {
            TagView *view = dic[@"TagView"];
            NSString *id = dic[@"UserID"];
            NSLog(@"userid --- > %@", id);
            if (view == activeUserView) {
//                NSArray *parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */id, [NSNumber numberWithBool:NO],nil];
//                
//                [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
                break;
            }
        }
        return;
    }
    
    activeUserView = nil;
    activeUserView = tagView;
//    activeUserView = (TagView*)gesture.view;
    activeUserView.btnView.hidden = NO;
//    [activeUserView.delBtn addTarget:self action:@selector(deleteUserTag:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)deleteUserTag:(UIButton *)button {
    for (NSDictionary *dic in userTaggingArray) {
        TagView *view = dic[@"TagView"];
        
        if (view == activeUserView) {
            activeUserView.btnView.hidden = YES;
            
            NSString *userID = [dic objectForKey:@"UserID"];
            NSString *username = [dic objectForKey:@"UserName"];
            
            [self addUserTagIntoUndoArray:userID UserName:username TaggingView:touchedView previousFrame:previousRect status:TAG_DELETE];
            [activeUserView removeFromSuperview];
            [activeUserView setNeedsDisplay];
            [userTaggingArray removeObject:dic];
            activeUserView = nil;
            break;
        }
    }
    
}

- (void)addUserTagIntoArray:(NSString*)userID UserName:(NSString *)username TaggingView:(TagView*)TagView undoFlag:(BOOL)flag {
    NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                         userID, @"UserID",
                         username, @"UserName",
                         TagView, @"TagView",
                         nil];
    
    //On initialization
    
    [userTaggingArray addObject:aDic];
    if (flag)
        [self addUserTagIntoUndoArray:userID UserName:username TaggingView:TagView previousFrame:TagView.frame status:TAG_ADD];
}

- (NSDictionary *)createProductTagDictionary:gsItem BBX:(UIView*)view TagView:(UIView*)tagView {
    NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                         gsItem, @"GSBaseElement",
                         view, @"BoundingBox",
                         tagView, @"TagView",
                         nil];
    return  aDic;
}
- (void)addProductTagIntoArray:gsItem BBX:(UIView*)view TagView:(UIView*)tagView undoFlag:(BOOL)flag {
    NSDictionary *aDic = [self createProductTagDictionary:gsItem BBX:view TagView:tagView];
    
    [productTaggingArray addObject:aDic];
    availableNextTag = NO;
    if (flag)
        [self addProductTagIntoUndoArray:selectedProduct BBX:view TagView:nil previousFrame:view.frame status:TAG_ADD];
    
}

- (void)addProductTagIntoUndoArray:(GSBaseElement*)gsElement BBX:(UIView*)view TagView:(UIView*)tagView previousFrame:(CGRect)preRect status:(NSInteger)status{
    NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                         gsElement, @"GSBaseElement",
                         view, @"BoundingBox",
                         [NSValue valueWithCGRect:preRect], @"UndoRect",
                         [NSNumber numberWithInteger:status], @"TagStatus",
                         tagView, @"TagView",
                         nil];
    
    //On initialization
    
    [undoProductArray addObject:aDic];
}

- (void)addProductTagIntoRedoArray:(GSBaseElement*)gsElement BBX:(UIView*)view TagView:(UIView*)tagView previousFrame:(CGRect)preRect status:(NSInteger)status{
    NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                         gsElement, @"GSBaseElement",
                         view, @"BoundingBox",
                         [NSValue valueWithCGRect:preRect], @"UndoRect",
                         [NSNumber numberWithInteger:status], @"TagStatus",
                         tagView, @"TagView",
                         nil];
    
    //On initialization
    
    [redoProductArray addObject:aDic];
}

- (void)addUserTagIntoUndoArray:(NSString*)userID UserName:(NSString *)username
                    TaggingView:(TagView*)TagView previousFrame:(CGRect)preRect status:(NSInteger)status{
    NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                         userID, @"UserID",
                         username, @"UserName",
                         TagView, @"TagView",
                         [NSValue valueWithCGRect:preRect], @"UndoRect",
                         [NSNumber numberWithInteger:status], @"TagStatus",
                         nil];
    
    //On initialization
    
    [undoUserArray addObject:aDic];
    NSLog(@"undo array %@", undoUserArray);
}

- (void)addUserTagIntoRedoArray:(NSString*)userID UserName:(NSString *)username
                    TaggingView:(TagView*)TagView previousFrame:(CGRect)preRect status:(NSInteger)status{
    NSDictionary *aDic= [NSDictionary dictionaryWithObjectsAndKeys:
                         userID, @"UserID",
                         username, @"UserName",
                         TagView, @"TagView",
                         [NSValue valueWithCGRect:preRect], @"UndoRect",
                         [NSNumber numberWithInteger:status], @"TagStatus",
                         nil];
    
    //On initialization
    
    [redoUserArray addObject:aDic];
}


- (void)setBtnOnScrollView
{
    CGRect scrRect = [[UIScreen mainScreen]bounds];

    CGFloat space = CGRectGetWidth(scrRect)/ (btnArray.count - 1);
    self.btnScrollView.contentSize = CGSizeMake(space * (btnArray.count + 2), CGRectGetHeight(_btnScrollView.bounds));
    self.btnScrollView.contentOffset = CGPointMake(0, 0);
    self.btnScrollView.delaysContentTouches = NO;
    
    int idx = 0;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, space * (btnArray.count + 2), CGRectGetHeight(_btnScrollView.bounds))];
    [self.btnScrollView addSubview:view];
    
    for (idx = 0; idx < btnArray.count; idx++) {
        GSTaggingScrollBtnView *btnView =
        [[[NSBundle mainBundle] loadNibNamed:@"GSTaggingScrollBtnView" owner:self options:nil] objectAtIndex:0];

        NSString *str = [btnArray objectAtIndex:idx];
        NSString *imgStr = [btnInactImgArray objectAtIndex:idx];
        [btnView.tagBtn setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        [btnView.tagBtn setTitle:str forState:UIControlStateNormal];
        [btnView.tagBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] forState:UIControlStateNormal];

        btnView.tagBtn.tag = idx;
        [btnView.tagBtn addTarget:self action:@selector(toolBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [ToolBtnArray addObject:btnView.tagBtn];
        btnView.frame = CGRectMake(space * idx, 0, 60, CGRectGetHeight(self.btnScrollView.bounds));
        [view addSubview:btnView];
    }
}

- (void)toolBtnAction:(UIButton*)sender
{
    if (currToolBtn != nil) {
        [currToolBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] forState:UIControlStateNormal];
    }
    currToolBtn = sender;
     [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.tagBtnView.hidden = YES;

    NSLog(@"button clicked");
    if (sender.tag == 3) { //People, Product Tag
        _titleLab.text = NSLocalizedString(@"_TAG_TITLE_", nil);
        _tagActionView.hidden = NO;
        _commentActionView.hidden = YES;
        self.btnScrollView.contentOffset = CGPointMake(0, 0);
        self.actionView.hidden = NO;
        
        [_userTagButton setImage:[UIImage imageNamed:@"UserTagInact"] forState:UIControlStateNormal];
        [_productTagButton setImage:[UIImage imageNamed:@"ProductTagInact"] forState:UIControlStateNormal];
        [currTagBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] forState:UIControlStateNormal];
        currTagBtn = nil;
        isUserToggled = NO;
        isProuctToggled = NO;
        isCommentToggled = NO;
        isLocationToggled = NO;
        availableNextTag = YES;
    } else if(sender.tag == 4) {  //comment
         _titleLab.text = NSLocalizedString(@"_TAG_COMMENT_TITLE", nil);
        [_editBtn setTitle:NSLocalizedString(@"_TAG_EDIT_COMMENT_BTN_", nil) forState:UIControlStateNormal];
        _tagActionView.hidden = YES;
         _commentActionView.hidden = NO;
        isUserToggled = NO;
        isProuctToggled = NO;
        isCommentToggled = YES;
        isLocationToggled = NO;
        
        CGRect scrRect = [[UIScreen mainScreen]bounds];
        
        CGFloat space = CGRectGetWidth(scrRect)/ (btnArray.count - 1);
        self.btnScrollView.contentOffset = CGPointMake(space , 0);
        [self initalizeForTaggingComment];
    }
    else if(sender.tag == 5) {  //location
         _titleLab.text = NSLocalizedString(@"_TAG_LOCATION_TITLE", nil);
        [_editBtn setTitle:NSLocalizedString(@"_TAG_EDIT_LOCATION_BTN_", nil) forState:UIControlStateNormal];

        _tagActionView.hidden = YES;
        _commentActionView.hidden = NO;
        isUserToggled = NO;
        isProuctToggled = NO;
        isCommentToggled = NO;
        isLocationToggled = YES;
        
        CGRect scrRect = [[UIScreen mainScreen]bounds];
        
        CGFloat space = CGRectGetWidth(scrRect)/ (btnArray.count - 1);
        self.btnScrollView.contentOffset = CGPointMake(space , 0);
        [self initializeLocationTagging];
    }
    else {
        self.btnScrollView.contentOffset = CGPointMake(0, 0);
        self.actionView.hidden = YES;
        self.tagLab.hidden = YES;
    }
    
    for (int i = 0; i < ToolBtnArray.count; i++) {
        UIButton *btn = [ToolBtnArray objectAtIndex:i];
        if (i == sender.tag) {
            [btn setImage:[UIImage imageNamed:[btnImgArray objectAtIndex:i]] forState:UIControlStateNormal];
        } else {
            [btn setImage:[UIImage imageNamed:[btnInactImgArray objectAtIndex:i]] forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldCreateBottomButtons
{
    return YES;
}
#pragma mark - Touch Methods

float beginToolViewPositionY;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchedDic = nil;
    touchedView = nil;
    touchedBoundingView = nil;
    isMoved = false;
    isAdded = false;
    beginPoint = CGPointZero;
    beginToolViewPositionY = 0;
    
    UITouch *touch = [touches anyObject];
  
    
     CGPoint selfLocation = [touch locationInView:self.view];
    
    if (selfLocation.y > ToolViewFirstPointY && selfLocation.y < ToolViewLastPointY && selfLocation.y > _ToolView.frame.origin.y) {
        beginToolViewPositionY = selfLocation.y;
        return;
    }
    
    CGPoint lastPoint = [touch locationInView:self.drawView];
    
    if (isUserToggled) {
        if (lastPoint.y > _ToolView.frame.origin.y ||
            lastPoint.y < 0) return;

        for(NSDictionary *dic in userTaggingArray) {
            TagView *tv = [dic objectForKey:@"TagView"];
            
            NSLog(@"tab label : %@", tv.nameLab.text);
            NSLog(@"  orginx   %f", tv.frame.origin.x);
            NSLog(@"  orginy   %f", tv.frame.origin.y);
            
            if ((tv.frame.origin.x + tv.frame.size.width + touchOffSet >= lastPoint.x && lastPoint.x >= tv.frame.origin.x - touchOffSet) &&
                (tv.frame.origin.y + tv.frame.size.height + touchOffSet >= lastPoint.y && lastPoint.y >= tv.frame.origin.y - touchOffSet)) {
                touchedView = tv;
                touchedDic = dic;
                previousRect = tv.frame;
                offX = tv.frame.origin.x - lastPoint.x;
                offY = tv.frame.origin.y - lastPoint.y;
                break;
            }
         }

        if (touchedView == nil) {
            //Add Tag
            [self tapDetected:lastPoint];
        }
    } else if (isProuctToggled) {
        if (lastPoint.y > _ToolView.frame.origin.y ||
            lastPoint.y < 0) return;

        beginPoint = lastPoint;

        if (!savedTag) {
            fixedPoint = CGPointZero;
            
            UIView *tmpView = nil;
            NSDictionary *tmpDic  = nil;
            if (!availableNextTag) {
                for (NSDictionary *pDic in productTaggingArray) {
                    UIView *view = [pDic objectForKey:@"BoundingBox"];
                    NSLog(@"  orginx   %f", view.frame.origin.x);
                    NSLog(@"  orginy   %f", view.frame.origin.y);
                    
                    if (fabs(view.frame.origin.x - lastPoint.x) < 2 * touchOffSet && fabs(view.frame.origin.y - lastPoint.y) < 2 * touchOffSet) {
                        fixedPoint = CGPointMake(view.frame.origin.x + view.frame.size.width, view.frame.origin.y + view.frame.size.height);
                        touchedBoundingView = view;
                        touchedDic = pDic;
                        previousRect = view.frame;
                        break;
                    } else if (fabs(view.frame.origin.x + view.frame.size.width - lastPoint.x) < 2 * touchOffSet && fabs(view.frame.origin.y + view.frame.size.height - lastPoint.y) < 2 * touchOffSet) {
                        
                        fixedPoint = CGPointMake(view.frame.origin.x, view.frame.origin.y);
                        touchedBoundingView = view;
                        touchedDic = pDic;
                        previousRect = view.frame;
                        break;
                    } else if (fabs(view.frame.origin.x + view.frame.size.width - lastPoint.x) < 2 * touchOffSet && fabs(view.frame.origin.y - lastPoint.y) < 2 * touchOffSet) {
                        
                        fixedPoint = CGPointMake(view.frame.origin.x , view.frame.origin.y + view.frame.size.height);
                        touchedBoundingView = view;
                        touchedDic = pDic;
                        previousRect = view.frame;
                        break;
                    } else if (fabs(view.frame.origin.x - lastPoint.x) < 2 * touchOffSet && fabs(view.frame.origin.y + view.frame.size.height - lastPoint.y) < 2 * touchOffSet) {
                        
                        fixedPoint = CGPointMake(view.frame.origin.x + view.frame.size.width, view.frame.origin.y);
                        touchedBoundingView = view;
                        touchedDic = pDic;
                        previousRect = view.frame;
                        break;
                    }
                    
                    if ((view.frame.origin.x + view.frame.size.width + touchOffSet >= lastPoint.x && lastPoint.x >= view.frame.origin.x - touchOffSet) &&
                        (view.frame.origin.y + view.frame.size.height + touchOffSet >= lastPoint.y && lastPoint.y >= view.frame.origin.y - touchOffSet)) {
                        if (tmpView == nil) {
                            tmpView = view;
                            tmpDic = pDic;
                            touchedBoundingView = tmpView;
                            touchedDic = tmpDic;
                            previousRect = tmpView.frame;
                            isMoved = YES;
                            offX = touchedBoundingView.frame.origin.x - beginPoint.x;
                            offY = touchedBoundingView.frame.origin.y - beginPoint.y;
                            previousRect = tmpView.frame;
                        } else if(tmpView.frame.size.width > view.frame.size.width && tmpView.frame.size.height > view.frame.size.height) {
                            tmpView = view;
                            tmpDic = pDic;
                            touchedBoundingView = tmpView;
                            touchedDic = tmpDic;
                            previousRect = tmpView.frame;
                            isMoved = YES;
                            offX = touchedBoundingView.frame.origin.x - beginPoint.x;
                            offY = touchedBoundingView.frame.origin.y - beginPoint.y;
                            previousRect = tmpView.frame;
                        }
                        
                    }
                    
                }
            }
        } else {
            for(NSDictionary *dic in productTaggingArray) {
                UIView *tv = [dic objectForKey:@"TagView"];
                
                if ((tv.frame.origin.x + tv.frame.size.width + touchOffSet >= lastPoint.x && lastPoint.x >= tv.frame.origin.x - touchOffSet) &&
                    (tv.frame.origin.y + tv.frame.size.height + touchOffSet >= lastPoint.y && lastPoint.y >= tv.frame.origin.y - touchOffSet)) {
                    touchedBoundingView = tv;
                    touchedDic = dic;
                    previousRect = tv.frame;
                    offX = tv.frame.origin.x - lastPoint.x;
                    offY = tv.frame.origin.y - lastPoint.y;
                    break;
                }
            }
        }
       
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    
    CGPoint selfLocation = [touch locationInView:self.view];
    if (selfLocation.y > ToolViewFirstPointY && selfLocation.y < ToolViewLastPointY && selfLocation.y > _ToolView.frame.origin.y) {
        CGFloat movingPoint = beginToolViewPositionY - selfLocation.y;
        CGFloat bottomMargin = self.toolViewBottomMargin.constant + movingPoint;
        if (bottomMargin < 50 && bottomMargin > -1 * (_ToolView.frame.size.height)) {
            self.toolViewBottomMargin.constant = 50 + movingPoint;
        }
        return;
    }
    
    // add the current point to the path
    CGPoint currentLocation = [touch locationInView:self.drawView];
    if (currentLocation.y > _ToolView.frame.origin.y ||
        currentLocation.y < 0 || currentLocation.x < 0 ||
        currentLocation.x > self.drawView.bounds.size.width)
        return;
    
    CGPoint previousLocation = [touch previousLocationInView:self.drawView];
    if (isUserToggled) {
        if (touchedView != nil && !CGPointEqualToPoint(currentLocation, previousLocation)
            && (currentLocation.x + touchedView.frame.size.width + offX < self.drawView.frame.size.width &&
                currentLocation.x + offX > 0)
                &&
                currentLocation.y + touchedView.frame.size.height + offY < self.drawView.frame.size.height &&
                currentLocation.y + offY > 0
            ) {
            touchedView.frame = CGRectMake(currentLocation.x + offX, currentLocation.y + offY, touchedView.frame.size.width, touchedView.frame.size.height);
            
            [touchedView setNeedsDisplay];
        }
    } else if (isProuctToggled) {
        if (!savedTag) {
            if (fabs(beginPoint.x - currentLocation.x) > 5 && fabs(beginPoint.y - currentLocation.y) > 5
                && !CGPointEqualToPoint(currentLocation, previousLocation)) {
                if (availableNextTag && !CGPointEqualToPoint(beginPoint, CGPointZero)) {
                    
                    BBXView *bbView = [[[NSBundle mainBundle] loadNibNamed:@"BBXView" owner:self options:nil] objectAtIndex:0];
                    touchedBoundingView = (UIView*)bbView;
                    touchedBoundingView.frame = CGRectMake(beginPoint.x, beginPoint.y, (currentLocation.x - beginPoint.x), (currentLocation.y - beginPoint.y));
                    [self.drawView addSubview:touchedBoundingView];
                    touchedBoundingView.backgroundColor = [UIColor clearColor];
                    
                    UIView *view = bbView.bBody;
                    NSLog(@"Array count %ld", productTaggingArray.count);
                    UIColor *color = [colorArray objectAtIndex: productTaggingArray.count % colorArray.count];
                    view.layer.borderColor = color.CGColor;
                    view.backgroundColor = [UIColor clearColor];
                    view.layer.borderWidth = 2.0f;
                    //left top corner
                    view = bbView.bLTCorner;
                    view.layer.cornerRadius = view.frame.size.width/2;
                    view.backgroundColor = color;
                    [touchedBoundingView addSubview:view];
                    //right top corner
                    view = bbView.bRTCorner;
                    view.layer.cornerRadius = view.frame.size.width/2;
                    view.backgroundColor = color;
                    [touchedBoundingView addSubview:view];
                    
                    //left bottom corner
                    view = bbView.bLBCorner;
                    view.layer.cornerRadius = view.frame.size.width/2;
                    view.backgroundColor = color;
                    [touchedBoundingView addSubview:view];
                    
                    //right bottom corner
                    view = bbView.bRBCorner;
                    view.layer.cornerRadius = view.frame.size.width/2;
                    view.backgroundColor = color;
                    [touchedBoundingView addSubview:view];
                    
                    [self.drawView addSubview: touchedBoundingView];
                    [touchedBoundingView setNeedsDisplay];
                    availableNextTag = NO;
                    isAdded = YES;

                } else {
                    if (isMoved) {
                        if  (currentLocation.x + touchedBoundingView.frame.size.width + offX < self.drawView.frame.size.width &&
                             currentLocation.x + offX > 0 &&
                            currentLocation.y + touchedBoundingView.frame.size.height + offY < self.drawView.frame.size.height &&
                            currentLocation.y + offY > 0) {
                            touchedBoundingView.frame = CGRectMake(currentLocation.x + offX, currentLocation.y + offY, touchedBoundingView.frame.size.width, touchedBoundingView.frame.size.height);
                            [touchedBoundingView setNeedsDisplay];
                        }
                    } else {
                        if (!CGPointEqualToPoint(fixedPoint,CGPointZero)) {
                            touchedBoundingView.frame = CGRectMake(fixedPoint.x, fixedPoint.y, (currentLocation.x - fixedPoint.x), (currentLocation.y - fixedPoint.y));
                            [touchedBoundingView setNeedsDisplay];
                        } else {
                            touchedBoundingView.frame = CGRectMake(beginPoint.x, beginPoint.y, (currentLocation.x - beginPoint.x), (currentLocation.y - beginPoint.y));
                            NSLog(@"moving touchesBoundingView %f --- %f", touchedBoundingView.frame.origin.x, touchedBoundingView.frame.origin.y);
                            [touchedBoundingView setNeedsDisplay];
                        }
                    }
                }
            }
        } else {
            if (touchedBoundingView != nil && !CGPointEqualToPoint(currentLocation, previousLocation)
                && (currentLocation.x + touchedBoundingView.frame.size.width + offX < self.drawView.frame.size.width &&
                    currentLocation.x + offX > 0)
                &&
                currentLocation.y + touchedBoundingView.frame.size.height + offY < self.drawView.frame.size.height &&
                currentLocation.y + offY > 0
                ) {
                touchedBoundingView.frame = CGRectMake(currentLocation.x + offX, currentLocation.y + offY, touchedBoundingView.frame.size.width, touchedBoundingView.frame.size.height);
                
                [touchedBoundingView setNeedsDisplay];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesMoved:touches withEvent:event];
    
    if (isUserToggled) {
        if (touchedDic != nil && touchedView != nil) {
            if (fabs(previousRect.origin.x - touchedView.frame.origin.x) < touchOffSet &&
                fabs(previousRect.origin.y - touchedView.frame.origin.y) < touchOffSet) {
                
                if (activeUserView != nil) {
                    activeUserView.btnView.hidden = YES;
                }
                UITouch *touch = [touches anyObject];
                
                CGPoint selfLocation = [touch locationInView:self.view];

                if ((touchedView.frame.origin.x + touchedView.frame.size.width - selfLocation.x) < 20 &&
                    (touchedView.frame.origin.y + touchedView.frame.size.height - selfLocation.y) < 20 &&
                    touchedView == activeUserView) {
                    [self deleteUserTag:activeUserView.delBtn];
                    return;
                }
                
                if (activeUserView == touchedView) {
                    NSString *id = touchedDic[@"UserID"];
                    NSLog(@"userid --- > %@", id);
                    [self gotoProfilePage:id];
                    
                    return;
                }
                
                activeUserView = nil;
                activeUserView = touchedView;
                activeUserView.btnView.hidden = NO;

                return;
            }
//                [userTaggingArray removeObject:touchedDic];
//                if (![self.removingUserTagArry containsObject:touchedDic]) {
//                    [self.removingUserTagArry addObject:touchedDic];
//                }
//                
//                [touchedView removeFromSuperview];
//                [touchedView setNeedsDisplay];
//                
//                isDel = YES;
//            }
        
            
            NSString *userID = [touchedDic objectForKey:@"UserID"];
            NSString *username = [touchedDic objectForKey:@"UserName"];
           
            [self addUserTagIntoUndoArray:userID UserName:username TaggingView:touchedView previousFrame:previousRect status:TAG_MOVE];
         }
    } else if (isProuctToggled) {
        if (isAdded) {
            productTagView = touchedBoundingView;
//            if (!addedWardrobe) {
//                [self addContentWardrobeWithIndex:productTaggingArray.count];
//            } else {
                [self showProductSearchViewController];
//            }
            isAdded = NO;
        } else {
            GSBaseElement *element = touchedDic[@"GSBaseElement"];
            TagProductView *tagView = touchedDic[@"TagView"];
            UIView *bbx = touchedDic[@"BoundingBox"];
            
            [self addProductTagIntoUndoArray:element BBX:savedTag? bbx : touchedBoundingView TagView:savedTag? touchedBoundingView : tagView previousFrame:previousRect status:TAG_MOVE];
           
        }

    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesEnded:touches withEvent:event];
}

- (void)gotoProfilePage:(NSString*)userID
{
 
    if (userID != nil && ![userID isEqualToString:@""]) {
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:userID, nil];
        
        [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
    } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_ERROR_", nil)
                                                                                     message:NSLocalizedString(@"_TAG_USER_NOT_FOUND_", nil)
                                                                 preferredStyle:UIAlertControllerStyleAlert];

        
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_OK_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //nothing
        
            }];
        
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSArray * parametersForNextVC = nil;
    __block id selectedSpecificResult;
    
    switch (connection)
    {
      
        case GET_FASHIONISTA:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     selectedSpecificResult = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: selectedSpecificResult, [NSNumber numberWithBool:NO], nil, nil];
            
            [self stopActivityFeedback];
            
            if(!self.currentPresenterViewController){
                [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            }else{
                [self.currentPresenterViewController transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
                [self.currentPresenterViewController dismissControllerModal];
            }
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (void)dismissThisViewController
{
    [self dismissViewController];
}
- (void)dismissParentViewController
{
    NSLog(@"dismissParentViewController:");
    [self dismissViewController];
}

#pragma mark - Action func
- (IBAction)closeAction:(id)sender {
//    showCam = NO;
//    if (!showCam) {
//        showCam = YES;
//        
//        conCam = [[SCCaptureCameraController alloc] init];
//        conCam.delegate = self;
//        [self presentViewController:conCam animated:NO completion:nil];
    
        //        [parentController presentModalViewController:self animated:YES];
        //        camnav = [[SCNavigationController alloc] init];
        //        camnav.scNaigationDelegate = self;
        //        [camnav showCameraWithParentController:self];
//    }
    [self dismissViewController];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)undoAction:(id)sender {
    if (isUserToggled) {
        NSDictionary *dic = [undoUserArray lastObject];
        if (dic == nil) return;
        
        NSInteger st = [dic[@"TagStatus"] integerValue];
        TagView *tv = [dic objectForKey:@"TagView"];
        CGRect undoPoint = [[dic objectForKey:@"UndoRect"] CGRectValue];
        CGRect redoPoint = tv.frame;
        NSString *userid = [dic objectForKey:@"UserID"];
        NSString *username = [dic objectForKey:@"UserName"];
        
        if (st == TAG_DELETE) {
            [self addUserTagIntoArray:userid UserName:username TaggingView:tv undoFlag:NO];
            if ([self.removingUserTagArry containsObject:dic]) {
                [self.removingUserTagArry removeObject:dic];
            }
            [self.drawView addSubview:tv];
            [tv setNeedsDisplay];
        } else if (st == TAG_ADD) {
            if (![self.removingUserTagArry containsObject:dic]) {
                [self.removingUserTagArry addObject:dic];
            }
            [tv removeFromSuperview];
            [tv setNeedsDisplay];
            [userTaggingArray removeObject:dic];
        } else if (st == TAG_MOVE) {
            tv.frame = undoPoint;
            [tv setNeedsDisplay];
        }
        
        [self addUserTagIntoRedoArray:userid UserName:username TaggingView:tv previousFrame:redoPoint status:st];
        [undoUserArray removeObject:dic];
    } else if (isProuctToggled) {
        NSDictionary *dic = [undoProductArray lastObject];
        if (dic == nil) return;

        GSBaseElement* element = dic[@"GSBaseElement"];
        NSInteger st = [dic[@"TagStatus"] integerValue];
        //        NSInteger st = [[dic objectForKey:@"TagStatus"] integerValue];
        UIView *tv = [dic objectForKey:@"BoundingBox"];
        TagProductView *tagView = dic[@"TagView"];
        CGRect undoPoint = [[dic objectForKey:@"UndoRect"] CGRectValue];
        CGRect redoPoint = tv.frame;
        
        if (st == TAG_DELETE) {
            [self addProductTagIntoArray:element BBX:tv TagView:tagView undoFlag:NO];
            if ([self.removingProductTagArry containsObject:dic]) {
                [self.removingProductTagArry removeObject:dic];
            }
            [productTaggingArray removeObject:dic];
            [self.drawView addSubview:tagView];
            [tv setNeedsDisplay];
        } else
        if (st == TAG_ADD) {
            [tv removeFromSuperview];
            [tv setNeedsDisplay];
            if (![self.removingProductTagArry containsObject:dic]) {
                [self.removingProductTagArry addObject:dic];
            }
            [productTaggingArray removeObject:dic];
        } else if (st == TAG_MOVE) {
            if (!savedTag)
                tv.frame = undoPoint;
            else
                tagView.frame = undoPoint;
            
            [tv setNeedsDisplay];
        }
        
        [self addProductTagIntoRedoArray:element BBX:tv TagView:tagView previousFrame:redoPoint status:st];
        [undoProductArray removeObject:dic];
        
        [self ProcessWhenNOTag];
    } else if (isCommentToggled) {
        if (undoCommentArry.count > 0) {
            NSString *comm = [undoCommentArry lastObject];
            if (comm != nil) {
                NSString *tmp = _textView.text;
                [redoCommentArry addObject:tmp];
                _textView.text = comm;
                commentStr = comm;
                [undoCommentArry removeObject:comm];
            }
        }
    }  else if (isLocationToggled) {
        if (undoLocationArry.count > 0) {
            NSString *comm = [undoLocationArry lastObject];
            if (comm != nil) {
                NSString *tmp = _textView.text;
                [redoLocationArry addObject:tmp];
                _textView.text = comm;
                locationStr = comm;
                [undoLocationArry removeObject:comm];
            }
        }
    }
}

- (IBAction)redoAction:(id)sender {
    if (isUserToggled) {
        NSDictionary *dic = [redoUserArray lastObject];
        if (dic == nil) return;
        
        NSInteger st = [[dic objectForKey:@"TagStatus"] integerValue];
        TagView *tv = [dic objectForKey:@"TagView"];
        CGRect redoPoint = [[dic objectForKey:@"UndoRect"] CGRectValue];
        CGRect undoPoint = tv.frame;
        NSString *userid = [dic objectForKey:@"UserID"];
        NSString *username = [dic objectForKey:@"UserName"];
        
        if (st == TAG_DELETE) {
            if (![self.removingUserTagArry containsObject:dic]) {
                [self.removingUserTagArry addObject:dic];
            }
            [tv removeFromSuperview];
            [tv setNeedsDisplay];
            [userTaggingArray removeObject:dic];
        } else if (st == TAG_MOVE) {
            tv.frame = redoPoint;
        } else if (st == TAG_ADD) {
            if ([self.removingUserTagArry containsObject:dic]) {
                [self.removingUserTagArry removeObject:dic];
            }
            [self addUserTagIntoArray:userid UserName:username TaggingView:tv undoFlag:NO];
            [self.drawView addSubview:tv];
            [tv setNeedsDisplay];
        }
        
        [tv setNeedsDisplay];
        
        [self addUserTagIntoUndoArray:userid UserName:username TaggingView:tv previousFrame:undoPoint status:st];
        [redoUserArray removeObject:dic];
    } else if (isProuctToggled) {
        NSDictionary *dic = [redoProductArray lastObject];
        if (dic == nil) return;

        NSInteger st = [dic[@"TagStatus"] integerValue];
        TagProductView *tagView = [dic objectForKey:@"TagView"];
        GSBaseElement *element = [dic objectForKey:@"GSBaseElement"];
        UIView *tv = [dic objectForKey:@"BoundingBox"];
        CGRect redoPoint = [[dic objectForKey:@"UndoRect"] CGRectValue];
        CGRect undoPoint = tv.frame;

        
        if (st == TAG_DELETE) {
            [tagView removeFromSuperview];
            [tagView setNeedsDisplay];
            if (![self.removingProductTagArry containsObject:dic]) {
                [self.removingProductTagArry addObject:dic];
            }
            [productTaggingArray removeObject:dic];
        } else
        if (st == TAG_MOVE) {
            if (!savedTag)
                tv.frame = redoPoint;
            else
                tagView.frame = redoPoint;
        } else if (st == TAG_ADD) {
            [self addProductTagIntoArray:element BBX:tv TagView:tagView undoFlag:NO];
            if ([self.removingProductTagArry containsObject:dic]) {
                [self.removingProductTagArry removeObject:dic];
            }
            [self.drawView addSubview:tv];
            [tv setNeedsDisplay];
        }
        
        [tv setNeedsDisplay];
        
        [self addProductTagIntoUndoArray:element BBX:tv TagView:tagView previousFrame:undoPoint status:st];
        [redoProductArray removeObject:dic];
        
        [self ProcessWhenNOTag];
    } else if (isCommentToggled) {
        if (redoCommentArry.count > 0) {
            NSString *comm = [redoCommentArry lastObject];
            if (comm != nil) {
                NSString *tmp = _textView.text;
                [undoCommentArry addObject:tmp];
                _textView.text = comm;
                commentStr = comm;
                [redoCommentArry removeObject:comm];
            }
        }
    } else if (isLocationToggled) {
        if (redoLocationArry.count > 0) {
            NSString *comm = [redoLocationArry lastObject];
            if (comm != nil) {
                NSString *tmp = _textView.text;
                [undoLocationArry addObject:tmp];
                _textView.text = comm;
                locationStr = comm;
                [redoLocationArry removeObject:comm];
            }
        }
    }
}



- (IBAction)searchProduct:(id)sender {
    if (_addToWardrobeVCContainer.alpha < 1.0) {
        return;
    }
    [searchBaseVC searchProduct];

}

- (IBAction)nextTagAction:(id)sender {
    
    availableNextTag = YES;
    _tagBtnView.hidden = YES;
    _tagLab.hidden = NO;
}


- (IBAction)cancelAction:(id)sender {
    if (_addToWardrobeVCContainer.alpha < 1.0) {
        return;
    }
    
    [searchBaseVC.view removeFromSuperview];
    [searchBaseVC removeFromParentViewController];
    
    [_addToWardrobeVCContainer setHidden:YES];
    
    [_addToWardrobeVCBackground setHidden:YES];
    [_productSearchToolView setHidden:YES];
    
    [self.view sendSubviewToBack:_addToWardrobeVCBackground];
    
    [self.view sendSubviewToBack:_addToWardrobeVCContainer];
    [self.view sendSubviewToBack:_productSearchToolView];
    
    searchBaseVC = nil;
    
    [productTagView removeFromSuperview];
    [productTagView setNeedsDisplay];
    productTagView = nil;
    availableNextTag = YES;
}


- (IBAction)addTag:(id)sender {
    if (_addToWardrobeVCContainer.alpha < 1.0) {
        return;
    }
    
    [searchBaseVC.view removeFromSuperview];
    [searchBaseVC removeFromParentViewController];
 
    [_addToWardrobeVCContainer setHidden:YES];
    
    [_addToWardrobeVCBackground setHidden:YES];
    [_productSearchToolView setHidden:YES];
    
    [self.view sendSubviewToBack:_addToWardrobeVCBackground];
    
    [self.view sendSubviewToBack:_addToWardrobeVCContainer];
    [self.view sendSubviewToBack:_productSearchToolView];
    
    searchBaseVC = nil;
    if (productTagView != nil) {
        NSLog(@"touchesboundingbox %f     %f", productTagView.frame.origin.x, productTagView.frame.origin.y);

        if (removeUndoAct) { //initalize redo, undo array
            [undoProductArray removeAllObjects];
            [redoProductArray removeAllObjects];
            removeUndoAct = NO;
        }

        
        for (NSDictionary* dic in productTaggingArray) {
            GSBaseElement* element = dic[@"GSBaseElement"];
            if ([selectedProduct.idGSBaseElement isEqualToString:element.idGSBaseElement]) {
                [productTagView removeFromSuperview];
                return;
            }
        }
        
        [self addProductTagIntoArray:selectedProduct BBX:productTagView TagView:nil undoFlag:YES];
        
        savedTag = NO;
        
        [self showTagBtnView:savedTag];
        _editTagBtn.enabled = NO;
        _saveTagBtn.enabled = YES;
        _nextTagBtn.enabled = YES;
        self.tagLab.hidden = YES;
    }
}

- (IBAction)userAction:(id)sender {
    if (isUserToggled) {return;}
    
    _tagLab.hidden = NO;
    _tagLab.text = NSLocalizedString(@"_TAG_USER_DESCRIPTION_", nil);
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"UserTag"] forState:UIControlStateNormal];
    if (currTagBtn != nil) {
        [currTagBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] forState:UIControlStateNormal];
        [currTagBtn setImage:[UIImage imageNamed:@"ProductTagInact"] forState:UIControlStateNormal];
    }
    self.tagBtnView.hidden = YES;

    currTagBtn = sender;
    isUserToggled = YES;
    isProuctToggled = NO;
}

- (IBAction)productAction:(id)sender {
    if (isProuctToggled) {return;}

    if (productTaggingArray.count > 0) {
        self.tagBtnView.hidden = NO;
        self.tagLab.hidden = YES;
         availableNextTag = NO;
    } else {
        availableNextTag = YES;
        _tagLab.hidden = NO;
        _tagLab.text = NSLocalizedString(@"_TAG_PRODUCT_DESCRIPTION_", nil);
    }
    

    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"ProductTag"] forState:UIControlStateNormal];

    if (currTagBtn != nil) {
        [currTagBtn setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6] forState:UIControlStateNormal];
        [currTagBtn setImage:[UIImage imageNamed:@"UserTagInact"] forState:UIControlStateNormal];

    }
    currTagBtn = sender;
    isUserToggled = NO;
    isProuctToggled = YES;
}

//FashionistaPostViewDelegate
- (void)showProductSearchViewController:(FashionistaPostViewController *)viewcontroller
{
    addedWardrobe = YES;
    if (productTaggingArray.count > 0) {
        for (NSDictionary *dic in productTaggingArray) {
            GSBaseElement *element = dic[@"GSBaseElement"];
            UIView *bbx = dic[@"BoundingBox"];
            TagProductView *tagView  = dic[@"TagView"];
            if (tagView != nil) {
                element.product_polygons = [NSString stringWithFormat:@"%f,%f,%f,%f", tagView.frame.origin.x - (bbx.frame.size.width - tagView.frame.size.width)/2, tagView.frame.origin.y - (bbx.frame.size.height - tagView.frame.size.height)/2, bbx.frame.size.width, bbx.frame.size.height];
            } else {
                element.product_polygons = [NSString stringWithFormat:@"%f,%f,%f,%f", bbx.frame.origin.x, bbx.frame.origin.y, bbx.frame.size.width, bbx.frame.size.height];
            }
             [self addWardrobeToContent:element];
        }
    }

}

- (void)showProductSearchViewController
{
    searchBaseVC = nil;
    //
    @try {

        searchBaseVC = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]];

    }
    @catch (NSException *exception) {

        return;

    }

    if (searchBaseVC != nil)
    {
        [self addChildViewController:searchBaseVC];
        searchBaseVC.searchBaseDelegate = self;
        //[addPostToPageVC willMoveToParentViewController:self];

        searchBaseVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainer.frame.size.width, _addToWardrobeVCContainer.frame.size.height);

        [searchBaseVC.view setClipsToBounds:YES];

        [_addToWardrobeVCContainer addSubview:searchBaseVC.view];

        [searchBaseVC didMoveToParentViewController:self];

        [_addToWardrobeVCContainer setHidden:NO];

        [_addToWardrobeVCBackground setHidden:NO];
        [_productSearchToolView setHidden:NO];
        
        [self.view bringSubviewToFront:_addToWardrobeVCBackground];

        [self.view bringSubviewToFront:_addToWardrobeVCContainer];
        [self.view bringSubviewToFront:_productSearchToolView];
    }

}

//SearchBaseDelegate
- (void)finishItemToWardrobe:(SearchBaseViewController*)searchBaseController Item:(GSBaseElement*)tagProduct WardrobeID:(NSString*)wardrobeID
{
    selectedProduct = tagProduct;
    self.tagBtn.enabled = YES;
}


- (IBAction)uploadAction:(id)sender {
    
    //People tag posting
    if (userTaggingArray.count > 0) {
        //initialize
        [self.tempPostingUserTagArry removeAllObjects];
        
        for (int i = 0; i < userTaggingArray.count; i++) {
            NSDictionary *dic = [userTaggingArray objectAtIndex:i];
            NSString *username = [dic objectForKey:@"UserName"];
            TagView *view = [dic objectForKey:@"TagView"];
            CGFloat xPOS = view.frame.origin.x / _tagImgView.image.size.width;
            CGFloat yPOS = view.frame.origin.y / _tagImgView.image.size.height;
            isPosting = YES;
            
            [self addKeywordFromNameWithIndex:username Index:i XPos:xPOS YPos:yPOS];
        }
    }
        //delete keywordFashionistaContent
        for (NSDictionary *dic in self.removingUserTagArry) {
            NSString *title = [dic objectForKey:@"UserName"];
            isPosting = YES;

            [self removeKyewordFromContent:title];
        }
        [self.removingUserTagArry removeAllObjects];
    
    
    if (productTaggingArray.count > 0) {
        if (!addedWardrobe) {
            isPosting = YES;
            [self addContentWardrobeWithIndex:0];
        } else {
            for (NSDictionary *dic in productTaggingArray) {
                GSBaseElement *element = dic[@"GSBaseElement"];
                UIView *bbx = dic[@"BoundingBox"];
                TagProductView *tagView  = dic[@"TagView"];
                if (tagView != nil) {
                    element.product_polygons = [NSString stringWithFormat:@"%f,%f,%f,%f", tagView.frame.origin.x - (bbx.frame.size.width - tagView.frame.size.width)/2, tagView.frame.origin.y - (bbx.frame.size.height - tagView.frame.size.height)/2, bbx.frame.size.width, bbx.frame.size.height];
                } else {
                    element.product_polygons = [NSString stringWithFormat:@"%f,%f,%f,%f", bbx.frame.origin.x, bbx.frame.origin.y, bbx.frame.size.width, bbx.frame.size.height];
                }
                NSLog(@"polygons --->   %@", element.product_polygons);
                isPosting = YES;
                [self addWardrobeToContent:element];
                
            }
        }
    }
    if (addedWardrobe) {
            for (NSDictionary *dic in self.removingProductTagArry) {
                GSBaseElement *element = dic[@"GSBaseElement"];
                if ([self.PostedProductArry containsObject:element]) {
                    isPosting = YES;
                    [self removeItemfromContent:element];
                }
                
            }
            [self.removingProductTagArry removeAllObjects];    
    }
    if (commentStr != nil) {  //upload comment
        if (![commentStr isEqualToString:@""]) {
            isPosting = YES;
            [self uploadComment:commentStr];
        } else { //delete
            if (undoCommentArry.count > 0) {
                NSString *comm = [undoCommentArry lastObject];
                if (![comm isEqual:@""]) {
                    isPosting = YES;
                    [self deleteComment];
                }
            }
        }
    }
    if (locationStr != nil) {
        if ([locationStr isEqualToString:NSLocalizedString(@"_NO_SET_LOCATION_", nil)] || [locationStr isEqualToString:@""]) {
            isPosting = YES;
             [self postLocation:@""];
        } else
            isPosting = YES;
            [self postLocation:locationStr];
    }
    
    if(isPosting == NO) {
        isPosting = YES;

        [self dismissViewController];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"finishNotification" object:self];
    }
}

bool clickedEditBtn = false;
- (IBAction)saveTagAction:(id)sender {
    if (clickedEditBtn) {
        clickedEditBtn = NO;
        return;
    }
    
    savedTag = YES;
    
    [self addProductTag];

    [self showTagBtnView:savedTag];
    
    _nextTagBtn.enabled = NO;
    _saveTagBtn.enabled = NO;
    _editTagBtn.enabled = YES;
}

- (void)showTagBtnView:(BOOL)saved {
    _tagBtnView.hidden = NO;
    _nextTagBtn.hidden = saved;
    _saveTagBtn.hidden = saved;
    _editTagBtn.hidden = !saved;
}

- (IBAction)editTagAction:(id)sender {
    clickedEditBtn = YES;
    //Show BBX, hide ProdutTagView
    for (NSDictionary *dic in productTaggingArray) {
        UIView *view = dic[@"BoundingBox"];
        UIView *tagView = dic[@"TagView"];
        
        CGFloat px, py;
        px = tagView.frame.origin.x - (view.frame.size.width - tagView.frame.size.width)/2;
        py = tagView.frame.origin.y - (view.frame.size.height - tagView.frame.size.height)/2;
        view.frame = CGRectMake(px, py, view.frame.size.width, view.frame.size.height);
        [self.drawView addSubview:view];
        [tagView removeFromSuperview];

    }

    [undoProductArray removeAllObjects];
    [redoProductArray removeAllObjects];
    
    _nextTagBtn.enabled = YES;
    _saveTagBtn.enabled = YES;
    _editTagBtn.enabled = NO;
    
    savedTag = NO;
    [self showTagBtnView:savedTag];

}

- (void)addProductTag {
    NSMutableArray *tmpArry = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in productTaggingArray) {
        TagProductView *tagView = [[[NSBundle mainBundle] loadNibNamed:@"TagProductView" owner:self options:nil] objectAtIndex:0];
        GSBaseElement* element = dic[@"GSBaseElement"];
        
        NSString *productname = [element mainInformation];
        if (productname == nil || [productname isEqualToString:@""]) {
            productname = [element name];
        }
        
        CGFloat width =  [productname sizeWithFont:[UIFont fontWithName:@"AvantGarde-Book" size:10 ]].width;
        if (width > LIMIT_WIDTH)
            width = LIMIT_WIDTH;
        
        tagView.tagLabWidth.constant = width + 10;
        
        tagView.tagNameLab.text = productname;
        CGFloat tagViewWidth = 50 + width + 10;
        CGFloat tagViewHeight = 30;
        UIView *bbx = dic[@"BoundingBox"];
        
        CGFloat px = bbx.frame.origin.x + (bbx.frame.size.width - tagViewWidth)/2;
        CGFloat py = bbx.frame.origin.y + (bbx.frame.size.height - tagViewHeight)/2;
        
        tagView.frame = CGRectMake(px, py, tagViewWidth, tagViewHeight);
        
        [self.drawView addSubview:tagView];
        [bbx removeFromSuperview];
        
//        [productTaggingArray removeObject:dic];

//        [self addProductTagIntoArray:element BBX:bbx TagView:tagView undoFlag:NO];
        NSDictionary *pDic = [self createProductTagDictionary:element BBX:bbx TagView:tagView];
        [tmpArry addObject:pDic];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProduct:)];
        singleTap.numberOfTapsRequired = 1;
        [tagView setUserInteractionEnabled:YES];
        [tagView addGestureRecognizer:singleTap];
    }
    
    [productTaggingArray removeAllObjects];
    productTaggingArray = tmpArry;
    
    [undoProductArray removeAllObjects];
    [redoProductArray removeAllObjects];
}

- (void) tapProduct: (UIGestureRecognizer *) gesture {
    if (activeProductView != nil) {
        activeProductView.deleteTagBtn.hidden = YES;
        activeProductView.separateView.hidden = YES;
    }
    
    if (activeProductView == (TagProductView*)gesture.view) {
        for (NSDictionary *dic in productTaggingArray) {
            TagProductView *view = dic[@"TagView"];
            GSBaseElement *element = dic[@"GSBaseElement"];
            if (view == activeProductView) {
                [self showProductDetailsView:element];
                break;
            }
        }
        return;
    }
    
    activeProductView = (TagProductView*)gesture.view;
    activeProductView.deleteTagBtn.hidden  = NO;
    activeProductView.separateView.hidden = NO;

    [activeProductView.deleteTagBtn addTarget:self action:@selector(deleteProductTag:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)deleteProductTag:(UIButton *)button {
    for (NSDictionary *dic in productTaggingArray) {
        TagProductView *view = dic[@"TagView"];
        GSBaseElement *element = dic[@"GSBaseElement"];
        UIView *bbx = dic[@"BoundingBox"];
        
        if (view == activeProductView) {
            activeProductView.deleteTagBtn.hidden = YES;
            activeProductView.separateView.hidden = YES;
            
            [self addProductTagIntoUndoArray:element BBX:bbx TagView:view previousFrame:view.frame status:TAG_DELETE];
            [activeProductView removeFromSuperview];

            [self.removingProductTagArry addObject:dic];
            [productTaggingArray removeObject:dic];
//            activeProductView = nil;

            break;
        }
    }
    [self ProcessWhenNOTag];
    
}

- (void)ProcessWhenNOTag {
    if (productTaggingArray.count <= 0) {
        _tagLab.hidden = NO;
        _tagBtnView.hidden = YES;
        availableNextTag = YES;
        savedTag = NO;
        removeUndoAct = YES;
    } else {
        _tagLab.hidden = YES;
        _tagBtnView.hidden = NO;
        availableNextTag = NO;
        savedTag = [_editTagBtn isEnabled];
        removeUndoAct = NO;
    }
}

#pragma COMMENT TAGGING
CGFloat bottomToolMargin;
CGFloat bottomImgMargin;
CGFloat topImgMargin;
NSString *commentTxt;

- (void)initalizeForTaggingComment {
    _textView.text  = commentStr;
    bottomToolMargin = _toolViewBottomMargin.constant;
    bottomImgMargin = _imageViewBottomMargin.constant;
    topImgMargin = _imageViewTopMargin.constant;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyNotificationMethod:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [_textView setEditable:YES];
    [_textView becomeFirstResponder];
}

- (void)showKeyNotificationMethod:(NSNotification*)notification
{
    if (isCommentToggled) {
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        CGRect commentViewRect = _commentActionView.bounds;
        CGRect toolViewRect = _ToolView.frame;

        
        if (toolViewRect.size.height + bottomToolMargin - keyboardFrameBeginRect.size.height < commentViewRect.size.height) {
            CGFloat offheight = commentViewRect.size.height - (toolViewRect.size.height + bottomToolMargin - keyboardFrameBeginRect.size.height);
            _toolViewBottomMargin.constant = bottomToolMargin + offheight;
            _imageViewBottomMargin.constant = bottomImgMargin + offheight;
            _imageViewTopMargin.constant = topImgMargin - offheight;
        }
    }

}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    commentTxt = textView.text;
    _editToolView.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [_textView setEditable:NO];
    _editToolView.hidden = YES;
    _toolViewBottomMargin.constant = bottomToolMargin;
    _imageViewBottomMargin.constant = bottomImgMargin;
    _imageViewTopMargin.constant = topImgMargin;

}

- (IBAction)seePostImageAction:(id)sender {
    CGFloat alphaValue;
    NSString *btnTitle;

    if(_addToWardrobeVCContainer.alpha == 1) {
        alphaValue = 0.05;
        btnTitle = NSLocalizedString(@"_TAG_BACK_PRODUCT_SEARCH_", nil);
        _addToWardrobeVCContainer.userInteractionEnabled = NO;
    } else {
        alphaValue = 1;
        btnTitle = NSLocalizedString(@"_TAG_SEE_POST_IMAGE_", nil);
        _addToWardrobeVCContainer.userInteractionEnabled = YES;
    }
    
    [UIView animateWithDuration:1 animations:^{
         _addToWardrobeVCContainer.alpha = 0.5;
    } completion:^(BOOL finished) {
        
        _addToWardrobeVCContainer.alpha = alphaValue;
        UIButton *btn  = (UIButton*)sender;
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        
    }];
   
}

- (IBAction)cancelEditAction:(id)sender {
    _textView.text = commentTxt;
    [_textView resignFirstResponder];
}

- (IBAction)submitEditAction:(id)sender {
    [_textView resignFirstResponder];
    commentStr = _textView.text;
    if(![_textView.text  isEqual: @""]) {
        [undoCommentArry addObject:commentTxt];
    }
}
- (IBAction)editAction:(id)sender {
    if (isCommentToggled) {
        [_textView setEditable:YES];
        [_textView becomeFirstResponder];
    } else if (isLocationToggled) {
        UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
        GSTaggingLocationSearchViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(TAGGINGPRODUCTSEARCH_VC) stringValue]];
        
        nextViewController.locationDelegate = self;
        
        [self prepareViewController:nextViewController withParameters:nil];
        [nextViewController setSearchContext:FASHIONISTAS_SEARCH];
        nextViewController.userListMode = SUGGESTED;
        [self showViewControllerModal:nextViewController];
        [self setTitleForModal:@"TAGGING LOCATION"];
    }
}

#pragma  location tagging
- (void)initializeLocationTagging
{
//    commentStr = _textView.text;
    
    if (locationStr == nil || [locationStr isEqualToString:@""]) {
        _textView.text = NSLocalizedString(@"_NO_SET_LOCATION_", nil);
    } else {
        _textView.text = locationStr;
    }
    
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    GSTaggingLocationSearchViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(TAGGINGPRODUCTSEARCH_VC) stringValue]];
    
    nextViewController.locationDelegate = self;
    
    [self prepareViewController:nextViewController withParameters:nil];
    [nextViewController setSearchContext:FASHIONISTAS_SEARCH];
    nextViewController.userListMode = SUGGESTED;
    [self showViewControllerModal:nextViewController];
    [self setTitleForModal:@"TAGGING LOCATION"];

}

-(void) setLocation:(POI *)poi {
    selectedPoi = poi;
    [undoLocationArry addObject:_textView.text];

    NSLog(@"set location --- > %@", poi.name);
    NSString *address = poi.address == nil? @"" : poi.address;
    locationStr = [NSString stringWithFormat:@"%@\n%@", poi.name, address];
    _textView.text = locationStr;
}

#pragma ActivityIndicator
-(void) showFeedbackActivity:(NSString*)message {
    [self showActivityIndicator:message];
}
-(void) hideFeedbackActivity :(NSString *)title {
    [self hideActivityIndicator];
    
    NSLog(@"hideFeedbackActivity --- > %@", title);
    if ([self.postActionArray containsObject:title]) {
        [self.postActionArray removeObject:title];
    }
    if (self.postActionArray.count <= 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_INFO_", nil)
                                                                                 message:NSLocalizedString(@"_POST_SUCCESS_", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_OK_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewController];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishNotification" object:self];
            
        }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
-(void)showActivityIndicator:(NSString*)message
{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:message];
}
-(void)hideActivityIndicator
{
    [self stopActivityFeedback];
    
}
//-(void)postedImage {
//
//    if (conCam != nil) {
//        self.tagImgView.image = self.tagImg;
//
//        [conCam reportPostedImage];
//    }
//}

#pragma mark - Avoid user leave post creation unless cancelled or finished

- (void)leftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleLeftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)homeAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleRightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)rightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELPOSTEDITINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

@end
