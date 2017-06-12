//
//  BaseViewController+BottomControlsManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "SearchBaseViewController.h"
#import "LivePlayerViewController.h"
#import "LiveFilterViewController.h"
#import "GSTaggingViewController.h"
#import "UIButton+CustomCreation.h"
#import "UILabel+CustomCreation.h"
#import <objc/runtime.h>

static char LEFTBUTTON_KEY;
static char RIGHTBUTTON_KEY;
static char MIDDLELEFTBUTTON_KEY;
static char MIDDLERIGHTBUTTON_KEY;
static char HOMEBUTTON_KEY;

static char NOTIFICATIONIMAGE_KEY;

static char BOTTOMCONTROLSVIEW_KEY;
static char BOTTOMCONTROLSHEIGHTCONSTRAINT_KEY;
static char SEARCHBACKGROUNDADBUTTON_KEY;

static char CURRENTSHAREDOBJECT_KEY;
static char CURRENTPREVIEWIMAGE_KEY;
static char DOCCONTROLLER_KEY;

static char BOTTOMBARVIEW_KEY;

#define kBottomViewBackgroundColor clearColor
#define kBottomButtonsHeight 60
#define kBottomControlsBackgroundColor whiteColor
#define kBottomControlsAlpha 1
#define kBackgroundAdButtonHeight 30
#define kFontInBackgroundAdButton "Avenir-Light"
#define kFontSizeInBackgroundAdButton 12
#define kFontColorInBackgroundAdButton grayColor
#define kNumberOfShareHintsToShow 3

#define kAttemptsNum 3

@implementation BaseViewController (BottomControlsManagement)

#pragma mark - Bottom controls managememt


// Getter and setter for notificationImage
- (UIImageView *)notificationImage
{
    return objc_getAssociatedObject(self, &NOTIFICATIONIMAGE_KEY);
}

