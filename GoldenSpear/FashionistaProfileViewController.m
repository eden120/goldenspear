//
//  FashionistaProfileViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FashionistaProfileViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "AddItemToWardrobeViewController.h"
#import "AnalyticsViewController.h"
#import "NSString+CheckWhiteSpaces.h"
#import "PlaceHolderUITextView.h"
#import "UILabel+CustomCreation.h"
#import "NYTPhotosViewController.h"


#import "GSImageCollectionViewCell.h"
#import "AppDelegate.h"
#import "GSContentViewPost.h"

#import "SearchBaseViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "FashionistaUserListViewController.h"
#import "GSEditInfoViewController.h"
#import "GSShowInfoViewController.h"
#import "GSDateFilterSectionHeaderView.h"
#import "FullVideoViewController.h"
#import "GSSuggestionCell.h"

#define kOffsetToShowUpperView -80
#define kOffsetForBottomScroll 10
#define kSeparatorViewShadowXOffset 0
#define kSeparatorViewShadowYOffset 2
#define kSeparatorViewShadowOpacity 0.5
#define kSeparatorViewShadowRadius 4

#define kMinUsernameLength 3

#define kLowestYearForFilter 2014

#define GSPOST_CELL @"PostCell"
#define GSWARDROBE_CELL @"WardrobeCell"
#define kSuggestionViewHeight   150
#define GSSUGGESTION_CELL  @"suggestionCell"

@implementation NYTExamplePhotoUserProf

@end

@interface BaseViewController (Protected)

- (void)showMessageWithImageNamed:(NSString*)imageNamed;

@end

@interface FashionistaProfileViewController ()

@end

@implementation FashionistaProfileViewController
{
    BOOL _bContinueUpdating;
    BOOL _bLoadMoreContent;
    BOOL _bEditPost;
    NSString* loadingPostInPage;
    
    NSMutableDictionary* downloadedPosts;
    NSMutableDictionary* gsElements;
    NSMutableDictionary* postElements;
    NSMutableDictionary* downloadedWardrobes;
    NSMutableDictionary* filteringPosts;
    NSMutableArray *userWardrobesElements;
    
    BOOL showingWardrobe;
    
    GSDoubleDisplayViewController* postsDoubleDisplayController;
    GSDoubleDisplayViewController* wardrobesDoubleDisplayController;
    
    BOOL willShowFollowers;
    /*
    NSMutableArray* downloadQueue;
    BOOL downloadingInQueue;
    BOOL interruptedSearch;
    */
    BOOL uploadHeader;
    
    AVPlayerViewController * player;
    BOOL playing;
    
    NSString* editedTitle;
    NSString* editedSubTitle;
    
    profileEditFieldMode currentEditFieldMode;
    
    BOOL _hasGoneToInfo;
    NSMutableArray* monthFilterArray;
    NSMutableDictionary* monthComponents;
    
    NSInteger yearFiltered;
    NSInteger monthFiltered;
    
    BOOL cancelOperation;
    BOOL showingOptions;
    
    NSArray* optionHandlers;
    
    BOOL showingOwn;
    
    BOOL finishedDownloading;
    
    GSUserVideosViewController* userVideosController;
    
    BOOL searchingPosts;
    BOOL isRefreshing;
    
    BOOL editMode;
    NSString* originalUserName;
    CMTime currenttime;
    
    BOOL searchSuggestion;
    NSMutableArray *suggestionList;
    
    BOOL magazineLoding;
}

- (void)dealloc{
    self.editViews = nil;
    downloadedPosts = nil;
    downloadedWardrobes = nil;
    gsElements = nil;
    postElements = nil;
    filteringPosts = nil;
    postsDoubleDisplayController = nil;
    wardrobesDoubleDisplayController = nil;
    //downloadQueue = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player.player currentItem]];
    [player.player removeObserver:self forKeyPath:@"rate"];
    [player.view removeFromSuperview];
    player = nil;
    editedTitle = @"";
    editedSubTitle = @"";
    monthFilterArray = nil;
    monthComponents = nil;
}

- (void)selectAButton{
    if(_bEditionMode){
        [self selectTheButton:self.middleLeftButton];
    }
}

- (BOOL)shouldCreateEditPencils{
    return _bEditionMode;
}

