//
//  LiveStreamViewController.m
//  GoldenSpear
//
//  Created by Crane on 8/27/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "LiveStreamViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "UIButton+CustomCreation.h"
#import "UILabel+CustomCreation.h"
#import "VCSimpleSession.h"
#import "PrivacyBtnView.h"
#import "SCNavigationController.h"
#import "MarqueeLabel.h"
#import "LiveFilterViewController.h"

//#import "LMLivePreview.h"
#define MAX_TIME 180000 //(sec)
#import <QuartzCore/QuartzCore.h>


#define TOPBAR_TRANSPARENT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]
#define CLICKED_TRANSPARENT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]
#define CLICKING_TRANSPARENT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f]

@interface LiveStreamViewController () <VCSessionDelegate, UITextFieldDelegate, FilterSearchtDelegate>
@property (nonatomic, retain) VCSimpleSession* session;
@property(nonatomic) int timeSec;
@property(nonatomic) int timeMin;
@end

@implementation LiveStreamViewController {
    CGFloat maxLabelWidth;
    NSMutableArray *catArry;
    NSMutableArray *selectedCatArry;
    bool isBroadCasting;
    NSTimer *timer;
    NSMutableArray *privacyArry;
    NSMutableArray *privacyTitleArry;
    UIView *priview;
    int activePricacyItem;
    NSString *parentPath;
    NSString *subPath;
    NSMutableArray *toolBtnArry;
    MarqueeLabel *lengthyLabel;
    BOOL settedCoreData;
    NSString *privacyID;
    NSString *categoryID;
    NSString *livestreamingID;
    LiveStreaming * liveStreaming;
    BOOL disableSettigns;
    BOOL isAddedCategory;
    BOOL isLoadingFilter;
    NSMutableArray *catButtons;
    
    NSMutableArray *filterCountries;
    NSMutableArray *filterStates;
    NSMutableArray *filtercities;
    NSMutableArray *filterAges;
    BOOL isSelectedMale;
    BOOL isSelectedFemale;
    NSMutableArray *filterEthnicities;
    NSMutableArray *filterLooks;
    NSMutableArray *filterTags;
    NSMutableArray *filterProducts;
    NSMutableArray *filterBrands;
    BOOL isPostSuccess;
    int postingCount;
    int postingEthnicityCount;
    BOOL startedBroadcast;
    UIButton *settingBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeMin = 0;
    self.timeSec = 0;
    activePricacyItem = 1;
    isAddedCategory = NO;
    parentPath = @"rtmp://messaging.goldenspear.com/live/";
    subPath = nil;
    //iinitialize
    catArry = [[NSMutableArray alloc]init];
    selectedCatArry = [[NSMutableArray alloc]init];
    catButtons = [[NSMutableArray alloc]init];
    isPostSuccess = NO;
    isBroadCasting = NO;
    startedBroadcast = NO;
    privacyArry = [[NSMutableArray alloc]init];
    toolBtnArry = [[NSMutableArray alloc]init];
    [self setupToolView:NO];
    
    /*filter arraies initialize*/
    filterCountries = [[NSMutableArray alloc]init];
    filterStates = [[NSMutableArray alloc]init];
    filtercities = [[NSMutableArray alloc]init];
    filterAges = [[NSMutableArray alloc]init];
    isSelectedMale = NO;
    isSelectedFemale = NO;
    filterEthnicities = [[NSMutableArray alloc]init];
    filterLooks = [[NSMutableArray alloc]init];
    filterTags = [[NSMutableArray alloc]init];
    filterProducts = [[NSMutableArray alloc]init];
    filterBrands = [[NSMutableArray alloc]init];
    
    [self initActivityFeedback];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityLabel];
    [self shouldTopbarTransparent];
    
    [self setupTopView];
    
    _popview.layer.cornerRadius = 5.0f;
    
//    UITapGestureRecognizer *lbTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lbHandleTapGesture:)];
//    [self.preview addGestureRecognizer:lbTapGesture];
    // Setup a 'Double tap' recognizer
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.topBarView addGestureRecognizer:doubleTapGesture];

    
//    captureSession = [[StreamCaptureSession alloc] initWithPreview:self.preview];
//    [captureSession startSession];
    
    _session = [[VCSimpleSession alloc] initWithVideoSize:CGSizeMake(540, 960) frameRate:30 bitrate:1000000 useInterfaceOrientation:NO];
    
    [self.preview addSubview:_session.previewView];
    _session.previewView.frame = self.preview.bounds;
    
    _session.delegate = self;
    [_session setOrientationLocked:YES];
