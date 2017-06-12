//
//  BaseViewController+TopBarManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 20/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+UserManagement.h"

#import "UIButton+CustomCreation.h"
#import "UILabel+CustomCreation.h"
#import "SearchBaseViewController.h"
#import "FashionistaProfileViewController.h"
#import "FashionistaPostViewController.h"

#import <objc/runtime.h>

#define TOPBAR_TRANSPARENT_COLOR [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f]

#define kTopBarTitleLeftMargin 70
#define kTopBarImageViewWidth 50
#define kTopBarImageViewLeftMargin 10
#define kTopbarImageViewTopMargin 5

#define kTopBarProfileImageViewWidth 27
#define kTopBarProfileImageViewLeftMargin 38
#define kTopbarProfileImageViewTopMargin 17

#define kTopBarHeight 60
#define kTopBarElementsTopOffset 20
#define kTopBarElementsInterItemSpace 4
#define kTopBarElementsOuterSpace 20
#define kTopBarBackgroundColor whiteColor
#define kTopBarAlpha 1
#define kTopBarShadowOpacity 0.5
#define kTopBarShadowRadius 4
#define kTopBarSideShadowRadius 20

#define kMenuButtonHeight 30
#define kFontInMenuButton "Avenir-Light"
#define kFontSizeInMenuButton 18

#define kHintButtonHeight 30
#define kFontInHintButton "Avenir-Light"
#define kFontSizeInHintButton 18

#define kTopBarPortionForTitle 0.60
#define kFontInTitleLabel "AvantGarde-Book"
#define kFontSizeInTitleLabel 26

#define kFontInSubtitleLabel "AvantGarde-Book"
#define kFontSizeInSubtitleLabel 18

#define kFontInUsernameLabel "Avenir-Light"
#define kFontSizeInUsernameLabel 16

#define kFeaturesSearchButtonHeight 30
#define kFeaturesSearchButtonWidth 30
#define kFontInFeaturesSearchButton "Avenir-Light"
#define kFontSizeInFeaturesSearchButton 16

#define kReportButtonHeight self.subtitleLabel.frame.size.height
#define kFontInReportButton "Avenir-Light"
#define kFontSizeInReportButton 16

#define kAddTermButtonHeight 25
#define kFontInAddTermButton "Avenir-Light"
#define kFontSizeInAddTermButton 16

#define kPostAndStylistSearchButtonOuterInset 40
#define kPostAndStylistSearchButtonHeight 25
#define kPostAndStylistSearchButtonWidth 80
#define kFontInPostAndStylistSearchButton "Avenir-Medium"
#define kFontSizeInPostAndStylistSearchButton 14

#define kNotSuccessfulTermsLabelHeight 15
#define kFontInNotSuccessfulTermsLabel "Avenir-Light"
#define kFontSizeInNotSuccessfulTermsLabel 12

#define kSearchTermsListHeight 30
#define kSuggestedFiltersRibbonHeight 35

#define kFontInNoFilterTermsLabel "Avenir-Light"
#define kFontSizeInNoFilterTermsLabel 12

static char HINTVIEW_KEY;
static char HINTBACKGROUNDVIEW_KEY;
static char HINTLABEL_KEY;
static char HINTPREV_KEY;
static char HINTNEXT_KEY;
static char HINTCLOSE_KEY;
static char UPDATING_HINT;
static char REPORTBUTTON_KEY;
static char ADDTERMBUTTON_KEY;
static char POSTSEARCH_KEY;
static char STYLISTSEARCH_KEY;

static char TITLELABEL_KEY;
static char TITLEBUTTON_KEY;
static char SUBTITLELABEL_KEY;
static char USERNAMELABEL_KEY;
static char SUBTITLEBUTTON_KEY;
static char NOTSUCCESSFULTERMSLABEL_KEY;
static char TOPBARVIEW_KEY;
static char UPPERSECTION_KEY;
static char TOPBARHEIGHTCONSTRAINT_KEY;
static char SEARCHTERMSLISTVIEW_KEY;
static char SUGGESTEDFILTERSRIBBONVIEW_KEY;
static char SHOULDSHOWSUGGESTEDFILTERSRIBBONVIEW_KEY;
static char NOFILTERTERMSLABEL_KEY;
static char CLEARTERMSBUTTON_KEY;
static char RESETTERMSBUTTON_KEY;
static char MENUBUTTON_KEY;

static char NAVIGATIONARROWSVIEW_KEY;
static char TITLEPENCIL_KEY;
static char SUBTITLEPENCIL_KEY;

static char HIDESTOPBAR_KEY;

NSTimer* fadeOutTimer;
CGFloat maxLabelWidth;

@implementation BaseViewController (TopBarManagement)

#pragma mark - Top bar managememt

- (void) setHidesTopBar:(BOOL)hidesTopBar
{
    NSNumber *number = [NSNumber numberWithBool: hidesTopBar];
    objc_setAssociatedObject(self, &HIDESTOPBAR_KEY, number , OBJC_ASSOCIATION_RETAIN);
}

- (BOOL) hidesTopBar
{
    NSNumber *number = objc_getAssociatedObject(self, &HIDESTOPBAR_KEY);
    return [number boolValue];
}

//Getter and setter for titlePencil
- (UIImageView *)titlePencil
{
    return objc_getAssociatedObject(self, &TITLEPENCIL_KEY);
}