- (BOOL)shouldCreateSubtitleLabel{
    return _bEditionMode||(self.shownStylist.fashionistaTitle&&![self.shownStylist.fashionistaTitle isEqualToString:@""]);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.showVideos){
        [self performSelector:@selector(hideTextFieldsUpperView) withObject:nil afterDelay:0.5];
        [self videosMenuPushed:self.videoMenuButton];
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [_monthFilterTable selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectedPostId = nil;
    //_selectedPostToDelete = nil;
    magazineLoding = NO;
    _bContinueUpdating = YES;
    _bLoadMoreContent = NO;
    _bPhotoChanged = NO;
    _bEditPost = NO;
    _selectedPagePosts = [[NSMutableArray alloc]init];
    _selectedPage = nil;
    editMode = NO;
    searchSuggestion = YES;
    suggestionList = [[NSMutableArray alloc] init];
    
    _addWebSiteLabel.hidden = YES;
    _pencilImage.hidden = YES;
    
    if (editMode) {
        _editProfileCoverButton.hidden = NO;
        [_editProfileImageButton setBackgroundColor:[UIColor colorWithRed:208 green:208 blue:208 alpha:0.77]];
        [_editProfileImageButton setTitle:@"EDIT PICTURE" forState:UIControlStateNormal];
        if ([_shownStylist.fashionistaBlogURL isEqualToString:@""]) {
            _addWebSiteLabel.hidden = NO;
            _pencilImage.hidden = NO;
        }
        else {
            _fashionistaURL.textColor = [UIColor blueColor];
            _fashionistaURLField.textColor = [UIColor blueColor];
        }
        [_editProfileButton setTitle:@"PUBLISH" forState:UIControlStateNormal];
    }
    else {
        _editProfileCoverButton.hidden = YES;
        [_editProfileImageButton setTitle:@"" forState:UIControlStateNormal];
        [_editProfileImageButton setBackgroundColor:[UIColor clearColor]];
        _fashionistaURL.textColor = [UIColor blackColor];
        _fashionistaURLField.textColor = [UIColor blackColor];
        [_editProfileButton setTitle:@"EDIT PROFILE" forState:UIControlStateNormal];
    }
 //   self.uploadImageLabel.hidden = NO;
    self.uploadImageLabel.hidden = YES;
    // Get the current user
    User * currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
    
    // Setup textfields appearance
    [self setupTextFields];
    
    bool bRightTitleChanged = false;
    
    if(_bEditionMode)
    {
        self.constraintHeightFollow.constant = 0;
        
        self.fashionistaURL.hidden = NO;
        //self.fashionistaURLField.hidden = NO;
        self.fashionistaURLField.delegate = self;
        
        [self.fashionistaURLField setValue:[UIFont fontWithName: @"Avenir-Medium" size: 16] forKeyPath:@"_placeholderLabel.font"];
        [self.fashionistaURLField setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.fashionistaURLField setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
        [self.fashionistaURLField.layer setCornerRadius:5];
        
       // [self showEditPageButton];
    }
    else
    {
        self.fashionistaURL.hidden = NO;
        self.fashionistaURLField.hidden = YES;
        [self hideEditPageButton];
        
        if([self isThisUserMe:_shownStylist.idUser])
        {
            bRightTitleChanged = true;
            _editProfileButton.hidden = NO;
        }
        else
        {
            _editProfileButton.hidden = YES;
            [self uploadFashionistaView];
        }
    }
    
    // Init collection views cell types
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:GSPOST_CELL, nil]];
    
    // Initialize results array
    if (_postsArray == nil)
    {
        _postsArray = [[NSMutableArray alloc] init];
    }
    
    if (_wardrobesArray == nil) {
        _wardrobesArray = [[NSMutableArray alloc] init];
    }
    // Initialize results groups array
    if (_pagesGroups == nil)
    {
        _pagesGroups = [[NSMutableArray alloc] init];
    }
    
    // Check if there are results
    [self initFetchedResultsControllerForCollectionViewWithCellType:GSPOST_CELL WithEntity:@"FashionistaPost" andPredicate:@"idFashionistaPost IN %@" inArray:_postsArray sortingWithKeys:[NSArray arrayWithObject:@"createdAt"] ascending:NO andSectionWithKeyPath:nil];
    
    // Setup Collection View
    [self initCollectionViewsLayout];
    
    if(!([self isThisUserMe:_shownStylist.idUser]) && currentUser)
    {
        showingOwn = NO;
        // Fetch user follows to properly show the 'Follow' button
        [self initFollowsFetchedResultsControllerWithEntity:@"Follow" andPredicate:@"followingId IN %@" inArray:[NSArray arrayWithObject:currentUser.idUser] sortingWithKey:@"idFollow" ascending:YES];
        [self.analyticsButton setHidden:YES];
        [self.lblAnalytics setHidden:YES];
        [self.followButton setHidden:NO];
        [self.optionsButton setHidden:NO];
        [self.reportButton setHidden:NO];
        self.suggestionViewHeightConstraint.constant = 0;
        [self.suggestionView setHidden:YES];
        if (_shownStylist.isPublic) {
            self.privateLabel.hidden = YES;
            self.infoViewContainer.hidden = NO;
            self.videoListContainer.hidden = NO;
            self.wardrobesContainerView.hidden = NO;
            self.postsContainerView.hidden = NO;
        }
        else {
            self.privateLabel.hidden = NO;
            self.infoViewContainer.hidden = YES;
            self.videoListContainer.hidden = YES;
            self.wardrobesContainerView.hidden = YES;
            self.postsContainerView.hidden = YES;
        }
        
//        [self showStylistFollowers:nil];
    }
    else
    {
        showingOwn = YES;
        [self.optionsButton setHidden:YES];
        [self.followButton setHidden:YES];
        [self.analyticsButton setHidden:NO];
        [self.lblAnalytics setHidden:NO];
        [self.reportButton setHidden:YES];
        [self.privateLabel setHidden:YES];
        self.infoViewContainer.hidden = NO;
        self.videoListContainer.hidden = NO;
        self.wardrobesContainerView.hidden = NO;
        self.postsContainerView.hidden = NO;
        self.suggestionViewHeightConstraint.constant = 0;
        [self.suggestionView setHidden:YES];
        searchSuggestion = NO;
    }
    
    UIImage *reportImage = [UIImage imageNamed:@"Report.png"];
    
    [[self.reportButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    
    //Redesign
    downloadedPosts = [NSMutableDictionary new];
    downloadedWardrobes = [NSMutableDictionary new];
    gsElements = [NSMutableDictionary new];
    postElements = [NSMutableDictionary new];
    filteringPosts = [NSMutableDictionary new];
    //Set bar title
    NSString* subtitleString = (_shownStylist.fashionistaTitle?_shownStylist.fashionistaTitle:@"");
//    if(_bEditionMode&&[subtitleString isEqualToString:@""]){
//        subtitleString = NSLocalizedString(@"_DEFAULT_NO_USERTITLE_EDIT_", nil);
//    }
    
    if (editMode && [subtitleString isEqualToString:@""]) {
        subtitleString = NSLocalizedString(@"_DEFAULT_NO_USERTITLE_EDIT_", nil);
    }
    
    [self setTopBarTitle:_shownStylist.fashionistaName andSubtitle:subtitleString];
    
    
    //DoubleDisplay
    [self setupPostsController];
    [self setupWardrobesController];
    
    //downloadQueue = [NSMutableArray new];
    
    [self.monthFilterTable registerNib:[UINib nibWithNibName:@"GSDateFilterSectionHeaderView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"sectionHeaderCell"];
    
    [self setupMonthsForFiltering];
    self.moreOptions.viewDelegate = self;
    //Must re-add height constraint because it is broken for comming from another nib
    self.optionsViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.moreOptions
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute: NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:46];
    [self.moreOptions addConstraint:self.optionsViewHeightConstraint];
    
    self.wardrobeButton.backgroundColor = GOLDENSPEAR_COLOR;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(!(appDelegate.addingProductsToWardrobeID == nil))
    {
        if(!([appDelegate.addingProductsToWardrobeID isEqualToString:@""]))
        {
            _addingProductsToWardrobeID = appDelegate.addingProductsToWardrobeID;
        }
    }
    
    if(appDelegate.currentUser)
    {
        [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
        
        if (!(_wardrobesFetchedResultsController == nil))
        {
            userWardrobesElements = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
            {
                Wardrobe * tmpWardrobe = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                
                if([tmpWardrobe.idWardrobe isEqualToString:_addingProductsToWardrobeID])
                {
                    _addingProductsToWardrobe = tmpWardrobe;
                }
                
                [userWardrobesElements addObjectsFromArray:tmpWardrobe.itemsId];
            }
            
            _wardrobesFetchedResultsController = nil;
            _wardrobesFetchRequest = nil;
            
            [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
        }
    }
}

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    if(self.videoMenuButton.selected&&![_TextFieldsUpperView isHidden]){
        [self moveUpUpperView];
    }
}

- (void)setupMonthsForFiltering{
    monthFilterArray = [NSMutableArray new];
    monthComponents = [NSMutableDictionary new];
    
    NSDate * today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components: (NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:today];
    NSInteger currentYear = dateComponents.year;
    NSInteger currentMonth = dateComponents.month;

    NSDateComponents *userRegisteredDateComponents = [calendar components: (NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self.shownStylist.createdAt];
    NSInteger userRegisteredYear = userRegisteredDateComponents.year;
    NSInteger userRegisteredMonth = userRegisteredDateComponents.month;

    [monthComponents setObject:[[NSMutableArray alloc] initWithObjects:@"ALL", nil] forKey:[NSNumber numberWithInteger:0]];
    [monthFilterArray addObject:[NSNumber numberWithInteger:0]];
    for (NSInteger i = currentYear; i>=(MAX(kLowestYearForFilter, userRegisteredYear)); i--) {
        NSMutableArray* newYear = [NSMutableArray new];
        NSInteger limitMonth = 12;
        NSInteger startMonth = 1;
        
        if ((i == userRegisteredYear) && (i == currentYear))
        {
            startMonth = userRegisteredMonth;
            limitMonth = currentMonth - (startMonth - 1) + (startMonth - 1);
        }
        else
        {
            if (i == userRegisteredYear)
            {
                startMonth = userRegisteredMonth;
            }
            if (i == currentYear)
            {
                limitMonth = currentMonth - (startMonth - 1);
                
            }
        }
        
        
//        if ((i==currentYear) && (i==userRegisteredYear)) {
//            limitMonth = currentMonth;
//        }
//        if ((i!=currentYear) && (i==userRegisteredYear)) {
//            limitMonth = userRegisteredMonth;
//        }
        for (NSInteger j=startMonth; j<=limitMonth; j++) {
            [newYear addObject:[NSNumber numberWithInteger:j]];
        }
        [monthComponents setObject:newYear forKey:[NSNumber numberWithInteger:i]];
        [monthFilterArray addObject:[NSNumber numberWithInteger:i]];
    }
}

- (void)setupPostsController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BasicScreens" bundle:[NSBundle mainBundle]];
    postsDoubleDisplayController = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",DOUBLEDISPLAY_VC]];
    
    [postsDoubleDisplayController willMoveToParentViewController:self];
    [self.postsContainerView addSubview:postsDoubleDisplayController.view];
    [self addChildViewController:postsDoubleDisplayController];
    [postsDoubleDisplayController didMoveToParentViewController:self];
    [postsDoubleDisplayController setupAutolayout];
    
    postsDoubleDisplayController.delegate = self;
    postsDoubleDisplayController.itemsPerRow = 3;
    postsDoubleDisplayController.cellsHideHeader = YES;
}

- (void)setupWardrobesController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BasicScreens" bundle:[NSBundle mainBundle]];
    wardrobesDoubleDisplayController = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",DOUBLEDISPLAY_VC]];
    
    [wardrobesDoubleDisplayController willMoveToParentViewController:self];
    [self.wardrobesContainerView addSubview:wardrobesDoubleDisplayController.view];
    [self addChildViewController:wardrobesDoubleDisplayController];
    [wardrobesDoubleDisplayController didMoveToParentViewController:self];
    [wardrobesDoubleDisplayController setupAutolayout];
    
    wardrobesDoubleDisplayController.delegate = self;
    wardrobesDoubleDisplayController.itemsPerRow = 3;
    wardrobesDoubleDisplayController.cellsHideHeader = YES;
    wardrobesDoubleDisplayController.isOwner = showingOwn;
    wardrobesDoubleDisplayController.isWardrobe = YES;
}

-(void) removePostsInCoreData
{
    if(!(self.mainFetchedResultsController == nil))
    {
        for (FashionistaPost *tmpPost in self.mainFetchedResultsController.fetchedObjects)
        {
            if(!(tmpPost == nil))
            {
                if([tmpPost isKindOfClass:[FashionistaPost class]])
                {
                    if(!(tmpPost.userId == nil))
                    {
                        if (!([tmpPost.userId isEqualToString:@""]))
                        {
                            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            
                            if (!(appDelegate.currentUser == nil))
                            {
                                if(!(appDelegate.currentUser.idUser == nil))
                                {
                                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                                    {
                                        if([tmpPost.userId isEqualToString:appDelegate.currentUser.idUser])
                                        {
                                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                                            
                                            [currentContext deleteObject:tmpPost];
                                            NSError * error = nil;
                                            if (![currentContext save:&error])
                                            {
                                                NSLog(@"Error saving context! %@", error);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    /*
    if([downloadQueue count]>0){
        interruptedSearch = YES;
        [self resetPostsQueue];
    }
     */
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.headerVideobackgroundImageView.hidden = YES;
    BOOL showFeedback = NO;
    /*
    if(interruptedSearch){
        [self preloadAllPosts];
        interruptedSearch = NO;
        
    }else
        */
//    if(!finishedDownloading)
//    {
        showFeedback = YES;
        // Get / Reload the Fashionista User Pages
        [self setMainFetchedResultsController:nil];
        [self setMainFetchRequest:nil];
        [self.postsArray removeAllObjects];
    
    [self.wardrobesArray removeAllObjects];
    [gsElements removeAllObjects];
    [downloadedWardrobes removeAllObjects];
    
        [self getUserPosts];
        [self getUsersWardrobes];
//    }
    // Reload User Wardrobes
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                if([appDelegate.currentUser.idUser isEqualToString:self.shownStylist.idUser])
                {
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    if(showFeedback){
                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                    }
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                    
                    [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
                }
            }
        }
    }
    
    if(!showingOwn){
        if([self doesCurrentUserFollowsStylistWithId:_shownStylist.idUser])
        {
            self.followButton.hidden = YES;
            self.optionsButton.hidden = NO;
        }
        else
        {
            self.followButton.hidden = NO;
            self.optionsButton.hidden = YES;
        }
    }else{
        self.shownStylist = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
        originalUserName = self.shownStylist.fashionistaName;
        [self setupTextFields];
    }
    [self.postsContainerView layoutIfNeeded];
    [self.wardrobesContainerView layoutIfNeeded];
    [self showOptions:NO fromPoint:CGPointZero];
    if(!showFeedback){
        [self stopActivityFeedback];
    }
}


#pragma mark - Profile information views management

-(void) setupTextFields
{
    NSURL *noImageFileURL = [[NSBundle mainBundle] URLForResource: @"portrait" withExtension:@"png"];
    
    UIImage * image = [UIImage cachedImageWithURL:[noImageFileURL absoluteString]];
    [self.fashionistaImage setImage:image];
    
    if (!(_shownStylist == nil))
    {
        if(!(_shownStylist.idUser == nil))
        {
            if(!([_shownStylist.idUser isEqualToString:@""]))
            {
                if([_shownStylist.isFashionista boolValue])
                {
                    self.fashionistaURL.text = _shownStylist.fashionistaBlogURL;
                    self.verifiedBadge.hidden = YES;
                    if (_shownStylist.validatedprofile != nil)
                    {
                        self.verifiedBadge.hidden = (_shownStylist.validatedprofile.boolValue == NO);
                    }
                    
                    
                    self.fashionistaURLField.text = self.fashionistaURL.text;
                    
                    [self setUserImages];
                }
            }
        }
    }
}

- (void)setUserImages{
    UIImage* placeholderImage = nil;
    if(self.fashionistaImage.image){
        placeholderImage = self.fashionistaImage.image;
    }else{
        placeholderImage = [UIImage imageNamed:@"portrait.png"];
    }
    [self.fashionistaImage setImageWithURL:[NSURL URLWithString:_shownStylist.picture] placeholderImage:placeholderImage];
    
    
    self.fashionistaImage.layer.masksToBounds = YES;
    self.fashionistaImage.layer.borderWidth = 2;
    self.fashionistaImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    if(_shownStylist.headerMedia==nil){
        self.profileHeaderImage.hidden = YES;
        self.headerVideoContainer.hidden = YES;
        self.headerVideobackgroundImageView.hidden = YES;
    }else{
        if ([_shownStylist.headerType isEqualToString:@"video"]) {
            [self setupVideoWithUrl:_shownStylist.headerMedia];
            self.profileHeaderImage.hidden = YES;
            self.headerVideoContainer.hidden = NO;
            self.headerVideobackgroundImageView.hidden = NO;
        }else{
            if(self.profileHeaderImage.image){
                placeholderImage = self.profileHeaderImage.image;
            }else{
                placeholderImage = [UIImage imageNamed:@"no_image_big.png"];
            }
            [self.profileHeaderImage setImageWithURL:[NSURL URLWithString:_shownStylist.headerMedia] placeholderImage:placeholderImage];
            
            self.profileHeaderImage.hidden = NO;
            self.headerVideoContainer.hidden = YES;
            self.headerVideobackgroundImageView.hidden = YES;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([player.player rate]) {
            playing = YES;
        }else{
            playing = NO;
        }
        self.videoPlayButton.selected = !playing;
    }
}

- (void)setupVideoWithUrl:(NSString*)videoURL{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[player.player currentItem]];
    [player.player removeObserver:self forKeyPath:@"rate"];
    [player.view removeFromSuperview];
    player = nil;
    
    NSError *_error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: &_error];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    player = [[AVPlayerViewController alloc] init];
    player.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoURL]];
    player.showsPlaybackControls = NO;
    player.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player.player currentItem]];
    [player.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    self.videoPlayButton.selected = YES;
    
    player.view.frame = self.headerVideoContainer.bounds;
    UIView * pView = player.view;
    pView.backgroundColor = [UIColor clearColor];
    
    AVAsset *asset = [player.player currentItem].asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(1, 1);
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    self.headerVideobackgroundImageView.image = thumbnail;
   // self.profileHeaderImage.image = thumbnail;
    self.headerVideobackgroundImageView.hidden = NO;
    
    NSLog(@"Video URL : %@",videoURL);
    
    // Insert View into Post View
    
    [self.headerVideoContainer addSubview:pView];
    [self.profileHeaderImage.superview sendSubviewToBack:self.profileHeaderImage];
    [self.uploadImageLabel.superview sendSubviewToBack:self.uploadImageLabel];
    self.uploadImageLabel.hidden = YES;
   // [self.headerVideobackgroundImageView.superview bringSubviewToFront:self.headerVideobackgroundImageView];
    [pView.superview bringSubviewToFront:pView];
    [self.videoPlayButton.superview bringSubviewToFront:self.videoPlayButton];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void) hideEditPageButton
{
    for (UIView* v in self.editViews) {
        v.hidden = YES;
    }
}

- (void) showEditPageButton
{
    for (UIView* v in self.editViews) {
        v.hidden = NO;
    }
}

- (void)showTextFieldsUpperView
{
    if(!([_TextFieldsUpperView isHidden]))
    {
        return;
    }
    
    CGFloat offset = 265;//((self.view.frame.size.height)*((IS_IPHONE_4_OR_LESS) ? (0.52) : (0.48)));
    
    // Show Add Terms text field and set the focus
    //    [self.view bringSubviewToFront:_TextFieldsUpperView];
    [_TextFieldsUpperView setHidden:NO];
    
    CGFloat constant = self.TextFieldUpperViewTopConstraint.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.TextFieldUpperViewTopConstraint.constant = newConstant;
                         
                         [_TextFieldsUpperView setAlpha:1.0];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)moveUpUpperView{
    CGFloat offset = -265;
    
    CGFloat constant = self.TextFieldUpperViewTopConstraint.constant;
    
    CGFloat newConstant = constant + offset;
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.TextFieldUpperViewTopConstraint.constant = newConstant;
                         
                         [_TextFieldsUpperView setAlpha:0.01];
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         
                         [_TextFieldsUpperView setHidden:YES];
                         
                     }];
}

- (void)hideTextFieldsUpperView
{
    if([_TextFieldsUpperView isHidden])
    {
        return;
    }
    
    if(_TextFieldsUpperView.alpha < 1.0)
    {
        return;
    }
    
    [self.view endEditing:YES];
    [self moveUpUpperView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.view endEditing:YES];
    return YES;
}

// OVERRIDE: Action to perform when user swipes to right: go to previous screen
- (void)panGesture:(UIPanGestureRecognizer *)sender
{
    
    CGPoint velocity = [sender velocityInView:self.view];
    
    CGPoint translation = [sender translationInView:self.view];
    
    CGFloat widthPercentage  = fabs(translation.x / CGRectGetWidth(sender.view.bounds));
    
    CGFloat heightPercentage  = fabs(translation.y / CGRectGetHeight(sender.view.bounds));
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        // Perform the transition when swipe right
        if (velocity.x > 0)
        {
            if(widthPercentage > 0.3)
            {
                [self swipeRightAction];
            }
        }
        
        // Perform the transition when swipe left
        if (velocity.x < 0)
        {
            if(widthPercentage > 0.3)
            {
                [self swipeLeftAction];
            }
        }
        
        // Hide the advanced search when swipe up
        if (velocity.y > 0)
        {
            if(heightPercentage > 0.1)
            {
                [self swipeDownAction];
            }
        }
        
        if (velocity.y < 0)
        {
            if(heightPercentage > 0.1)
            {
                [self swipeUpAction];
            }
        }
        
        // Hide the advanced search when swipe up
        if ((IS_IPHONE_4_OR_LESS) && (velocity.y < 0))
        {
            if(heightPercentage > 0.1)
            {
                [self hideTextFieldsUpperView];
            }
        }
    }
}

// Action to perform when user swipes down
- (void)swipeDownAction
{
    if(self.moreOptions.superview.alpha == 0){
        [self.view endEditing:YES];
        [self showTextFieldsUpperView];
    }
}

- (void)swipeUpAction{
    if(self.moreOptions.superview.alpha == 0)
        [self hideTextFieldsUpperView];
}

// Check if arrived to the end of the collection view and, if so, request more results
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.monthFilterBackground.hidden&&self.moreOptions.superview.alpha == 0){
        // Check if the upper view should be shown
        if ((0 < scrollView.contentOffset.y) && (scrollView.isDragging))
        {
            [self hideTextFieldsUpperView];
        }
        
        // Check if the resuts reload should be performed
        if ((scrollView.contentOffset.y <= kOffsetToShowUpperView) && (scrollView.isDragging))
        {
            [self.view endEditing:YES];
            [self showTextFieldsUpperView];
        }
        
        // Check if the resuts reload should be performed
        if ((_bContinueUpdating) && (scrollView.contentOffset.y >= roundf((scrollView.contentSize.height-scrollView.frame.size.height)+kOffsetForBottomScroll)))
        {
            // Do it only if the total number of results is not achieved yet and a search is not already taking place
            if ([[self activityLabel] isHidden])
            {
                _bLoadMoreContent = YES;
                [self updateSearch];
            }
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [suggestionList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        GSSuggestionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GSSUGGESTION_CELL forIndexPath:indexPath];
        GSBaseElement *result = (GSBaseElement *)[suggestionList objectAtIndex:indexPath.item];
        
        if ([UIImage isCached:result.preview_image])
        {
            UIImage * image = [UIImage cachedImageWithURL:result.preview_image];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            cell.image.image = image;
        }
        else
        {
            [cell.image setImageWithURL:[NSURL URLWithString:result.preview_image] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
        }
        
        cell.name.text = result.mainInformation;
        cell.followButton.tag = indexPath.item;
        [cell.followButton addTarget:self action:@selector(onTapFollowUser:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
  }

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 130);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GSBaseElement *result = (GSBaseElement *)[suggestionList objectAtIndex:indexPath.item];
    [self openFashionistaWithId:result.fashionistaId];
    return;
}

- (void)openFashionistaWithId:(NSString *)userId{
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:userId, nil];
    
    [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
}
#pragma mark - Collection view methods


// Setup Main Collection View background image
- (void) setupBackgroundImage
{
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:nil];
    
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    
    [backgroundImageView setAlpha:1.00];
    
    [backgroundImageView setImage:[UIImage imageNamed:@"Splash_Background.png"]];
    
    [backgroundImageView setUserInteractionEnabled:YES];
    
    //    [backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAddSearchTerm)]];
    
    [self.mainCollectionView setBackgroundView:backgroundImageView];
}

// Initialize fetched Results Controller to fetch the current user wardrobes in order to properly show the hanger button
- (BOOL)initFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_wardrobesFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_wardrobesFetchRequest == nil)
        {
            if([arrayForPredicate count] > 0)
            {
                _wardrobesFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [_wardrobesFetchRequest setEntity:entity];
                
                // Filter results
                
                [_wardrobesFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [_wardrobesFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [_wardrobesFetchRequest setFetchBatchSize:20];
            }
        }
        
        if(_wardrobesFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_wardrobesFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _wardrobesFetchedResultsController = fetchedResultsController;
            
            _wardrobesFetchedResultsController.delegate = self;
        }
        
        if(_wardrobesFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_wardrobesFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_wardrobesFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}

// Check if the item is in the current user list of wardrobes
- (BOOL) doesCurrentUserWardrobesContainItemWithId:(GSBaseElement *)item
{
    NSString * itemId = @"";
    
    _wardrobesFetchedResultsController = nil;
    _wardrobesFetchRequest = nil;
    
    [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
    
    if (!(item == nil))
    {
        
        if(!(item.productId == nil))
        {
            if(!([item.productId isEqualToString:@""]))
            {
                itemId = item.productId;
            }
        }
        else if(!(item.wardrobeQueryId == nil))
        {
            if(!([item.wardrobeQueryId isEqualToString:@""]))
            {
                itemId = item.wardrobeQueryId;
            }
        }
        else if(!(item.fashionistaPostId == nil))
        {
            if(!([item.fashionistaPostId isEqualToString:@""]))
            {
                itemId = item.fashionistaPostId;
            }
        }
        else if(!(item.fashionistaPageId == nil))
        {
            if(!([item.fashionistaPageId isEqualToString:@""]))
            {
                itemId = item.fashionistaPageId;
            }
        }
        else if(!(item.wardrobeId == nil))
        {
            if(!([item.wardrobeId isEqualToString:@""]))
            {
                itemId = item.wardrobeId;
            }
        }
        else if(!(item.styleId == nil))
        {
            if(!([item.styleId isEqualToString:@""]))
            {
                itemId = item.styleId;
            }
        }
        else if(!(item.wardrobeQueryId == nil)) {
            if (!([item.wardrobeQueryId isEqualToString:@""])) {
                itemId = item.wardrobeQueryId;
            }
        }
    }
    
    if (!([itemId isEqualToString:@""]))
    {
        if (!(_wardrobesFetchedResultsController == nil))
        {
            if (!((int)[[_wardrobesFetchedResultsController fetchedObjects] count] < 1))
            {
                for (GSBaseElement *tmpGSBaseElement in [_wardrobesFetchedResultsController fetchedObjects])
                {
                    if([tmpGSBaseElement isKindOfClass:[GSBaseElement class]])
                    {
                        // Check that the element to search is valid
                        if (!(tmpGSBaseElement == nil))
                        {
                            if(!(tmpGSBaseElement.productId == nil))
                            {
                                if(!([tmpGSBaseElement.productId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.productId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.fashionistaPostId == nil))
                            {
                                if(!([tmpGSBaseElement.fashionistaPostId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.fashionistaPostId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.fashionistaPageId == nil))
                            {
                                if(!([tmpGSBaseElement.fashionistaPageId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.fashionistaPageId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.wardrobeId == nil))
                            {
                                if(!([tmpGSBaseElement.wardrobeId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.wardrobeId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.wardrobeQueryId == nil))
                            {
                                if(!([tmpGSBaseElement.wardrobeQueryId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.wardrobeQueryId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.styleId == nil))
                            {
                                if(!([tmpGSBaseElement.styleId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.styleId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                            else if(!(tmpGSBaseElement.wardrobeQueryId == nil))
                            {
                                if(!([tmpGSBaseElement.wardrobeQueryId isEqualToString:@""]))
                                {
                                    if ([tmpGSBaseElement.wardrobeQueryId isEqualToString:itemId])
                                    {
                                        return YES;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}


// Initialize a specific Fetched Results Controller to fetch the current user follows in order to properly show the heart button
- (BOOL)initFollowsFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_followsFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_followsFetchRequest == nil)
        {
            if([arrayForPredicate count] > 0)
            {
                _followsFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [_followsFetchRequest setEntity:entity];
                
                // Filter results
                
                [_followsFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [_followsFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [_followsFetchRequest setFetchBatchSize:20];
            }
        }
        
        if(_followsFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_followsFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_followsFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _followsFetchedResultsController = fetchedResultsController;
            
            _followsFetchedResultsController.delegate = self;
        }
        
        if(_followsFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_followsFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_followsFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}

// Check if the user is in the current user list of follows
- (BOOL) doesCurrentUserFollowsStylistWithId:(NSString *)stylistId
{
    _followsFetchedResultsController = nil;
    _followsFetchRequest = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                if(!(stylistId == nil))
                {
                    if (!([stylistId isEqualToString:@""]))
                    {
                        [self initFollowsFetchedResultsControllerWithEntity:@"Follow" andPredicate:@"followingId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idFollow" ascending:YES];
                        
                        if (!(_followsFetchedResultsController == nil))
                        {
                            if (!((int)[[_followsFetchedResultsController fetchedObjects] count] < 1))
                            {
                                for (Follow *tmpFollow in [_followsFetchedResultsController fetchedObjects])
                                {
                                    if([tmpFollow isKindOfClass:[Follow class]])
                                    {
                                        // Check that the follow is valid
                                        if (!(tmpFollow == nil))
                                        {
                                            if(!(tmpFollow.followedId == nil))
                                            {
                                                if(!([tmpFollow.followedId isEqualToString:@""]))
                                                {
                                                    if ([tmpFollow.followedId isEqualToString:stylistId])
                                                    {
                                                        return YES;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

// Check if the item is in the current user list of wardrobes
- (BOOL) isThisUserMe:(NSString *)shownStylistId
{
    if (!(shownStylistId == nil))
    {
        if(![shownStylistId isEqualToString:@""])
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if(!(appDelegate.currentUser.idUser == nil))
                {
                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        if([appDelegate.currentUser.idUser isEqualToString:shownStylistId])
                        {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

// OVERRIDE: Return the layout to be shown in a cell for a collection view
- (resultCellLayout)getLayoutTypeForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    return PAGELAYOUT;
}

// OVERRIDE: Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:GSPOST_CELL])
    {
        if(_bEditionMode)
        {
            if(_shownStylist == nil)
            {
                return 0;
            }
            
            return MAX([[[self getFetchedResultsControllerForCellType:cellType] sections] count], 1);
        }
        
        return [[[self getFetchedResultsControllerForCellType:cellType] sections] count];
    }
    
    return 1;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldShowDecorationViewForCollectionView:(UICollectionView *)collectionView
{
    return NO;
}

// OVERRIDE: Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldReportResultsforSection:(int)section
{
    return NO;
}

// OVERRIDE: Return the title to be shown in section header for a collection view
- (NSString *)getHeaderTitleForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)setupSelectedPageWithCellType:(NSString *)cellType{
    [self getNumberOfPostsDownloaded];
}

- (void)onTapAddToWardrobeButton:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
        return;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    FashionistaPost *selectedResult = [[self getFetchedResultsControllerForCellType:GSPOST_CELL] objectAtIndexPath:[NSIndexPath indexPathForItem:(sender.tag - (((int)(sender.tag/OFFSET))*OFFSET)) inSection:((int)(sender.tag/OFFSET))]];
    
    if (!([self doesCurrentUserWardrobesContainItemWithId:selectedResult]))
    {
        // Instantiate the 'AddItemToWardrobe' view controller within the container view
        
        if ([UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] != nil)
        {
            AddItemToWardrobeViewController *addItemToWardrobeVC = nil;
            
            @try {
                
                addItemToWardrobeVC = [[UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] instantiateViewControllerWithIdentifier:[@(ADDITEMTOWARDROBE_VC) stringValue]];
                
            }
            @catch (NSException *exception) {
                
                return;
                
            }
            
            if (addItemToWardrobeVC != nil)
            {
                if ([selectedResult isKindOfClass:[FashionistaPost class]])
                {
                    [addItemToWardrobeVC setPostToAdd:(FashionistaPost *)selectedResult];
                }
                //                else
                //                {
                //                    [addItemToWardrobeVC setItemToAdd:selectedResult];
                //                }
                
                
                [addItemToWardrobeVC setButtonToHighlight:sender];
                
                [self addChildViewController:addItemToWardrobeVC];
                
                //[addItemToWardrobeVC willMoveToParentViewController:self];
                
                addItemToWardrobeVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                
                [_addToWardrobeVCContainerView addSubview:addItemToWardrobeVC.view];
                
                [addItemToWardrobeVC didMoveToParentViewController:self];
                
                [_addToWardrobeVCContainerView setHidden:NO];
                
                [_addToWardrobeBackgroundView setHidden:NO];
                
                [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
                
                [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
            }
        }
    }
}

- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess
{
    if ((bSuccess) && (!(button == nil)))
    {
        // Change the hanger button imageç
        UIImage * buttonImage = [UIImage imageNamed:@"hanger_checked.png"];
        
        if (!(buttonImage == nil))
        {
            [button setImage:buttonImage forState:UIControlStateNormal];
            [button setImage:buttonImage forState:UIControlStateHighlighted];
            [[button imageView] setContentMode:UIViewContentModeScaleAspectFit];
        }
        
        // Reload User Wardrobes
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (!(appDelegate.currentUser == nil))
        {
            if(!(appDelegate.currentUser.idUser == nil))
            {
                if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPOST_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                    
                    [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
                }
            }
        }
    }
    
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_addToWardrobeVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_addToWardrobeVCContainerView setHidden:YES];
    
    [_addToWardrobeBackgroundView setHidden:YES];
}


// OVERRIDE: Just to prevent from being at the 'Add to Wardrobe' view
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([_addToWardrobeVCContainerView isHidden]))
        return;
    
    [super touchesEnded:touches withEvent:event];
    
}

#pragma mark - Requests


// Perform search with a new set of search terms
- (void)getUserPages
{
    if (!(_shownStylist.idUser == nil))
    {
        if (!([_shownStylist.idUser isEqualToString:@""]))
        {
            NSLog(@"Retrieving User Pages");
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownStylist.idUser, nil];
            
            [self performRestGet:GET_FASHIONISTAPAGES withParamaters:requestParameters];
        }
    }
}


- (void)getUserPosts
{
    if (!(_shownStylist.idUser == nil))
    {
        if (!([_shownStylist.idUser isEqualToString:@""]))
        {
            NSLog(@"Retrieving User Posts");
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownStylist.idUser,[self calculateDateStringForSelection],@"",@"",@"",@"", nil];
            
            searchingPosts = YES;
            finishedDownloading = NO;
            [self performRestGet:GET_FASHIONISTAPOSTS withParamaters:requestParameters];
            [self performRestGet:GET_FOLLOWERS_FOLLOWINGS_COUNT withParamaters:requestParameters];
        }
    }
}

- (void)getUsersWardrobes {
    if (!(_shownStylist.idUser == nil)) {
        if (!([_shownStylist.idUser isEqualToString:@""])) {
            NSLog(@"Retrieving User Wardrobes");
            
            // Perform request to get the search results
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
            
            NSArray *requestParameters = [[NSArray alloc] initWithObjects:_shownStylist.idUser, [self calculateDateStringForSelection], @"4", nil];
            
            searchingPosts = YES;
            finishedDownloading = NO;
            [self performRestGet:GET_FASHIONISTAWARDROBES withParamaters:requestParameters];
        }
    }
}

// Update search with more results
- (void)updateSearch
{
    
}

// Delete Post
- (void)deletePost:(FashionistaPost *)post
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        NSLog(@"Deleting post: %@", post.name);
        
        // Check that the id is valid
        
        if (!(post == nil))
        {
            if (!(post.idFashionistaPost == nil))
            {
                if (!([post.idFashionistaPost isEqualToString:@""]))
                {
                    // Perform request to delete
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DELETINGPOST_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:post, nil];
                    _idPostToDelete = post.idFashionistaPost;
                    
                    [self performRestDelete:DELETE_POST withParamaters:requestParameters];
                    
                }
            }
        }
    }
}

-(void)onTapFollowUser:(UIButton*)sender {
    GSBaseElement *result = (GSBaseElement *)[suggestionList objectAtIndex:sender.tag];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    setFollow * newFollow = [[setFollow alloc] init];
    
    [newFollow setFollow:result.fashionistaId];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
    
    [self performRestPost:FOLLOW_USER withParamaters:requestParameters];
    
    [suggestionList removeObjectAtIndex:sender.tag];
    [self.suggestionCollectionView reloadData];

    //    NSIndexPath *indexpath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    //    [theCell.suggestionList deleteItemsAtIndexPaths:@[indexpath]];
}


-(void)setSuggestionList:(NSArray*)mappingResult {
    searchSuggestion = NO;
    [suggestionList removeAllObjects];
    suggestionList = [NSMutableArray new];
    
    for (GSBaseElement *result in mappingResult)
    {
        if([result isKindOfClass:[GSBaseElement class]])
        {
            if (![self doesCurrentUserFollowsStylistWithId:result.fashionistaId]) {
                [suggestionList addObject:result];
            }
        }
    }
    
    if ([suggestionList count] == 0) {
        self.suggestionViewHeightConstraint.constant = 0;
        [self.suggestionView setHidden:YES];
    }
    if (![self doesCurrentUserFollowsStylistWithId:_shownStylist.idUser]) {
        self.suggestionViewHeightConstraint.constant = 0;
        [self.suggestionView setHidden:YES];
    }
    else {
        self.suggestionViewHeightConstraint.constant = kSuggestionViewHeight;
        [self.suggestionView setHidden:NO];
        [_suggestionCollectionView reloadData];
    }
}

- (void)processUserListAnswer:(NSArray*)mappingResult andConnection:(connectionType)connection{
    // Paramters for next VC (ResultsViewController)
    if (searchSuggestion) {
        [self setSuggestionList:mappingResult];
        return;
    }
    NSArray * parametersForNextVC = [NSArray arrayWithObjects: mappingResult, [NSNumber numberWithInt:connection], nil];
    
    [self stopActivityFeedback];
    
    if ([mappingResult count] > 0)
    {
        UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
        BaseViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(USERLIST_VC) stringValue]];
        
        [self prepareViewController:nextViewController withParameters:parametersForNextVC];
        [(SearchBaseViewController*)nextViewController setSearchContext:FASHIONISTAS_SEARCH];
        [self showViewControllerModal:nextViewController];
        ((FashionistaUserListViewController*)nextViewController).shownRelatedUser = _shownStylist;
        if (willShowFollowers) {
            ((FashionistaUserListViewController*)nextViewController).userListMode = FOLLOWERS;
            [self setTitleForModal:@"FOLLOWERS"];
        }else{
            ((FashionistaUserListViewController*)nextViewController).userListMode = FOLLOWED;
            [self setTitleForModal:@"FOLLOWING"];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_FOLLOWERSORFOLLOWING_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
}
/*
- (void)cancelCurrentSearch{
    if([downloadQueue count]>0){
        interruptedSearch = YES;
        [self resetPostsQueue];
    }
}
*/
- (void)processSearchPostsAnswer:(NSArray*)mappingResult{
    // Get the list of results that were provided
    for (GSBaseElement *result in mappingResult)
    {
        if([result isKindOfClass:[GSBaseElement class]])
        {
            if(!(result.fashionistaPostId == nil))
            {
                NSLog(@"Fashionista Post Type : %@", result.posttype);
                if  (!([result.fashionistaPostId isEqualToString:@""]))
                {
                    if(isRefreshing){
                        if(!([self.postsArray containsObject:result.fashionistaPostId]))
                        {
                            [self.postsArray removeAllObjects];
                            [downloadedPosts removeAllObjects];
                            [postElements removeAllObjects];
                        }
                        isRefreshing = NO;
                    }
                    if(!([self.postsArray containsObject:result.fashionistaPostId]))
                    {
                        [self preLoadImage:result.preview_image];
                        if(result.content_type&&[result.content_type integerValue]==1){
                            [self preLoadImage:result.content_url];
                        }
                        [self.postsArray addObject:result.fashionistaPostId];
                        [downloadedPosts setObject:[result postParamsFromBaseElement] forKey:result.fashionistaPostId];
                        [postElements setObject:result forKey:result.fashionistaPostId];
                        [postsDoubleDisplayController newDataObjectGathered:[result postParamsFromBaseElement]];
                    }
                }
            }
        }
    }
    
    [postsDoubleDisplayController refreshData];
    [self stopActivityFeedback];
}

- (void)processSearchWardrobesAnswer:(NSArray*)mappingResult{
    // Get the list of results that were provided
    for (GSBaseElement *result in mappingResult)
    {
        if([result isKindOfClass:[GSBaseElement class]])
        {
            NSLog(@"POST TYPE : %@", result.posttype);
            if(!(result.fashionistaPostId == nil))
            {
                NSLog(@"Wardrobe Name : %@", result.wardrobeQueryId);
                NSLog(@"Wardrobe name : %@", result.additionalInformation);
                if  (!([result.fashionistaPostId isEqualToString:@""]))
                {
                    if(isRefreshing){
                        if(!([self.wardrobesArray containsObject:result.fashionistaPostId]))
                        {
                            [self.wardrobesArray removeAllObjects];
                            [downloadedWardrobes removeAllObjects];
                            [gsElements removeAllObjects];
                        }
                        isRefreshing = NO;
                    }
                    if(!([self.wardrobesArray containsObject:result.fashionistaPostId]))
                    {
                        [self preLoadImage:result.preview_image];
                        if(result.content_type&&[result.content_type integerValue]==1){
                            [self preLoadImage:result.content_url];
                        }
                        [self.wardrobesArray addObject:result.fashionistaPostId];
                        [downloadedWardrobes setObject:[result postParamsFromBaseElement] forKey:result.fashionistaPostId];
                        [gsElements setObject:result forKey:result.fashionistaPostId];
                        [wardrobesDoubleDisplayController newDataObjectGathered:[result postParamsFromBaseElement]];
                    }
                }
            }
        }
    }
    
    [wardrobesDoubleDisplayController refreshData];
    [self stopActivityFeedback];
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSArray * parametersForNextVC = nil;
    __block FashionistaPost * selectedSpecificPost;
    NSManagedObjectContext *currentContext;
    NSMutableArray * postContent = [[NSMutableArray alloc] init];
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    
    __block SearchQuery *searchQuery;
    __block User * currentUser;
    
    switch (connection)
    {
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            if(searchingPosts){
                [postsDoubleDisplayController refreshData];
            }
            [self stopActivityFeedback];
            finishedDownloading = YES;
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            // Get the number of total results that were provided
            // and the string of terms that didn't provide any results
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if ([mappingResult count] > 0)
            {
                if(searchingPosts){
                    [self processSearchPostsAnswer:mappingResult];
                }else{
                    [self processUserListAnswer:mappingResult andConnection:connection];
                }
            }

            [postsDoubleDisplayController refreshData];
            self.postNumber.text = [self formatNumber:[NSNumber numberWithLong:[_postsArray count]]];
            [self stopActivityFeedback];
            finishedDownloading = YES;
            break;
        }
        case FINISHED_SEARCH_WITHOUT_WARDROBES:
        {
            if(searchingPosts){
                [wardrobesDoubleDisplayController refreshData];
            }
            [self stopActivityFeedback];
            finishedDownloading = YES;
            break;
        }
        case FINISHED_SEARCH_WITH_WARDROBES:
        {
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if ([mappingResult count] > 0)
            {
                [self processSearchWardrobesAnswer:mappingResult];
            }

            [wardrobesDoubleDisplayController refreshData];
            
            [self stopActivityFeedback];
            finishedDownloading = YES;
            break;

        }
        case GET_USER_FOLLOWS:
        {
            [_followsFetchedResultsController performFetch:nil];
            [self stopActivityFeedback];
            break;
        }
        case UNFOLLOW_USER:
        case FOLLOW_USER:
        {
            if (!(_shownStylist.idUser == nil))
            {
                if (!([_shownStylist.idUser isEqualToString:@""]))
                {
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownStylist.idUser, nil];
                    [self performRestGet:GET_FOLLOWERS_FOLLOWINGS_COUNT withParamaters:requestParameters];
                }
            }
            
            // Change the hanger button image
            if (connection == FOLLOW_USER)
            {
                self.followButton.hidden = YES;
                self.optionsButton.hidden = NO;
            }
            else
            {
                self.followButton.hidden = NO;
                self.optionsButton.hidden = YES;
            }
            
            // Reload User Follows
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if(!(appDelegate.currentUser.idUser == nil))
                {
                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                        
                        [self performRestGet:GET_USER_FOLLOWS withParamaters:requestParameters];
                        if (connection == FOLLOW_USER) {
                            //Show Notifications alert
                            self.turnNotificationsView.hidden = NO;
                            [self.turnNotificationsView.superview bringSubviewToFront:self.turnNotificationsView];
                            if (searchSuggestion)
                                [self showStylistFollowers:nil];
                        }
                        return;
                    }
                }
            }
            
            [self stopActivityFeedback];
            break;
        }
        case GET_USER_WARDROBES:
        {
            if(mappingResult == nil)
            {
                [self stopActivityFeedback];
            }
            break;
        }
        case GET_USER_WARDROBES_CONTENT:
        {
            //Reset the fetched results controller to fetch the current user wardrobes
            
            _wardrobesFetchedResultsController = nil;
            _wardrobesFetchRequest = nil;
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if(appDelegate.currentUser)
            {
                [self initFetchedResultsControllerWithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idWardrobe" ascending:YES];
                
                if (!(_wardrobesFetchedResultsController == nil))
                {
                    NSMutableArray * userWardrobesElements = [[NSMutableArray alloc] init];
                    
                    for (int i = 0; i < [[_wardrobesFetchedResultsController fetchedObjects] count]; i++)
                    {
                        Wardrobe * tmpWardrobe = [[_wardrobesFetchedResultsController fetchedObjects] objectAtIndex:i];
                        
                        [userWardrobesElements addObjectsFromArray:tmpWardrobe.itemsId];
                    }
                    
                    _wardrobesFetchedResultsController = nil;
                    _wardrobesFetchRequest = nil;
                    
                    [self initFetchedResultsControllerWithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:userWardrobesElements sortingWithKey:@"idGSBaseElement" ascending:YES];
                    
                    [self updateCollectionViewWithCellType:GSPOST_CELL fromItem:0 toItem:-1 deleting:NO];
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case UPLOAD_FASHIONISTAPOST_FORSHARE:
        {
            [self stopActivityFeedback];
            break;
        }
        case UPLOAD_FASHIONISTAPAGE:
        {
            [self stopActivityFeedback];
            break;
        }
        case GET_FULL_POST:
        {
            User* postUser = nil;
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            selectedSpecificPost = (FashionistaPost *)post;
                            break;
                        }
                    }
                }
            }
            
            postLikesNumber = selectedSpecificPost.likesNum;
            
            
            resultComments = [NSMutableArray arrayWithArray:[[selectedSpecificPost.comments allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]]];
//            resultComments = [NSMutableArray arrayWithArray:[selectedSpecificPost.comments allObjects]] sortedArrayUsingDescriptors:[NSArray arrayWithObject: count:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]]];
//            sortedFashionistaContent = [_shownFashionistaPostContent sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
            
            postContent = [NSMutableArray arrayWithArray:[selectedSpecificPost.contents allObjects]];
            // Get the list of contents that were provided
            for (FashionistaContent *content in postContent)
            {
                [self preLoadImage:content.image];
                //[UIImage cachedImageWithURL:content.image];
            }
            
            postUser = selectedSpecificPost.author;
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:_bEditPost], postLikesNumber, _shownStylist, _selectedElement, nil];
            
            if(loadingPostInPage&&[loadingPostInPage isEqualToString:selectedSpecificPost.idFashionistaPost]){
                loadingPostInPage = nil;
                [self stopActivityFeedback];
                //[self nextInQueue];
                if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
                {
                    if (magazineLoding) {
                        [self transitionToViewController:FASHIONISTACOVERPAGE_VC withParameters:parametersForNextVC];
                    }
                    else {
                        [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
                    }
                }
                _selectedElement = nil;
            }else{
                if(!(selectedSpecificPost.idFashionistaPost==nil))
                {
                    if(cancelOperation){
                        cancelOperation = NO;
                    }else{
                        [downloadedPosts setObject:parametersForNextVC forKey:selectedSpecificPost.idFashionistaPost];
                        if(yearFiltered!=0){
                            [filteringPosts setObject:parametersForNextVC forKey:selectedSpecificPost.idFashionistaPost];
                        }
                        [postsDoubleDisplayController newDataObjectGathered:parametersForNextVC];
                    }
                }
                //[self nextInQueue];
                
            }
            _bEditPost = NO;
            
            break;
        }
        case GET_POST:
        {
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            selectedSpecificPost = (FashionistaPost *)post;
                            break;
                        }
                    }
                }
            }
            
            // Get the number of likes of that post
            for (NSMutableDictionary *postLikesNumberDict in mappingResult)
            {
                if([postLikesNumberDict isKindOfClass:[NSMutableDictionary class]])
                {
                    postLikesNumber = [postLikesNumberDict objectForKey:@"likes"];
                }
            }
            
            // Get the list of comments that were provided
            for (Comment *comment in mappingResult)
            {
                if([comment isKindOfClass:[Comment class]])
                {
                    if(!(comment.idComment == nil))
                    {
                        if  (!([comment.idComment isEqualToString:@""]))
                        {
                            if(!([resultComments containsObject:comment.idComment]))
                            {
                                //[resultComments addObject:comment.idComment];
                                [resultComments addObject:comment];
                            }
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (FashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[FashionistaContent class]])
                {
                    if(!(content.idFashionistaContent == nil))
                    {
                        if  (!([content.idFashionistaContent isEqualToString:@""]))
                        {
                            if(!([postContent containsObject:content]))
                            {
                                [postContent addObject:content];
                                [self preLoadImage:content.image];
                                //[UIImage cachedImageWithURL:content.image];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:_bEditPost], postLikesNumber, _shownStylist, nil];
            
            if(loadingPostInPage&&[loadingPostInPage isEqualToString:selectedSpecificPost.idFashionistaPost]){
                loadingPostInPage = nil;
                [self stopActivityFeedback];
                //[self nextInQueue];
                if((!([parametersForNextVC count] < 2)) && ([postContent count] > 0))
                {
                    [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
                }
            }else{
                if(!(selectedSpecificPost.idFashionistaPost==nil))
                {
                    if(cancelOperation){
                        cancelOperation = NO;
                    }else{
                        [downloadedPosts setObject:parametersForNextVC forKey:selectedSpecificPost.idFashionistaPost];
                        if(yearFiltered!=0){
                            [filteringPosts setObject:parametersForNextVC forKey:selectedSpecificPost.idFashionistaPost];
                        }
                        [postsDoubleDisplayController newDataObjectGathered:parametersForNextVC];
                    }
                }
                //[self nextInQueue];
                
            }
            _bEditPost = NO;
            
            break;
        }
        case DELETE_POST:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            if (_idPostToDelete != nil)
            {
                [_postsArray removeObject:_idPostToDelete];
            }
            
            //[currentContext deleteObject:_selectedPostToDelete];
            
            [currentContext processPendingChanges];
            
            if (![currentContext save:nil])
            {
                NSLog(@"Save did not complete successfully.");
            }
            
            [self getUserPosts];
            //_selectedPostToDelete = nil;
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:GSPOST_CELL];
            
            // Update collection view
            [self updateCollectionViewWithCellType:GSPOST_CELL fromItem:0 toItem:-1 deleting:FALSE];
            
            //update post number
            self.postNumber.text = [self formatNumber:[NSNumber numberWithLong:[_postsArray count]]];
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_FOLLOWERS_FOLLOWINGS_COUNT:
        {
            NSNumber * numberFollowers = (NSNumber*)[[mappingResult firstObject] valueForKey:@"followers"];
            NSNumber * numberFollowings = (NSNumber*)[[mappingResult firstObject] valueForKey:@"followings"];
            
            _iNumberOfFollowers = [numberFollowers intValue];
            _iNumberOfFollowing = [numberFollowings intValue];
            
            self.followersNumber.text = [self formatNumber:numberFollowers];
            self.followingNumbers.text = [self formatNumber:numberFollowings];
            
            break;
        }
        case USER_ACCEPT_NOTICES:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unnoticedUsers removeObjectForKey:_shownStylist.idUser];
            break;
        }
        case USER_IGNORE_NOTICES:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unnoticedUsers setObject:[mappingResult firstObject] forKey:_shownStylist.idUser];
            break;
        }
        case GET_FASHIONISTA:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     currentUser = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */currentUser, [NSNumber numberWithBool:NO], nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            
            break;
        }
        default:
            
            break;
    }
}


#pragma mark - Actions

- (IBAction)onTapAnalytics:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
        return;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    [self transitionToViewController:ANALYTICS_VC withParameters:nil];
}

- (IBAction)onTapFollowButton:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!([self doesCurrentUserFollowsStylistWithId:_shownStylist.idUser]))
    {
        if (!(_shownStylist == nil))
        {
            if (!(_shownStylist.idUser == nil))
            {
                if(!([_shownStylist.idUser isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSLog(@"Following user: %@", _shownStylist.idUser);
                            
                            // Perform request to follow user
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_FOLLOWING_USER_MSG_", nil)];
                            
                            // Post the setFollow object
                            
                            setFollow * newFollow = [[setFollow alloc] init];
                            
                            [newFollow setFollow:_shownStylist.idUser];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
                            
                            [self performRestPost:FOLLOW_USER withParamaters:requestParameters];
                        }
                    }
                }
            }
        }
    }
    else
    {
        [self configOptions];
        CGPoint anchor = CGPointMake(sender.center.x, sender.superview.frame.origin.y + sender.center.y + 10);
        if(!showingOptions){
            [self.moreOptions showUpToDown:YES];
        }
        [self showOptions:!showingOptions fromPoint:anchor];
    }
}


- (IBAction)onTapReport:(id)sender {
    [self reportUser];
}

- (void)showTurnNotifications
{
    self.turnNotificationsView.hidden = NO;
    [self.turnNotificationsView.superview bringSubviewToFront:self.turnNotificationsView];
}

- (void)reportUser
{
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!([self.mainMenuView isHidden]))
    {
        [self showMainMenu:nil];
        return;
    }
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    // Here we need to pass a full frame
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    
    UIView *errorTypesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 220)];
    
    for (int i = 0; i < maxUserReportTypes; i++)
    {
        NSString *userReportType = [NSString stringWithFormat:@"_USER_REPORT_TYPE_%i_", i];
        
        UILabel *reportTypeLabel = [UILabel createLabelWithOrigin:CGPointMake(10, (10 * (i+1)) + (30 * i))
                                                          andSize:CGSizeMake(errorTypesView.frame.size.width - 80, 30)
                                               andBackgroundColor:[UIColor clearColor]
                                                         andAlpha:1.0
                                                          andText:NSLocalizedString(userReportType, nil)
                                                     andTextColor:[UIColor blackColor]
                                                          andFont:[UIFont fontWithName:@"Avenir-Light" size:15]
                                                   andUppercasing:NO
                                                       andAligned:NSTextAlignmentLeft];
        
        UISwitch *switchErrorType = [[UISwitch alloc] initWithFrame:CGRectMake(reportTypeLabel.frame.origin.x + reportTypeLabel.frame.size.width + 10, reportTypeLabel.frame.origin.y, 80, 10)];
        [switchErrorType setTag:i];
        [switchErrorType setOn:NO animated:NO];
        
        [errorTypesView addSubview:reportTypeLabel];
        [errorTypesView addSubview:switchErrorType];
    }
    
    // Add some custom content to the alert view
    [alertView setContainerView:errorTypesView];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"_CANCEL_", nil), NSLocalizedString(@"_SEND_", nil), nil]];
    
    [alertView setDelegate:self];
    
    [alertView setUseMotionEffects:true];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        if(buttonIndex == 1)
        {
            // Check that the name is valid
            
            if (!(_shownStylist.idUser == nil))
            {
                if(!([_shownStylist.idUser isEqualToString:@""]))
                {
                    // Post the UserReport object
                    
                    UserReport * newUserReport = [[UserReport alloc] init];
                    
                    [newUserReport setReportedUserId:_shownStylist.idUser];
                    
                    int reportType = 0;
                    
                    for (UIView * view in alertView.containerView.subviews)
                    {
                        if ([view isKindOfClass:[UISwitch class]])
                        {
                            reportType += ((pow(2,(view.tag))) * ([((UISwitch*) view) isOn]));
                        }
                    }
                    
                    [newUserReport setReportType:[NSNumber numberWithInt:reportType]];
                    
                    
                    if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        [newUserReport setUserId:appDelegate.currentUser.idUser];
                    }
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newUserReport, nil];
                    
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGPOSTCONTENTREPORT_ACTV_MSG_", nil)];
                    
                    [self performRestPost:ADD_USERREPORT withParamaters:requestParameters];
                }
            }
        }
        
        [alertView close];
        
    }];
    
    // And launch the dialog
    [alertView show];
}

- (void)unfollowUser
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!(_shownStylist == nil))
    {
        if (!(_shownStylist.idUser == nil))
        {
            if(!([_shownStylist.idUser isEqualToString:@""]))
            {
                if (!(appDelegate.currentUser.idUser == nil))
                {
                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        NSLog(@"UNfollowing user: %@", _shownStylist.idUser);
                        
                        // Perform request to follow user
                        
                        // Provide feedback to user
                        [self stopActivityFeedback];
                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNFOLLOWING_USER_MSG_", nil)];
                        
                        // Post the unsetFollow object
                        
                        unsetFollow * newUnsetFollow = [[unsetFollow alloc] init];
                        
                        [newUnsetFollow setUnfollow:_shownStylist.idUser];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newUnsetFollow, nil];
                        
                        [self performRestPost:UNFOLLOW_USER withParamaters:requestParameters];
                    }
                }
            }
        }
    }
}

- (void)configOptions{
    NSMutableArray* optionsArray = [NSMutableArray new];
    NSMutableArray* handlersArray = [NSMutableArray new];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UserUserUnfollow* unfollow = [appDelegate.currentUser.unnoticedUsers objectForKey:_shownStylist.idUser];
    if(unfollow)
    {
        [optionsArray addObject:@"NOTIFICATIONS ON"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(turnOnNotifications:)]];
    }else{
        [optionsArray addObject:@"NOTIFICATIONS OFF"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(turnOffNotifications:)]];
    }
    //[optionsArray addObject:[NSLocalizedString(@"_REPORT_BTN_",nil) uppercaseString]];
    [optionsArray addObject:[NSLocalizedString(@"_STOPFOLLOW_BTN_",nil) uppercaseString]];
    
   // [handlersArray addObject:[NSValue valueWithPointer:@selector(reportUser)]];
    [handlersArray addObject:[NSValue valueWithPointer:@selector(unfollowUser)]];
    
    optionHandlers = [NSArray arrayWithArray:handlersArray];
    [self.moreOptions setOptions:optionsArray];
    [self.moreOptions layoutIfNeeded];
}

- (void)optionsView:(GSOptionsView *)optionView heightChanged:(CGFloat)newHeight{
    self.optionsViewHeightConstraint.constant = newHeight;
    [self.moreOptions layoutIfNeeded];
}

- (void)optionsView:(GSOptionsView *)optionView selectOptionAtIndex:(NSInteger)option{
    if ([optionHandlers count]>option) {
        SEL retriveSelector = [[optionHandlers objectAtIndex:option] pointerValue];
        [self performSelector:retriveSelector withObject:nil];
    }
    [self dismissOptionButtons:nil];
}

- (void)showOptions:(BOOL)showOrNot fromPoint:(CGPoint)anchor{
    showingOptions = showOrNot;
    
    if (showOrNot) {
        self.moreOptions.superview.alpha = 1;
        [self.moreOptions moveAngleToPosition:anchor.x];
        [self.moreOptions.superview layoutIfNeeded];
        
        [self.moreOptions.superview.superview bringSubviewToFront:self.moreOptions.superview];
    }else{
        [self.moreOptions.superview.superview sendSubviewToBack:self.moreOptions.superview];
        self.moreOptions.superview.alpha = 0;
    }
}

- (void)showCameraPic{
    if ([UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] != nil)
    {
        CustomCameraViewController *imagePicker = nil;
        
        @try {
            
            imagePicker = [[UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] instantiateViewControllerWithIdentifier:[@(CUSTOMCAMERA_VC) stringValue]];
            
        }
        @catch (NSException *exception) {
            
            return;
            
        }
        
        if (imagePicker != nil)
        {
            imagePicker.delegate = self;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==100) {
        // Instantiate the 'CustomCameraViewController' view controller
        if (buttonIndex == 0) // PHOTO
        {
            [self showCameraPic];
        }else if (buttonIndex == 1) //VIDEO
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"_SELECT_SOURCE_PHOTO_",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"_TAKE_VIDEO_", nil), NSLocalizedString(@"_CHOOSE_VIDEO_", nil), nil];
            actionSheet.tag = 101;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
    }else if (actionSheet.tag==101) {
        //VIDEO ACTIONSHEET
        // Prepare Image Picker
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        switch (buttonIndex)
        {
            case 0: //Take photo
                
                // Ensure that device has camera
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"Device has no camera", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
                    
                    [alertView show];
                    
                    return;
                }
                else
                {
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                }
                
                break;
                
            case 1: // Select from camera roll
                
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                break;
                
            default:
                
                return;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)onTapCreateNewElement:(UIButton *)sender
{
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
            
            return;
        }
    }
}

- (void)onTapView:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
        return;
    
    int iIdx = (int)sender.tag + (_bEditionMode?-1:0);
    
    if (!(iIdx>=[self.postsArray count]))
    {
        _selectedPostId = [self.postsArray objectAtIndex:iIdx];
    }
    
    // Perform request to get its properties from GS server
    if(!(_selectedPostId == nil))
    {
        if(!([_selectedPostId isEqualToString:@""]))
        {
            // Perform request to get the result contents
            _bEditPost = NO;
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedPostId, [NSNumber numberWithBool:magazineLoding], nil];
            
            //[self performRestGet:GET_POST withParamaters:requestParameters];
            [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
        }
    }
}

- (void)onTapDelete:(UIButton *)sender
{
    int iIdx = (int)sender.tag + (_bEditionMode?-1:0);

    
    if (!(iIdx>=[self.postsArray count]))
    {
        _idPostToDelete = [self.postsArray objectAtIndex:iIdx];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEPOST_", nil) message:NSLocalizedString(@"_REMOVEPOST_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
        
        [alertView show];
    }
}


- (IBAction)onTapEditProfile:(id)sender {
    if (!editMode) {
        editMode = YES;
        [self.editProfileButton setTitle:@"PUBLISH" forState:UIControlStateNormal];
        [_editProfileImageButton setBackgroundColor:[UIColor colorWithRed:208 green:208 blue:208 alpha:0.77]];
        self.editProfileCoverButton.hidden = NO;
        [_editProfileImageButton setTitle:@"EDIT PICTURE" forState:UIControlStateNormal];
        if ([_shownStylist.fashionistaBlogURL isEqualToString:@""]) {
            _addWebSiteLabel.hidden = NO;
            _pencilImage.hidden = NO;
        }
        else {
            _fashionistaURL.textColor = [UIColor blueColor];
            _fashionistaURLField.textColor = [UIColor blueColor];
        }
        [self setTitleColor:[UIColor blueColor]];
        NSString* subtitleString = (_shownStylist.fashionistaTitle?_shownStylist.fashionistaTitle:@"");

        if ([subtitleString isEqualToString:@""]) {
            subtitleString = NSLocalizedString(@"_DEFAULT_NO_USERTITLE_EDIT_", nil);
            [self setTopBarTitle:_shownStylist.fashionistaName andSubtitle:subtitleString];
        }
    }
    else {
        editMode = NO;
        [self.editProfileButton setTitle:@"EDIT PROFILE" forState:UIControlStateNormal];
        [_editProfileImageButton setTitle:@"" forState:UIControlStateNormal];
        [_editProfileImageButton setBackgroundColor:[UIColor clearColor]];
        self.editProfileCoverButton.hidden = YES;
        _fashionistaURL.textColor = [UIColor blackColor];
        _fashionistaURLField.textColor = [UIColor blackColor];
        [self setTitleColor:[UIColor darkGrayColor]];
        _addWebSiteLabel.hidden = YES;
        _pencilImage.hidden = YES;
        
        NSString* subtitleString = (_shownStylist.fashionistaTitle?_shownStylist.fashionistaTitle:@"");
        
        if ([subtitleString isEqualToString:@""]) {
            [self setTopBarTitle:_shownStylist.fashionistaName andSubtitle:subtitleString];
        }
    }
}

#pragma mark - Alert views management


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"_CANCELSTYLISTEDITING_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            [super swipeRightAction];
        }
    }
    else if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEPOST_", nil)])
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:NSLocalizedString(@"_CANCEL_", nil)])
        {
            if(!(_idPostToDelete == nil))
            {
                _idPostToDelete = nil;
            }
        }
        else if([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
        {
            if (_idPostToDelete != nil)
            {
                [self deletePost:_idPostToDelete];
            }
        }
    }
}


#pragma mark - Profile information updates management


- (void)actionAfterSignUp
{
    //[super actionAfterSignUp];
    self.shownStylist = [(AppDelegate*)[UIApplication sharedApplication].delegate currentUser];
    
    // Reload the Fashionista User Pages
    [self getUserPosts];
    [self getUsersWardrobes];
    
    // Setup textfields appearance
    [self setupTextFields];
    
    //    [self swipeRightAction];
}

- (void)actionAfterSignUpWithError
{
    [super actionAfterSignUpWithError];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_FASHIONISTA_", nil) message:NSLocalizedString(@"_ERROR_APPLY_FASHIONISTA_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
}


#pragma mark - Storyboard management


// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintPrevAction:nil];
        
        return;
    }
    
    if(!([_addToWardrobeVCContainerView isHidden]))
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }
    
    if(!(_bEditionMode))
    {
        [super swipeRightAction];
    }
    else
    {
        {
            [super swipeRightAction];
        }
    }
}

- (BOOL)shouldCreateTitleButton
{
    return _bEditionMode;
}

// Check if the current view controller must show the menu button
- (BOOL)shouldCreateSubtitleButton{
    return _bEditionMode;
}

- (void)titleButtonAction:(UIButton *)sender{
    if (!editMode) {
        return;
    }
    [self startEditingField:profileEditFieldModeName];
}

- (void)subtitleButtonAction:(UIButton *)sender{
    if (!editMode) {
        return;
    }
    [self startEditingField:profileEditFieldModeTitle];
}

- (void)saveUser{
    User * currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
    if(_bEditionMode)
    {
        if (!(currentUser == nil))
        {
            if(!(currentUser.idUser == nil))
            {
                if(!([currentUser.idUser isEqualToString:@""]))
                {
                    if (!(_shownStylist == nil))
                    {
                        if(!(_shownStylist.idUser == nil))
                        {
                            if(!([_shownStylist.idUser isEqualToString:@""]))
                            {
                                if([currentUser.idUser isEqualToString:_shownStylist.idUser])
                                {
                                    // Save and go to view post
                                    
                                    BOOL changesMade = NO;
                                    
                                    if(_bPhotoChanged)
                                        changesMade = YES;
                                    
                                    if(!([_shownStylist.fashionistaBlogURL isEqualToString:self.fashionistaURLField.text]))
                                    {
                                        _shownStylist.fashionistaBlogURL = self.fashionistaURLField.text;
                                        changesMade = YES;
                                    }
                                    
                                    if(editedTitle){
                                        _shownStylist.fashionistaName = editedTitle;
                                        changesMade = YES;
                                    }
                                    
                                    if(editedSubTitle){
                                        _shownStylist.fashionistaTitle = editedSubTitle;
                                        changesMade = YES;
                                    }
                                    if(_hasGoneToInfo){
                                        changesMade = YES;
                                    }
                                    if(changesMade)
                                    {
                                        _shownStylist.isFashionista = [NSNumber numberWithBool:YES];
                                        [_shownStylist setDelegate:self];
                                        [self stopActivityFeedback];
                                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATING_USER_ACTV_MSG_", nil)];
                                        [_shownStylist updateUserToServerDBVerbose:YES];
                                        
                                        NSString * key = [NSString stringWithFormat:@"HIGHLIGHTSAVEVIEW_%d", [self.restorationIdentifier intValue]];
                                        
                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                        
                                        // Save into defaults if doesn't already exists
                                        if (!([defaults objectForKey:key]))
                                        {
                                            [defaults setInteger:1 forKey:key];
                                            
                                            [defaults synchronize];
                                        }
                                        else
                                        {
                                            int iNumHighlights = (int)[defaults integerForKey:key];
                                            
                                            [defaults setInteger:(iNumHighlights+1) forKey:key];
                                            
                                            [defaults synchronize];
                                        }
                                    }
                                    
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
        // Do nothing, shouldn't be there
    }
    _bPhotoChanged = NO;
}

-(BOOL) checkUsernameField
{
    
    return YES;
}

- (void)userAccount:(User *)user updateFinishedWithError:(NSString *)errorString{
    if ([errorString isEqualToString:@"_ERROR_03_02_"]) {
        self.shownStylist.fashionistaName = originalUserName;
        editedTitle = nil;
        [self setTopBarTitle:_shownStylist.fashionistaName andSubtitle:nil];
    }
    [self stopActivityFeedback];
}

// User delegate: sign up
- (void)userAccount:(User *)user didSignUpSuccessfully:(BOOL)bSignUpSuccess
{
    [super userAccount:user didSignUpSuccessfully:bSignUpSuccess];
    
    user.picImage = nil;
    user.headerMediaPath = nil;
}

#pragma mark - Logout
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    
    [self stopActivityFeedback];
    
    if (_bEditionMode)
    {
        return;
    }
    else
    {
        [self closeAddingItemToWardrobeHighlightingButton:nil withSuccess:NO];
    }
}



#pragma mark - picture management

- (IBAction)btnChangePageTitle:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_EDITPAGETITLE_", nil) message:NSLocalizedString(@"_EDITPAGETITLE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_OK_", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
    [alertView textFieldAtIndex:0].placeholder = NSLocalizedString(@"_EDITPAGETITLE_MSG_", nil);
    [alertView textFieldAtIndex:0].text = _selectedPage.title;
    [alertView show];
}


- (IBAction)btnPicture:(UIButton *)sender {

    if(!_bEditionMode || !editMode)
    {
        NYTExamplePhotoUserProf *selectedPhoto = nil;
        
        NSMutableArray * photos = [[NSMutableArray alloc]init];
        
        NYTExamplePhotoUserProf *photo = [[NYTExamplePhotoUserProf alloc] init];

        NSURL *noImageFileURL = [[NSBundle mainBundle] URLForResource: @"portrait" withExtension:@"png"];
        
        UIImage * image = [UIImage cachedImageWithURL:_shownStylist.full_picture withNoImageFileURL:noImageFileURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"portrait.png"];
        }
        
        photo.image = image;
        
        selectedPhoto = photo;
        
        [photos addObject:photo];
        
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos initialPhoto:selectedPhoto];
        [self presentViewController:photosViewController animated:YES completion:nil];
        
        return;
    }
    
    uploadHeader = NO;
    // Instantiate the 'CustomCameraViewController' view controller
    
    if ([UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] != nil)
    {
        CustomCameraViewController *imagePicker = nil;
        
        @try {
            
            imagePicker = [[UIStoryboard storyboardWithName:@"BasicScreens" bundle:nil] instantiateViewControllerWithIdentifier:[@(CUSTOMCAMERA_VC) stringValue]];
            
        }
        @catch (NSException *exception) {
            
            return;
            
        }
        
        if (imagePicker != nil)
        {
            imagePicker.delegate = self;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.description delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}


// Select image for user profile picture
- (void)imagePickerController:(CustomCameraViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = [info objectForKey:@"data"];
    
    if (!(_shownStylist == nil))
    {
        if(uploadHeader){
            NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
            
            if (mediaType && CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
                NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
                NSString *moviePath = [videoUrl relativePath];
                _shownStylist.headerMediaPath = moviePath;
                if(((UIImagePickerController*)picker).sourceType == UIImagePickerControllerSourceTypeCamera){
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
                        UISaveVideoAtPathToSavedPhotosAlbum (moviePath, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                    }
                }
                
                self.profileHeaderImage.hidden = YES;
                self.headerVideoContainer.hidden = NO;
                [self setupVideoWithUrl:[videoUrl absoluteString]];
            }else{
                UIImage * finalProfilePic = [[chosenImage fixOrientation] scaleToSizeKeepAspect:CGSizeMake(600, 600)];
                
                _shownStylist.headerMediaPath = finalProfilePic;
                self.profileHeaderImage.image = finalProfilePic;
                self.profileHeaderImage.hidden = NO;
                self.headerVideoContainer.hidden = YES;
                self.headerVideobackgroundImageView.hidden = YES;
                [self.headerVideoContainer.superview sendSubviewToBack:self.headerVideoContainer];
                [self.headerVideobackgroundImageView.superview sendSubviewToBack:self.headerVideobackgroundImageView];
                [self.uploadImageLabel.superview sendSubviewToBack:self.uploadImageLabel];
                self.uploadImageLabel.hidden = YES;
            }
        }else{
            UIImage * finalProfilePic = [[chosenImage fixOrientation] scaleToSizeKeepAspect:CGSizeMake(600, 600)];
            
            _shownStylist.picImage = finalProfilePic;
            self.fashionistaImage.image = finalProfilePic;
        }
    }
    //    self.avatarImage.image = chosenImage;
    //  bPictureDirty = YES;
    _bPhotoChanged = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self saveUser];
}

// In case user cancels changing image
- (void) imagePickerControllerDidCancel:(CustomCameraViewController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Statistics


-(void)uploadFashionistaView
{
    // Check that the name is valid
    
    if (!(self.shownStylist.idUser == nil))
    {
        if(!([self.shownStylist.idUser isEqualToString:@""]))
        {
            // Post the ProductView object
            
            FashionistaView * newFashionistaView = [[FashionistaView alloc] init];
            
            [newFashionistaView setFashionistaId:self.shownStylist.idUser];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newFashionistaView setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newFashionistaView setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newFashionistaView setFingerprint:appDelegate.finger.fingerprint];
            
            if(!(newFashionistaView == nil))
            {
                if(!(newFashionistaView.fashionistaId == nil))
                {
                    if(!([newFashionistaView.fashionistaId isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newFashionistaView, nil];
                        
                        [self performRestPost:ADD_FASHIONISTAVIEW withParamaters:requestParameters];
                    }
                }
            }
        }
    }
}

-(void) postAnayliticsIntervalTimeBetween:(NSDate *) startTime and:(NSDate *) endTime
{
    if (!(self.shownStylist.idUser == nil))
    {
        if(!([self.shownStylist.idUser isEqualToString:@""]))
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            //            if(!([appDelegate.currentUser.idUser isEqualToString:self.shownStylist.idUser]))
            if(!([self.idUserViewing isEqualToString:self.shownStylist.idUser]))
            {
                // Post the ProductView object
                
                FashionistaViewTime * newPostViewTime = [[FashionistaViewTime alloc] init];
                
                [newPostViewTime setStartTime:startTime];
                
                [newPostViewTime setEndTime:endTime];
                
                [newPostViewTime setFashionistaId:self.shownStylist.idUser];
                
                
                if (!(self.idUserViewing == nil))
                {
                    if (!([self.idUserViewing isEqualToString:@""]))
                    {
                        [newPostViewTime setUserId:self.idUserViewing];
                    }
                }
                
                if(!(_searchQuery == nil))
                {
                    if(!(_searchQuery.idSearchQuery == nil))
                    {
                        if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                        {
                            [newPostViewTime setStatProductQueryId:_searchQuery.idSearchQuery];
                        }
                    }
                }
                
                [newPostViewTime setFingerprint:appDelegate.finger.fingerprint];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostViewTime, nil];
                
                [self performRestPost:ADD_FASHIONISTAVIEWTIME withParamaters:requestParameters];
            }
        }
    }
}


-(NSString *) formatNumber:(NSNumber *) num
{
    int intNumber = [num intValue];
    NSString * sRes = [NSString stringWithFormat:@"%d", intNumber ];
    
    if (intNumber > 1000000)
    {
        float floatNumber = intNumber/ 1000000;
        sRes = [NSString stringWithFormat:@"%.1fM", floatNumber ];
    }
    else if (intNumber > 1000)
    {
        float floatNumber = intNumber/ 1000;
        sRes = [NSString stringWithFormat:@"%.1fk", floatNumber ];
    }
    
    return sRes;
}

- (IBAction)showStylistPosts:(UIButton *)sender
{
    [self hideTextFieldsUpperView];
    if(self.infoButton.selected){
        [self infoButtonPushed:self.infoButton];
    }else if(self.videoMenuButton.selected){
        [self videosMenuPushed:self.videoMenuButton];
    }
    if(showingWardrobe){
        [self wardrobeButtonPushed:self.wardrobeButton];
    }
}

- (IBAction)showStylistFollowers:(UIButton *)sender
{
    if(!(_iNumberOfFollowers > 0))
    {
        return;
    }
    
    NSLog(@"Searching followers for Stylist: %@", _shownStylist.fashionistaName);
    
    // Perform request to get the search results
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    NSString * currentUserId = @"";
    
    if(_shownStylist.idUser)
    {
        if(!([_shownStylist.idUser isEqualToString:@""]))
        {
            currentUserId = _shownStylist.idUser;
        }
    }
    
    willShowFollowers = YES;
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"", @"followers", currentUserId, nil];
    
    searchingPosts = NO;
    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS withParamaters:requestParameters];
}

- (IBAction)showStylistFollowing:(UIButton *)sender
{
    if(!(_iNumberOfFollowing > 0))
    {
        return;
    }
    
    NSLog(@"Searching followers for Stylist: %@", _shownStylist.fashionistaName);
    
    // Perform request to get the search results
    
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    
    NSString * currentUserId = @"";
    
    if(_shownStylist.idUser)
    {
        if(!([_shownStylist.idUser isEqualToString:@""]))
        {
            currentUserId = _shownStylist.idUser;
        }
    }
    
    willShowFollowers = NO;
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"", @"followed", currentUserId, nil];
    
    searchingPosts = NO;
    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS withParamaters:requestParameters];
}