//    [self.view addSubview:[[LMLivePreview alloc] initWithFrame:self.view.bounds]];

    _ctgScrollView.hidden = YES;
    _redDot.hidden = YES;
    _liveLbl.hidden = YES;
    _titleTextField.delegate = self;
    
    [self.view bringSubviewToFront:_popupBGView];
    
    [_privacyBtn addTarget:self action:@selector(privacyAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyNotificationMethod:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [self getPrivacyValues];

    
}
- (void)showMarqueeLabel:(BOOL)showing
{
    [lengthyLabel removeFromSuperview];
    if (showing) {
        _titleTextField.hidden = YES;
        lengthyLabel = [[MarqueeLabel alloc] initWithFrame:_labelView.bounds duration:10.0 andFadeLength:5.0f];
        lengthyLabel.textColor = [UIColor whiteColor];
        lengthyLabel.text = NSLocalizedString(@"_LIVE_BROADCASTING_TITLE_", nil);
        lengthyLabel.marqueeType = MLContinuous;
        [_labelView addSubview:lengthyLabel];
    } else {
        _titleTextField.hidden = NO;
    }
}
- (void)setupToolView: (BOOL)isRecording
{
    CGRect scrRect = [[UIScreen mainScreen]bounds];
    if (toolBtnArry.count > 0) {
        for (UIButton *btn in toolBtnArry) {
            [btn removeFromSuperview];
        }
        [toolBtnArry removeAllObjects];
    }
    
    UIButton *btn;
    if (!isRecording) {
        CGFloat space = (scrRect.size.width - 40 - 35 * 4)/3;
        CGFloat x = 20;
        CGFloat height = 47;//_toolView.frame.size.height;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 40, 35)
                   normalImgStr:@"live_share.png"
                highlightImgStr:@""
                 selectedImgStr:@""
                         action:@selector(liveShareAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];

        x += 40 + space;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 40, 35)
                   normalImgStr:@"live_tag.png"
                highlightImgStr:@""
                 selectedImgStr:@"live_tag.png"
                         action:@selector(liveTagAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];

        x += 40 + space;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 35, 35)
                   normalImgStr:@"live_videofilter.png"
                highlightImgStr:@""
                 selectedImgStr:@"live_videofilter.png"
                         action:@selector(liveVideoFilterAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];

        x += 35 + space;
        UIButton* btn = [self buildButton:CGRectMake(x, (height - 35)/2, 30, 35)
                   normalImgStr:@"live_filter.png"
                highlightImgStr:@""
                 selectedImgStr:@""
                         action:@selector(liveCategoryAction:)
                     parentView:_toolView];
        settingBtn = btn;
        [toolBtnArry addObject:btn];

        
    } else {
        CGFloat space = (scrRect.size.width - 40 - 35 * 5)/4;
        CGFloat x = 20;
        CGFloat height = _toolView.bounds.size.height;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 40, 35)
                   normalImgStr:@"live_share.png"
                highlightImgStr:@""
                 selectedImgStr:@""
                         action:@selector(liveShareAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];

        x += 40 + space;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 35, 35)
                   normalImgStr:@"live_comment.png"
                highlightImgStr:@""
                 selectedImgStr:@""
                         action:@selector(liveCommentAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];

        x += 35 + space;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 35, 35)
                   normalImgStr:@"live_chat.png"
                highlightImgStr:@""
                 selectedImgStr:@""
                         action:@selector(liveChatAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];

        x += 35 + space;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 40, 35)
                   normalImgStr:@"live_tag.png"
                highlightImgStr:@""
                 selectedImgStr:@"live_tag.png"
                         action:@selector(liveTagAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];
        
        x += 40 + space;
        btn = [self buildButton:CGRectMake(x, (height - 35)/2, 35, 35)
                   normalImgStr:@"live_videofilter.png"
                highlightImgStr:@""
                 selectedImgStr:@"live_videofilter.png"
                         action:@selector(liveVideoFilterAction:)
                     parentView:_toolView];
        [toolBtnArry addObject:btn];

    }
}

- (void)liveShareAction:(UIButton*)sender
{
    //
    NSLog(@"liveShareAction");
}
- (void)liveTagAction:(UIButton*)sender
{
    NSLog(@"liveTagAction");
}
- (void)liveVideoFilterAction:(UIButton*)sender
{
    NSLog(@"liveVideoFilterAction");
}
- (void)liveCategoryAction:(UIButton*)sender
{
    
    if (disableSettigns)
        return;
    
//    if (liveStreaming.idLiveStreaming == nil || [liveStreaming.idLiveStreaming isEqualToString:@""]) {
//        isLoadingFilter = YES;
//        [self postLiveStreamingObject];
//        return;
//    }
//    isLoadingFilter = NO;
    NSLog(@"liveCategoryAction");
    NSString* destinationStoryboard = @"FashionistaContents";
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:destinationStoryboard bundle:nil];
    
    if (nextStoryboard != nil)
    {

        LiveFilterViewController *vc = [nextStoryboard instantiateViewControllerWithIdentifier:[@(LIVEFILTER_VC) stringValue]];
        vc.liveStringObject = liveStreaming;
        vc.filterCatArry = selectedCatArry;
        vc.filtercountries = filterCountries;
        vc.filterstates = filterStates;
        vc.filtercities = filtercities;
        vc.setSelectedMale = isSelectedMale;
        vc.setSelectedFemale = isSelectedFemale;
        vc.filterageArray = filterAges;
        vc.filterselectedEthnicities = filterEthnicities;
        vc.filterselectedLooks = filterLooks;
        vc.filterselectedTags = filterTags;
        vc.filterproducts = filterProducts;
        vc.filterbrands = filterBrands;
        
        vc.filterDelegate = self;
        CATransition* transition = [CATransition animation];
        transition.duration = 0.2;
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        [self.view.window.layer addAnimation:transition forKey:kCATransition];
        [self presentViewController:vc animated:NO completion:nil];
    }
}
- (void)setCategories:(LiveFilterViewController*)vc Arry: (NSMutableArray *)aryy
{
    
    selectedCatArry = aryy;
   
    for (int i = 0; i < catArry.count; i++) {
        BOOL isSelected = NO;
        UIButton *sender = [catButtons objectAtIndex:i];
        
        for (LiveStreamingCategory *selCat in selectedCatArry) {
            LiveStreamingCategory  *cat = [catArry objectAtIndex:i];
            

            if ([selCat.idLiveStreamingCategory isEqualToString:cat.idLiveStreamingCategory]) {
                isSelected = YES;
                categoryID = cat.idLiveStreamingCategory;
                NSLog(@"seleced Category ---> %@,  id ----> %@", cat.name, categoryID);
                break;
            }
            
        }
        [UIView animateWithDuration:0.4 animations:^{
            [sender setBackgroundColor:CLICKING_TRANSPARENT_COLOR];
        }
         completion:^(BOOL finished) {
             [sender setBackgroundColor:isSelected? CLICKED_TRANSPARENT_COLOR: TOPBAR_TRANSPARENT_COLOR];
             
         }];
    }
    
    if (filterCountries.count > 0)
        [filterCountries removeAllObjects];
    filterCountries = [[NSMutableArray alloc]initWithArray: vc.filtercountries];
    
    filterStates = vc.filterstates.mutableCopy;
    filtercities = vc.filtercities.mutableCopy;

    filterAges = vc.filterageArray.mutableCopy;
    filterEthnicities = vc.filterselectedEthnicities.mutableCopy;
    filterLooks = vc.filterselectedLooks.mutableCopy;
    filterTags = vc.filterselectedTags.mutableCopy;
    
}
- (void)setGender:(LiveFilterViewController *)vc Male:(BOOL)isMale Female:(BOOL)isFemale
{
    isSelectedMale = isMale;
    isSelectedFemale = isFemale;
}