- (void)setTitlePencil:(UIImageView *)titlePencil
{
    objc_setAssociatedObject(self, &TITLEPENCIL_KEY, titlePencil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//Getter and setter for subtitlePencil

- (UIImageView *)subTitlePencil
{
    return objc_getAssociatedObject(self, &SUBTITLEPENCIL_KEY);
}

- (void)setSubTitlePencil:(UIImageView *)subTitlePencil
{
    objc_setAssociatedObject(self, &SUBTITLEPENCIL_KEY, subTitlePencil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//Getter and setter for navigationArrowsView

- (UIView *)navigationArrowsView
{
    return objc_getAssociatedObject(self, &NAVIGATIONARROWSVIEW_KEY);
}

- (void)setNavigationArrowsView:(UIView *)navArrowView
{
    objc_setAssociatedObject(self, &NAVIGATIONARROWSVIEW_KEY, navArrowView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for hintView
- (UIImageView *)hintView
{
    return objc_getAssociatedObject(self, &HINTVIEW_KEY);
}

- (void)setHintView:(UIImageView *)hintView
{
    objc_setAssociatedObject(self, &HINTVIEW_KEY, hintView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for hintBackgroundView
- (UIView *)hintBackgroundView
{
    return objc_getAssociatedObject(self, &HINTBACKGROUNDVIEW_KEY);
}

- (void)setHintBackgroundView:(UIImageView *)hintBackgroundView
{
    objc_setAssociatedObject(self, &HINTBACKGROUNDVIEW_KEY, hintBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for hintLabel
- (UILabel *)hintLabel
{
    return objc_getAssociatedObject(self, &HINTLABEL_KEY);
}

- (void)setHintLabel:(UILabel *)hintLabel
{
    objc_setAssociatedObject(self, &HINTLABEL_KEY, hintLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for hintPrev
- (UIButton *)hintPrev
{
    return objc_getAssociatedObject(self, &HINTPREV_KEY);
}

- (void)setHintPrev:(UIButton *)hintPrev
{
    objc_setAssociatedObject(self, &HINTPREV_KEY, hintPrev, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for hintNext
- (UIButton *)hintNext
{
    return objc_getAssociatedObject(self, &HINTNEXT_KEY);
}

- (void)setHintNext:(UIButton *)hintNext
{
    objc_setAssociatedObject(self, &HINTNEXT_KEY, hintNext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for hintClose
- (UIButton *)hintClose
{
    return objc_getAssociatedObject(self, &HINTCLOSE_KEY);
}

- (void)setHintClose:(UIButton *)hintClose
{
    objc_setAssociatedObject(self, &HINTCLOSE_KEY, hintClose, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for updatingHint
- (NSNumber *)updatingHint
{
    return objc_getAssociatedObject(self, &UPDATING_HINT);
}

- (void)setUpdatingHint:(NSNumber *)updatingHint
{
    objc_setAssociatedObject(self, &UPDATING_HINT, updatingHint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for titleLabel
- (UILabel *)titleLabel
{
    return objc_getAssociatedObject(self, &TITLELABEL_KEY);
}

- (void)setTitleLabel:(UILabel *)titleLabel
{
    objc_setAssociatedObject(self, &TITLELABEL_KEY, titleLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for titleButton
- (UIButton *)titleButton
{
    return objc_getAssociatedObject(self, &TITLEBUTTON_KEY);
}

- (void)setTitleButton:(UIButton *)titleButton
{
    objc_setAssociatedObject(self, &TITLEBUTTON_KEY, titleButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for subtitleLabel
- (UILabel *)subtitleLabel
{
    return objc_getAssociatedObject(self, &SUBTITLELABEL_KEY);
}

- (void)setSubtitleLabel:(UILabel *)subtitleLabel
{
    objc_setAssociatedObject(self, &SUBTITLELABEL_KEY, subtitleLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for usernameLabel
- (UILabel *)usernameLabel
{
    return objc_getAssociatedObject(self, &USERNAMELABEL_KEY);
}

- (void)setUsernameLabel:(UILabel *)usernameLabel
{
    objc_setAssociatedObject(self, &USERNAMELABEL_KEY, usernameLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for subtitleButton
- (UIButton *)subtitleButton
{
    return objc_getAssociatedObject(self, &SUBTITLEBUTTON_KEY);
}

- (void)setSubtitleButton:(UIButton *)subtitleButton
{
    objc_setAssociatedObject(self, &SUBTITLEBUTTON_KEY, subtitleButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for notSuccessfulTermsLabel
- (UILabel *)notSuccessfulTermsLabel
{
    return objc_getAssociatedObject(self, &NOTSUCCESSFULTERMSLABEL_KEY);
}

- (void)setNotSuccessfulTermsLabel:(UILabel *)notSuccessfulTermsLabel
{
    objc_setAssociatedObject(self, &NOTSUCCESSFULTERMSLABEL_KEY, notSuccessfulTermsLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for searchTermsListView
- (SlideButtonView *)searchTermsListView
{
    return objc_getAssociatedObject(self, &SEARCHTERMSLISTVIEW_KEY);
}

- (void)setSearchTermsListView:(SlideButtonView *)searchTermsListView
{
    objc_setAssociatedObject(self, &SEARCHTERMSLISTVIEW_KEY, searchTermsListView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for SuggestedFiltersRibbonView
- (SlideButtonView *)SuggestedFiltersRibbonView
{
    return objc_getAssociatedObject(self, &SUGGESTEDFILTERSRIBBONVIEW_KEY);
}

- (void)setSuggestedFiltersRibbonView:(SlideButtonView *)SuggestedFiltersRibbonView
{
    objc_setAssociatedObject(self, &SUGGESTEDFILTERSRIBBONVIEW_KEY, SuggestedFiltersRibbonView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for SuggestedFiltersRibbonView
- (NSNumber *)bShouldShowSuggestedFiltersRibbonView
{
    return objc_getAssociatedObject(self, &SHOULDSHOWSUGGESTEDFILTERSRIBBONVIEW_KEY);
}

- (void)setBShouldShowSuggestedFiltersRibbonView:(NSNumber *)bShouldShowSuggestedFiltersRibbonView
{
    objc_setAssociatedObject(self, &SHOULDSHOWSUGGESTEDFILTERSRIBBONVIEW_KEY, bShouldShowSuggestedFiltersRibbonView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for noFilterTermsLabel
- (UILabel *)noFilterTermsLabel
{
    return objc_getAssociatedObject(self, &NOFILTERTERMSLABEL_KEY);
}

- (void)setNoFilterTermsLabel:(UILabel *)noFilterTermsLabel
{
    objc_setAssociatedObject(self, &NOFILTERTERMSLABEL_KEY, noFilterTermsLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for topBarView
- (UIView *)topBarView
{
    return objc_getAssociatedObject(self, &TOPBARVIEW_KEY);
}

- (void)setTopBarView:(UIView *)topBarView
{
    objc_setAssociatedObject(self, &TOPBARVIEW_KEY, topBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for upperSection
- (UIView *)upperSection
{
    return objc_getAssociatedObject(self, &UPPERSECTION_KEY);
}

- (void)setUpperSection:(UIView *)upperSection
{
    objc_setAssociatedObject(self, &UPPERSECTION_KEY, upperSection, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for topBarHeightConstraint
- (NSLayoutConstraint *)topBarHeightConstraint
{
    return objc_getAssociatedObject(self, &TOPBARHEIGHTCONSTRAINT_KEY);
}

- (void)setTopBarHeightConstraint:(NSLayoutConstraint *)topBarHeightConstraint
{
    objc_setAssociatedObject(self, &TOPBARHEIGHTCONSTRAINT_KEY, topBarHeightConstraint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for menuButton
- (UIButton *)menuButton
{
    return objc_getAssociatedObject(self, &MENUBUTTON_KEY);
}

- (void)setMenuButton:(UIButton *)menuButton
{
    objc_setAssociatedObject(self, &MENUBUTTON_KEY, menuButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for clearTermsButton
- (UIButton *)clearTermsButton
{
    return objc_getAssociatedObject(self, &CLEARTERMSBUTTON_KEY);
}

- (void)setClearTermsButton:(UIButton *)clearTermsButton
{
    objc_setAssociatedObject(self, &CLEARTERMSBUTTON_KEY, clearTermsButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for reportButton
- (UIButton *)reportButton
{
    return objc_getAssociatedObject(self, &REPORTBUTTON_KEY);
}

- (void)setReportButton:(UIButton *)reportButton
{
    objc_setAssociatedObject(self, &REPORTBUTTON_KEY, reportButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for addTermButton
- (UIButton *)addTermButton
{
    return objc_getAssociatedObject(self, &ADDTERMBUTTON_KEY);
}

- (void)setAddTermButton:(UIButton *)addTermButton
{
    objc_setAssociatedObject(self, &ADDTERMBUTTON_KEY, addTermButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for postsSearch
- (UIButton *)postsSearch
{
    return objc_getAssociatedObject(self, &POSTSEARCH_KEY);
}

- (void)setPostsSearch:(UIButton *)postsSearch
{
    objc_setAssociatedObject(self, &POSTSEARCH_KEY, postsSearch, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for stylistsSearch
- (UIButton *)stylistsSearch
{
    return objc_getAssociatedObject(self, &STYLISTSEARCH_KEY);
}

- (void)setStylistsSearch:(UIButton *)stylistsSearch
{
    objc_setAssociatedObject(self, &STYLISTSEARCH_KEY, stylistsSearch, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for resetTermsButton
- (UIButton *)resetTermsButton
{
    return objc_getAssociatedObject(self, &RESETTERMSBUTTON_KEY);
}

- (void)setResetTermsButton:(UIButton *)resetTermsButton
{
    objc_setAssociatedObject(self, &RESETTERMSBUTTON_KEY, resetTermsButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Basic call for top bar creation
- (void)createTopBar
{
    // If not overriden, default title is 'Search' and subtitle is empty
    
    NSString * vcTitle = NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",[self.restorationIdentifier intValue]]), nil);
    
    NSString * vcSubtitle = NSLocalizedString(([NSString stringWithFormat:@"_VCSUBTITLE_%i_",[self.restorationIdentifier intValue]]), nil);
    if(!self.topBarView.hidden&&!self.hidesTopBar){
        [self createTopBarWithTitle:vcTitle andSubTitle: vcSubtitle];
    }
    if (self.currentPresenterViewController) {
        [self.currentPresenterViewController setTitleForModal:vcTitle];
    }
}

/*
// Basic call for top bar creation
- (void)createTopBar
{
    // If not overriden, default title is 'Search' and subtitle is empty
    
    NSString * vcTitle = NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",[self.restorationIdentifier intValue]]), nil);
    
    NSString * vcSubtitle = NSLocalizedString(([NSString stringWithFormat:@"_VCSUBTITLE_%i_",[self.restorationIdentifier intValue]]), nil);
    
    [self createTopBarWithTitle:vcTitle andSubTitle: vcSubtitle];
}
*/
// Set View Controller title and subtitle
#ifndef _ADD_OSAMA_
- (UIImage*) titleImage
{
    return nil;
}
#endif

#ifndef _Maksym
-(void)setProfileImage:(NSString*)imageURL {
    if (imageURL != nil) {
        UIImageView *titleImgView = [[UIImageView alloc]initWithFrame:CGRectMake(kTopBarProfileImageViewLeftMargin, kTopbarProfileImageViewTopMargin, kTopBarProfileImageViewWidth, kTopBarProfileImageViewWidth)];
        titleImgView.contentMode = UIViewContentModeScaleAspectFill;
        [titleImgView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
        [self.topBarView addSubview:titleImgView];
    }
}
#endif

- (void)setTopBarTitle:(NSString *)topBarTitle andSubtitle:(NSString *)topBarSubtitle
{
    BOOL bShouldCenterTitle = [self shouldCenterTitle];
    BOOL hasSubTitle = [self shouldCreateSubtitleLabel];
    
    if (!(topBarTitle == nil))
    {
        [self.titleLabel setText:[topBarTitle uppercaseString]];
        
        CGFloat labelHeight = self.titleLabel.frame.size.height;
        [self.titleLabel sizeToFit];
        CGRect labelFrame = self.titleLabel.frame;
        labelFrame.size.height = labelHeight;
        labelFrame.size.width = MIN(labelFrame.size.width,maxLabelWidth);
        self.titleLabel.frame = labelFrame;

        if (bShouldCenterTitle) {
            CGPoint theCenter = self.titleLabel.center;
            theCenter.x = self.topBarView.center.x;
            self.titleLabel.center = theCenter;
        } else {
            CGFloat titleHeight = (hasSubTitle ? (kTopBarHeight-(kTopBarElementsInterItemSpace*2))*kTopBarPortionForTitle :kTopBarHeight - 2*kTopBarElementsInterItemSpace);
            self.titleLabel.frame = CGRectMake(kTopBarTitleLeftMargin, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, titleHeight);
        }
        if([self shouldCreateEditPencils]){
            CGRect pencilFrame = self.titlePencil.frame;
            pencilFrame.size.height = self.titlePencil.frame.size.height;
            pencilFrame.origin.x = self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width+2;
            pencilFrame.origin.y = self.titleLabel.frame.origin.y;
            self.titlePencil.frame = pencilFrame;
        }
    }

    if (!(topBarSubtitle == nil))
    {
        [self.subtitleLabel setText:topBarSubtitle];
        
        CGFloat labelHeight = self.subtitleLabel.frame.size.height;
        [self.subtitleLabel sizeToFit];
        CGRect labelFrame = self.subtitleLabel.frame;
        labelFrame.size.height = labelHeight;
        labelFrame.size.width = MIN(labelFrame.size.width,maxLabelWidth);
        self.subtitleLabel.frame = labelFrame;
        
        if (bShouldCenterTitle) {
            CGPoint theCenter = self.subtitleLabel.center;
            theCenter.x = self.topBarView.center.x;
            self.subtitleLabel.center = theCenter;
        } else {
            CGFloat subtitleHeight = (hasSubTitle ? ((kTopBarHeight-(kTopBarElementsInterItemSpace*2))*(1-kTopBarPortionForTitle)) : 0.);
            self.subtitleLabel.frame = CGRectMake(kTopBarTitleLeftMargin, self.subtitleLabel.frame.origin.y, self.subtitleLabel.frame.size.width, subtitleHeight);
            [self.subtitleLabel sizeToFit];
        }
        
        if([self shouldCreateEditPencils]){
            CGRect pencilFrame = self.subTitlePencil.frame;
            pencilFrame.size.height = self.subTitlePencil.frame.size.height;
            pencilFrame.origin.x = self.subtitleLabel.frame.origin.x+self.subtitleLabel.frame.size.width+2;
            pencilFrame.origin.y = self.subtitleLabel.frame.origin.y;
            self.subTitlePencil.frame = pencilFrame;
        }
        
    }
}

-(void)setTitleColor:(UIColor*)color {
    self.titleLabel.textColor = color;
    self.subtitleLabel.textColor = color;
}

// Set View Controller not successful terms label
- (void)setNotSuccessfulTermsText:(NSString *)notSuccessfulTermsText
{
    if (!(notSuccessfulTermsText == nil))
    {
        [self.notSuccessfulTermsLabel setText:notSuccessfulTermsText];
    }
}

// Bring view to top
- (void)bringTopBarToFront
{
    [self.view bringSubviewToFront:self.topBarView];
    
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityLabel];
    [self.view bringSubviewToFront:self.hintBackgroundView];
    [self.view bringSubviewToFront:self.hintView];
}

- (float)topBarHeight
{
    return (self.upperSection.frame.size.height /*- (kSuggestedFiltersRibbonHeight * [self shouldCreateSuggestedFiltersRibbon])*/);
}

- (BOOL)shouldCenterTitle{
    return YES;
}

// Check if the current view controller must show the menu button
- (BOOL)shouldCreateTitleButton
{
    // Create the title button for some specific ViewControllers: FashionistaMainPage
    if (([self.restorationIdentifier isEqualToString:[@(FASHIONISTAMAINPAGE_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(PRODUCTSHEET_VC) stringValue]])
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the menu button
- (BOOL)shouldCreateSubtitleButton
{
    // Create the title button for some specific ViewControllers: FashionistaMainPage
    if (([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]])
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the left arrow
- (BOOL)shouldCreateBackButton{
    return ([self fromViewController] != nil);
}

// Check if the current view controller must show the right arrow
- (BOOL)shouldCreateForwardButton{
    return NO;
}

// Check if the current view controller must show the 'not successful terms' label
- (BOOL)shouldCreateNotSuccessfulTermsLabel
{
    return NO;
    
//    // Create the terms list for some specific ViewControllers: Results, History, Trending
//    if (([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]])
//        )
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
}

// Check if the current view controller must show the menu button
- (BOOL)shouldCreateMenuButton
{
    if ([self.restorationIdentifier isEqualToString:[@(SIGNIN_VC) stringValue]] || [self.restorationIdentifier isEqualToString:[@(FORGOTPWD_VC) stringValue]] || [self.restorationIdentifier isEqualToString:[@(EMAILVERIFY_VC) stringValue]] || [self.restorationIdentifier isEqualToString:[@(SIGNUP_VC) stringValue]] || [self.restorationIdentifier isEqualToString:[@(REQUIREDPROFILESTYLIST_VC) stringValue]] || [self.restorationIdentifier isEqualToString:[@(FASHIONISTACOVERPAGE_VC) stringValue]])
    {
        return NO;
    }
    
//    if ([self.restorationIdentifier isEqualToString:[@(EDITPROFILE_VC) stringValue]])
//    {
//        //Check if user is already loged in
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        
//        if ((appDelegate.currentUser == nil))
//        {
//            return NO;
//        }
//        else
//        {
//            return YES;
//        }
//    }
    
    // Do not create the button for some specific ViewControllers: Instructions
    if ((!([self.restorationIdentifier isEqualToString:[@(INSTRUCTIONS_VC) stringValue]])) && (!(([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]]) && (self.parentViewController != nil))))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (UIImage*)thirdButtonImage{
    return nil;
}

- (void)thirdButtonBarAction:(UIButton *)sender{
    
}

- (BOOL)shouldCreatethirdButton{
    return NO;
}

// Check if the current view controller must show the hint button
- (BOOL)shouldCreateHintButton
{
    return NO;
    
    // Do not create the button for some specific ViewControllers: Instructions
    if (![self.restorationIdentifier isEqualToString:[@(INSTRUCTIONS_VC) stringValue]] &&
        (!([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]] && (self.parentViewController != nil))))
    {
        [self checkAvailableHints];
        
        if(iNumHints == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the hint button
- (BOOL)shouldCreateEditPencils
{
    return NO;
}

// Check if the current view controller must show the hint button
- (BOOL)shouldCreateTitleLabel
{
    // Do not create the button for some specific ViewControllers: Instructions
    if ((!(([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]]) && (self.parentViewController != nil))))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the search terms list
- (BOOL)shouldCreateSearchTermsList
{
    // Create the terms list for some specific ViewControllers: Results and Search
    if (([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(PRODUCTFEATURESEARCH_VC) stringValue]])
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the 'Report' button
- (BOOL)shouldCreateReportButton
{
    return NO;
}

// Check if the current view controller must show the 'Add' and 'Features' buttons
- (BOOL)shouldCreateAddAndFeaturesButtons
{
    return NO;
    
    // Create the buttons for some specific ViewControllers: Results
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

// Check if the current view controller must show the 'PostSearch' and 'StylistSearch' buttons
- (BOOL)shouldCreatePostAndStylistsSearchButtons
{
    // Create the buttons for some specific ViewControllers: Results
    if (([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]])
        )
    {
        if(([((SearchBaseViewController *) self) searchContext] == FASHIONISTAPOSTS_SEARCH) || ([((SearchBaseViewController *) self) searchContext] == FASHIONISTAS_SEARCH))
        {
            return YES;
        }
    }

    return NO;
}

// Check if the current view controller must show the 'Clear' button
- (BOOL)shouldCreateClearButton
{
    // Create the terms list for some specific ViewControllers: Search & ProductFeatureSearch
    if ([self.restorationIdentifier isEqualToString:[@(PRODUCTFEATURESEARCH_VC) stringValue]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the 'Reset' button
- (BOOL)shouldCreateResetButton
{
    // Create the terms list for some specific ViewControllers: ProductFeatureSearch
    if (([self.restorationIdentifier isEqualToString:[@(PRODUCTFEATURESEARCH_VC) stringValue]]))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must show the filter terms suggestions
- (BOOL)shouldCreateSuggestedFiltersRibbon
{
    // Create the filter terms ribbon for some specific ViewControllers: Search
    if (([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(PRODUCTFEATURESEARCH_VC) stringValue]])
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Check if the current view controller must adapt the viewconstraint to the top bar height
- (BOOL)shouldAdaptViewToTopBarHeight
{
    // Adapt only some ViewControllers to the top bar height: Product Sheet
    if (([self.restorationIdentifier isEqualToString:[@(PRODUCTSHEET_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAMAINPAGE_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]])
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)shouldCreateSubtitleLabel{
    return NO;
}
- (BOOL)shouldTopbarTransparent{
    return NO;
}

-(BOOL)shouldCreateTopBar {
    if (([self.restorationIdentifier isEqualToString:[@(INSTRUCTIONS_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(SIGNIN_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(EMAILVERIFY_VC) stringValue]]) ||
        //        ([self.restorationIdentifier isEqualToString:[@(FORGOTPWD_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(SIGNUP_VC) stringValue]]) ||
        ([self.restorationIdentifier isEqualToString:[@(FASHIONISTACOVERPAGE_VC) stringValue]])
        )
    {
        return NO;
    }
    return YES;
}

-(void)createWardrobeButton {
    float fXRef = self.topBarView.frame.size.width;
    
    fXRef -= kHintButtonHeight;
    CGFloat yHintButton = floorf((kTopBarHeight - kHintButtonHeight)/2.);
    // Set the menu button
    UIButton * hangerbutton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,yHintButton)
                                                     andSize:CGSizeMake(kHintButtonHeight, kHintButtonHeight)
                                              andBorderWidth:0.0
                                              andBorderColor:[UIColor clearColor]
                                                     andText:NSLocalizedString(@"_HINT_BTN_", nil)
                                                     andFont:[UIFont fontWithName:@kFontInHintButton size:kFontSizeInHintButton]
                                                andFontColor:[UIColor blackColor]
                                              andUppercasing:YES
                                                andAlignment:UIControlContentHorizontalAlignmentCenter
                                                    andImage:[UIImage imageNamed:@"hanger_unchecked"]
                                                andImageMode:UIViewContentModeScaleAspectFit
                                          andBackgroundImage:nil];
    
    // Button action
    [hangerbutton addTarget:self action:@selector(onTapAddToWardrobeButton:) forControlEvents:UIControlEventTouchUpInside];
    hangerbutton.tag = -1;
    
    // Button transparency
    //[hintButton setAlpha:0.45];
    
    // Add button to view
    [self.topBarView addSubview:hangerbutton];
}
// Create top bar controls
- (void)createTopBarWithTitle: (NSString *) topTitle andSubTitle: (NSString *) topSubtitle;
{
    if (![self shouldCreateTopBar]) {
        return;
    }
    
    [self.topBarView removeFromSuperview];
    
    BOOL bShouldCreateMenuButton = [self shouldCreateMenuButton];
    BOOL bShouldCreateHintButton = [self shouldCreateHintButton];
    BOOL bShouldCreateThirdButton = [self shouldCreatethirdButton];
    BOOL bShouldCreateTitleLabel = [self shouldCreateTitleLabel];
    BOOL bShouldCreateSearchTermsList = [self shouldCreateSearchTermsList];
    BOOL bShouldCreateSuggestedFiltersRibbon = [self shouldCreateSuggestedFiltersRibbon];
    BOOL bShouldCreateReportButton = [self shouldCreateReportButton];
    BOOL bShouldCreateAddAndFeaturesButtons = [self shouldCreateAddAndFeaturesButtons];
    BOOL bShouldCreatePostAndStylistsSearchButtons = [self shouldCreatePostAndStylistsSearchButtons];
    BOOL bShouldCreateClearButton = [self shouldCreateClearButton];
    BOOL bShouldCreateResetButton = [self shouldCreateResetButton];
    BOOL bShouldCreateNotSuccessfulTermsLabel = [self shouldCreateNotSuccessfulTermsLabel];
    BOOL bShouldCreateTitleButton = [self shouldCreateTitleButton];
    BOOL bShouldCreateSubtitleButton = [self shouldCreateSubtitleButton];
    BOOL bShouldCreateEditPencils = [self shouldCreateEditPencils];
//    BOOL bShouldCenterTitle = [self shouldCenterTitle];
    BOOL bShouldTopbarTransparent = [self shouldTopbarTransparent];
    
    self.topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,/*kTopBarElementsInterItemSpace + */
                                                               kTopBarHeight - ((kTopBarHeight*kTopBarPortionForTitle)*(!bShouldCreateTitleLabel))+
                                                               ((kSearchTermsListHeight+kTopBarElementsInterItemSpace) * bShouldCreateSearchTermsList)+
                                                               (kNotSuccessfulTermsLabelHeight* bShouldCreateNotSuccessfulTermsLabel)+
                                                               (kSuggestedFiltersRibbonHeight * bShouldCreateSuggestedFiltersRibbon)+
                                                               ((kPostAndStylistSearchButtonHeight) * bShouldCreatePostAndStylistsSearchButtons)
                                                               )];
    
    // View appearance
    [self.topBarView setBackgroundColor:[UIColor clearColor]];
    [self.topBarView setAlpha:kTopBarAlpha];
    [self.topBarView setClipsToBounds:NO];
    
    
    // Set a white view as a backgroud and frame for the upper controls
    self.upperSection = [[UIView alloc] initWithFrame:CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y, self.topBarView.frame.size.width, (self.topBarView.frame.size.height-(kSuggestedFiltersRibbonHeight * bShouldCreateSuggestedFiltersRibbon)))];
    
    // Section appearance
#ifndef _ADD_OSAMA_
     [self.upperSection setBackgroundColor:bShouldTopbarTransparent? TOPBAR_TRANSPARENT_COLOR:[UIColor kTopBarBackgroundColor]];
#else
    [self.upperSection setBackgroundColor:[UIColor kTopBarBackgroundColor]];
#endif
    [self.upperSection setAlpha:kTopBarAlpha];
    [self.upperSection setClipsToBounds:NO];
    // Set the shadow
    self.upperSection.layer.shadowOpacity = kTopBarShadowOpacity;
    self.upperSection.layer.shadowRadius = kTopBarShadowRadius;
    
    // Setup a 'Double tap' recognizer
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.upperSection addGestureRecognizer:doubleTapGesture];
    
    // Add filter terms ribbon to view
    [self.topBarView addSubview:self.upperSection];
    
    float fXRef = self.topBarView.frame.size.width;
#ifndef _ADD_OSAMA_
    UIImage *titleImg = [self titleImage];
    if (titleImg != nil) {
        UIImageView *titleImgView = [[UIImageView alloc]initWithFrame:CGRectMake(kTopBarImageViewLeftMargin, kTopbarImageViewTopMargin, kTopBarImageViewWidth, kTopBarImageViewWidth)];
        titleImgView.contentMode = UIViewContentModeScaleAspectFill;
        titleImgView.image = titleImg;
        [self.topBarView addSubview:titleImgView];
    }
#endif
    
    // Menu button
    
    if (bShouldCreateMenuButton)
    {
        fXRef -= ((kTopBarElementsOuterSpace) + kHintButtonHeight);
        CGFloat yMenuButton = floorf((kTopBarHeight - kMenuButtonHeight)/2.);
        // Set the menu button
        self.menuButton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,yMenuButton)
                                                   andSize:CGSizeMake(kMenuButtonHeight, kMenuButtonHeight)
                                            andBorderWidth:0.0
                                            andBorderColor:[UIColor clearColor]
                                                   andText:NSLocalizedString(@"_MENU_BTN_",nil)
                                                   andFont:[UIFont fontWithName:@kFontInMenuButton size:kFontSizeInMenuButton]
                                              andFontColor:[UIColor blackColor]
                                            andUppercasing:YES
                                              andAlignment:UIControlContentHorizontalAlignmentCenter
                                                  andImage:bShouldTopbarTransparent? [UIImage imageNamed:@"live_direction.png"] : [UIImage imageNamed:@"Menu.png"]
//                                                  andImage:[UIImage imageNamed:@"Menu.png"]
                                              andImageMode:UIViewContentModeScaleAspectFit
                                        andBackgroundImage:nil];
        
        // Button action
        [self.menuButton addTarget:self action:@selector(showMainMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        // Button transparency
        //[self.menuButton setAlpha:0.45];
        
        // Add button to view
        [self.topBarView addSubview:self.menuButton];
    }
    
    // Hints button
    
    if (bShouldCreateHintButton)
    {
        fXRef -= (((bShouldCreateMenuButton) ? (kTopBarElementsInterItemSpace+10) : (kTopBarElementsOuterSpace)) + kHintButtonHeight);
        CGFloat yHintButton = floorf((kTopBarHeight - kHintButtonHeight)/2.);
        // Set the menu button
        UIButton * hintButton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,yHintButton)
                                                         andSize:CGSizeMake(kHintButtonHeight, kHintButtonHeight)
                                                  andBorderWidth:0.0
                                                  andBorderColor:[UIColor clearColor]
                                                         andText:NSLocalizedString(@"_HINT_BTN_", nil)
                                                         andFont:[UIFont fontWithName:@kFontInHintButton size:kFontSizeInHintButton]
                                                    andFontColor:[UIColor blackColor]
                                                  andUppercasing:YES
                                                    andAlignment:UIControlContentHorizontalAlignmentCenter
                                                        andImage:[UIImage imageNamed:@"HintButton.png"]
                                                    andImageMode:UIViewContentModeScaleAspectFit
                                              andBackgroundImage:nil];
        
        // Button action
        [hintButton addTarget:self action:@selector(hintAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Button transparency
        //[hintButton setAlpha:0.45];
        
        // Add button to view
        [self.topBarView addSubview:hintButton];
    }
    
    //Third button
    if (bShouldCreateThirdButton)
    {
        fXRef -= (((bShouldCreateMenuButton||bShouldCreateHintButton) ? (kTopBarElementsInterItemSpace+10) : (kTopBarElementsOuterSpace)) + kHintButtonHeight);
        CGFloat yHintButton = floorf((kTopBarHeight - kHintButtonHeight)/2.);
        // Set the menu button
        UIButton * thirdButton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,yHintButton)
                                                         andSize:CGSizeMake(kHintButtonHeight, kHintButtonHeight)
                                                  andBorderWidth:0.0
                                                  andBorderColor:[UIColor clearColor]
                                                         andText:@""
                                                         andFont:[UIFont fontWithName:@kFontInHintButton size:kFontSizeInHintButton]
                                                    andFontColor:[UIColor blackColor]
                                                  andUppercasing:YES
                                                    andAlignment:UIControlContentHorizontalAlignmentCenter
                                                        andImage:[self thirdButtonImage]
                                                    andImageMode:UIViewContentModeScaleAspectFit
                                              andBackgroundImage:nil];
        
        // Button action
        [thirdButton addTarget:self action:@selector(thirdButtonBarAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add button to view
        [self.topBarView addSubview:thirdButton];
    }
    
    // Top Bar Title
    
    
    fXRef -= (4*kTopBarElementsInterItemSpace);
    CGFloat rightMargin = self.topBarView.frame.size.width - fXRef;
    maxLabelWidth = fXRef - rightMargin;
    
    BOOL hasSubtitle = (topSubtitle&&![topSubtitle isEqualToString:@""])||[self shouldCreateSubtitleLabel];
    if(bShouldCreateTitleLabel)
    {
        // Set the title label
        /*
        if (bShouldCenterTitle) {
         CGRect barFrame = self.topBarView.bounds;
            self.titleLabel = [UILabel createLabelWithOrigin:barFrame.origin
                                                     andSize:barFrame.size
                                          andBackgroundColor:[UIColor clearColor]
                                                    andAlpha:kTopBarAlpha
                                                     andText:topTitle
                                                andTextColor:[UIColor darkGrayColor]
                                                     andFont:[UIFont fontWithName:@kFontInTitleLabel size:kFontSizeInTitleLabel]
                                              andUppercasing:YES
                                                  andAligned:NSTextAlignmentCenter];
        }else{
         */
        
        CGFloat titleHeight = (hasSubtitle ? (kTopBarHeight-(kTopBarElementsInterItemSpace*2))*kTopBarPortionForTitle :kTopBarHeight - 2*kTopBarElementsInterItemSpace);
            self.titleLabel = [UILabel createLabelWithOrigin:CGPointMake(kTopBarElementsOuterSpace, kTopBarElementsInterItemSpace)
                                                     andSize:CGSizeMake(fXRef-5,titleHeight)
                                          andBackgroundColor:[UIColor clearColor]
                                                    andAlpha:kTopBarAlpha
                                                     andText:topTitle
                                                andTextColor:bShouldTopbarTransparent? [UIColor whiteColor]:[UIColor darkGrayColor]
//                                                andTextColor:[UIColor darkGrayColor]
                                                     andFont:[UIFont fontWithName:@kFontInTitleLabel size:kFontSizeInTitleLabel]
                                              andUppercasing:YES
                                                  andAligned:NSTextAlignmentCenter];
        CGFloat labelHeight = self.titleLabel.frame.size.height;
        [self.titleLabel sizeToFit];
        CGRect labelFrame = self.titleLabel.frame;
        labelFrame.size.height = labelHeight;
        labelFrame.size.width = MIN(MAX(labelFrame.size.width, 60),maxLabelWidth);
        self.titleLabel.frame = labelFrame;
        
        CGPoint theCenter = self.titleLabel.center;
        theCenter.x = self.topBarView.center.x;
        
        self.titleLabel.center = theCenter;
        
            if(bShouldCreateEditPencils){
// REMOVED AS REQUESTED BY KARINA!!
//                self.titlePencil = [UIImageView new];
//                self.titlePencil.image = [UIImage imageNamed:@"editpencil_small.png"];
//                self.titlePencil.contentMode = UIViewContentModeScaleAspectFit;
//                [self.titlePencil sizeToFit];
//                [self.topBarView addSubview:self.titlePencil];
//                
//                CGRect pencilFrame = self.titlePencil.frame;
//                pencilFrame.size.height = self.titleLabel.frame.size.height;
//                pencilFrame.origin.x = self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width+2;
//                pencilFrame.origin.y = self.titleLabel.frame.origin.y;
//                self.titlePencil.frame = pencilFrame;
                
            }
        
        //}
        
        // Title transparency
        [self.titleLabel setAlpha:0.7];
        
        // Add title to view
        [self.topBarView addSubview:self.titleLabel];
        
        // Title button
        
        if (bShouldCreateTitleButton)
        {
            // Set the title button
            self.titleButton = [UIButton createButtonWithOrigin:self.titleLabel.frame.origin
                                                        andSize:self.titleLabel.frame.size
                                                 andBorderWidth:0.0
                                                 andBorderColor:[UIColor clearColor]
                                                        andText:nil
                                                        andFont:[UIFont fontWithName:@kFontInMenuButton size:kFontSizeInMenuButton]
                                                   andFontColor:[UIColor blackColor]
                                                 andUppercasing:YES
                                                   andAlignment:UIControlContentHorizontalAlignmentCenter
                                                       andImage:nil
                                                   andImageMode:UIViewContentModeScaleAspectFit
                                             andBackgroundImage:nil];
            
            // Button action
            [self.titleButton addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add button to view
            [self.topBarView addSubview:self.titleButton];
        }
        
    }
    
    // Top Bar Subtitle
    //if (!bShouldCenterTitle) {
    float subTitleOriginY = ((bShouldCreateTitleLabel) ? (self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height) : (2));
    
    // Set the subtitle label
    CGFloat subtitleHeight = (hasSubtitle ? ((kTopBarHeight-(kTopBarElementsInterItemSpace*2))*(1-kTopBarPortionForTitle)) : 0.);
    self.subtitleLabel = [UILabel createLabelWithOrigin:CGPointMake(kTopBarElementsOuterSpace, subTitleOriginY)
                                                andSize:CGSizeMake(fXRef,subtitleHeight)
                                     andBackgroundColor:[UIColor clearColor]
                                               andAlpha:kTopBarAlpha
                                                andText:topSubtitle
                                           andTextColor:[UIColor grayColor]
                                                andFont:[UIFont fontWithName:@kFontInSubtitleLabel size:kFontSizeInSubtitleLabel]
                                         andUppercasing:NO
                                             andAligned:NSTextAlignmentCenter];
    if(hasSubtitle){
        CGFloat labelHeight = self.subtitleLabel.frame.size.height;
        [self.subtitleLabel sizeToFit];
        CGRect labelFrame = self.subtitleLabel.frame;
        labelFrame.size.height = labelHeight;
        labelFrame.size.width = MIN(MAX(labelFrame.size.width, MAX(60, self.titleLabel.frame.size.width)),maxLabelWidth);
        self.subtitleLabel.frame = labelFrame;
        
        CGPoint theCenter = self.subtitleLabel.center;
        theCenter.x = self.titleLabel.center.x;
        self.subtitleLabel.center = theCenter;
        
        if(bShouldCreateEditPencils){
// REMOVED AS REQUESTED BY KARINA!!
//            self.subTitlePencil = [UIImageView new];
//            self.subTitlePencil.image = [UIImage imageNamed:@"editpencil_small.png"];
//            self.subTitlePencil.contentMode = UIViewContentModeScaleAspectFit;
//            [self.subTitlePencil sizeToFit];
//            [self.topBarView addSubview:self.subTitlePencil];
//            
//            CGRect pencilFrame = self.subTitlePencil.frame;
//            pencilFrame.size.height = self.subTitlePencil.frame.size.height;
//            pencilFrame.origin.x = self.subtitleLabel.frame.origin.x+self.subtitleLabel.frame.size.width+2;
//            pencilFrame.origin.y = self.subtitleLabel.frame.origin.y;
//            self.subTitlePencil.frame = pencilFrame;
            
        }
        
        // Title transparency
        [self.subtitleLabel setAlpha:0.7];
        
        // Add subtitle to view
        [self.topBarView addSubview:self.subtitleLabel];
        
    }else{
        
    }
    
    // Set the username label
    
    self.usernameLabel = [UILabel createLabelWithOrigin:CGPointMake(kTopBarElementsOuterSpace + fXRef, self.subtitleLabel.frame.origin.y)
                                                andSize:CGSizeMake(self.topBarView.frame.size.width-fXRef,((kTopBarHeight-(kTopBarElementsInterItemSpace*2))*(1-kTopBarPortionForTitle)))
                                     andBackgroundColor:[UIColor clearColor]
                                               andAlpha:kTopBarAlpha
                                                andText:topSubtitle
                                           andTextColor:[UIColor blackColor]
                                                andFont:[UIFont fontWithName:@kFontInUsernameLabel size:kFontSizeInUsernameLabel]
                                         andUppercasing:NO
                                             andAligned:NSTextAlignmentLeft];
    
    self.usernameLabel.numberOfLines = 0;
    self.usernameLabel.hidden = YES;
    self.usernameLabel.alpha = 0.7;
    
    // Add subtitle to view
    [self.topBarView addSubview:self.usernameLabel];
    
    // Title button
    
    if (bShouldCreateSubtitleButton)
    {
        // Set the title button
        self.subtitleButton = [UIButton createButtonWithOrigin:self.subtitleLabel.frame.origin
                                                       andSize:self.subtitleLabel.frame.size
                                                andBorderWidth:0.0
                                                andBorderColor:[UIColor clearColor]
                                                       andText:nil
                                                       andFont:[UIFont fontWithName:@kFontInMenuButton size:kFontSizeInMenuButton]
                                                  andFontColor:[UIColor blackColor]
                                                andUppercasing:YES
                                                  andAlignment:UIControlContentHorizontalAlignmentCenter
                                                      andImage:nil
                                                  andImageMode:UIViewContentModeScaleAspectFit
                                            andBackgroundImage:nil];
        
        // Button action
        [self.subtitleButton addTarget:self action:@selector(subtitleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add button to view
        [self.topBarView addSubview:self.subtitleButton];
    }
    
    
    // Report button
    
    if (bShouldCreateReportButton)
    {
        // Set the menu button
        self.reportButton = [UIButton createButtonWithOrigin:CGPointMake(self.menuButton.frame.origin.x + ((self.menuButton.frame.size.width - kReportButtonHeight)/2),self.subtitleLabel.frame.origin.y)
                                                     andSize:CGSizeMake(kReportButtonHeight, kReportButtonHeight)
                                              andBorderWidth:0.0
                                              andBorderColor:[UIColor clearColor]
                                                     andText:NSLocalizedString(@"_REPORT_BTN_",nil)
                                                     andFont:[UIFont fontWithName:@kFontInReportButton size:kFontSizeInReportButton]
                                                andFontColor:[UIColor lightGrayColor]
                                              andUppercasing:YES
                                                andAlignment:UIControlContentHorizontalAlignmentCenter
                                                    andImage:[UIImage imageNamed:@"Report.png"]
                                                andImageMode:UIViewContentModeScaleAspectFit
                                          andBackgroundImage:nil];
        
        // Button action
        [self.reportButton addTarget:self action:@selector(reportAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.topBarView addSubview:self.reportButton];
    }
    
    
    // Search terms list
    
    if (bShouldCreateSearchTermsList)
    {
        //float fSearchInterItemMargin = kTopBarElementsInterItemSpace;
        
        //int iAddTermAndFeaturesSearchButtonsWidth = kAddTermButtonHeight + kFeaturesSearchButtonWidth + kTopBarElementsInterItemSpace + kTopBarElementsInterItemSpace;
        
        fXRef = self.topBarView.frame.size.width - (kTopBarElementsOuterSpace + kTopBarElementsOuterSpace);
        
        if (bShouldCreateAddAndFeaturesButtons)
        {
            // ASUMED THAT ONLY THE ADD TERM BUTTON WILL BE ADDED; SO COMMENTED THE FEATURES BUTTON SIZES
            
            fXRef = self.topBarView.frame.size.width - (kTopBarElementsOuterSpace + kTopBarElementsOuterSpace + kAddTermButtonHeight + kTopBarElementsInterItemSpace /*+ kFeaturesSearchButtonWidth + kTopBarElementsInterItemSpace*/);
        }
        else if (bShouldCreateClearButton)
        {
            if(bShouldCreateResetButton)
            {
                fXRef = self.topBarView.frame.size.width - (kTopBarElementsOuterSpace + kTopBarElementsOuterSpace + kAddTermButtonHeight + kTopBarElementsInterItemSpace + kFeaturesSearchButtonWidth + kTopBarElementsInterItemSpace);
            }
            else
            {
                fXRef = self.topBarView.frame.size.width - (kTopBarElementsOuterSpace + kTopBarElementsOuterSpace + kFeaturesSearchButtonWidth + kTopBarElementsInterItemSpace);
            }
        }
        
        // Set the search terms list
        self.searchTermsListView = [[SlideButtonView alloc] initWithFrame:CGRectMake(kTopBarElementsOuterSpace, self.subtitleLabel.frame.origin.y+self.subtitleLabel.frame.size.height+kTopBarElementsInterItemSpace, fXRef, kSearchTermsListHeight)];
        
        //[self.searchTermsListView setupSearchTermsListView] ASSUMED that init already sets all default values as desired in this case
        
        // Add search terms list to view
        [self.topBarView addSubview:self.searchTermsListView];
        
        fXRef = self.searchTermsListView.frame.origin.x + self.searchTermsListView.frame.size.width + kTopBarElementsInterItemSpace;
        
        
        if(bShouldCreateAddAndFeaturesButtons)
        {
            // Set the add term (written) button
            self.addTermButton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,self.searchTermsListView.frame.origin.y+((kSearchTermsListHeight-kAddTermButtonHeight)/2))
                                                          andSize:CGSizeMake(kAddTermButtonHeight, kAddTermButtonHeight)
                                                   andBorderWidth:0.0
                                                   andBorderColor:[UIColor clearColor]
                                                          andText:NSLocalizedString(@"_ADDTERM_BTN_", nil)
                                                          andFont:[UIFont fontWithName:@kFontInFeaturesSearchButton size:kFontSizeInFeaturesSearchButton]
                                                     andFontColor:[UIColor blackColor]
                                                   andUppercasing:NO
                                                     andAlignment:UIControlContentHorizontalAlignmentCenter
                                                         andImage:[UIImage imageNamed:@"Add_Term_Menu.png"]
                                                     andImageMode:UIViewContentModeScaleAspectFit
                                               andBackgroundImage:nil];
            
            // Button action
            [self.addTermButton addTarget:self action:@selector(addTermAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add button to view
            [self.topBarView addSubview:self.addTermButton];
            
            // set tiling effect
            //[self showTile:addTermButton];
            
            fXRef += (kAddTermButtonHeight + kTopBarElementsInterItemSpace);
            
            // ASUMED THAT ONLY THE ADD TERM BUTTON WILL BE ADDED; SO COMMENTED THE FEATURES BUTTON SIZES
            
            
            //            // Set the 'Features' search button
            //            UIButton * featuresSearchButton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,self.searchTermsListView.frame.origin.y+((kSearchTermsListHeight-kFeaturesSearchButtonHeight)/2))
            //                                                                     andSize:CGSizeMake(kFeaturesSearchButtonWidth, kFeaturesSearchButtonHeight)
            //                                                              andBorderWidth:0.0
            //                                                              andBorderColor:[UIColor clearColor]
            //                                                                     andText:NSLocalizedString(@"_FEATURESSEARCH_BTN_", nil)
            //                                                                     andFont:[UIFont fontWithName:@kFontInFeaturesSearchButton size:kFontSizeInFeaturesSearchButton]
            //                                                                andFontColor:[UIColor blackColor]
            //                                                              andUppercasing:NO
            //                                                                andAlignment:UIControlContentHorizontalAlignmentCenter
            //                                                                    andImage:[UIImage imageNamed:@"FeaturesButton.png"]
            //                                                                andImageMode:UIViewContentModeScaleAspectFit
            //                                                          andBackgroundImage:nil];
            //
            //            // Button action
            //            [featuresSearchButton addTarget:self action:@selector(featuresSearchAction:) forControlEvents:UIControlEventTouchUpInside];
            //
            //            // Add button to view
            //            [self.topBarView addSubview:featuresSearchButton];
        }
        else if (bShouldCreateClearButton)
        {
            if(bShouldCreateResetButton)
            {
                // Set the menu button
                self.resetTermsButton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,self.searchTermsListView.frame.origin.y+((kSearchTermsListHeight-kAddTermButtonHeight)/2))
                                                                 andSize:CGSizeMake(kAddTermButtonHeight, kAddTermButtonHeight)
                                                          andBorderWidth:0.0
                                                          andBorderColor:[UIColor clearColor]
                                                                 andText:NSLocalizedString(@"_RESET_BTN_", nil)
                                                                 andFont:[UIFont fontWithName:@kFontInFeaturesSearchButton size:kFontSizeInFeaturesSearchButton]
                                                            andFontColor:[UIColor blackColor]
                                                          andUppercasing:NO
                                                            andAlignment:UIControlContentHorizontalAlignmentCenter
                                                                andImage:[UIImage imageNamed:@"reset.png"]
                                                            andImageMode:UIViewContentModeScaleAspectFit
                                                      andBackgroundImage:nil];
                
                // Button action
                [self.resetTermsButton addTarget:self action:@selector(resetTermsAction:) forControlEvents:UIControlEventTouchUpInside];
                
                // Add button to view
                [self.topBarView addSubview:self.resetTermsButton];
                
                fXRef += (kTopBarElementsInterItemSpace + kAddTermButtonHeight);
            }
            
            // Set the clear terms button
            self.clearTermsButton = [UIButton createButtonWithOrigin:CGPointMake(fXRef,self.searchTermsListView.frame.origin.y+((kSearchTermsListHeight-kFeaturesSearchButtonHeight)/2))
                                                             andSize:CGSizeMake(kFeaturesSearchButtonWidth, kFeaturesSearchButtonHeight)
                                                      andBorderWidth:0.0
                                                      andBorderColor:[UIColor clearColor]
                                                             andText:NSLocalizedString(@"_CLEARTERMS_BTN_", nil)
                                                             andFont:[UIFont fontWithName:@kFontInFeaturesSearchButton size:kFontSizeInFeaturesSearchButton]
                                                        andFontColor:[UIColor blackColor]
                                                      andUppercasing:NO
                                                        andAlignment:UIControlContentHorizontalAlignmentCenter
                                                            andImage:[UIImage imageNamed:@"Clear.png"]
                                                        andImageMode:UIViewContentModeScaleAspectFit
                                                  andBackgroundImage:nil];
            
            // Button action
            [self.clearTermsButton addTarget:self action:@selector(clearTermsAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add button to view
            [self.topBarView addSubview:self.clearTermsButton];
        }
    }
    
    // Not Successful Terms Label
    
    if(bShouldCreateNotSuccessfulTermsLabel)
    {
        // Set the notSuccessfulTerms label
        self.notSuccessfulTermsLabel = [UILabel createLabelWithOrigin:CGPointMake(self.searchTermsListView.frame.origin.x, self.searchTermsListView.frame.origin.y+self.searchTermsListView.frame.size.height)
                                                              andSize:CGSizeMake(self.searchTermsListView.frame.size.width,kNotSuccessfulTermsLabelHeight)
                                                   andBackgroundColor:[UIColor clearColor]
                                                             andAlpha:kTopBarAlpha
                                                              andText:@""
                                                         andTextColor:[UIColor grayColor]
                                                              andFont:[UIFont fontWithName:@kFontInNotSuccessfulTermsLabel size:kFontSizeInNotSuccessfulTermsLabel]
                                                       andUppercasing:NO
                                                           andAligned:NSTextAlignmentLeft];
        
        // Add title to view
        [self.topBarView addSubview:self.notSuccessfulTermsLabel];
    }
    
    
    // Post and Stylists Search buttons
    
    if(bShouldCreatePostAndStylistsSearchButtons)
    {
        float fYRef = ((bShouldCreateNotSuccessfulTermsLabel) ? (self.notSuccessfulTermsLabel.frame.origin.y + self.notSuccessfulTermsLabel.frame.size.height + kTopBarElementsInterItemSpace) : (self.searchTermsListView.frame.origin.y + self.searchTermsListView.frame.size.height + kTopBarElementsInterItemSpace));
        
        // Set the post search button
        self.postsSearch = [UIButton createButtonWithOrigin:CGPointMake(kPostAndStylistSearchButtonOuterInset,fYRef)
                                                    andSize:CGSizeMake(kPostAndStylistSearchButtonWidth, kPostAndStylistSearchButtonHeight)
                                             andBorderWidth:0.0
                                             andBorderColor:[UIColor clearColor]
                                                    andText:[NSLocalizedString(@"_FASHIONISTA_POSTS_", nil) uppercaseString]
                                                    andFont:[UIFont fontWithName:@kFontInPostAndStylistSearchButton size:kFontSizeInPostAndStylistSearchButton]
                                               andFontColor:[UIColor lightGrayColor]
                                             andUppercasing:NO
                                               andAlignment:UIControlContentHorizontalAlignmentCenter
                                                   andImage:nil
                                               andImageMode:UIViewContentModeScaleAspectFit
                                         andBackgroundImage:nil];//[UIImage imageNamed:@"PostAndStylistButtonBackground.png"]];
        
        // Button action
        [self.postsSearch addTarget:self action:@selector(switchToPostSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add button to view
        [self.topBarView addSubview:self.postsSearch];
        
        
        // Set the stylists search button
        self.stylistsSearch = [UIButton createButtonWithOrigin:CGPointMake(self.view.frame.size.width-kPostAndStylistSearchButtonOuterInset-kPostAndStylistSearchButtonWidth,fYRef)
                                                       andSize:CGSizeMake(kPostAndStylistSearchButtonWidth, kPostAndStylistSearchButtonHeight)
                                                andBorderWidth:0.0
                                                andBorderColor:[UIColor clearColor]
                                                       andText:[NSLocalizedString(@"_FASHIONISTAS_", nil) uppercaseString]
                                                       andFont:[UIFont fontWithName:@kFontInPostAndStylistSearchButton size:kFontSizeInPostAndStylistSearchButton]
                                                  andFontColor:[UIColor lightGrayColor]
                                                andUppercasing:NO
                                                  andAlignment:UIControlContentHorizontalAlignmentCenter
                                                      andImage:nil
                                                  andImageMode:UIViewContentModeScaleAspectFit
                                            andBackgroundImage:nil];//[UIImage imageNamed:@"PostAndStylistButtonBackground.png"]];
        
        // Button action
        [self.stylistsSearch addTarget:self action:@selector(switchToStylistSearch:) forControlEvents:UIControlEventTouchUpInside];
        
        // Add button to view
        [self.topBarView addSubview:self.stylistsSearch];
    }
    
    // Filter terms ribbon
    
    if (bShouldCreateSuggestedFiltersRibbon)
    {
        // Set the property that controls whtether the ribbon should be shown or not
        self.bShouldShowSuggestedFiltersRibbonView = [NSNumber numberWithBool:YES];
        
        // Set the filter terms ribbon
        self.SuggestedFiltersRibbonView = [[SlideButtonView alloc] initWithFrame:CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y+(self.topBarView.frame.size.height-kSuggestedFiltersRibbonHeight), self.topBarView.frame.size.width, kSuggestedFiltersRibbonHeight)];
        
        [self.SuggestedFiltersRibbonView setColorTextButtons:[UIColor blackColor]];
        
        [self.SuggestedFiltersRibbonView setBUppercaseButtonsText:YES];
        
        //[self.SuggestedFiltersRibbonView setupSuggestedFiltersRibbonView] ASSUMED that init already sets all default values as desired in this case
        
        // Set the inner shadow
        //        [self.SuggestedFiltersRibbonView makeInsetShadowWithRadius:kTopBarShadowRadius Color:[UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.2] Directions:[NSArray arrayWithObject:@"top"]];
        [self.SuggestedFiltersRibbonView makeInsetShadowWithRadius:kTopBarSideShadowRadius Color:[UIColor whiteColor] Directions:[NSArray arrayWithObject:@"left"]];
        [self.SuggestedFiltersRibbonView makeInsetShadowWithRadius:kTopBarSideShadowRadius Color:[UIColor whiteColor] Directions:[NSArray arrayWithObject:@"right"]];
        
        // Set the outer shadow
        //        self.SuggestedFiltersRibbonView.clipsToBounds = NO;
        //        self.SuggestedFiltersRibbonView.layer.shadowColor = [[UIColor blackColor] CGColor];
        //        self.SuggestedFiltersRibbonView.layer.shadowOffset = CGSizeMake(0,3);
        //        self.SuggestedFiltersRibbonView.layer.shadowOpacity = 0.3;
        self.topBarView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.topBarView.layer.shadowOffset = CGSizeMake(0,5);
        self.topBarView.layer.shadowRadius = 5.0;
        self.topBarView.layer.shadowOpacity = 0.5;
        
        
        // Add filter terms ribbon to view
        [self.topBarView addSubview:self.SuggestedFiltersRibbonView];
        
        // Setup the NO filter terms label
        // Set the notSuccessfulTerms label
        self.noFilterTermsLabel = [UILabel createLabelWithOrigin:CGPointMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y+(self.topBarView.frame.size.height-kSuggestedFiltersRibbonHeight))
                                                         andSize:CGSizeMake(self.topBarView.frame.size.width, kSuggestedFiltersRibbonHeight)
                                   //                                              andBackgroundColor:[UIColor clearColor]
                                              andBackgroundColor:[UIColor whiteColor]
                                                        andAlpha:1.0
                                                         andText:NSLocalizedString(@"_NOFILTERTERMS_LBL_", nil)
                                                    andTextColor:[UIColor darkGrayColor]
                                                         andFont:[UIFont fontWithName:@kFontInNoFilterTermsLabel size:kFontSizeInNoFilterTermsLabel]
                                                  andUppercasing:NO
                                                      andAligned:NSTextAlignmentCenter];
        
        // Hide label
        [self.noFilterTermsLabel setHidden:YES];
        
        // Add label to view
        [self.topBarView addSubview:self.noFilterTermsLabel];
    }
    else
    {
        /*        // Set the shadow
         self.topBarView.layer.shadowOpacity = kTopBarShadowOpacity;
         self.topBarView.layer.shadowRadius = kTopBarShadowRadius;
         */
    }
    
    // Add view
    [self.view addSubview:self.topBarView];
    
    // Init the Main Menu view
    [self initMainMenu];
    
    
    // Init the hint view
    self.hintView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.hintView setImage:[UIImage imageNamed:@"Wardrobes.jpg"]];
    self.hintView.clipsToBounds = NO;
    self.hintView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.hintView.layer.shadowOffset = CGSizeMake(0,5);
    self.hintView.layer.shadowOpacity = 0.5;
    self.hintView.hidden = YES;
    
    [self.view addSubview:self.hintView];
    
    // And the hint background view
    self.hintBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.hintBackgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    // Close hint button
    self.hintClose = [UIButton createButtonWithOrigin:CGPointMake(self.hintBackgroundView.frame.size.width-40, self.hintBackgroundView.frame.size.height-40) andSize:CGSizeMake(30, 30) andBorderWidth:0.0 andBorderColor:[UIColor clearColor] andText:@"X" andFont:self.hintLabel.font andFontColor:[UIColor whiteColor] andUppercasing:NO andAlignment:UIControlContentHorizontalAlignmentCenter andImage:[UIImage imageNamed:@"closeWhite.png"] andImageMode:UIViewContentModeScaleAspectFill andBackgroundImage:nil];
    [self.hintClose addTarget:self action:@selector(hideHints:) forControlEvents:UIControlEventTouchUpInside];
    [self.hintBackgroundView addSubview:self.hintClose];
    [self.hintBackgroundView bringSubviewToFront:self.hintClose];
    
    self.hintBackgroundView.hidden = YES;
    [self.view addSubview:self.hintBackgroundView];
    [self.view bringSubviewToFront:self.hintBackgroundView];
    
    self.hintLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.hintLabel.backgroundColor = [UIColor blackColor];
    self.hintLabel.textColor = [UIColor whiteColor];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    [self.hintLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:14]];
    [self.hintBackgroundView addSubview:self.hintLabel];
    
    // Botones
    self.hintPrev = [UIButton createButtonWithOrigin:CGPointMake(5, 8) andSize:CGSizeMake(25, 25) andBorderWidth:0.0 andBorderColor:[UIColor clearColor] andText:@"<" andFont:self.hintLabel.font andFontColor:[UIColor whiteColor] andUppercasing:NO andAlignment:UIControlContentHorizontalAlignmentCenter andImage:[UIImage imageNamed:@"hint_left.png"] andImageMode:UIViewContentModeScaleAspectFill andBackgroundImage:nil];
    
    self.hintNext = [UIButton createButtonWithOrigin:CGPointMake(5, 8) andSize:CGSizeMake(25, 25) andBorderWidth:0.0 andBorderColor:[UIColor clearColor] andText:@">" andFont:self.hintLabel.font andFontColor:[UIColor whiteColor] andUppercasing:NO andAlignment:UIControlContentHorizontalAlignmentCenter andImage:[UIImage imageNamed:@"hint_right.png"] andImageMode:UIViewContentModeScaleAspectFill andBackgroundImage:nil];
    
    [self.hintPrev addTarget:self action:@selector(hintPrevAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.hintNext addTarget:self action:@selector(hintNextAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.hintLabel addSubview:self.hintPrev];
    [self.hintLabel addSubview:self.hintNext];
    [self.hintLabel bringSubviewToFront:self.hintPrev];
    [self.hintLabel bringSubviewToFront:self.hintNext];
}

- (void)createArrows{
    [self.navigationArrowsView removeFromSuperview];
    BOOL bShouldCreateBackButton = [self shouldCreateBackButton];
    BOOL bShouldCreateForwardButton = [self shouldCreateForwardButton];
    BOOL bShouldTopbarTransparent = [self shouldTopbarTransparent];

    if(bShouldCreateBackButton||bShouldCreateForwardButton){
        CGRect barBounds = self.topBarView.bounds;
        barBounds.size.height = 60;
        self.navigationArrowsView = [[TouchTransparentView alloc] initWithFrame:barBounds];
        if (bShouldCreateBackButton) {
#ifndef _ADD_OSAMA_
             UIImage* backImage = bShouldTopbarTransparent? [UIImage imageNamed:@"live_backArrow.png"] : [UIImage imageNamed:@"backarrow.png"];
#else
            UIImage* backImage = [UIImage imageNamed:@"backarrow.png"];
#endif
            UIButton* back = [UIButton createButtonWithOrigin:CGPointMake(10, 0)
                                                      andSize:CGSizeMake(backImage.size.width, self.navigationArrowsView.frame.size.height)
                                               andBorderWidth:0.0
                                               andBorderColor:[UIColor clearColor]
                                                      andText:@""
                                                      andFont:self.hintLabel.font
                                                 andFontColor:[UIColor whiteColor]
                                               andUppercasing:NO
                                                 andAlignment:UIControlContentHorizontalAlignmentCenter
                                                     andImage:backImage
                                                 andImageMode:UIViewContentModeScaleAspectFill
                                           andBackgroundImage:nil];
            [back addTarget:self action:@selector(swipeRightAction) forControlEvents:UIControlEventTouchUpInside];
            [self.navigationArrowsView addSubview:back];
        }
        if (bShouldCreateForwardButton) {
            UIImage* forwardImage = [UIImage imageNamed:@"nextarrow.png"];
            UIButton* forward= [UIButton createButtonWithOrigin:CGPointMake(self.navigationArrowsView.frame.size.width-forwardImage.size.width-10, 0)
                                                        andSize:CGSizeMake(forwardImage.size.width, self.navigationArrowsView.frame.size.height)
                                                 andBorderWidth:0.0
                                                 andBorderColor:[UIColor clearColor]
                                                        andText:@""
                                                        andFont:self.hintLabel.font
                                                   andFontColor:[UIColor whiteColor]
                                                 andUppercasing:NO
                                                   andAlignment:UIControlContentHorizontalAlignmentCenter
                                                       andImage:forwardImage
                                                   andImageMode:UIViewContentModeScaleAspectFill
                                             andBackgroundImage:nil];
            [forward addTarget:self action:@selector(swipeLeftAction) forControlEvents:UIControlEventTouchUpInside];
            [self.navigationArrowsView addSubview:forward];
        }
        [self.topBarView addSubview:self.navigationArrowsView];
        
        fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:4
                                                        target:self
                                                      selector:@selector(fadeArrows)
                                                      userInfo:nil
                                                       repeats:NO];
    }
}
- (void)cancelFadeArrow{
    [fadeOutTimer invalidate];
    fadeOutTimer = nil;
}

- (void)fadeArrows{
    [self fadeArrows:NO];
}

- (void)showArrows{
    [self cancelFadeArrow];
    [self fadeArrows:YES];
    fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:4
                                                    target:self
                                                  selector:@selector(fadeArrows)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)hideTopBar{
    self.hidesTopBar = YES;
    self.topBarView.hidden = YES;
    [self.topBarView.superview sendSubviewToBack:self.topBarView];
}

- (void)fadeArrows:(BOOL)appear{
    CGFloat alphaValue = 0.;
    if (appear) {
        alphaValue = 1.;
        [self.navigationArrowsView.superview bringSubviewToFront:self.navigationArrowsView];
        self.navigationArrowsView.alpha = alphaValue;
    }else{
        [UIView animateWithDuration:1
                         animations:^{
                             self.navigationArrowsView.alpha = alphaValue;
                         }
                         completion:^(BOOL finished) {
                             [self.navigationArrowsView.superview sendSubviewToBack:self.navigationArrowsView];
                         }];
    }
}

- (void)hideSuggestedFiltersRibbonAnimated:(BOOL) bAnimated
{
    if (self.SuggestedFiltersRibbonView == nil)
    {
        return;
    }

    if(self.SuggestedFiltersRibbonView.alpha < 1.0)
    {
        return;
    }
    
    if (bAnimated)
    {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                             
                             [self.SuggestedFiltersRibbonView setAlpha:0.01];
                             [self.SuggestedFiltersRibbonView setHidden:YES];
                             
                             self.topBarView.frame = CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y, self.topBarView.frame.size.width, self.topBarView.frame.size.height-kSuggestedFiltersRibbonHeight);

                         }
                         completion:^(BOOL finished) {

                         }];
    }
    else
    {
        [self.SuggestedFiltersRibbonView setHidden:YES];
        [self.SuggestedFiltersRibbonView setAlpha:0.01];

        self.topBarView.frame = CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y, self.topBarView.frame.size.width, self.topBarView.frame.size.height-kSuggestedFiltersRibbonHeight);
    }
}

- (void)showSuggestedFiltersRibbonAnimated:(BOOL) bAnimated
{
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.activityLabel];
    
    if ((self.SuggestedFiltersRibbonView == nil) || (!([self.bShouldShowSuggestedFiltersRibbonView boolValue])))
    {
        return;
    }
    
    if(self.SuggestedFiltersRibbonView.alpha > 0.01)
    {
        return;
    }

    if (bAnimated)
    {
        /*
        if(self.mainMenuView.hidden == YES)
         */
            [self.SuggestedFiltersRibbonView setHidden:NO];
         
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^ {
                             
                             [self.SuggestedFiltersRibbonView setAlpha:1];
                             
                             self.topBarView.frame = CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y, self.topBarView.frame.size.width,
                                                                kTopBarElementsInterItemSpace + kTopBarHeight-
                                                                ((kTopBarHeight*kTopBarPortionForTitle)*(![self shouldCreateTitleLabel]))+
                                                                (kSearchTermsListHeight * [self shouldCreateSearchTermsList])+
                                                                ( kNotSuccessfulTermsLabelHeight* [self shouldCreateNotSuccessfulTermsLabel])+
                                                                (kSuggestedFiltersRibbonHeight * [self shouldCreateSuggestedFiltersRibbon])+
                                                                ((kPostAndStylistSearchButtonHeight) * [self shouldCreatePostAndStylistsSearchButtons]));
                         }
                         completion:^(BOOL finished) {
                          
                         }];
    }
    else
    {
        [self.SuggestedFiltersRibbonView setAlpha:1];

        /*
        if(self.mainMenuView.hidden == YES)
         */
            [self.SuggestedFiltersRibbonView setHidden:NO];
        
        self.topBarView.frame = CGRectMake(self.topBarView.frame.origin.x, self.topBarView.frame.origin.y, self.topBarView.frame.size.width,
                                           kTopBarElementsInterItemSpace + kTopBarHeight-
                                           ((kTopBarHeight*kTopBarPortionForTitle)*(![self shouldCreateTitleLabel]))+
                                           (kSearchTermsListHeight * [self shouldCreateSearchTermsList])+
                                           (kNotSuccessfulTermsLabelHeight* [self shouldCreateNotSuccessfulTermsLabel])+
                                           (kSuggestedFiltersRibbonHeight * [self shouldCreateSuggestedFiltersRibbon])+
                                           ((kPostAndStylistSearchButtonHeight) * [self shouldCreatePostAndStylistsSearchButtons]));
    }
}

- (void)hideSearchTermsListAnimated:(BOOL) bAnimated
{
    if ((self.searchTermsListView == nil) || ([self.searchTermsListView isHidden]))
    {
        return;
    }
    
    if (bAnimated)
    {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                             
                             [self.searchTermsListView setAlpha:0.01];
                             [self.resetTermsButton setAlpha:0.01];
                             [self.clearTermsButton setAlpha:0.01];
                             self.upperSection.frame = CGRectMake(self.upperSection.frame.origin.x, self.upperSection.frame.origin.y, self.upperSection.frame.size.width, self.upperSection.frame.size.height-kSearchTermsListHeight);
                             if([self shouldCreateSuggestedFiltersRibbon])
                             {
                                 self.SuggestedFiltersRibbonView.frame = CGRectMake(self.SuggestedFiltersRibbonView.frame.origin.x, self.SuggestedFiltersRibbonView.frame.origin.y-kSearchTermsListHeight, self.SuggestedFiltersRibbonView.frame.size.width, self.SuggestedFiltersRibbonView.frame.size.height);
                             }
                         }
                         completion:^(BOOL finished) {
                             
                             [self.searchTermsListView setHidden:YES];
                             [self.resetTermsButton setHidden:YES];
                             [self.clearTermsButton setHidden:YES];
                         }];
    }
    else
    {
        [self.searchTermsListView setHidden:YES];
        [self.searchTermsListView setAlpha:0.01];
        [self.resetTermsButton setHidden:YES];
        [self.resetTermsButton setAlpha:0.01];
        [self.clearTermsButton setHidden:YES];
        [self.clearTermsButton setAlpha:0.01];
        self.upperSection.frame = CGRectMake(self.upperSection.frame.origin.x, self.upperSection.frame.origin.y, self.upperSection.frame.size.width, self.upperSection.frame.size.height-kSearchTermsListHeight);
        if([self shouldCreateSuggestedFiltersRibbon])
        {
            self.SuggestedFiltersRibbonView.frame = CGRectMake(self.SuggestedFiltersRibbonView.frame.origin.x, self.SuggestedFiltersRibbonView.frame.origin.y-kSearchTermsListHeight, self.SuggestedFiltersRibbonView.frame.size.width, self.SuggestedFiltersRibbonView.frame.size.height);
        }
    }
}

- (void)showSearchTermsListAnimated:(BOOL) bAnimated
{
    if ((self.searchTermsListView == nil) || (!([self.searchTermsListView isHidden])))
    {
        return;
    }
    
    if (bAnimated)
    {
        [self.searchTermsListView setHidden:NO];
        [self.resetTermsButton setHidden:NO];
        [self.clearTermsButton setHidden:NO];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^ {
                             
                             [self.searchTermsListView setAlpha:1];
                             [self.resetTermsButton setAlpha:1];
                             [self.clearTermsButton setAlpha:1];
                             self.upperSection.frame = CGRectMake(self.upperSection.frame.origin.x, self.upperSection.frame.origin.y, self.upperSection.frame.size.width, self.upperSection.frame.size.height+kSearchTermsListHeight);
                             if([self shouldCreateSuggestedFiltersRibbon])
                             {
                                 self.SuggestedFiltersRibbonView.frame = CGRectMake(self.SuggestedFiltersRibbonView.frame.origin.x, self.SuggestedFiltersRibbonView.frame.origin.y+kSearchTermsListHeight, self.SuggestedFiltersRibbonView.frame.size.width, self.SuggestedFiltersRibbonView.frame.size.height);
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    else
    {
        [self.searchTermsListView setAlpha:1];
        [self.searchTermsListView setHidden:NO];
        [self.resetTermsButton setAlpha:1];
        [self.resetTermsButton setHidden:NO];
        [self.clearTermsButton setAlpha:1];
        [self.clearTermsButton setHidden:NO];
        self.upperSection.frame = CGRectMake(self.upperSection.frame.origin.x, self.upperSection.frame.origin.y, self.upperSection.frame.size.width, self.upperSection.frame.size.height+kSearchTermsListHeight);
        if([self shouldCreateSuggestedFiltersRibbon])
        {
            self.SuggestedFiltersRibbonView.frame = CGRectMake(self.SuggestedFiltersRibbonView.frame.origin.x, self.SuggestedFiltersRibbonView.frame.origin.y+kSearchTermsListHeight, self.SuggestedFiltersRibbonView.frame.size.width, self.SuggestedFiltersRibbonView.frame.size.height);
        }
    }
}

- (void)hideTile:(UIButton *)tilingButton
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {

                         tilingButton.titleLabel.alpha = 0.01;
                     
                     }
                     completion:^(BOOL finished) {
                         
                         [self showTile:tilingButton];
                     
                     }];
}

- (void)showTile:(UIButton *)tilingButton
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {

                         tilingButton.titleLabel.alpha = 1;

                     } completion:^(BOOL finished) {
                     
                         [self hideTile:tilingButton];

                     }];
}

// Handle double tap on top bar
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        [self scrollMainCollectionViewToTop];
    }
}

// Title button action
- (void)titleButtonAction:(UIButton *)sender
{
    
}

// Subtitle button action
- (void)subtitleButtonAction:(UIButton *)sender
{
    
}

// Report button action
- (void)reportAction:(UIButton *)sender
{
    
}

// Hide the hints view
- (void)hideHints:(UIButton *)sender
{
    if(self.hintView.hidden)
        return;
    
    if(sender == nil)
    {
        if(iSelectedHint<iNumHints)
        {
            iSelectedHint++;
            [self updateHintViews];
            return;
        }
    }

    if(([self.hintLabel.text isEqualToString:NSLocalizedString(@"_POSTANDBEVALIDATED_", nil)]) || ([self.hintLabel.text isEqualToString:NSLocalizedString(@"_SHARE_BTN_", nil)]))
    {
        [self hideMessage];
        
        return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.hintView.alpha = 0.0;
                         self.hintBackgroundView.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         self.hintView.hidden = YES;
                         self.hintBackgroundView.hidden = YES;
                         
                         
                     }];
}

int iNumHints = 0;
int iSelectedHint = 1;

- (void)checkAvailableHints
{
    int iVC = [self.restorationIdentifier intValue];
    bool bMiss = false;
    int iN = 0;
    iNumHints = 0;
    
    while(!bMiss)
    {
        iN++;
        NSString * fileName = [NSString stringWithFormat:@"HINT_%d_%d", iVC, iN];
        
        if([self isKindOfClass:[SearchBaseViewController class]])
        {
            SearchBaseViewController * s = (SearchBaseViewController*)self;
            int iContext = s.searchContext;
            fileName = [NSString stringWithFormat:@"HINT_%d_%d_%d", iVC, iContext, iN];
        }
        
        NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
            iNumHints++;
        else
            bMiss = true;
    }
}


- (void)hintPrevAction:(UIButton *)sender
{
    if(iSelectedHint > 1)
        iSelectedHint--;
    [self updateHintViews];
}

- (void)hintNextAction:(UIButton *)sender
{
    if(iSelectedHint<iNumHints)
        iSelectedHint++;
    [self updateHintViews];
}

- (void)updateHintViews
{
//    self.updatingHint = [NSNumber numberWithBool:NO];
    
    int iVC = [self.restorationIdentifier intValue];
    if([self isKindOfClass:[SearchBaseViewController class]])
    {
        SearchBaseViewController * s = (SearchBaseViewController*)self;
        int iContext = s.searchContext;
        [self.hintView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"HINT_%d_%d_%d.jpg", iVC, iContext, iSelectedHint]]];
    }
    else
    {
        [self.hintView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"HINT_%d_%d.jpg", iVC, iSelectedHint]]];
    }
    
    NSString * title = NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",[self.restorationIdentifier intValue]]), nil);
    
    if([self isKindOfClass:[SearchBaseViewController class]])
    {
        SearchBaseViewController * s = (SearchBaseViewController*)self;
        int iContext = s.searchContext;
        title = NSLocalizedString(([NSString stringWithFormat:@"_VCTITLE_%i_",iContext]), nil);
    }
    
    self.hintLabel.text = [NSString stringWithFormat:@"%@ Hints (%d/%d)", title, iSelectedHint, iNumHints];
    
    self.hintPrev.hidden = (iSelectedHint == 1);
    self.hintNext.hidden = (iSelectedHint == iNumHints);
    
}

-(void)showHintsFirstTime
{
    return;
    
    int iVC = [self.restorationIdentifier intValue];
    
    if((iVC == 7) || (iVC == 31))
    {
        NSString * tmpCurrentUser = [[((AppDelegate *)[[UIApplication sharedApplication] delegate]) currentUser] idUser];
        
        if(tmpCurrentUser == nil)
        {
            return;
        }

        NSString * tmpShownStylist = nil;
        BOOL bEditionMode = NO;
        
        if([self isKindOfClass:[FashionistaProfileViewController class]])
        {
            tmpShownStylist = [[((FashionistaProfileViewController *) self) shownStylist] idUser];
            bEditionMode = [((FashionistaProfileViewController *) self) bEditionMode];
        }
        else if ([self isKindOfClass:[FashionistaPostViewController class]])
        {
            tmpShownStylist = [[((FashionistaPostViewController *) self) shownPost] userId];
            bEditionMode = [((FashionistaPostViewController *) self) bEditingMode];
        }
        
        if (!(tmpShownStylist == nil))
        {
            if(!([tmpShownStylist isEqualToString:@""]))
            {
                if (!(tmpCurrentUser == nil))
                {
                    if(!([tmpCurrentUser isEqualToString:@""]))
                    {
                        if(!([tmpShownStylist isEqualToString:tmpCurrentUser]))
                        {
                            return;
                        }
                        else if(!(bEditionMode))
                        {
                            return;
                        }
                    }
                }
            }
        }
    }

    NSString * key = [NSString stringWithFormat:@"HINT_%d", iVC];

    if([self isKindOfClass:[SearchBaseViewController class]])
    {
        SearchBaseViewController * s = (SearchBaseViewController*)self;
        int iContext = s.searchContext;
        key = [NSString stringWithFormat:@"HINT_%d_%d", iVC, iContext];
    }
    
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Generate UUID if doesn't already exists
    if ([defaults objectForKey:key] == nil)
    {
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        
        
        [defaults setObject:dateString forKey:key];
        [defaults synchronize];

        [self hintAction:nil];
    }
    
}


// Hint action
- (void)hintAction:(UIButton *)sender
{
    if(self.hintBackgroundView.hidden == NO)
        return;
    
    [self checkAvailableHints];

    if(iNumHints == 0)
        return;
    self.updatingHint = [NSNumber numberWithBool:NO];
    self.hintBackgroundView.hidden = NO;
    iSelectedHint = 1;
    
    [self.view endEditing:YES];
    [self updateHintViews];
    
    self.hintBackgroundView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.hintBackgroundView.alpha = 0.0;
    [self.view bringSubviewToFront:self.hintBackgroundView];
    
    self.hintView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //self.hintView.userInteractionEnabled = YES;
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

// Add term action
- (void)addTermAction:(UIButton *)sender
{
    return;
}

// Features Search action
- (void)featuresSearchAction:(UIButton *)sender
{
    return;
}

// Reset Terms action
- (void)resetTermsAction:(UIButton *)sender
{
    return;
}

// Clear Terms action
- (void)clearTermsAction:(UIButton *)sender
{
    return;
}

// Clear Terms action
- (void)switchToPostSearch:(UIButton *)sender
{
    return;
}

// Clear Terms action
- (void)switchToStylistSearch:(UIButton *)sender
{
    return;
}



@end