#pragma mark - Report users offense

// Check if the current view controller must show the 'Report' button
- (BOOL)shouldCreateReportButton
{
    return NO;
}

// Report user
- (void)reportAction:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if(!([self.mainMenuView isHidden]))
    {
        [self showMainMenu:nil];
        return;
    }
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    // Here we need to pass a full frame
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    
    UIView *errorTypesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 220)];
    
    for (int i = 0; i < maxUserReportTypes; i++)
    {
        //"_USER_REPORT_TYPE_0_" = "Offensiveness or disrespect with my opinion";
        //"_USER_REPORT_TYPE_1_" = "Harassment";
        //"_USER_REPORT_TYPE_2_" = "Specific violent threats";
        //"_USER_REPORT_TYPE_3_" = "Publication of private images or information ";
        //"_USER_REPORT_TYPE_4_" = "Spamming";
        
        
        NSString *userReportType = [NSString stringWithFormat:@"_USER_REPORT_TYPE_%i_", i];
        
        UILabel *reportTypeLabel = [UILabel createLabelWithOrigin:CGPointMake(10, (10 * (i+1)) + (30 * i))
                                                          andSize:CGSizeMake(errorTypesView.frame.size.width - 80, 30)
                                               andBackgroundColor:[UIColor clearColor]
                                                         andAlpha:1.0
                                                          andText:NSLocalizedString(userReportType, nil)
                                                     andTextColor:[UIColor blackColor]
                                                          andFont:[UIFont fontWithName:@"Avenir-Light" size:15]
                                                   andUppercasing:NO
                                                       andAligned:NSTextAlignmentLeft];
        
        UISwitch *switchErrorType = [[UISwitch alloc] initWithFrame:CGRectMake(reportTypeLabel.frame.origin.x + reportTypeLabel.frame.size.width + 10, reportTypeLabel.frame.origin.y, 80, 10)];
        [switchErrorType setTag:i];
        [switchErrorType setOn:NO animated:NO];
        
        [errorTypesView addSubview:reportTypeLabel];
        [errorTypesView addSubview:switchErrorType];
    }
    
    // Add some custom content to the alert view
    [alertView setContainerView:errorTypesView];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"_CANCEL_", nil), NSLocalizedString(@"_SEND_", nil), nil]];
    
    [alertView setDelegate:self];
    
    [alertView setUseMotionEffects:true];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        if(buttonIndex == 1)
        {
            // Check that the name is valid
            
            if (!(_shownStylist.idUser == nil))
            {
                if(!([_shownStylist.idUser isEqualToString:@""]))
                {
                    // Post the UserReport object
                    
                    UserReport * newUserReport = [[UserReport alloc] init];
                    
                    [newUserReport setReportedUserId:_shownStylist.idUser];
                    
                    int reportType = 0;
                    
                    for (UIView * view in alertView.containerView.subviews)
                    {
                        if ([view isKindOfClass:[UISwitch class]])
                        {
                            reportType += ((pow(2,(view.tag))) * ([((UISwitch*) view) isOn]));
                        }
                    }
                    
                    [newUserReport setReportType:[NSNumber numberWithInt:reportType]];
                    
                    
                    if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        [newUserReport setUserId:appDelegate.currentUser.idUser];
                    }
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newUserReport, nil];
                    
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGPOSTCONTENTREPORT_ACTV_MSG_", nil)];
                    
                    [self performRestPost:ADD_USERREPORT withParamaters:requestParameters];
                }
            }
        }
        
        [alertView close];
        
    }];
    
    // And launch the dialog
    [alertView show];
    
}