- (void)setProducts:(LiveFilterViewController*)vc Arry:(NSMutableArray*)products {
    filterProducts = products;
}
- (void)setBrands:(LiveFilterViewController*)vc Arry:(NSMutableArray*)brands {
    filterBrands = brands;
}
- (void)liveCommentAction:(UIButton*)sender
{
    NSLog(@"liveCommentAction");
}
- (void)liveChatAction:(UIButton*)sender
{
    NSLog(@"liveChatAction");
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:normalImgStr] forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}
- (void)privacyAction:(UIButton*)sender
{
    if (disableSettigns) return;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(_privacyBtn.frame.origin.x, _privacyBtn.frame.origin.y + _privacyBtn.frame.size.height, _privacyBtn.frame.size.width, _privacyBtn.frame.size.height * 3)];
    view.backgroundColor = TOPBAR_TRANSPARENT_COLOR;
    [self.view addSubview:view];
    
    for (int i = 0; i < privacyArry.count; i++) {
        LiveStreamingPrivacy *privacy = [privacyArry objectAtIndex:i];
        NSString *title = privacy.name;
        PrivacyBtnView *btnView = [[[NSBundle mainBundle] loadNibNamed:@"PrivacyBtnView" owner:self options:nil] objectAtIndex:0];
        if (i == activePricacyItem) {
            btnView.prBtn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:12];
        } else {
            btnView.prBtn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12];
        }
        [btnView.prBtn setTitle:title forState:UIControlStateNormal];
        btnView.frame = CGRectMake(0, _privacyBtn.bounds.size.height * i, _privacyBtn.bounds.size.width, _privacyBtn.bounds.size.height * 3);
        btnView.prBtn.tag = i;
        [btnView.prBtn addTarget:self action:@selector(priItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnView];
    }
    priview = view;
}

- (void)priItemAction: (UIButton*)sender {
    int tag = sender.tag;
    activePricacyItem = tag;
    LiveStreamingPrivacy *privacy = [privacyArry objectAtIndex:tag];

    
    [_privacyBtn setTitle:privacy.name forState:UIControlStateNormal];
    privacyID = privacy.idLiveStreamingPrivacy;
    
    [priview removeFromSuperview];
    priview = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self createArrows];
}

- (void)getPrivacyValues
{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
    
    
    [self performRestGet:GET_LIVESTREAMINGPRIVACY withParamaters:nil];
}

