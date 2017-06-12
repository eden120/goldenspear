//
//  MagazineTappedViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/7/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "MagazineTappedViewController.h"
#import "HTHorizontalSelectionList.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "SearchBaseViewController.h"
#import "FashionistaUserListViewController.h"
#import "UILabel+CustomCreation.h"
#import "FullVideoViewController.h"
#import "NYTPhotosViewController.h"
#import "FashionistaProfileViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MagazineTappedViewController() <HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource>

@property (weak, nonatomic) IBOutlet HTHorizontalSelectionList *topNaviList;

@end

@implementation MagazineTappedViewController {
    NSArray *topNavs;
    NSInteger updatingCommentIndex;
    NSInteger commentToDelete;
    
    NSArray* optionHandlers;
    
    BOOL showingOptions;
    
    FashionistaPost* thePost;
    User* postOwner;
    FashionistaContent* theContent;
    
    NSMutableDictionary* commentIndexDict;
    
    BOOL _bComingFromTagsSearch;
    
    NSArray* keywordsAlreadyDownloaded;
    
    BOOL isGETLIKE;
    BOOL searchingPosts;
    NSString *postId;
    
    CMTime currentTime;
    BOOL isSound;
    
    NSMutableArray *searchKeys;
    NSMutableArray *searchStrings;
    NSMutableDictionary *numOfMatches;
    NSInteger currentSearchIndex;
}

- (BOOL)shouldCreateHintButton{
    return NO;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    topNavs = [[NSArray alloc] initWithObjects:@"SHARE", @"COMMENT", @"RELATED", @"MORE", nil];
    _topNaviList.delegate = self;
    _topNaviList.dataSource = self;
    
    _topNaviList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    _topNaviList.selectionIndicatorStyle = HTHorizontalSelectionIndicatorStyleNone;
    _topNaviList.showsEdgeFadeEffect = YES;
    
    _topNaviList.selectionIndicatorColor = [UIColor whiteColor];
    [_topNaviList setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_topNaviList setTitleFont:[UIFont fontWithName:@"Avenir-Heavy" size:18] forState:UIControlStateNormal];
    [_topNaviList setTitleFont:[UIFont fontWithName:@"Avenir-Heavy" size:18] forState:UIControlStateSelected];
    [_topNaviList setTitleFont:[UIFont fontWithName:@"Avenir-Heavy" size:18] forState:UIControlStateHighlighted];
    
    
    _contentView.viewDelegate = self;
    _contentView.postDelegate = self;
    _contentView.viewDelegate = self;
    
    currentTime = kCMTimeZero;
    
    thePost = [_postParameters objectAtIndex:1];
    postOwner = [_postParameters objectAtIndex:6];
    theContent = [[_postParameters objectAtIndex:2] firstObject];
    
    if ([_postParameters count] > 7) {
        
        if ([[_postParameters objectAtIndex:7] isKindOfClass:[SearchQuery class]]) {
            [self setSearchQuery:[_postParameters objectAtIndex:7]];
        }
    }
    
    _contentView.contentScroll.scrollEnabled = YES;
    
    _imagesQueue = [[NSOperationQueue alloc] init];
    
    _imagesQueue.maxConcurrentOperationCount = 3;
    
    [self setTopBarTitle:postOwner.fashionistaName andSubtitle:postOwner.fashionistaTitle];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return topNavs.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    
    return topNavs[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    // update the view for the corresponding index
    
}

@end