- (void)customAlertViewButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
}

#pragma mark - Button Bar functions

- (void)updateCurrentVisibleView{
    if (showingWardrobe) {
        self.wardrobesContainerView.hidden = NO;
        [self.wardrobesContainerView.superview bringSubviewToFront:self.wardrobesContainerView];
        self.postsContainerView.hidden = YES;
        [wardrobesDoubleDisplayController refreshVisibleView];
    }else{
        self.postsContainerView.hidden = NO;
        [self.postsContainerView.superview bringSubviewToFront:self.postsContainerView];
        self.wardrobesContainerView.hidden = YES;
        [postsDoubleDisplayController refreshVisibleView];
    }
}

- (void)startEditingField:(profileEditFieldMode)fieldMode{
    currentEditFieldMode = fieldMode;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BasicScreens" bundle:[NSBundle mainBundle]];
    GSTextEditViewController* editController = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",TEXTEDIT_VC]];
    editController.textDelegate = self;
    [self showViewControllerModal:editController withTopBar:NO];
    switch (fieldMode) {
        case profileEditFieldModeName:
            editController.controllerTitle.text = @"Edit User Name";
            editController.textEdit.text = (editedTitle?editedTitle:_shownStylist.fashionistaName);
            break;
        case profileEditFieldModeTitle:
            editController.controllerTitle.text = @"Edit User Title";
            editController.textEdit.text = (editedSubTitle?editedSubTitle:_shownStylist.fashionistaTitle);
            break;
        case profileEditFieldModeWebpage:
            editController.controllerTitle.text = @"Edit User Webpage";
            editController.textEdit.text = self.fashionistaURLField.text;
            break;
    }
}