- (void)getCategoryList
{
    if (catArry.count > 0) return;
    
    NSLog(@"Getting live streaming category...");
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
    
    [self performRestGet:GET_LIVESTREAMINGCATEGORIES withParamaters:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)postLiveStreamingObject
{
//    if (selectedCatArry.count <= 0) {
//        [self.view bringSubviewToFront:_popupBGView];
//        _popupBGView.hidden = NO;
//        _popview.hidden = NO;
//        _ctgScrollView.hidden = YES;
//        
//        return;
//    }
    
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    LiveStreaming * newLiveStreaming;
//    if (livestreamingID != nil && ![livestreamingID isEqualToString:@""]) {
//        [self setBroadCasting];
//    } else {
        newLiveStreaming = [[LiveStreaming alloc] initWithEntity:[NSEntityDescription entityForName:@"LiveStreaming" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];

        //location
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSNumber *lat  = appDelegate.currentLocationLat;
        NSNumber *lng = appDelegate.currentLocationLon;
        [newLiveStreaming setLatitude:lat];
        [newLiveStreaming setLongitud:lng];
        
        CLGeocoder *ceo = [[CLGeocoder alloc]init];
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:[lat floatValue] longitude:[lng floatValue]]; //insert your coordinates
        
        [ceo reverseGeocodeLocation:loc
                  completionHandler:^(NSArray *placemarks, NSError *error) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      if (placemark) {
                          
                          
                          NSLog(@"placemark %@",placemark);
                          //String to hold address
                          NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                          NSLog(@"addressDictionary %@", placemark.addressDictionary);
                          
                          NSLog(@"placemark %@",placemark.region);
                          NSLog(@"placemark %@",placemark.country);  // Give Country Name
                          NSLog(@"placemark %@",placemark.locality); // Extract the city name
                          NSLog(@"location %@",placemark.name);
                          NSLog(@"location %@",placemark.ocean);
                          NSLog(@"location %@",placemark.postalCode);
                          NSLog(@"location %@",placemark.subLocality);
                          
                          NSLog(@"location %@",placemark.location);
                          //Print the location to console
                          NSLog(@"I am currently at %@",locatedAt);
                          [newLiveStreaming setLocation:[NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.country]];
                      }
                      else {
                          NSLog(@"Could not locate");
                      }
                  }
         ];
        
        //userid
        if (!(appDelegate.currentUser == nil))
        {
            if(!(appDelegate.currentUser.idUser == nil)) {
                [newLiveStreaming setOwnerId:appDelegate.currentUser.idUser];
            }
        }
        //title
        [newLiveStreaming setTitle:_titleTextField.text];

        //privacy
        if (privacyID != nil && ![privacyID isEqualToString:@""])
            [newLiveStreaming setPrivacyId:privacyID];
        //category
        
        NSLog(@"Uploading live streaming...");
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newLiveStreaming, [NSNumber numberWithBool:NO], nil];
        
        [self performRestPost:UPLOAD_LIVESTREAMING withParamaters:requestParameters];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) connectionStatusChanged:(VCSessionState) state
{
    switch(state) {
        case VCSessionStateStarting:
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"", nil)];

            //[self.btnConnect setTitle:@"Connecting" forState:UIControlStateNormal];
            break;
        case VCSessionStateStarted:
            [self stopActivityFeedback];
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(targetMethod:)
                                                   userInfo:nil
                                                    repeats:YES];
            if (!isBroadCasting) {
                disableSettigns = YES;
                settingBtn.enabled = NO;
                
                isBroadCasting = YES;
                _redDot.hidden = NO;
                _liveLbl.hidden = NO;
                [settingBtn setImage:[UIImage imageNamed:@"live_filter_inact.png"] forState:UIControlStateNormal];
                [_recordBtn setImage:[UIImage imageNamed:@"red_record.png"] forState:UIControlStateNormal];
                [self setupToolView:YES];
                [self showMarqueeLabel:YES];
                _ctgScrollView.hidden = YES;
                _viewers.hidden = YES;
                //        [captureSession startBroadCast:@"rtmp://messaging.goldenspear.com/live/osama" enableWrite:YES];
            }
            //[self.btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
            break;
        default:
           // [self.btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            break;
    }
}
- (void)targetMethod:(NSTimer *)timer {
    self.timeSec++;
    if (self.timeSec == 60)
    {
        self.timeSec = 0;
        self.timeMin++;
    }
    //Format the string 00:00
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d min", self.timeMin, self.timeSec];
    //Display on your label
    self.timeLab.text= timeNow;
    
    CGFloat moveX = _seekbar.bounds.size.width/MAX_TIME * (self.timeMin * 60 + self.timeSec);
    
    CGFloat tmp = _trackerMove.constant;
    
    if (tmp < _seekbar.bounds.size.width)
        _trackerMove.constant = tmp + moveX;
    else {
        _trackerMove.constant = 1.0f;
    }
    
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
}

- (BOOL)shouldCreateBottomButtons
{
    return YES;
}
- (BOOL)shouldTopbarTransparent{
    return YES;
}
- (void) setupTopView
{
    // Top bar title
    NSString * title = NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",[self.restorationIdentifier intValue]]), nil);
    
    
    // Set top bar title and subtitle
    [self setTopBarTitle:title andSubtitle:nil];
}

- (BOOL)shouldCreateBackButton{
    return YES;
}

- (BOOL)shouldCreateMenuButton
{
    return NO;
}
- (void)showMenu:(UIButton*)sender
{
    UIButton *lb = (UIButton*)sender;
    UIView *menuView = [[UIView alloc]initWithFrame:CGRectMake(lb.bounds.origin.x, lb.bounds.origin.y + lb.bounds.size.height, lb.bounds.size.width, 60)];
    menuView.backgroundColor = TOPBAR_TRANSPARENT_COLOR;
    //invite
    UIButton *invite = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, menuView.frame.size.width, 20)];
    [invite setTitle:@"Invite Only" forState:UIControlStateNormal];
    [invite setFont:[UIFont fontWithName:@"Avenir-Medium" size:20]];

    [invite setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [menuView addSubview:invite];
    [invite addTarget:self action:@selector(inviteAction:) forControlEvents:UIControlEventTouchUpInside];
    //public
    UIButton *pub = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, menuView.frame.size.width, 20)];
    [pub setTitle:@"Invite Only" forState:UIControlStateNormal];
    [pub setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [menuView addSubview:pub];
    [pub addTarget:self action:@selector(publicAction:) forControlEvents:UIControlEventTouchUpInside];
    //All friends
    UIButton *alFriend = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, menuView.frame.size.width, 20)];
    [alFriend setTitle:@"Invite Only" forState:UIControlStateNormal];
    [alFriend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [menuView addSubview:alFriend];
    [alFriend addTarget:self action:@selector(allFriendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:menuView];
    
    [UIView animateWithDuration:0.4 animations:^{
        menuView.frame = CGRectMake(menuView.frame.origin.x, menuView.frame.origin.y,
                                    menuView.frame.size.width, 20);
    }
     completion:^(BOOL finished) {
         menuView.frame = CGRectMake(menuView.frame.origin.x, menuView.frame.origin.y,
                                     menuView.frame.size.width, menuView.frame.size.height);
     }];
}

- (void)inviteAction:(UIButton*)sender
{
    
}

- (void)lbHandleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        [self showArrows];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        [self showArrows];
    }
}