- (void)setNotificationImage:(UIImageView *)notificationImage
{
    objc_setAssociatedObject(self, &NOTIFICATIONIMAGE_KEY, notificationImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for middleLeftButton
- (UIButton *)middleLeftButton
{
    return objc_getAssociatedObject(self, &MIDDLELEFTBUTTON_KEY);
}

- (void)setMiddleLeftButton:(UIButton *)middleLeftButton
{
    objc_setAssociatedObject(self, &MIDDLELEFTBUTTON_KEY, middleLeftButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for middleRightButton
- (UIButton *)middleRightButton
{
    return objc_getAssociatedObject(self, &MIDDLERIGHTBUTTON_KEY);
}

- (void)setMiddleRightButton:(UIButton *)middleRightButton
{
    objc_setAssociatedObject(self, &MIDDLERIGHTBUTTON_KEY, middleRightButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for leftButton
- (UIButton *)leftButton
{
    return objc_getAssociatedObject(self, &LEFTBUTTON_KEY);
}

- (void)setLeftButton:(UIButton *)leftButton
{
    objc_setAssociatedObject(self, &LEFTBUTTON_KEY, leftButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for rightButton
- (UIButton *)rightButton
{
    return objc_getAssociatedObject(self, &RIGHTBUTTON_KEY);
}

- (void)setRightButton:(UIButton *)rightButton
{
    objc_setAssociatedObject(self, &RIGHTBUTTON_KEY, rightButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for homeButton
- (UIButton *)homeButton
{
    return objc_getAssociatedObject(self, &HOMEBUTTON_KEY);
}

- (void)setHomeButton:(UIButton *)homeButton
{
    objc_setAssociatedObject(self, &HOMEBUTTON_KEY, homeButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for bottomBarView
- (UIView *)bottomBarView
{
    return objc_getAssociatedObject(self, &BOTTOMBARVIEW_KEY);
}

- (void)setBottomBarView:(UIView *)bottomBarView
{
    objc_setAssociatedObject(self, &BOTTOMBARVIEW_KEY, bottomBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for bottomControlsView
- (UIScrollView *)bottomControlsView
{
    return objc_getAssociatedObject(self, &BOTTOMCONTROLSVIEW_KEY);
}

- (void)setBottomControlsView:(UIScrollView *)bottomControlsView
{
    objc_setAssociatedObject(self, &BOTTOMCONTROLSVIEW_KEY, bottomControlsView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for searchBackgroundAdButton
- (UIButton *)searchBackgroundAdButton
{
    return objc_getAssociatedObject(self, &SEARCHBACKGROUNDADBUTTON_KEY);
}

- (void)setSearchBackgroundAdButton:(UIButton *)searchBackgroundAdButton
{
    objc_setAssociatedObject(self, &SEARCHBACKGROUNDADBUTTON_KEY, searchBackgroundAdButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for bottomControlsHeightConstraint
- (NSLayoutConstraint *)bottomControlsHeightConstraint
{
    return objc_getAssociatedObject(self, &BOTTOMCONTROLSHEIGHTCONSTRAINT_KEY);
}

- (void)setBottomControlsHeightConstraint:(NSLayoutConstraint *)bottomControlsHeightConstraint
{
    objc_setAssociatedObject(self, &BOTTOMCONTROLSHEIGHTCONSTRAINT_KEY, bottomControlsHeightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for currentSharedObject
- (Share *)currentSharedObject
{
    return objc_getAssociatedObject(self, &CURRENTSHAREDOBJECT_KEY);
}

- (void)setCurrentSharedObject:(Share *)currentSharedObject
{
    objc_setAssociatedObject(self, &CURRENTSHAREDOBJECT_KEY, currentSharedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for currentPreviewImage
- (UIImage *)currentPreviewImage
{
    return objc_getAssociatedObject(self, &CURRENTPREVIEWIMAGE_KEY);
}

- (void)setCurrentPreviewImage:(UIImage *)currentPreviewImage
{
    objc_setAssociatedObject(self, &CURRENTPREVIEWIMAGE_KEY, currentPreviewImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for docController
- (UIDocumentInteractionController *)docController
{
    return objc_getAssociatedObject(self, &DOCCONTROLLER_KEY);
}

- (void)setDocController:(UIDocumentInteractionController *)docController
{
    objc_setAssociatedObject(self, &DOCCONTROLLER_KEY, docController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Basic call for bottom controls creation
- (void)createBottomControls
{
    // If not overriden, default actions are 'Post' / 'Share' and 'Search'
    [self createBottomControlsWithExtraButtons];
    
    if(![self.hintBackgroundView isHidden])
    {
        [self.view bringSubviewToFront:self.hintBackgroundView];
        [self.view bringSubviewToFront:self.hintView];
    }
}

int iii = 0;

- (void)moveScrollBar{
    CGSize contentSize = self.bottomControlsView.contentSize;
    [self.bottomControlsView setContentOffset:CGPointMake(contentSize.width-self.bottomControlsView.frame.size.width, 0) animated:YES];
}

// Bring view to top
- (void)bringBottomControlsToFront
{
    [self.view bringSubviewToFront:self.bottomBarView];
    //[self.view bringSubviewToFront:self.bottomControlsView];
}

// Check if the current view controller must show the bottom buttons
- (BOOL)shouldCreateBottomButtons
{
    // Create the bottom button for some specific ViewControllers: Product Sheet, Product Feature Search
    if (([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(PRODUCTSHEET_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(PRODUCTFEATURESEARCH_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(VISUALSEARCH_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(REQUIREDPROFILESTYLIST_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(USERPROFILE_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(ACCOUNT_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(STYLIST_VC) stringValue]])  ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAMAINPAGE_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(STYLES_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(NOTIFICATIONS_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(NEWSFEED_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(LIKES_VC) stringValue]]) ||
         ([self.restorationIdentifier isEqualToString:[@(TAGGEDHISTORY_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(CHANGEPASSWORD_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(HELPSUPPORT_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(LINKACCOUNTS_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FRIENDS_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(CREATEPOST_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(DISCOVER_VC) stringValue]])

        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the bottom button for the background Ad
- (BOOL)shouldCreateBackgroundAdButton
{
    // Only Search should show it...
    if (([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]])
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must adapt the viewconstraint to the bottom controls height
- (BOOL)shouldAdaptViewToBottomControlsHeight
{
    // Adapt only some ViewControllers to the bottom controls height: Product Sheet
    if (([self.restorationIdentifier isEqualToString:[@(PRODUCTSHEET_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAMAINPAGE_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(STYLES_VC) stringValue]])
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)createBasicBottomControls{
    BOOL bShouldCreateBottomButtons = [self shouldCreateBottomButtons];
    BOOL bShouldCreateBackgroundAdButton = [self shouldCreateBackgroundAdButton];
    BOOL bShouldAdaptViewToBottomControlsHeight = [self shouldAdaptViewToBottomControlsHeight];
    
    if(!(self.bottomBarView == nil))
    {
        // Remove subviews from previous usage of this cell
        [[self.bottomBarView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.bottomBarView removeFromSuperview];
        self.bottomBarView = nil;
    }
    
    self.bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  self.view.frame.size.height-(kBackgroundAdButtonHeight * bShouldCreateBackgroundAdButton)-(kBottomButtonsHeight * bShouldCreateBottomButtons)-(1*bShouldCreateBottomButtons),
                                                                  self.view.frame.size.width,
                                                                  (kBackgroundAdButtonHeight * bShouldCreateBackgroundAdButton)+(kBottomButtonsHeight * bShouldCreateBottomButtons)+(1*bShouldCreateBottomButtons))];
    
    [self.bottomBarView setBackgroundColor:[UIColor kBottomViewBackgroundColor]];
    
    if(!(self.bottomControlsView == nil))
    {
        // Remove subviews from previous usage of this cell
        [[self.bottomControlsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.bottomControlsView removeFromSuperview];
        self.bottomControlsView = nil;
    }
    CGFloat buttonsHeight = kBottomButtonsHeight* bShouldCreateBottomButtons;
    self.bottomControlsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                             self.bottomBarView.frame.size.height-buttonsHeight,
                                                                             self.view.frame.size.width,
                                                                             buttonsHeight)];
    
    [self.bottomControlsView setBackgroundColor:[UIColor whiteColor]];
    
    // Add button to view
    [self.bottomBarView addSubview:self.bottomControlsView];
    
    // Buttons
    if (bShouldCreateBottomButtons)
    {
        [self createBottomControlsWithOrigin:CGPointMake(0, self.bottomControlsView.frame.size.height-kBottomButtonsHeight) andSize:CGSizeMake(self.bottomControlsView.frame.size.width, kBottomButtonsHeight)];
    }
    
    if(bShouldCreateBackgroundAdButton)
    {
        // Set the menu button
        self.searchBackgroundAdButton = [UIButton createButtonWithOrigin:CGPointMake(0, 0)
                                                                 andSize:CGSizeMake(self.bottomBarView.frame.size.width, kBackgroundAdButtonHeight)
                                                          andBorderWidth:0.0
                                                          andBorderColor:[UIColor clearColor]
                                                                 andText:NSLocalizedString(@"_BACKGROUNDAD_TEXT_DEFAULT_", nil)
                                                                 andFont:[UIFont fontWithName:@kFontInBackgroundAdButton size:kFontSizeInBackgroundAdButton]
                                                            andFontColor:[UIColor kFontColorInBackgroundAdButton]
                                                          andUppercasing:YES
                                                            andAlignment:UIControlContentHorizontalAlignmentCenter
                                                                andImage:nil
                                                            andImageMode:UIViewContentModeScaleAspectFit
                                                      andBackgroundImage:nil];
        
        // Button action
        [self.searchBackgroundAdButton addTarget:self action:@selector(onTapBackgroundAdButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // Start hidden
        [self.searchBackgroundAdButton setHidden:YES];
        
        // Add button to view
        [self.bottomBarView addSubview:self.searchBackgroundAdButton];
    }
    
    // Stroke line
    if(bShouldCreateBottomButtons)
    {
        CGRect barFrame = self.bottomBarView.bounds;
        UIView *strokeView = [[UIView alloc] initWithFrame:CGRectMake(barFrame.origin.x, barFrame.origin.y+barFrame.size.height-self.homeButton.frame.size.height-1, self.bottomBarView.frame.size.width, 1)];
        
        [strokeView setBackgroundColor:[UIColor darkGrayColor]];
        
        [strokeView setAlpha:0.35];
        
        [self.bottomBarView addSubview:strokeView];
    }
    
    [self.view addSubview:self.bottomBarView];
    
    if (bShouldAdaptViewToBottomControlsHeight)
    {
        self.bottomControlsHeightConstraint.constant = self.bottomBarView.frame.size.height;
    }
}

- (void)addExtraButton:(NSString*)iconName withHandler:(SEL)handler{
    UIView* controlsView = [self.bottomControlsView viewWithTag:100];
    UIView* lastButton = [controlsView.subviews lastObject];
    CGPoint buttonOrigin = CGPointMake(lastButton.frame.origin.x+lastButton.frame.size.width, 0);
    
    UIButton * button = [UIButton createButtonWithOrigin:buttonOrigin
                                                 andSize:lastButton.frame.size
                                          andBorderWidth:0.0
                                          andBorderColor:[UIColor clearColor]
                                                 andText:@""
                                                 andFont:[UIFont systemFontOfSize:15]
                                            andFontColor:[UIColor blackColor]
                                          andUppercasing:YES
                                            andAlignment:UIControlContentHorizontalAlignmentCenter
                                                andImage:nil
                                            andImageMode:UIViewContentModeScaleAspectFit
                                      andBackgroundImage:nil];
    [self assignButtonImage:button withName:iconName];
    // Button Action
    [button addTarget:self action:handler forControlEvents:UIControlEventTouchUpInside];
    // Add button to view
    [controlsView addSubview:button];
    CGRect theFrame = controlsView.frame;
    theFrame.size.width += button.frame.size.width;
    controlsView.frame = theFrame;
    self.bottomControlsView.scrollEnabled = YES;
    self.bottomControlsView.contentSize = CGSizeMake(theFrame.size.width,1);
}

- (void)addExtraButtons{
    
}

// Create Bottom controls
- (void)createBottomControlsWithExtraButtons
{
    [self createBasicBottomControls];
    [self addExtraButtons];
}

- (void)createBottomControlsWithOrigin: (CGPoint)controlsOrigin andSize: (CGSize)controlsSize
{
    UIView * controlsView = [[UIView alloc] initWithFrame:CGRectMake(controlsOrigin.x, controlsOrigin.y, controlsSize.width, controlsSize.height)];
    controlsView.tag = 100;
    
    // View appearance
    [controlsView setBackgroundColor:[UIColor kBottomControlsBackgroundColor]];
    [controlsView setAlpha:kBottomControlsAlpha];
    
    // We want a margin of N units per side
    float fMargin = 0;
    
    float fButtonSize = controlsView.frame.size.width/5;
    float fBottomButtonSpace = (controlsView.frame.size.width-fMargin*2.0-fButtonSize)/4.0; // Div by N-1
    
    float fClickableSpace = (controlsView.frame.size.width-fMargin*2.0-fButtonSize)/4.0; // Div by N-1
    CGPoint buttonOrigin;
    
    SEL axAction[] = { @selector(leftAction:), @selector(middleLeftAction:), @selector(homeAction:), @selector(middleRightAction:), @selector(rightAction:)};
    
    for(int i = 0; i < 5; i++)
    {
        buttonOrigin = CGPointMake(fMargin + fBottomButtonSpace*i, 0);

        UIButton * button = [UIButton createButtonWithOrigin:buttonOrigin
                             
                                                     andSize:CGSizeMake(fClickableSpace, controlsView.frame.size.height)
                                              andBorderWidth:0.0
                                              andBorderColor:[UIColor clearColor]
                                                     andText:@""
                                                     andFont:[UIFont systemFontOfSize:15]
                                                andFontColor:[UIColor blackColor]
                                              andUppercasing:YES
                                                andAlignment:UIControlContentHorizontalAlignmentCenter
                                                    andImage:nil
                                                andImageMode:UIViewContentModeScaleAspectFit
                                          andBackgroundImage:nil];
        button.tag = i;
        // Button Action
        [button addTarget:self action:axAction[i] forControlEvents:UIControlEventTouchUpInside];
        // Add button to view
        [controlsView addSubview:button];
        
        // Create
        switch(i)
        {
            case 0:
                self.leftButton = button; break;
            case 1:
                self.middleLeftButton = button; break;
            case 2:
                self.homeButton = button; break;
            case 3:
                self.middleRightButton = button; break;
            case 4:
                self.rightButton = button; break;
        }
    }
    
    // Add view
    [self.bottomControlsView addSubview:controlsView];
    
    [self setNavigationButtons];
    self.bottomControlsView.scrollEnabled = NO;
    
    [self autoSelectButton];
}

- (void)selectAButton{
    
}

- (void)autoSelectButton{
    [self selectAButton];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastSelectedButton = [[defaults objectForKey:GSLastTabSelected] integerValue];
    if (lastSelectedButton>=0) {
        UIButton* theButton;
        switch (lastSelectedButton) {
            case 1:
                theButton = self.middleLeftButton;
                break;
            case 2:
                theButton = self.homeButton;
                break;
            case 3:
                theButton = self.middleRightButton;
                break;
            case 4:
                theButton = self.rightButton;
                break;
            default:
                theButton = self.leftButton;
                break;
        }
        theButton.selected = YES;
    }
}

- (void)assignButtonImage:(UIButton*)theButton withName:(NSString*)imageName{
    [theButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageName]] forState:UIControlStateNormal];
    [theButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_on.png",imageName]] forState:UIControlStateSelected];
}

- (void)setButtonImage:(NSInteger)index withName:(NSString*)imageName{
    UIButton* theButton;
    switch(index)
    {
        case 0:
            theButton = self.leftButton; break;
        case 1:
            theButton = self.middleLeftButton; break;
        case 2:
            theButton = self.homeButton; break;
        case 3:
            theButton = self.middleRightButton; break;
        case 4:
        default:
            theButton = self.rightButton; break;
    }
    [self assignButtonImage:theButton withName:imageName];
}

- (void)setupNotificationsLabel{
    [self.notificationImage removeFromSuperview];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate.userNewNotifications intValue] > 0)
    {
        //Prepare the notification image
        CGRect buttonFrame = self.middleLeftButton.bounds;
        self.notificationImage = [[UIImageView alloc] initWithFrame:buttonFrame];
        [self.notificationImage setContentMode:UIViewContentModeScaleAspectFit];
        
        UIView* fullBackground = [[UIView alloc] initWithFrame:buttonFrame];
        CGRect circleFrame = CGRectMake(buttonFrame.size.width*0.6,buttonFrame.size.height*0.2,buttonFrame.size.width*0.2,buttonFrame.size.width*0.2);
        
        UIView* circleView = [[UIView alloc] initWithFrame:circleFrame];
        circleView.layer.cornerRadius = circleView.frame.size.width/2;
        circleView.backgroundColor = [UIColor redColor];
        
        UILabel * numberLabel = [UILabel createLabelWithOrigin:circleFrame.origin
                                                       andSize:circleFrame.size
                                            andBackgroundColor:[UIColor clearColor]
                                                      andAlpha:1.0
                                                       andText:[appDelegate.userNewNotifications stringValue]
                                                  andTextColor:[UIColor whiteColor]
                                                       andFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]
                                                andUppercasing:YES
                                                    andAligned:NSTextAlignmentCenter];
        [fullBackground addSubview:circleView];
        [fullBackground addSubview:numberLabel];
        
        UIGraphicsBeginImageContextWithOptions(fullBackground.bounds.size, NO, 0.0);
        
        [fullBackground.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *notificationImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        self.notificationImage.image = notificationImage;
        
        [self.middleLeftButton addSubview:self.notificationImage];
    }
    [self.bottomControlsView layoutIfNeeded];
}

- (void)setNavigationButtons
{
    [self setButtonImage:0 withName:@"newsfeed_ico"];
    [self setButtonImage:1 withName:@"profile_ico"];
    [self setButtonImage:2 withName:@"post_ico"];
    [self setButtonImage:3 withName:@"discover_ico"];
    [self setButtonImage:4 withName:@"search_ico"];
    
    [self setupNotificationsLabel];
}

// Capture screen to share it
- (UIImage *)getScreenCapture
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else
    {
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
    }
    
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

// Post
- (void)postAction
{
    [self showMainMenu:nil];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(([appDelegate.currentUser.isFashionista boolValue]) == YES)
        {
            if(!(appDelegate.currentUser.idUser == nil))
            {
                if(!([appDelegate.currentUser.idUser isEqualToString: @""]))
                {
                    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                    
                    FashionistaPost * newPost = [[FashionistaPost alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaPost" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                    
                    [newPost setUserId:appDelegate.currentUser.idUser];
                    
                    [newPost setType:@"article"];
                    
                    [currentContext processPendingChanges];
                    
                    [currentContext save:nil];

                    if(!(newPost == nil))
                    {
                        if((!(newPost.userId == nil)) && (!([newPost.userId isEqualToString:@""])))
                        {
                            NSLog(@"Uploading fashionista post...");
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPost, [NSNumber numberWithBool:NO], nil];
                            
                            [self performRestPost:UPLOAD_FASHIONISTAPOST_FORSHARE withParamaters:requestParameters];
                            
                        }
                    }
                }
            }
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImage *imageToShare = [UIImage imageNamed:@"Logo.png"];
    
    NSString *messageToShare = NSLocalizedString(@"_SHARE_GENERIC_MSG_", nil);
    
    NSURL * urlToShare = [NSURL URLWithString:NSLocalizedString(@"_SHARE_GENERIC_URL_", nil)];
    
    if(self.currentSharedObject == nil)
    {
        // Shared Items
        imageToShare = [self getScreenCapture];
    }
    else
    {
        if(!(self.currentSharedObject.idShare == nil))
        {
            if(!([self.currentSharedObject.idShare isEqualToString:@""]))
            {
                // Shared Items
                
                if(!(self.currentPreviewImage == nil))
                {
                    imageToShare = self.currentPreviewImage;
                }
                
                if((!(self.currentSharedObject.sharedPostId == nil)) && (!([self.currentSharedObject.sharedPostId isEqualToString:@""])))
                {
                    messageToShare = NSLocalizedString(@"_SHARE_POST_MSG_", nil);
                    urlToShare = [NSURL URLWithString:[NSString stringWithFormat:NSLocalizedString(@"_SHARE_POST_URL_", nil), self.currentSharedObject.idShare]];
                }
                else if((!(self.currentSharedObject.sharedProductId == nil)) && (!([self.currentSharedObject.sharedProductId isEqualToString:@""])))
                {
                    messageToShare = NSLocalizedString(@"_SHARE_PRODUCT_MSG_", nil);
                    urlToShare = [NSURL URLWithString:[NSString stringWithFormat:NSLocalizedString(@"_SHARE_PRODUCT_URL_", nil), self.currentSharedObject.idShare]];
                }
                
            }
        }
    }
    
    
    if (buttonIndex == 0) // FACEBOOK
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *facebookController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                
                [facebookController dismissViewControllerAnimated:YES completion:nil];
                
                switch(result)
                {
                    case SLComposeViewControllerResultDone:
                    {
                        NSLog(@"Shared...");
                        [self afterSharedIn:@"facebook"];
                        break;
                    }
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        NSLog(@"Cancelled...");
                        
                        break;
                    }
                }};
            
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.string = messageToShare;

            [facebookController setInitialText:messageToShare];
            [facebookController addImage:imageToShare];
            [facebookController addURL:urlToShare];
            [facebookController setCompletionHandler:completionHandler];
            [self presentViewController:facebookController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FACEBOOK_",nil)
                                                            message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        self.currentSharedObject = nil;
        self.currentPreviewImage = nil;
    }
    else if (buttonIndex == 1) // TWITTER
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *twitterController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                
                [twitterController dismissViewControllerAnimated:YES completion:nil];
                
                switch(result)
                {
                    case SLComposeViewControllerResultDone:
                    {
                        NSLog(@"Shared...");
                        [self afterSharedIn:@"twitter"];
                        break;
                    }
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        NSLog(@"Cancelled...");
                        
                        break;
                    }
                }};

            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.string = messageToShare;

            [twitterController setInitialText:messageToShare];
            [twitterController addURL:urlToShare];
            [twitterController setCompletionHandler:completionHandler];
            [self presentViewController:twitterController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_TWITTER_",nil)
                                                            message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        self.currentSharedObject = nil;
        self.currentPreviewImage = nil;
    }
    else if (buttonIndex == 2) // INSTAGRAM
    {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]])
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *documentsPath = [paths objectAtIndex:0];
            
            NSString* savePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.igo"];
            
            BOOL result = NO;
            
            @autoreleasepool {
                
                NSData *imageData = UIImageJPEGRepresentation(imageToShare, 0.5);
                result = [imageData writeToFile:savePath atomically:YES];
                imageData = nil;
            }
            
            if(result)
            {
                self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
                
                [self.docController setDelegate:self];
                
                [self.docController setUTI:@"com.instagram.exclusivegram"];
                
                [self.docController setAnnotation:@{@"InstagramCaption" : [NSString stringWithFormat:@"%@ %@", messageToShare, urlToShare]}];
                
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                pasteBoard.string = [NSString stringWithFormat:@"%@ %@", messageToShare, urlToShare];
                
                [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
            }
            else
            {
                NSError *error = nil;
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                
                NSString *documentsPath = [paths objectAtIndex:0];
                
                NSString* deletePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.igo"];
                
                if (![[NSFileManager defaultManager] removeItemAtPath:deletePath error:&error])
                {
                    NSLog(@"Error cleaning up temporary image file: %@", error);
                }
                
                self.currentSharedObject = nil;
                self.currentPreviewImage = nil;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INSTAGRAM_",nil)
                                                                message:NSLocalizedString(@"_CANTSHAREIMAGE_",nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INSTAGRAM_",nil)
                                                            message:NSLocalizedString(@"_SOCIALNETWORKNOTAVAILABLE_",nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        self.currentSharedObject = nil;
        self.currentPreviewImage = nil;
    }
    else if (buttonIndex == 3) // PINTEREST
    {
        {
            // items to share
            NSArray *sharingItems =  @[messageToShare, imageToShare, urlToShare];
            
            // create the controller
            UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:sharingItems applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFacebook,
                                           UIActivityTypePostToTwitter,
                                           ];
            
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            activityVC.completionWithItemsHandler = ^(NSString *act, BOOL done, NSArray *returnedItems, NSError *activityError)
            {
                if ( done )
                {
                    NSLog(@"Shared in %@", act);
                    
                    [self afterSharedIn:act];
                }
            };
            
            [self presentViewController:activityVC animated:YES completion:nil];
        }
        
        self.currentSharedObject = nil;
        self.currentPreviewImage = nil;

    }
    else
    {
        NSLog(@"Cancel sharing");
        
        self.currentSharedObject = nil;
        self.currentPreviewImage = nil;
    }
}

// Perform Share
- (void) performSocialShareWithCurrentInfo
{
    
        UIActionSheet *sharingSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"_SHARE_BTN_",nil)
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"_CANCEL_BTN_",nil)
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:NSLocalizedString(@"_FACEBOOK_",nil), NSLocalizedString(@"_TWITTER_",nil), NSLocalizedString(@"_INSTAGRAM_",nil), NSLocalizedString(@"_PINTEREST_",nil),  /*NSLocalizedString(@"_OTHER_",nil),*/ nil];
    
        [sharingSheet showInView:self.view];
}

// Share
- (void) socialShareActionWithShareObject: (Share *)sharedObject andPreviewImage:(UIImage *) previewImage
{
    self.currentSharedObject = sharedObject;
    self.currentPreviewImage = previewImage;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults integerForKey:@"UserSharesNumber"])
    {
        [self showMessageWithImageNamed:@"HINT_share-paste.jpg"];
        
        [defaults setInteger:1 forKey:@"UserSharesNumber"];
        
        // Save to device defaults
        [defaults synchronize];
    }
    else
    {
        int iCurrentUserSharesNumber = (int)[defaults integerForKey:@"UserSharesNumber"];
        
        if(!(iCurrentUserSharesNumber >= kNumberOfShareHintsToShow))
        {
            [self showMessageWithImageNamed:@"HINT_share-paste.jpg"];
            
            [defaults setInteger:(iCurrentUserSharesNumber+1) forKey:@"UserSharesNumber"];
            
            // Save to device defaults
            [defaults synchronize];
        }
        else
        {
            [self performSocialShareWithCurrentInfo];
            
            [defaults setInteger:(iCurrentUserSharesNumber+1) forKey:@"UserSharesNumber"];
            
            // Save to device defaults
            [defaults synchronize];
        }
    }
}

-(void) showMessageWithImageNamed:(NSString *)imageName
{
    if(self.hintBackgroundView.hidden == NO)
        return;
    
    self.hintBackgroundView.hidden = NO;
    
    [self.view endEditing:YES];
    
    self.updatingHint = [NSNumber numberWithBool:NO];
    
    [self.hintView setImage:[UIImage imageNamed:imageName/*@"HINT_stylist-approval.jpg"*/]];
    
    self.hintLabel.text = NSLocalizedString(@"_SHARE_BTN_", nil);
    
    self.hintPrev.hidden = YES;
    self.hintNext.hidden = YES;
    
    self.hintBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.hintBackgroundView.alpha = 0.0;
    [self.view bringSubviewToFront:self.hintBackgroundView];
    
    self.hintView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.hintView.alpha = 0.0;
    self.hintView.hidden = NO;
    [self.view bringSubviewToFront:self.hintView];
    
    
    float fNewW = self.view.frame.size.width * 0.8;
    float fNewH = self.view.frame.size.height * 0.8;
    float fOffX = self.view.frame.size.width * 0.1;
    float fOffY = self.view.frame.size.height * 0.1;
    self.hintLabel.userInteractionEnabled = YES;
    self.hintLabel.alpha = 0.0;
    self.hintLabel.frame = CGRectMake(fOffX, fOffY-40, fNewW, 40);
    self.hintNext.frame = CGRectMake(fNewW - 30, 8, 25, 25);
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.hintView.frame = CGRectMake(fOffX, fOffY, fNewW, fNewH);
                         self.hintView.alpha = 1.0;
                         self.hintBackgroundView.alpha = 1.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.3
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^ {
                                              self.hintLabel.alpha = 1.0;
                                              
                                          } completion:^(BOOL finished) {
                                              
                                              
                                          }];
                         
                     }];
}

// Hide the hints view
- (void)hideMessage
{
    if(self.hintView.hidden)
        return;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.hintView.alpha = 0.0;
                         self.hintBackgroundView.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         self.hintView.hidden = YES;
                         self.hintBackgroundView.hidden = YES;
                         
                         if(!(self.currentSharedObject == nil))
                         {
                             [self performSocialShareWithCurrentInfo];
                         }
                     }];
}

-(UIDocumentInteractionController *)setupControllerWithURL:(NSURL *)fileURL usingDelegate:(id<UIDocumentInteractionControllerDelegate>) interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    interactionController.UTI = @"com.instagram.exclusivegram";
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString* deletePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.ig"];
    
    if (![[NSFileManager defaultManager] removeItemAtPath:deletePath error:&error])
    {
        NSLog(@"Error cleaning up temporary image file: %@", error);
    }
    
    self.currentSharedObject = nil;
    self.currentPreviewImage = nil;
    
    [self afterSharedIn:@"instagram"];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSError *error = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString* deletePath = [documentsPath stringByAppendingPathComponent:@"imageToShare.ig"];
    
    if (![[NSFileManager defaultManager] removeItemAtPath:deletePath error:&error])
    {
        NSLog(@"Error cleaning up temporary image file: %@", error);
    }
    
    self.currentSharedObject = nil;
    self.currentPreviewImage = nil;
}

// Background Ad action
- (void)onTapBackgroundAdButton:(UIButton *)sender
{
    return;
}

- (void)selectTheButton:(UIButton*)sender{
    NSInteger buttonIndex = sender.tag;
    if(!sender){
        buttonIndex = -1;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:buttonIndex] forKey:GSLastTabSelected];
    [defaults synchronize];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] resetMenuIndex];
}

- (void)leftAction:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        [self showProfileErrorMessage];
        [self middleLeftAction:nil];
        return;
    }
    [self transitionToViewController:NEWSFEED_VC withParameters:nil];
}

- (void)rightAction:(UIButton *)sender
{
    [self transitionToViewController:SEARCH_VC withParameters:nil];
}

- (void)middleLeftAction:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if([appDelegate.userNewNotifications intValue] > 0){
        //Show notices popup
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BasicScreens" bundle:[NSBundle mainBundle]];
        BaseViewController* theVC = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",NOTIFICATIONS_VC]];
        [self prepareViewController:theVC withParameters:nil];
        [self showViewControllerModal:theVC];
    }else{
        //Show user profile
        [self transitionToViewController:USERPROFILE_VC withParameters:nil];
    }
}

- (void)middleRightAction:(UIButton *)sender
{

    [self transitionToViewController:DISCOVER_VC withParameters:nil];
}

- (BOOL)taggingViewController
{
    [self postAction];
    
    return YES;

}
- (void)taggingCameraViewController
{
    [self setFromViewController:self.currentPresenterViewController];
    SCCaptureCameraController *conCam = [[SCCaptureCameraController alloc] init];
    conCam.delegate = self;
    [self presentViewController:conCam animated:YES completion:nil];
}
- (void)homeAction:(UIButton *)sender
{
//    NSString* destinationStoryboard = @"FashionistaContents";
//    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:destinationStoryboard bundle:nil];
//    
//    if (nextStoryboard != nil)
//    {
//        
//        LiveFilterViewController *vc = [nextStoryboard instantiateViewControllerWithIdentifier:[@(LIVEFILTER_VC) stringValue]];
//        CATransition* transition = [CATransition animation];
//        transition.duration = 0.2;
//        transition.type = kCATransitionMoveIn;
//        transition.subtype = kCATransitionFromRight;
//        [self.view.window.layer addAnimation:transition forKey:kCATransition];
//        [self presentViewController:vc animated:NO completion:nil];
//    }
//    return;
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        [self showProfileErrorMessage];
        [self middleLeftAction:nil];
        return;
    }
    [self taggingCameraViewController];

}

-(void)showProfileErrorMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                    message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                          otherButtonTitles:nil];
    [alert show];
}
@end