- (void)commitEditionWithString:(NSString *)textString{
    switch (currentEditFieldMode) {
        case profileEditFieldModeName:
            editedTitle = textString;
            [self setTopBarTitle:textString andSubtitle:nil];
            break;
        case profileEditFieldModeTitle:
            editedSubTitle = textString;
            if ([editedSubTitle isEqualToString:@""]) {
                NSString *subTitle = NSLocalizedString(@"_DEFAULT_NO_USERTITLE_EDIT_", nil);
                [self setTopBarTitle:nil andSubtitle:subTitle];
                break;
            }
            [self setTopBarTitle:nil andSubtitle:textString];
            break;
        case profileEditFieldModeWebpage:
            self.fashionistaURL.text = textString;
            self.fashionistaURLField.text = textString;
            if (editMode && [textString isEqualToString:@""]) {
                _addWebSiteLabel.hidden = NO;
                _pencilImage.hidden = NO;
            }
            else {
                _addWebSiteLabel.hidden = YES;
                _pencilImage.hidden = YES;
            }
            break;
    }
    [self dismissControllerModal];
    [self saveUser];
}

- (IBAction)editWebpagePushed:(id)sender {
    if (!editMode) {
        return;
    }
    [self startEditingField:profileEditFieldModeWebpage];
}