// OVERRIDE: (Just to prevent from being at 'Zoomed Image View' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    [self dismissMe];
}

-(void) dismissMe {
    if (_session){
       [_session endRtmpSession];
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    
    // NSLog(@"%s: controller.view.window=%@", _func_, controller.view.window);
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

//Setup category scrollview
-(void)setupCategoryView
{
    CGFloat itemWidth = 70;
    CGFloat offsetX = 20;
    CGFloat offsetY = 10;
    CGFloat firstLine = 5;
    CGFloat secondLine = firstLine + offsetY + itemWidth;
    CGFloat currentPosX = 15;
    CGFloat currentPosY = 5;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(_ctgScrollView.bounds.origin.x, _ctgScrollView.bounds.origin.y, secondLine + (offsetX + itemWidth) * catArry.count, _ctgScrollView.bounds.size.height)];
    view.backgroundColor = [UIColor clearColor];
    [_ctgScrollView addSubview:view];
    
    for (int i = 0; i < catArry.count; i++) {
        LiveStreamingCategory *cat = [catArry objectAtIndex:i];
        UIButton *itemView = [[UIButton alloc]initWithFrame:CGRectMake(currentPosX, currentPosY, itemWidth, itemWidth)];
//        UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(currentPosX, currentPosY, itemWidth, itemWidth)];
        itemView.layer.cornerRadius = itemWidth/2;
        itemView.backgroundColor = TOPBAR_TRANSPARENT_COLOR;
        NSString *ctcount = [NSString stringWithFormat:@"%@", cat.numLiveStreams];
        
        UILabel *ctLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, itemWidth, 20)];
        ctLbl.text = ctcount;
        ctLbl.textAlignment = NSTextAlignmentCenter;
        ctLbl.textColor = [UIColor whiteColor];
        [ctLbl setFont:[UIFont fontWithName:@"Avenir-Medium" size:20]];
        [itemView addSubview:ctLbl];
        
        UILabel *nameLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, itemWidth/2 + 5, itemWidth, 15)];
        nameLbl.text = cat.name;
        nameLbl.textAlignment = NSTextAlignmentCenter;
        nameLbl.textColor = [UIColor whiteColor];
        [nameLbl setFont:[UIFont fontWithName:@"AvantGarde-Book" size:13]];
        [itemView addSubview:nameLbl];
        
        itemView.tag = i;

        [itemView addTarget:self action:@selector(clickedCatItem:) forControlEvents:UIControlEventTouchDown];
        
        [view addSubview:itemView];
        [catButtons addObject:itemView];
        
        currentPosX += itemWidth/2 + offsetX;
        if (currentPosY == firstLine) {
            currentPosY = secondLine;
        } else if(currentPosY == secondLine) {
            currentPosY = firstLine;
        }
    }
    _ctgScrollView.contentSize = CGSizeMake(currentPosX + itemWidth/2, _ctgScrollView.frame.size.height);
 
}
- (void)clickedCatItem:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    LiveStreamingCategory  *cat = [catArry objectAtIndex:tag];
    BOOL isSelected = NO;
    if ([selectedCatArry containsObject:cat]) {
        isSelected = NO;
        [selectedCatArry removeObject:cat];
    } else {
        isSelected = YES;
        [selectedCatArry addObject:cat];
    }
    
    
    categoryID = cat.idLiveStreamingCategory;
    NSLog(@"seleced Category ---> %@,  id ----> %@", cat.name, categoryID);
    
    
    [UIView animateWithDuration:0.4 animations:^{
        [sender setBackgroundColor:CLICKING_TRANSPARENT_COLOR];
        }
         completion:^(BOOL finished) {
             [sender setBackgroundColor:isSelected? CLICKED_TRANSPARENT_COLOR: TOPBAR_TRANSPARENT_COLOR];
             
         }];
    
   
}

- (IBAction)switchCam:(id)sender {
//    [captureSession changeCamera];
    VCCameraState cameraState = [_session cameraState];
    if (cameraState == VCCameraStateBack) {
         bool isTorch = [_session torch];
        if (isTorch) {
            [_flashBtn setImage:[UIImage imageNamed:@"live_flash_inact.png"] forState:UIControlStateNormal];
            [_session setTorch:NO];
        }
        [_session setCameraState:VCCameraStateFront];
    } else if (cameraState == VCCameraStateFront) {
        [_session setCameraState:VCCameraStateBack];
    }
}

