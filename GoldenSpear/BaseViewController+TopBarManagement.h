//
//  BaseViewController+TopBarManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 20/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import "BaseViewController.h"
#import "TouchTransparentView.h"

@interface BaseViewController (TopBarManagement)

// Top controls management
@property UILabel *titleLabel;
@property UIButton *titleButton;
@property UILabel *subtitleLabel;
@property UILabel *usernameLabel;
@property UIButton *subtitleButton;
@property UILabel *notSuccessfulTermsLabel;
@property UILabel *noFilterTermsLabel;
@property SlideButtonView *searchTermsListView;
@property SlideButtonView *SuggestedFiltersRibbonView;
@property NSNumber *bShouldShowSuggestedFiltersRibbonView;
@property UIButton *menuButton;
@property UIButton *clearTermsButton;
@property UIButton *resetTermsButton;
@property UIView *topBarView;
@property UIView * upperSection;
@property UIImageView * hintView;
@property UIView * hintBackgroundView;
@property UILabel * hintLabel;
@property UIButton * hintPrev;
@property UIButton * hintNext;
@property UIButton * hintClose;
@property NSNumber *updatingHint;
@property UIButton * addTermButton;
@property UIButton * reportButton;
@property UIButton * postsSearch;
@property UIButton * stylistsSearch;

@property TouchTransparentView * navigationArrowsView;
@property UIImageView* titlePencil;
@property UIImageView* subTitlePencil;

@property BOOL hidesTopBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeightConstraint;

- (void)createTopBar;
- (void)setTopBarTitle:(NSString *)topBarTitle andSubtitle:(NSString *)topBarSubtitle;
-(void)setProfileImage:(NSString*)imageURL;
-(void)createWardrobeButton;
- (void)setTitleColor:(UIColor*)color;
- (void)setNotSuccessfulTermsText:(NSString *)notSuccessfulTermsText;
- (void)bringTopBarToFront;
- (float)topBarHeight;
- (void)showSuggestedFiltersRibbonAnimated:(BOOL) bAnimated;
- (void)hideSuggestedFiltersRibbonAnimated:(BOOL) bAnimated;
- (void)hideSearchTermsListAnimated:(BOOL) bAnimated;
- (void)showSearchTermsListAnimated:(BOOL) bAnimated;
- (void)reportAction:(UIButton *)sender;
- (void)hintAction:(UIButton *)sender;
- (void)hintPrevAction:(UIButton *)sender;
- (void)hintNextAction:(UIButton *)sender;
- (void)hideHints:(UIButton *)sender;
- (void)showHintsFirstTime;
- (void)titleButtonAction:(UIButton *)sender;
- (void)subtitleButtonAction:(UIButton *)sender;

- (void)createArrows;
- (void)fadeArrows;
- (void)showArrows;
- (void)cancelFadeArrow;
- (void)hideTopBar;

@end