- (IBAction)continousButtonPushed:(UIButton*)sender {
    [self.view endEditing:YES];
    if(self.infoButton.selected){
        [self infoButtonPushed:self.infoButton];
    }else if(self.videoMenuButton.selected){
        [self videosMenuPushed:self.videoMenuButton];
    }else{
        sender.selected = !sender.selected;
        [postsDoubleDisplayController switchView];
        [wardrobesDoubleDisplayController switchView];
    }
    self.wardrobeButton.backgroundColor = GOLDENSPEAR_COLOR;
}

- (IBAction)infoButtonPushed:(UIButton*)sender {
    [self.view endEditing:YES];
    if (_bEditionMode) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:[NSBundle mainBundle]];
        UIViewController* vc = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",EDITINFO_VC]];
        [self showViewControllerModal:vc];
        _hasGoneToInfo = YES;
    }else{
        sender.selected = !sender.selected;
        if (sender.selected) {
            sender.backgroundColor = GOLDENSPEAR_COLOR;
            self.wardrobeButton.backgroundColor = [UIColor clearColor];
            [self.infoViewContainer.superview bringSubviewToFront:self.infoViewContainer];
            
        }else{
            sender.backgroundColor = [UIColor clearColor];
            self.wardrobeButton.backgroundColor = GOLDENSPEAR_COLOR;
            [self.infoViewContainer.superview sendSubviewToBack:self.infoViewContainer];
        }
        
    }
}