- (void)setBroadCasting {
    switch(_session.rtmpSessionState) {
        case VCSessionStateNone:
        case VCSessionStatePreviewStarted:
        case VCSessionStateEnded:
        case VCSessionStateError:
            [_session startRtmpSessionWithURL:parentPath andStreamKey:livestreamingID];
            break;
        default:
            [_session endRtmpSession];
            break;
    }
    
    
}
- (IBAction)recordAction:(id)sender {
    if (isBroadCasting) {
        [self setupToolView:NO];
        [self showMarqueeLabel:NO];
        
        isBroadCasting = NO;
        _redDot.hidden = YES;
        _liveLbl.hidden = YES;
        [_recordBtn setImage:[UIImage imageNamed:@"recordBtn.png"] forState:UIControlStateNormal];
        
        [self stopTimer];
    } else {
        startedBroadcast = YES;
        if (!isPostSuccess) {
            [self preparingBroadCasting];
        } else {
            [self setBroadCasting];
        }
    }
    //[self setBroadCasting];
}

- (IBAction)hidePopupAction:(id)sender {
    [self.view sendSubviewToBack:_popupBGView];
    _popupBGView.hidden = YES;
    _popview.hidden = YES;
    _ctgScrollView.hidden = NO;
    
    [self getCategoryList];
}

- (IBAction)torchAction:(id)sender {
    VCCameraState cameraState = [_session cameraState];
    if (cameraState == VCCameraStateFront)
        return;
        
    bool isTorch = [_session torch];
    UIButton *btn = (UIButton*)sender;
    [btn setImage:isTorch? [UIImage imageNamed:@"live_flash_inact.png"]:  [UIImage imageNamed:@"live_flash.png"] forState:UIControlStateNormal];
    [_session setTorch:!isTorch];
    
}

CGFloat tmpConstrast;
- (void)showKeyNotificationMethod:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect viewRect = _actionView.bounds;
    
    tmpConstrast = _toolviewBottomMargin.constant;
    if (viewRect.size.height + tmpConstrast - keyboardFrameBeginRect.size.height < 30) {
        CGFloat offheight = 30 - (viewRect.size.height + tmpConstrast - keyboardFrameBeginRect.size.height);
        _toolviewBottomMargin.constant = tmpConstrast + offheight;
    }    
}


- (void)textViewDidBeginEditing:(UITextView *)textView {

}

- (void)textViewDidEndEditing:(UITextView *)textView {

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _toolviewBottomMargin.constant = tmpConstrast;
    [_actionView setNeedsDisplay];
    [_titleTextField resignFirstResponder];
    return YES;
}
- (void)preparingBroadCasting
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        [self postLiveStreamingObject];
        return;
    }
    
    if (settedCoreData && !isPostSuccess) {
        isPostSuccess = YES;
        [self updateLiveStreaming];
    }
}

- (void)addItemsToLiveStreaming
{
    postingCount = 0;
    
    [self addCategorytoLiveStreaming];
    [self addCountrytoLiveStreaming];
    [self addStatetoLiveStreaming];
    [self addCityLiveStreaming];
    postingEthnicityCount = 0;
    // [self uploadLiveStreamingEthnicity];
    [self addTypeLookLiveStreaming];
    [self addHashTagLiveStreaming];
    [self addProductCatLiveStreaming];
    [self addBrandLiveStreaming];

    if (postingCount == 0 && postingEthnicityCount == filterEthnicities.count) {
        [self setBroadCasting];
    }
}
#pragma mark - POST Filer
- (void)addCountrytoLiveStreaming
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (Country *cat in filterCountries) {
        if (cat.idCountry == nil || [cat.idCountry isEqualToString:@""])
            continue;
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        postingCount++;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming, livestreamingID, cat.idCountry, nil];
        
        [self performRestPost:ADD_COUNTRY_TO_LIVESTREAMING withParamaters:requestParameters];
    }
}
- (void)addStatetoLiveStreaming
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (StateRegion *cat in filterStates) {
        if (cat.idStateRegion == nil || [cat.idStateRegion isEqualToString:@""])
            continue;
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        postingCount++;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming,livestreamingID, cat.idStateRegion, nil];
        
        [self performRestPost:ADD_STATEREGION_TO_LIVESTREAMING withParamaters:requestParameters];
    }
}
- (void)addCityLiveStreaming
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (City *cat in filtercities) {
        if (cat.idCity == nil || [cat.idCity isEqualToString:@""])
            continue;
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        postingCount++;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming, livestreamingID, cat.idCity, nil];
        
        [self performRestPost:ADD_CITY_TO_LIVESTREAMING withParamaters:requestParameters];
    }
}
- (void)addTypeLookLiveStreaming
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (NSDictionary *dic in filterLooks) {
        TypeLook *typeLook = dic[@"TypeLookObject"];
        
        if (typeLook.idTypeLook == nil || [typeLook.idTypeLook isEqualToString:@""])
            continue;
        
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        postingCount++;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming,livestreamingID, typeLook.idTypeLook, nil];
        
        [self performRestPost:ADD_TYPELOOK_TO_LIVESTREAMING withParamaters:requestParameters];
    }
}