- (IBAction)wardrobeButtonPushed:(UIButton *)sender {
    [self.view endEditing:YES];
    if(self.infoButton.selected){
        [self infoButtonPushed:self.infoButton];
    }else if(self.videoMenuButton.selected){
        [self videosMenuPushed:self.videoMenuButton];
    }else{
        sender.selected = !sender.selected;
//        if (sender.selected) {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"User Wardrobes"
//                                                            message:NSLocalizedString(@"_NOTYETIMPLMENETED_MSG_", nil)
//                                                           delegate:nil
//                                                  cancelButtonTitle:NSLocalizedString(@"_OK_BTN_", nil)
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }
        showingWardrobe = sender.selected;
        [self updateCurrentVisibleView];
    }
    self.wardrobeButton.backgroundColor = GOLDENSPEAR_COLOR;
}

- (IBAction)mailButtonPushed:(UIButton *)sender {
    [self.view endEditing:YES];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"User Messages"
                                                    message:NSLocalizedString(@"_NOTYETIMPLMENETED_MSG_", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"_OK_BTN_", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)calendarButtonPushed:(UIButton *)sender {
    [self.view endEditing:YES];
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = GOLDENSPEAR_COLOR;
    }else{
        sender.backgroundColor = [UIColor clearColor];
    }
    [self moveMonthFilter:sender.selected];
}

- (IBAction)turnOnNotifications:(id)sender {
    [self turnUserNotifications:YES];
}

- (IBAction)turnOffNotifications:(id)sender {
    [self turnUserNotifications:NO];
}

- (IBAction)updateHeaderFile:(id)sender {
    if(!_bEditionMode)
    {
        return;
    }
    if (!editMode) {
        return;
    }
    uploadHeader = YES;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"_SELECT_SOURCE_PHOTO_",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"_CHOOSE_PHOTO_", nil), NSLocalizedString(@"_CHOOSE_VIDEO_", nil), nil];
    actionSheet.tag = 100;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (IBAction)videoPlay:(id)sender {
    if (player) {
        if (playing) {
            [player.player pause];
        }else{
            [player.player play];
        }
    }
}

- (IBAction)videosMenuPushed:(UIButton*)sender {
    [self.view endEditing:YES];
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = GOLDENSPEAR_COLOR;
        [self.videoListContainer.superview bringSubviewToFront:self.videoListContainer];
        self.wardrobeButton.backgroundColor = [UIColor clearColor];
    }else{
        sender.backgroundColor = [UIColor clearColor];
        [self.videoListContainer.superview sendSubviewToBack:self.videoListContainer];
        self.wardrobeButton.backgroundColor = GOLDENSPEAR_COLOR;
    }
}

- (IBAction)closeDateFilter:(id)sender {
    [self moveMonthFilter:NO];
}

- (IBAction)dismissOptionButtons:(id)sender {
    if(showingOptions){
        [self showOptions:NO fromPoint:CGPointZero];
    }
}

- (void)turnUserNotifications:(BOOL)onOrNot{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UserUserUnfollow* unfollow = [appDelegate.currentUser.unnoticedUsers objectForKey:_shownStylist.idUser];
    if(unfollow&&onOrNot){
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestDelete:USER_ACCEPT_NOTICES withParamaters:requestParameters];
    }else if(!onOrNot){
        unfollow = [UserUserUnfollow new];
        unfollow.userId = appDelegate.currentUser.idUser;
        unfollow.usertoignoreId = _shownStylist.idUser;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestPost:USER_IGNORE_NOTICES withParamaters:requestParameters];
    }
    
    self.turnNotificationsView.hidden = YES;
    [self.turnNotificationsView.superview sendSubviewToBack:self.turnNotificationsView];
}

- (NSInteger)getNumberOfCompleteDownloadedPosts{
    NSInteger i = 0;
    NSDictionary* checkDict = downloadedPosts;
    if(yearFiltered!=0){
        checkDict = filteringPosts;
    }
    for (id object in [checkDict allValues]) {
        if ([object isKindOfClass:[NSArray class]]) {
            i++;
        }
    }
    return i;
}

//Gets the total number of Posts fetched
- (NSInteger)getNumberOfPostsDownloaded{
    return [self.postsArray count];
}

//Gets the total number of Posts fetched
- (NSInteger)getNumberOfWardrobesDownloaded{
    return [self.wardrobesArray count];
}

- (void)videosController:(GSUserVideosViewController *)controller notifyPanGesture:(UIPanGestureRecognizer *)sender{
    [self panGesture:sender];
}

#pragma mark GSDoubleDisplayDelegate

- (NSInteger)numberOfSectionsInDataForDoubleDisplay:(GSDoubleDisplayViewController *)displayController forMode:(GSDoubleDisplayMode)displayMode{
    if (displayController==postsDoubleDisplayController) {
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
                return 1;
                break;
                
            case GSDoubleDisplayModeList:
                return [self getNumberOfPostsDownloaded];
                //return [self getNumberOfCompleteDownloadedPosts];
                break;
        }
    }else{
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
                return 1;
                break;
                
            case GSDoubleDisplayModeList:
                return [self getNumberOfWardrobesDownloaded];
                //return [self getNumberOfCompleteDownloadedPosts];
                break;
        }
    }
}

- (NSInteger)doubleDisplay:(GSDoubleDisplayViewController *)displayController numberOfRowsInSection:(NSInteger)section forMode:(GSDoubleDisplayMode)displayMode{
    if (displayController==postsDoubleDisplayController) {
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
                return [self getNumberOfPostsDownloaded];
                break;
                
            case GSDoubleDisplayModeList:
                return 1;
                break;
        }
        
    }else{
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
                return [self getNumberOfWardrobesDownloaded];
                break;
                
            case GSDoubleDisplayModeList:
                return 1;
                break;
        }
    }
}

- (id)doubleDisplay:(GSDoubleDisplayViewController *)displayController objectForRowAtIndexPath:(NSIndexPath *)indexPath forMode:(GSDoubleDisplayMode)displayMode{
    if (displayController==postsDoubleDisplayController) {
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
                
                if (indexPath.item>=[self.postsArray count]) {
                    return nil;
                }
                
                return [self.postsArray objectAtIndex:indexPath.item];
                break;
                
            case GSDoubleDisplayModeList:

                if (indexPath.section>=[self.postsArray count]) {
                    return nil;
                }

                return [self.postsArray objectAtIndex:indexPath.section];
                break;
        }
    }else{
        //Wardrobe
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
                
                if (indexPath.item>=[self.wardrobesArray count]) {
                    return nil;
                }
                
                return [self.wardrobesArray objectAtIndex:indexPath.item];
                break;
                
            case GSDoubleDisplayModeList:
                
                if (indexPath.section>=[self.wardrobesArray count]) {
                    return nil;
                }
                
                return [self.wardrobesArray objectAtIndex:indexPath.section];
                break;
        }
    }
}

- (id)doubleDisplay:(GSDoubleDisplayViewController *)displayController dataForRowAtIndexPath:(NSIndexPath *)indexPath forMode:(GSDoubleDisplayMode)displayMode{
    if (displayController==postsDoubleDisplayController) {
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
                return [self getSimplePostDataAtIndexPath:indexPath];
                break;
            case GSDoubleDisplayModeList:
                return [self getExtendedPostDataAtIndexPath:indexPath];
                break;
        }
    }else{
        //Wardrobe
        switch (displayMode) {
            case GSDoubleDisplayModeCollection:
            {
                return [self getSimpleWardrobeDataAtIndexPath:indexPath];
                break;
            }
            case GSDoubleDisplayModeList:
            {
                return [self getExtendedWardrobeDataAtIndexPath:indexPath];
                break;
            }
            default:
                break;
        }
    }
}

- (void)doubleDisplay:(GSDoubleDisplayViewController *)displayController selectItemAtIndexPath:(NSIndexPath *)indexPath isMagazine:(BOOL)isMagazine{
    if (displayController==postsDoubleDisplayController) {
        if(![[self activityIndicator] isHidden])
            return;
        magazineLoding = isMagazine;
        [self openPostAtIndexPath:indexPath];
    }else{
        //Wardrobe
        if(![[self activityIndicator] isHidden])
            return;
        magazineLoding = isMagazine;
        [self openWardrobeAtIndexPath:indexPath];
    }
}

- (void)openPostAtIndexPath:(NSIndexPath *)indexPath{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    [self resetPostsQueue];

    if (!(indexPath.item>=[self.postsArray count])) {

        _selectedPostId = [self.postsArray objectAtIndex:indexPath.item];
        _selectedElement = [postElements objectForKey:_selectedPostId];
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedPostId, [NSNumber numberWithBool:magazineLoding], nil];
        [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
        loadingPostInPage = _selectedPostId;
    }
}

-(void)openWardrobeAtIndexPath:(NSIndexPath*)indexPath {
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    [self resetPostsQueue];
    
    if (!(indexPath.item>=[self.wardrobesArray count])) {
        
        _selectedPostId = [self.wardrobesArray objectAtIndex:indexPath.item];
        _selectedElement = [gsElements objectForKey:_selectedPostId];
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_selectedPostId, [NSNumber numberWithBool:magazineLoding], nil];
        [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
        loadingPostInPage = _selectedPostId;
    }
}
- (void)doubleDisplay:(GSDoubleDisplayViewController *)displayController notifyPanGesture:(UIPanGestureRecognizer *)sender{
    [self panGesture:sender];
}

- (void)doubleDisplay:(GSDoubleDisplayViewController *)displayController objectDeleted:(id)object{
    [downloadedPosts removeObjectForKey:object];
    [postElements removeObjectForKey:object];
    if(yearFiltered!=0){
        [filteringPosts removeObjectForKey:object];
    }
    [self getUserPosts];
    _idPostToDelete = nil;
    
    // Update Fetched Results Controller
    [self performFetchForCollectionViewWithCellType:GSPOST_CELL];
    
    // Update collection view
    [self updateCollectionViewWithCellType:GSPOST_CELL fromItem:0 toItem:-1 deleting:FALSE];
    [postsDoubleDisplayController refreshData];
    self.postNumber.text = [self formatNumber:[NSNumber numberWithLong:[_postsArray count]]];
}

- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController commentDeleted:(NSInteger)comment fromPost:(NSString*)idPost{
    NSMutableArray* postData = [NSMutableArray arrayWithArray:[downloadedPosts objectForKey:idPost]];
    if ([postData count]>3) {
        NSMutableArray* comments = [NSMutableArray arrayWithArray:[postData objectAtIndex:3]];
        [comments removeObjectAtIndex:comment];
        [postData replaceObjectAtIndex:3 withObject:comments];
        [downloadedPosts setObject:postData forKey:idPost];
    }
}

- (void)doubleDisplay:(GSDoubleDisplayViewController*)displayController commentAdded:(Comment*)comment toPost:(NSString*)idPost updated:(NSInteger)updatedIndex{
    if (updatedIndex>=0) {
        [self updateComment:comment inPost:idPost atIndex:updatedIndex];
    }else{
        [self addTheComment:comment inPost:idPost];
    }
}

- (void)addTheComment:(Comment*)comment inPost:(NSString*)idPost{
    NSMutableArray* postData = [NSMutableArray arrayWithArray:[downloadedPosts objectForKey:idPost]];
    NSMutableArray* comments = [NSMutableArray arrayWithArray:[postData objectAtIndex:3]];
    [comments addObject:comment];
    [postData replaceObjectAtIndex:3 withObject:comments];
    [downloadedPosts setObject:postData forKey:idPost];
}

- (void)updateComment:(Comment*)comment inPost:(NSString*)idPost atIndex:(NSInteger)index{
    NSMutableArray* postData = [NSMutableArray arrayWithArray:[downloadedPosts objectForKey:idPost]];
    NSMutableArray* comments = [NSMutableArray arrayWithArray:[postData objectAtIndex:3]];
    
    [comments replaceObjectAtIndex:index withObject:comment];
    [postData replaceObjectAtIndex:3 withObject:comments];
    [downloadedPosts setObject:postData forKey:idPost];
}