- (void)addHashTagLiveStreaming{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (Keyword *kw in filterTags) {
        if (kw.idKeyword == nil || [kw.idKeyword isEqualToString:@""])
            continue;
        
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        postingCount++;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming,livestreamingID, kw.idKeyword, nil];
        
        [self performRestPost:ADD_HASHTAG_TO_LIVESTREAMING withParamaters:requestParameters];
    }
    
}

- (void)addProductCatLiveStreaming{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (ProductGroup *product in filterProducts) {
        if (product.idProductGroup == nil || [product.idProductGroup isEqualToString:@""])
            continue;
        
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        postingCount++;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming, livestreamingID, product.idProductGroup, nil];
        
        [self performRestPost:ADD_PRODUCTCATEGORY_TO_LIVESTREAMING withParamaters:requestParameters];
    }
}

- (void)addBrandLiveStreaming
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (Brand *brand in filterBrands) {
        if (brand.idBrand == nil || [brand.idBrand isEqualToString:@""])
            continue;
        
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        postingCount++;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming, livestreamingID, brand.idBrand, nil];
        
        [self performRestPost:ADD_BRAND_TO_LIVESTREAMING withParamaters:requestParameters];
    }
}

-(void)updateLiveStreaming
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    // Provide feedback to user
    
    
    NSString *genderStr;
    if (!isSelectedMale && !isSelectedFemale) {
        genderStr = @"[0]";
    } else if (isSelectedMale && !isSelectedFemale) {
        genderStr = @"[1]";
    } else if (!isSelectedMale && isSelectedFemale) {
        genderStr = @"[2]";
    } else if (isSelectedMale && isSelectedFemale) {
        genderStr = @"[1,2]";
    }
    if (genderStr != nil && ![genderStr isEqualToString:@""]) {
        //        genderStr = [genderStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [liveStreaming setGender:genderStr];
    }
    
    //    [{"min":15,"max":35}]
    NSString *ageStr = nil;
    for (int i=0; i < filterAges.count; i++) {
        NSDictionary *dic = [filterAges objectAtIndex:i];
        NSString *minStr = dic[@"MinAge"];
        NSString *maxStr = dic[@"MaxAge"];
        if (i == 0)
            ageStr = [NSString stringWithFormat:@"{\"min\":%@,\"max\":%@}", minStr, maxStr];
        if (i > 0)
            ageStr = [NSString stringWithFormat:@"%@,{\"min\":%@,\"max\":%@}",ageStr ,minStr, maxStr];
    }
    if (ageStr != nil) {
        ageStr = [NSString stringWithFormat:@"[%@]", ageStr];
        //        ageStr = [ageStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [liveStreaming setAgeRange:ageStr];
    }
    
    
    if (ageStr != nil || genderStr != nil) {
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming, [NSNumber numberWithBool:YES], nil];
        postingCount++;
        [self performRestPost:UPLOAD_LIVESTREAMING withParamaters:requestParameters];
    }
}

- (void)uploadLiveStreamingEthnicity {
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    if (filterEthnicities.count > postingEthnicityCount) {
        NSDictionary *dic = [filterEthnicities objectAtIndex:postingEthnicityCount];
        if (dic == nil) return;
        
        // for (NSDictionary *dic in selectedEthnicities) {
        NSString *dicStr = [dic objectForKey:kIdKey];
        if (dicStr == nil || [dicStr isEqualToString:@""])
            return;
        NSLog(@"uploadlivestreamingEthnicity -------> %@", [dic objectForKey:kNameKey]);
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        LiveStreamingEthnicity * newLiveStreamingEthnicity;
        
        newLiveStreamingEthnicity = [[LiveStreamingEthnicity alloc] initWithEntity:[NSEntityDescription entityForName:@"LiveStreamingEthnicity" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
        
        [newLiveStreamingEthnicity setEthnicityId:dicStr];
        [newLiveStreamingEthnicity setLivestreamingId:liveStreaming.idLiveStreaming];
        NSLog(@"Uploading live streaming ethnicity...");
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newLiveStreamingEthnicity, nil];
        postingEthnicityCount++;
        
        [self performRestPost:UPLOAD_LIVESTREAMINGETHINICITY withParamaters:requestParameters];
        
    }
}


- (void)addCategorytoLiveStreaming
{
    if (livestreamingID == nil || [livestreamingID isEqualToString:@""]) {
        return;
    }
    
    for (LiveStreamingCategory *cat in selectedCatArry) {
        if (cat.idLiveStreamingCategory == nil || [cat.idLiveStreamingCategory isEqualToString:@""])
            continue;
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGLIVESTREAMING_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:liveStreaming, livestreamingID, cat.idLiveStreamingCategory, nil];
        postingCount++;
        [self performRestPost:ADD_LIVESTREAMINGCATEGORY_TO_LIVESTREAMING withParamaters:requestParameters];
    }
}

- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    __block LiveStreaming *liveStreamingObj;
    __block LiveStreamingPrivacy *liveStreamingPrivacyObj;
    __block LiveStreamingCategory *liveStreamingCategoryObj;
    switch (connection)
    {
        case UPLOAD_LIVESTREAMING:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[LiveStreaming class]]))
                 {
                     liveStreamingObj = obj;
                     
                     // Stop enumeration
                     *stop = YES;
                 }
             }];
            
            
            NSLog([NSString stringWithFormat:@"LiveStreaming successfully uploaded! Retrieved Id: %@", liveStreamingObj.idLiveStreaming]);
            settedCoreData = YES;
            liveStreaming = liveStreamingObj;
            livestreamingID = liveStreamingObj.idLiveStreaming;
          
            [self stopActivityFeedback];
            
            if (startedBroadcast) {
                if (isPostSuccess) {
                    [self addItemsToLiveStreaming];
                } else {
                    [self preparingBroadCasting];
                }
            }
            break;
        }
        case ADD_LIVESTREAMINGCATEGORY_TO_LIVESTREAMING:
        {
            NSLog(@"Adding category to livestreaing succesfully!");
            [self stopActivityFeedback];
            isAddedCategory = YES;
            isPostSuccess = YES;
            [self notifyPost];
            break;
        }
        case GET_LIVESTREAMINGPRIVACY:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[LiveStreamingPrivacy class]]))
                 {
                     liveStreamingPrivacyObj = obj;
                     [privacyArry addObject:liveStreamingPrivacyObj];
                 }
             }];

            settedCoreData = YES;

            [self stopActivityFeedback];
            break;
        }
        case GET_LIVESTREAMINGCATEGORIES:
        {
            // Get the LiveStreaming object mapped from the API call response
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[LiveStreamingCategory class]]))
                 {
                     liveStreamingCategoryObj = obj;
                     if (liveStreamingCategoryObj.idLiveStreamingCategory != nil) {
                         if (![liveStreamingCategoryObj.idLiveStreamingCategory isEqualToString:@""]) {
                             [catArry addObject:liveStreamingCategoryObj];
                         }
                     }
                 }
             }];
            
            
            NSLog(@"%@", [NSString stringWithFormat:@"LiveStreaming successfully uploaded! Retrieved Id: %ld", (unsigned long)catArry.count]);
            settedCoreData = YES;
            [self postLiveStreamingObject];

            [self setupCategoryView];
            [self stopActivityFeedback];

            break;
        }
        case ADD_COUNTRY_TO_LIVESTREAMING:
        {
            NSLog(@"Adding country to livestreaing succesfully!");
            [self stopActivityFeedback];
            isPostSuccess = YES;
            [self notifyPost];
            
            break;
        }
        case ADD_STATEREGION_TO_LIVESTREAMING:
        {
            NSLog(@"Adding state to livestreaing succesfully!");
            
            [self stopActivityFeedback];
            isPostSuccess = YES;
            [self notifyPost];
            
            break;
        }
        case ADD_CITY_TO_LIVESTREAMING:
        {
            NSLog(@"Adding cities to livestreaing succesfully!");
            
            [self stopActivityFeedback];
            isPostSuccess = YES;
            [self notifyPost];
            
            break;
        }
        case ADD_HASHTAG_TO_LIVESTREAMING:
        {
            NSLog(@"Adding Hash tag to livestreaing succesfully!");
            
            [self stopActivityFeedback];
            isPostSuccess = YES;
            [self notifyPost];
            
            break;
        }
        case ADD_TYPELOOK_TO_LIVESTREAMING:
        {
            NSLog(@"Adding type look to livestreaing succesfully!");
            
            [self stopActivityFeedback];
            isPostSuccess = YES;
            [self notifyPost];
            
            break;
        }
        case ADD_PRODUCTCATEGORY_TO_LIVESTREAMING:
        {
            NSLog(@"Adding product category to livestreaing succesfully!");
            
            [self stopActivityFeedback];
            isPostSuccess = YES;
            [self notifyPost];
            
            break;
        }
        case ADD_BRAND_TO_LIVESTREAMING:
        {
            NSLog(@"Adding brand to livestreaing succesfully!");
            [self stopActivityFeedback];
            isPostSuccess = YES;
            [self notifyPost];
            break;
        }
//        case UPLOAD_LIVESTREAMING:
//        {
//            NSLog(@"Uploading LiveStreamng with Gender and Age Range to livestreaing succesfully!");
//            
//            [self stopActivityFeedback];
//            isPostSuccess = YES;
//            [self notifyPost];
//            break;
//        }
        case UPLOAD_LIVESTREAMINGETHINICITY:
        {
            NSLog(@"Uploading LiveStreamng Ethnicity succesfully!");
            
            [self stopActivityFeedback];
            isPostSuccess = YES;
            if (postingEthnicityCount == filterEthnicities.count) {
                [self notifyPost];
            } else
                [self uploadLiveStreamingEthnicity];
            
            break;
        }
        default:
            [super actionAfterSuccessfulAnswerToRestConnection:connection WithResult:mappingResult];
            break;
    }
}

- (void)notifyPost
{
    postingCount--;
    NSLog(@"post count   %d", postingCount);
    if (postingCount <= 0) {
        if (postingEthnicityCount == filterEthnicities.count) {
            [self setBroadCasting];
        } else if (postingEthnicityCount < filterEthnicities.count) {
            [self uploadLiveStreamingEthnicity];
        }
    }
    
}
#pragma mark - Avoid user leave post creation unless cancelled or finished

- (void)leftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleLeftAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)homeAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)middleRightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}

- (void)rightAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_CANCELPOSTEDITING_", nil) message:NSLocalizedString(@"_CANCELLIVESTREAMINGATTRANSITION_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
    
    [alertView show];
    
    return;
}
@end