- (void)doubleDisplay:(GSDoubleDisplayViewController *)vC viewProfilePushed:(User *)theUser{
    if(![_shownStylist.idUser isEqualToString:theUser.idUser]){
        [self startActivityFeedbackWithMessage:@""];
        NSArray* parametersForNextVC = [NSArray arrayWithObjects: theUser, [NSNumber numberWithBool:NO], nil, nil];
        [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
        
    }
    [self dismissControllerModal];
}

- (void)askForMoreDataInDoubleDisplay:(GSDoubleDisplayViewController *)vC{
    
}

- (GSBaseElement*)getElement:(id)content {
    NSString *fashionistaPostId = [content objectAtIndex:1];
    GSBaseElement *element = [gsElements objectForKey:fashionistaPostId];
    if (element == nil) {
        element = [postElements objectForKey:fashionistaPostId];
    }
    return element;
}

-(void)addToWardrobe:(id)content button:(UIButton *)sender {
    NSLog(@"Add Wardrobe");
    NSString *fashionistaPostId;
    if ([content count] > 3) {
        fashionistaPostId = [content objectAtIndex:1];
    }
    else {
        fashionistaPostId = [[content firstObject] objectAtIndex:1];
    }
    GSBaseElement *element = [gsElements objectForKey:fashionistaPostId];
    
    if(![[self activityIndicator] isHidden])
        return;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //Calculate the actual section in FetchedResultsController
    
    if(!(element == nil))
    {
        if (!([self doesCurrentUserWardrobesContainItemWithId:element]))
        {
            // Instantiate the 'AddItemToWardrobe' view controller within the container view
            
            if ([UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] != nil)
            {
                AddItemToWardrobeViewController *addItemToWardrobeVC = nil;
                
                @try {
                    
                    addItemToWardrobeVC = [[UIStoryboard storyboardWithName:@"Wardrobe" bundle:nil] instantiateViewControllerWithIdentifier:[@(ADDITEMTOWARDROBE_VC) stringValue]];
                    
                }
                @catch (NSException *exception) {
                    
                    return;
                    
                }
                
                if (addItemToWardrobeVC != nil)
                {
                    [addItemToWardrobeVC setItemToAdd:element];
                    
                    NSLog(@"IdBaseElement : %@", element.idGSBaseElement);
                    
                    [addItemToWardrobeVC setButtonToHighlight:sender];
                    
                    [self addChildViewController:addItemToWardrobeVC];
                    
                    //[addItemToWardrobeVC willMoveToParentViewController:self];
                    
                    addItemToWardrobeVC.view.frame = CGRectMake(0,0,_addToWardrobeVCContainerView.frame.size.width, _addToWardrobeVCContainerView.frame.size.height);
                    
                    [_addToWardrobeVCContainerView addSubview:addItemToWardrobeVC.view];
                    
                    [addItemToWardrobeVC didMoveToParentViewController:self];
                    
                    [_addToWardrobeVCContainerView setHidden:NO];
                    
                    [_addToWardrobeBackgroundView setHidden:NO];
                    
                    [self.view bringSubviewToFront:_addToWardrobeBackgroundView];
                    
                    [self.view bringSubviewToFront:_addToWardrobeVCContainerView];
                }
            }
        }
    }
}

#pragma mark - Post Getting functions

- (void)getPostFromGSServer:(FashionistaPost*)thePost{
    if(!([thePost.idFashionistaPost isEqualToString:@""]))
    {
        // Perform request to get the result contents
        NSLog(@"Getting contents for Fashionista post: %@", thePost.name);
        
        _bEditPost = NO;
        
        // Provide feedback to user
        if(loadingPostInPage){
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
        }
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:thePost.idFashionistaPost, [NSNumber numberWithBool:magazineLoding], nil];
        
        //[self performRestGet:GET_POST withParamaters:requestParameters];
        [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
    }
}

- (NSArray *)getSimplePostDataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item>=[self.postsArray count]) {
        return nil;
    }
    NSString * tmpPost = [self.postsArray objectAtIndex:indexPath.item];
    
    BOOL bShowHanger = YES;
    
    User * currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
    
    if (!(currentUser == nil))
    {
        if(!(currentUser.idUser == nil))
        {
            if(!([currentUser.idUser isEqualToString:@""]))
            {
                if (!(_shownStylist == nil))
                {
                    if(!(_shownStylist.idUser == nil))
                    {
                        if(!([_shownStylist.idUser isEqualToString:@""]))
                        {
                            if([currentUser.idUser isEqualToString:_shownStylist.idUser])
                            {
                                bShowHanger = NO;
                            }
                        }
                    }
                }
            }
        }
    }
    
    NSArray* postInfo = [downloadedPosts objectForKey:tmpPost];
    
    NSArray * cellContent = [NSArray arrayWithObjects: postInfo, [NSNumber numberWithBool:bShowHanger], [NSNumber numberWithBool:/*[self doesCurrentUserWardrobesContainItemWithId:tmpPost]*/NO], nil];
    
    return cellContent;
}

- (NSArray *)getSimpleWardrobeDataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item>=[self.wardrobesArray count]) {
        return nil;
    }
    NSString * tmpPost = [self.wardrobesArray objectAtIndex:indexPath.item];
    
    BOOL bShowHanger = YES;
    
    User * currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
    
    if (!(currentUser == nil))
    {
        if(!(currentUser.idUser == nil))
        {
            if(!([currentUser.idUser isEqualToString:@""]))
            {
                if (!(_shownStylist == nil))
                {
                    if(!(_shownStylist.idUser == nil))
                    {
                        if(!([_shownStylist.idUser isEqualToString:@""]))
                        {
                            if([currentUser.idUser isEqualToString:_shownStylist.idUser])
                            {
                                bShowHanger = NO;
                            }
                        }
                    }
                }
            }
        }
    }
    
    NSArray* wardrobeInfo = [downloadedWardrobes objectForKey:tmpPost];
    
    NSArray * cellContent = [NSArray arrayWithObjects: wardrobeInfo, [NSNumber numberWithBool:bShowHanger], [NSNumber numberWithBool:[self doesCurrentUserWardrobesContainItemWithId:[gsElements objectForKey:tmpPost]]], nil];
    
    return cellContent;
}

- (NSArray *)getExtendedPostDataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>=[self.postsArray count]) {
        return nil;
    }
    
    //FashionistaPost * tmpPost = [self.selectedPagePosts objectAtIndex:indexPath.row];
    NSString * tmpPost = [self.postsArray objectAtIndex:indexPath.section];
    
    //Check dictionary if post has been downloaded
    id maybePost = [downloadedPosts objectForKey:tmpPost];
    
    if([maybePost isKindOfClass:[NSArray class]]){
        if(yearFiltered!=0){
            [filteringPosts setObject:maybePost forKey:tmpPost];
        }
        return maybePost;
    }else
    if(![maybePost isKindOfClass:[NSNumber class]])
    {
        //Download the data
        if(!(tmpPost == nil))
        {
            [downloadedPosts setObject:[NSNumber numberWithInteger:indexPath.section] forKey:tmpPost];
            
            //[downloadQueue addObject:tmpPost];
            //[self processQueue];
        }
    }
    
    return nil;
}

- (NSArray *)getExtendedWardrobeDataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>=[self.wardrobesArray count]) {
        return nil;
    }
    
    //FashionistaPost * tmpPost = [self.selectedPagePosts objectAtIndex:indexPath.row];
    NSString * tmpPost = [self.wardrobesArray objectAtIndex:indexPath.section];
    
    //Check dictionary if post has been downloaded
    id maybePost = [downloadedWardrobes objectForKey:tmpPost];
    
    if([maybePost isKindOfClass:[NSArray class]]){
        if(yearFiltered!=0){
            [filteringPosts setObject:maybePost forKey:tmpPost];
        }
        return maybePost;
    }else
        if(![maybePost isKindOfClass:[NSNumber class]])
        {
            //Download the data
            if(!(tmpPost == nil))
            {
                [downloadedWardrobes setObject:[NSNumber numberWithInteger:indexPath.section] forKey:tmpPost];
                [gsElements setObject:[NSNumber numberWithInteger:indexPath.section] forKey:tmpPost];
                //[downloadQueue addObject:tmpPost];
                //[self processQueue];
            }
        }
    
    return nil;
}

/*
- (void)processQueue{
    if(!downloadingInQueue){
        if([downloadQueue count]>0){
            downloadingInQueue = YES;
            FashionistaPost* thePost = [downloadQueue firstObject];
            [self getPostFromGSServer:thePost];
        }else{
            finishedDownloading = YES;
        }
    }
}

- (BOOL)nextInQueue{
    if(downloadingInQueue){
        downloadingInQueue = NO;
        if ([downloadQueue count]>0) {
            [downloadQueue removeObjectAtIndex:0];
        }
    }
    [self processQueue];
    
    return ([downloadQueue count]>0);
}

- (void)preloadAllPosts{
    if ([self.postsArray count]>0) {
        finishedDownloading = NO;
    }
    for (int i = 0; i<[self.selectedPagePosts count]; i++) {
        [self getExtendedPostDataAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
    }
    [postsDoubleDisplayController refreshData];
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showInfoLoadSegue"]&&!_bEditionMode){
        GSShowInfoViewController* vc = (GSShowInfoViewController*)segue.destinationViewController;
        vc.shownStylist = _shownStylist;
    }
    if([segue.identifier isEqualToString:@"videoListLoadSegue"]){
        userVideosController = (GSUserVideosViewController*)segue.destinationViewController;
        userVideosController.shownStylist = self.shownStylist;
        userVideosController.delegate = self;
    }
}

- (void)resetPostsQueue{
    FashionistaPost* postToSave = nil;
    /*
    if(downloadingInQueue){
        cancelOperation = YES;
        postToSave = [downloadQueue firstObject];
    }
    [downloadQueue removeAllObjects];
     
    if(postToSave){
        [downloadQueue addObject:postToSave];
    }
    */
    NSMutableDictionary* savedPosts = [NSMutableDictionary new];
    //Delete all posts non-downloaded from list
    for (NSString* key in [downloadedPosts allKeys]) {
        id entry = [downloadedPosts objectForKey:key];
        if([entry isKindOfClass:[NSArray class]]){
            [savedPosts setObject:entry forKey:key];
        }
    }
    downloadedPosts = savedPosts;
}

- (void)resetPostsForFiltering{
    /*
    if(downloadingInQueue){
        cancelOperation = YES;
    }
    [downloadQueue removeAllObjects];
    [self nextInQueue];
    */
    [self.postsArray removeAllObjects];
    [filteringPosts removeAllObjects];
    NSMutableDictionary* savedPosts = [NSMutableDictionary new];
    //Delete all posts non-downloaded from list
    for (NSString* key in [downloadedPosts allKeys]) {
        id entry = [downloadedPosts objectForKey:key];
        if([entry isKindOfClass:[NSArray class]]){
            [savedPosts setObject:entry forKey:key];
        }
    }
    downloadedPosts = savedPosts;
    [self getUserPosts];
}

#pragma mark - DateFilter

- (void)moveMonthFilter:(BOOL)showOrNot{
    if (showOrNot) {
        self.monthFilterCenterConstraint.constant = 0;
        [self.monthFilterView.superview bringSubviewToFront:self.monthFilterView];
    }else{
        self.monthFilterBackground.hidden = YES;
        self.monthFilterCenterConstraint.constant = self.monthFilterTable.frame.size.width;
        self.calendarButton.selected = NO;
        self.calendarButton.backgroundColor = [UIColor clearColor];
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (showOrNot) {
                             self.monthFilterBackground.hidden = NO;
                         }else{
                             [self.monthFilterView.superview sendSubviewToBack:self.monthFilterView];
                         }
                     }];
}

- (NSString*)getMonthLabelForIndex:(NSInteger)monthIndex{
    switch (monthIndex) {
        case 0:
            return @"ALL";
            break;
        case 1:
            return @"JAN";
            break;
        case 2:
            return @"FEB";
            break;
        case 3:
            return @"MAR";
            break;
        case 4:
            return @"APR";
            break;
        case 5:
            return @"MAY";
            break;
        case 6:
            return @"JUN";
            break;
        case 7:
            return @"JUL";
            break;
        case 8:
            return @"AUG";
            break;
        case 9:
            return @"SEP";
            break;
        case 10:
            return @"OCT";
            break;
        case 11:
            return @"NOV";
            break;
        case 12:
            return @"DEC";
            break;
        default:
            return @"";
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"monthCell"];
    UIView* goldenBack = [UIView new];
    goldenBack.backgroundColor = GOLDENSPEAR_COLOR;
    cell.selectedBackgroundView = goldenBack;
    UILabel* theLabel = (UILabel*)[cell viewWithTag:100];
    NSNumber* yearName = [monthFilterArray objectAtIndex:indexPath.section];
    NSArray* monthArray = [monthComponents objectForKey:yearName];
    NSString* monthLabel = [self getMonthLabelForIndex:[[monthArray objectAtIndex:indexPath.row] integerValue]];
    theLabel.text = monthLabel;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [monthFilterArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    NSNumber* yearName = [monthFilterArray objectAtIndex:section];
    return [[monthComponents objectForKey:yearName]count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"%li",[[monthFilterArray objectAtIndex:section] integerValue]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeaderCell"];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    GSDateFilterSectionHeaderView* header = (GSDateFilterSectionHeaderView*)view;
    header.nameLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    if (section == 0) {
        [header.headerButton addTarget:self action:@selector(selectAllRow:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber* newYearFiltered = [monthFilterArray objectAtIndex:indexPath.section];
    NSInteger newMonthFiltered = [[[monthComponents objectForKey:newYearFiltered] objectAtIndex:indexPath.row] integerValue];
    if (indexPath.section == 0) {
        yearFiltered = 0;
        monthFiltered = 0;
    }
    else if(yearFiltered==[newYearFiltered integerValue]&&newMonthFiltered==monthFiltered){
        //Same row, disable filtering
        yearFiltered = 0;
        monthFiltered = 0;
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    else{
        yearFiltered = [newYearFiltered integerValue];
        monthFiltered = newMonthFiltered;
    }
    [self moveMonthFilter:NO];
    //Reload search with new filter
    [self resetPostsForFiltering];
}

-(void)selectAllRow:(id)sender {
    NSLog(@"Select ALL");
    NSIndexPath *indexpath = [_monthFilterTable indexPathForSelectedRow];
    [_monthFilterTable deselectRowAtIndexPath:indexpath animated:YES];
}
#pragma mark - MonthFilterHelpers
- (NSString*) calculateDateStringForSelection
{
    if (yearFiltered==0||monthFiltered==0) {
        return @"";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components: ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )  fromDate:[NSDate date]];
    dateComponents.day = 1;
    dateComponents.hour=0;
    dateComponents.minute=0;
    dateComponents.second=5;
    
    NSInteger nextMonth = monthFiltered+1;
    NSInteger nextYear = yearFiltered;
    if (nextMonth>12) {
        nextMonth = 1;
        nextYear++;
    }
    dateComponents.month = monthFiltered;
    dateComponents.year = yearFiltered;
    NSDate* fromDate = [calendar dateFromComponents:dateComponents];
    
    dateComponents.month = nextMonth;
    dateComponents.year = nextYear;
    NSDate* toDate = [calendar dateFromComponents:dateComponents];
    
    NSString* fromDateString = [dateFormatter stringFromDate:fromDate];
    NSString* toDateString = [dateFormatter stringFromDate:toDate];
    return [NSString stringWithFormat:@"createdAtFrom=%@&createdAtTo=%@",fromDateString,toDateString];
}

- (void)doubleDisplayLikeUpdatingFinished{
    
}

- (void)showMessageWithImageNamed:(NSString *)imageNamed andSharedObject:(Share *)sharedObject{
    self.currentSharedObject = sharedObject;
    [self showMessageWithImageNamed:imageNamed];
}

-(void)uploadPostSharedIn:(NSString *) sSocialNetwork
{
    // Check that the name is valid
    
    if (!(self.currentSharedObject.sharedPostId == nil))
    {
        if(!([self.currentSharedObject.sharedPostId isEqualToString:@""]))
        {
            // Post the FashionistaPostShared object
            
            FashionistaPostShared * newPostShared = [[FashionistaPostShared alloc] init];
            
            newPostShared.socialNetwork = sSocialNetwork;
            
            [newPostShared setPostId:self.currentSharedObject.sharedPostId];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newPostShared setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            [newPostShared setFingerprint:appDelegate.finger.fingerprint];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostShared, nil];
            
            [self performRestPost:ADD_POSTSHARED withParamaters:requestParameters];
        }
    }
}

-(void) afterSharedIn:(NSString *) sSocialNetwork
{    
    [self uploadPostSharedIn:sSocialNetwork];
}

-(void)showFullVideo:(NSInteger)orientation {
    if (![_shownStylist.headerType isEqualToString:@"video"]) {
        return;
    }
    FullVideoViewController *fullVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FullVideoViewController"];
    fullVC.modalPresentationStyle = UIModalPresentationPopover;
    fullVC.orientation = orientation;
    NSString* url = _shownStylist.headerMedia;
    if (url == nil || [url isEqualToString:@""]) {
        return;
    }
    fullVC.currentTime = player.player.currentTime;
    [player.player pause];
    fullVC.videoURL = url;
    fullVC.delegate = self;
    [self presentViewController:fullVC animated:YES completion:nil];
}

-(void)setPlayer:(CMTime)videoPlayer hasSound:(BOOL)sound {
    //isRefresh = NO;
    //currentTime = videoPlayer;
    //isSound = sound;
}

@end
