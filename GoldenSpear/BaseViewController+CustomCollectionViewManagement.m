//
//  BaseViewController+CustomCollectionViewManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 23/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+CustomCollectionViewManagement.h"
#import <objc/runtime.h>

#import "BaseViewController+FetchedResultsManagement.h"
#import "SearchBaseViewController.h"
#import "CollectionViewDecorationReusableView.h"
#import "CollectionViewHeaderReusableView.h"
#import "CollectionViewFooterReusableView.h"
#import "CollectionViewCustomLayout.h"


static char MAINCOLLECTIONCELLTYPE_KEY;
static char MAINCOLLECTIONVIEW_KEY;
static char MAINCOLLECTIONVIEWLAYOUT_KEY;
static char SECONDCOLLECTIONCELLTYPE_KEY;
static char SECONDCOLLECTIONVIEW_KEY;
static char SECONDCOLLECTIONVIEWLAYOUT_KEY;
static char THIRDCOLLECTIONCELLTYPE_KEY;
static char THIRDCOLLECTIONVIEW_KEY;
static char THIRDCOLLECTIONVIEWLAYOUT_KEY;
static char IMAGESQUEUE_KEY;


// Constants for result cells properties
#define ADNUM 5

#define kResultNumberOfColumns 2
#define kResultVerticalSpacing 5.0
#define kResultAdjustTopInset YES
#define kResultTopInset (((([self.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]])) && (([((SearchBaseViewController *) self) searchContext] == FASHIONISTAPOSTS_SEARCH) || ([((SearchBaseViewController *) self) searchContext] == FASHIONISTAS_SEARCH))) ? (156) : (126))
#define kResultAdjustBottomInset YES
#define kResultBottomInset 87.0
#define kResultAdjustSideInset NO
#define kResultSideInset 0.0        // only applied to iphone 6
#define kResultHorizontalSpacing 5.0
#define kResultItemWidth ((self.view.frame.size.width)-((kResultNumberOfColumns-1)*kResultHorizontalSpacing)-/*((kResultCellBorderLeft + kResultCellBorderRight)*kResultNumberOfColumns)-*/(kResultHorizontalSpacing*2))/kResultNumberOfColumns
#define kResultItemHeight kResultItemWidth
#define kResultHeaderHeight 80.0
#define kResultFooterHeight 0.0
#define kResultHeaderAndFooterInset 0.0
#define kResultForceStagging NO
#define kResultForceEqualHeights NO
#define kResultCellBorderTop 5.0
#define kResultCellStylistExtraBorderTop 15.0
#define kResultCellBorderBottom 0.0
#define kResultCellBorderLeft 7.0
#define kResultCellBorderRight 7.0
#define kResultCellDefaultAspectRatio 1.0
#define kResultSpaceBetweenCellImageAndCellTitles 0.0
#define kResultAdditionalHeightForTitle 50.0
#define kResultAdditionalHeightForPrice 20.0
#define kResultExtraBottomSpace 10.0
#define kResultAllowMultipleSelection NO
#define kHangerWidth 30
#define kHangerHeight 30
#define kHangerVInset 5-kResultCellBorderTop
#define kHangerHInset kHangerVInset-kResultCellBorderRight
#define kResultCellPostLayoutAspectRatio 1.25

// Constants for wardrobecontent cells properties
#define kWardrobeContentNumberOfColumns 2
#define kWardrobeContentVerticalSpacing 5.0
#define kWardrobeContentAdjustTopInset YES
#define kWardrobeContentTopInset 88.0
#define kWardrobeContentAdjustBottomInset YES
#define kWardrobeContentBottomInset 87.0
#define kWardrobeContentAdjustSideInset NO
#define kWardrobeContentSideInset 0.0        // only applied to iphone 6
#define kWardrobeContentHorizontalSpacing 5.0
#define kWardrobeContentItemWidth ((self.view.frame.size.width)-((kWardrobeContentNumberOfColumns-1)*kWardrobeContentHorizontalSpacing)-/*((kWardrobeContentCellBorderLeft + kWardrobeContentCellBorderRight)*kWardrobeContentNumberOfColumns)-*/(kWardrobeContentHorizontalSpacing*2))/kWardrobeContentNumberOfColumns
#define kWardrobeContentItemHeight kWardrobeContentItemWidth
#define kWardrobeContentHeaderHeight 0.0
#define kWardrobeContentFooterHeight 0.0
#define kWardrobeContentHeaderAndFooterInset 0.0
#define kWardrobeContentForceStagging NO
#define kWardrobeContentForceEqualHeights NO
#define kWardrobeContentCellBorderTop 5.0
#define kWardrobeContentCellBorderBottom 0.0
#define kWardrobeContentCellBorderLeft 7.0
#define kWardrobeContentCellBorderRight 7.0
#define kWardrobeContentCellDefaultAspectRatio 1.0
#define kWardrobeContentSpaceBetweenCellImageAndCellTitles 0.0
#define kWardrobeContentAdditionalHeightForTitle 50.0
#define kWardrobeContentAdditionalHeightForPrice 20.0
#define kWardrobeContentExtraBottomSpace 10.0
#define kWardrobeContentAllowMultipleSelection NO
#define kCreateViewMoveDeleteAddToButtonsInset 10
#define kCreateViewMoveDeleteAddToButtonsWidth kWardrobeContentItemWidth - (4*kCreateViewMoveDeleteAddToButtonsInset)
#define kCreateViewMoveDeleteAddToButtonsHeight 30


// Constants for wardrobe cells properties
#define kWardrobeNumberOfColumns 2
#define kWardrobeVerticalSpacing 5.0
#define kWardrobeItemWidth ((self.view.frame.size.width)-((kWardrobeNumberOfColumns-1)*kWardrobeHorizontalSpacing)-/*((kWardrobeCellBorderLeft + kWardrobeCellBorderRight)*kWardrobeNumberOfColumns)-*/(kWardrobeHorizontalSpacing*2))/kWardrobeNumberOfColumns
#define kWardrobeItemHeight kWardrobeItemWidth*1.25
#define kWardrobeHeaderHeight 0.0
#define kWardrobeFooterHeight 0.0
#define kWardrobeHeaderAndFooterInset 0.0
#define kWardrobeAdjustTopInset NO
#define kWardrobeTopInset 88.0
#define kWardrobeAdjustBottomInset YES
#define kWardrobeBottomInset 87.0
#define kWardrobeAdjustSideInset NO        // only applied to iphone 6
#define kWardrobeSideInset 0.0
#define kWardrobeHorizontalSpacing 5.0
#define kWardrobeForceStagging NO
#define kWardrobeForceEqualHeights NO
#define kWardrobeCellBorderTop 2.0
#define kWardrobeCellBorderBottom 2.0
#define kWardrobeCellBorderLeft 2.0
#define kWardrobeCellBorderRight 2.0
#define kWardrobeCellDefaultAspectRatio 1.5
#define kWardrobeSpaceBetweenCellImageAndCellTitles 2.0
#define kWardrobeAdditionalHeightForTitle 30.0
#define kWardrobeAllowMultipleSelection NO


// Constants for review cells properties
#define kReviewNumberOfColumns 1
#define kReviewItemWidth 300.0
#define kReviewItemHeight 120.0
#define kReviewHeaderHeight 0.0
#define kReviewFooterHeight 0.0
#define kReviewHeaderAndFooterInset 0.0
#define kReviewVerticalSpacing 3.0
#define kReviewAdjustTopInset NO
#define kReviewTopInset 10.0
#define kReviewAdjustBottomInset NO
#define kReviewBottomInset 87.0
#define kReviewAdjustSideInset NO        // only applied to iphone 6
#define kReviewSideInset 0.0
#define kReviewHorizontalSpacing 3.0
#define kReviewForceStagging NO
#define kReviewForceEqualHeights NO
#define kReviewCellBorderTop 2.0
#define kReviewCellBorderBottom 2.0
#define kReviewCellBorderLeft 2.0
#define kReviewCellBorderRight 2.0
#define kReviewCellDefaultAspectRatio 1.5
#define kReviewSpaceBetweenCellImageAndCellTitles 2.0
#define kReviewAdditionalHeightForTitle 30.0
#define kReviewAllowMultipleSelection NO


// Constants for comment cells properties
#define kCommentNumberOfColumns 1
#define kCommentItemWidth 300.0
#define kCommentItemHeight 80.0
#define kCommentHeaderHeight 0.0
#define kCommentFooterHeight 0.0
#define kCommentHeaderAndFooterInset 0.0
#define kCommentVerticalSpacing 3.0
#define kCommentAdjustTopInset YES
#define kCommentTopInset 10.0
#define kCommentAdjustBottomInset NO
#define kCommentBottomInset 87.0
#define kCommentAdjustSideInset NO        // only applied to iphone 6
#define kCommentSideInset 0.0
#define kCommentHorizontalSpacing 2.0
#define kCommentForceStagging NO
#define kCommentForceEqualHeights NO
#define kCommentCellBorderTop 1.0
#define kCommentCellBorderBottom 1.0
#define kCommentCellBorderLeft 1.0
#define kCommentCellBorderRight 1.0
#define kCommentCellDefaultAspectRatio 1.5
#define kCommentSpaceBetweenCellImageAndCellTitles 1.0
#define kCommentAdditionalHeightForTitle 0.0
#define kCommentAllowMultipleSelection NO


// Constants for content cells properties
#define kContentNumberOfColumns 1
#define kContentItemWidth 40.0
#define kContentItemHeight 40.0
#define kContentHeaderHeight 0.0
#define kContentFooterHeight 0.0
#define kContentHeaderAndFooterInset 0.0
#define kContentVerticalSpacing 3.0
#define kContentAdjustTopInset NO
#define kContentTopInset 10.0
#define kContentAdjustBottomInset NO
#define kContentBottomInset 87.0
#define kContentAdjustSideInset NO        // only applied to iphone 6
#define kContentSideInset 0.0
#define kContentHorizontalSpacing 2.0
#define kContentForceStagging NO
#define kContentForceEqualHeights YES
#define kContentCellBorderTop 1.0
#define kContentCellBorderBottom 1.0
#define kContentCellBorderLeft 1.0
#define kContentCellBorderRight 1.0
#define kContentCellDefaultAspectRatio 1.0
#define kContentSpaceBetweenCellImageAndCellTitles 2.0
#define kContentAdditionalHeightForTitle 30.0
#define kContentAllowMultipleSelection NO


// Constants for feature cells properties
#define kFeatureNumberOfColumns 3
#define kFeatureItemWidth 88.0
#define kFeatureItemHeight 135.0
#define kFeatureItemWidthEmbeded 75.0
#define kFeatureItemHeightEmbeded 115.0
#define kFeatureItemHeightOnlyLabel 22.0
#define kFeatureHeaderHeight 0.0
#define kFeatureFooterHeight 0.0
#define kFeatureHeaderAndFooterInset 0.0
#define kFeatureVerticalSpacing 3.0
#define kFeatureAdjustTopInset YES
#define kFeatureTopInset 5.0
#define kFeatureAdjustBottomInset YES
#define kFeatureBottomInset 87.0
#define kFeatureAdjustSideInset NO        // only applied to iphone 6
#define kFeatureSideInset 0.0
#define kFeatureHorizontalSpacing 2.0
#define kFeatureForceStagging NO
#define kFeatureForceEqualHeights YES
#define kFeatureCellBorderTop 1.0
#define kFeatureCellBorderBottom 1.0
#define kFeatureCellBorderLeft 1.0
#define kFeatureCellBorderRight 1.0
#define kFeatureCellDefaultAspectRatio 1.0
#define kFeatureSpaceBetweenCellImageAndCellTitles 2.0
#define kFeatureAdditionalHeightForTitle 30.0
#define kFeatureAllowMultipleSelection NO
#define kFeatureZoomWidth 17
#define kFeatureZoomHeight 17
#define kFeatureZoomInset 2


// Constants for wardrobebin cells properties
#define kWardrobeBinNumberOfColumns 500
#define kWardrobeBinItemWidth 65.0
#define kWardrobeBinItemHeight 65.0
#define kWardrobeBinHeaderHeight 0.0
#define kWardrobeBinFooterHeight 0.0
#define kWardrobeBinHeaderAndFooterInset 0.0
#define kWardrobeBinVerticalSpacing 3.0
#define kWardrobeBinAdjustTopInset NO
#define kWardrobeBinTopInset 2.0
#define kWardrobeBinAdjustBottomInset NO
#define kWardrobeBinBottomInset 87.0
#define kWardrobeBinAdjustSideInset NO        // only applied to iphone 6
#define kWardrobeBinSideInset 0.0
#define kWardrobeBinHorizontalSpacing 3.0
#define kWardrobeBinForceStagging NO
#define kWardrobeBinForceEqualHeights YES
#define kWardrobeBinCellBorderTop 2.0
#define kWardrobeBinCellBorderBottom 2.0
#define kWardrobeBinCellBorderLeft 2.0
#define kWardrobeBinCellBorderRight 2.0
#define kWardrobeBinCellDefaultAspectRatio 1.2
#define kWardrobeBinSpaceBetweenCellImageAndCellTitles 2.0
#define kWardrobeBinAdditionalHeightForTitle 20.0
#define kWardrobeBinAllowMultipleSelection YES


// Constants for post cells properties
#define kPostNumberOfColumns 2
#define kPostVerticalSpacing 5.0
#define kPostAdjustTopInset YES
#define kPostTopInset 35.0
#define kPostAdjustBottomInset YES
#define kPostBottomInset 87.0
#define kPostAdjustSideInset NO        // only applied to iphone 6
#define kPostSideInset 0.0
#define kPostHorizontalSpacing 5.0
#define kPostItemWidth ((self.view.frame.size.width)-((kPostNumberOfColumns-1)*kPostHorizontalSpacing)-/*((kPostCellBorderLeft + kPostCellBorderRight)*kPostNumberOfColumns)-*/(kPostHorizontalSpacing*2))/kPostNumberOfColumns
#define kPostItemHeight kPostItemWidth//*1.1
#define kPostHeaderHeight 0.0
#define kPostFooterHeight 0.0
#define kPostHeaderAndFooterInset 0.0
#define kPostForceStagging NO
#define kPostForceEqualHeights NO
#define kPostCellBorderTop 5.0
#define kPostCellBorderBottom 0.0
#define kPostCellBorderLeft 7.0
#define kPostCellBorderRight 7.0
#define kPostCellDefaultAspectRatio 1.0
#define kPostSpaceBetweenCellImageAndCellTitles 0.0
#define kPostAdditionalHeightForTitle 20
#define kPostAllowMultipleSelection NO


// Constants for search feature cells properties
#define kSearchFeatureNumberOfColumns 3
#define kSearchFeatureItemWidth 155 //88.0
#define kSearchFeatureItemHeight 215 //113.0
#define kSearchFeatureItemHeightOnlyLabel 22.0
#define kSearchFeatureHeaderHeight 15.0
#define kSearchFeatureFooterHeight 0.0
#define kSearchFeatureHeaderAndFooterInset 0.0
#define kSearchFeatureVerticalSpacing 3 //10.0
#define kSearchFeatureAdjustTopInset YES
#define kSearchFeatureTopInset 42.0+92.0
#define kSearchFeatureAdjustBottomInset YES
#define kSearchFeatureBottomInset 108.0
#define kSearchFeatureAdjustSideInset NO        // only applied to iphone 6
#define kSearchFeatureSideInset 0 //20.0
#define kSearchFeatureHorizontalSpacing 3 //10.0
#define kSearchFeatureForceStagging NO
#define kSearchFeatureForceEqualHeights YES
#define kSearchFeatureCellBorderTop 10.0
#define kSearchFeatureCellBorderBottom 10.0
#define kSearchFeatureCellBorderLeft 10.0
#define kSearchFeatureCellBorderRight 10.0
#define kSearchFeatureCellDefaultAspectRatio 1.0
#define kSearchFeatureSpaceBetweenCellImageAndCellTitles 1.0
#define kSearchFeatureAdditionalHeightForTitle 25.0
#define kSearchFeatureAllowMultipleSelection NO
#define kSearchFeatureZoomWidth 20
#define kSearchFeatureZoomHeight 20
#define kSearchFeatureExpandWidth 35
#define kSearchFeatureExpandHeight 35
#define kSearchFeatureZoomInset 2



// Constants for page cells properties
#define kPageNumberOfColumns 2
#define kPageVerticalSpacing 2.0
#define kPageAdjustTopInset YES
#define kPageTopInset 0.0
#define kPageAdjustBottomInset YES
#define kPageBottomInset 87.0
#define kPageAdjustSideInset NO        // only applied to iphone 6
#define kPageSideInset 0.0
#define kPageHorizontalSpacing 2.0
#define kPageItemWidth ((self.view.frame.size.width)-((kPageNumberOfColumns-1)*kPageHorizontalSpacing)-/*((kPageCellBorderLeft + kPageCellBorderRight)*kPageNumberOfColumns)-*/(kPageHorizontalSpacing*2))/kPageNumberOfColumns
#define kPageItemHeight kPageItemWidth
#define kPageHeaderHeight 0.0
#define kPageFooterHeight 0.0
#define kPageHeaderAndFooterInset 0.0
#define kPageForceStagging NO
#define kPageForceEqualHeights NO
#define kPageCellBorderTop 2.0
#define kPageCellBorderBottom 2.0
#define kPageCellBorderLeft 2.0
#define kPageCellBorderRight 2.0
#define kPageCellDefaultAspectRatio 1.5
#define kPageSpaceBetweenCellImageAndCellTitles 5.0
#define kPageAdditionalHeightForTitle 30.0
#define kPageAllowMultipleSelection NO
#define kHeartWidth 60
#define kHeartHeight 60
#define kHeartVInset 0
#define kHeartHInset -10



// Constants for notifications cells properties
#define kNotificationNumberOfColumns 1
#define kNotificationItemWidth self.view.frame.size.width
#define kNotificationItemHeight 70.0
#define kNotificationHeaderHeight 0.0
#define kNotificationFooterHeight 0.0
#define kNotificationHeaderAndFooterInset 0.0
#define kNotificationVerticalSpacing 0.0
#define kNotificationAdjustTopInset YES
#define kNotificationTopInset 87.0
#define kNotificationAdjustBottomInset YES
#define kNotificationBottomInset 67.0
#define kNotificationAdjustSideInset NO        // only applied to iphone 6
#define kNotificationSideInset 0.0
#define kNotificationHorizontalSpacing 0.0
#define kNotificationForceStagging NO
#define kNotificationForceEqualHeights NO
#define kNotificationCellBorderTop 0.0
#define kNotificationCellBorderBottom 0.0
#define kNotificationCellBorderLeft 0.0
#define kNotificationCellBorderRight 0.0
#define kNotificationCellDefaultAspectRatio 1.5
#define kNotificationSpaceBetweenCellImageAndCellTitles 0.0
#define kNotificationAdditionalHeightForTitle 00.0
#define kNotificationAllowMultipleSelection NO



@implementation BaseViewController (CollectionViewManagement)


#pragma mark - Collection views management

// Getter and setter for mainCollectionCellType
- (NSString *)mainCollectionCellType
{
    return objc_getAssociatedObject(self, &MAINCOLLECTIONCELLTYPE_KEY);
}

- (void)setMainCollectionCellType:(NSString *)mainCollectionCellType
{
    objc_setAssociatedObject(self, &MAINCOLLECTIONCELLTYPE_KEY, mainCollectionCellType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for mainCollectionView
- (UICollectionView *)mainCollectionView
{
    return objc_getAssociatedObject(self, &MAINCOLLECTIONVIEW_KEY);
}

- (void)setMainCollectionView:(UICollectionView *)mainCollectionView
{
    objc_setAssociatedObject(self, &MAINCOLLECTIONVIEW_KEY, mainCollectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for mainCollectionViewLayout
- (CollectionViewCustomLayout *)mainCollectionViewLayout
{
    return objc_getAssociatedObject(self, &MAINCOLLECTIONVIEWLAYOUT_KEY);
}

- (void)setMainCollectionViewLayout:(CollectionViewCustomLayout *)mainCollectionViewLayout
{
    objc_setAssociatedObject(self, &MAINCOLLECTIONVIEWLAYOUT_KEY, mainCollectionViewLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for secondCollectionCellType
- (NSString *)secondCollectionCellType
{
    return objc_getAssociatedObject(self, &SECONDCOLLECTIONCELLTYPE_KEY);
}

- (void)setSecondCollectionCellType:(NSString *)secondCollectionCellType
{
    objc_setAssociatedObject(self, &SECONDCOLLECTIONCELLTYPE_KEY, secondCollectionCellType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for secondCollectionView
- (UICollectionView *)secondCollectionView
{
    return objc_getAssociatedObject(self, &SECONDCOLLECTIONVIEW_KEY);
}

- (void)setSecondCollectionView:(UICollectionView *)secondCollectionView
{
    objc_setAssociatedObject(self, &SECONDCOLLECTIONVIEW_KEY, secondCollectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for secondCollectionViewLayout
- (CollectionViewCustomLayout *)secondCollectionViewLayout
{
    return objc_getAssociatedObject(self, &SECONDCOLLECTIONVIEWLAYOUT_KEY);
}

- (void)setSecondCollectionViewLayout:(CollectionViewCustomLayout *)secondCollectionViewLayout
{
    objc_setAssociatedObject(self, &SECONDCOLLECTIONVIEWLAYOUT_KEY, secondCollectionViewLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for thirdCollectionCellType
- (NSString *)thirdCollectionCellType
{
    return objc_getAssociatedObject(self, &THIRDCOLLECTIONCELLTYPE_KEY);
}

- (void)setThirdCollectionCellType:(NSString *)thirdCollectionCellType
{
    objc_setAssociatedObject(self, &THIRDCOLLECTIONCELLTYPE_KEY, thirdCollectionCellType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for thirdCollectionView
- (UICollectionView *)thirdCollectionView
{
    return objc_getAssociatedObject(self, &THIRDCOLLECTIONVIEW_KEY);
}

- (void)setThirdCollectionView:(UICollectionView *)thirdCollectionView
{
    objc_setAssociatedObject(self, &THIRDCOLLECTIONVIEW_KEY, thirdCollectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for thirdCollectionViewLayout
- (CollectionViewCustomLayout *)thirdCollectionViewLayout
{
    return objc_getAssociatedObject(self, &THIRDCOLLECTIONVIEWLAYOUT_KEY);
}

- (void)setThirdCollectionViewLayout:(CollectionViewCustomLayout *)thirdCollectionViewLayout
{
    objc_setAssociatedObject(self, &THIRDCOLLECTIONVIEWLAYOUT_KEY, thirdCollectionViewLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for imagesQueue
- (NSOperationQueue *)imagesQueue
{
    return objc_getAssociatedObject(self, &IMAGESQUEUE_KEY);
}

- (void)setImagesQueue:(NSOperationQueue *)imagesQueue
{
    objc_setAssociatedObject(self, &IMAGESQUEUE_KEY, imagesQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Init the images operation queue (to load them in the background)
- (void)initImagesQueue
{
    //  Operation queue initialization
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
}

// Init collection views appearance
- (void)initCollectionViewsLayout
{
    if (!(self.mainCollectionView == nil))
    {
        // Setup Collection View appearance
        [self initLayoutforCollectionView:self.mainCollectionView];
    }
    
    if (!(self.secondCollectionView == nil))
    {
        // Setup Collection View appearance
        [self initLayoutforCollectionView:self.secondCollectionView];
    }
    
    if (!(self.thirdCollectionView == nil))
    {
        // Setup Collection View appearance
        [self initLayoutforCollectionView:self.thirdCollectionView];
    }
}

// dictionary where to save the operations that are loading images of the cells
NSMutableDictionary * operationsLoadImages;

-(void)initOperationsLoadingImages
{
    if (operationsLoadImages != nil)
    {
        [operationsLoadImages removeAllObjects];
    }
    else
    {
        operationsLoadImages = [[NSMutableDictionary alloc] init];
    }
    

}

// Setup collection views for the set of given cell types
- (void)setupCollectionViewsWithCellTypes:(NSMutableArray *)cellTypes
{
    if((cellTypes == nil) || (!([cellTypes count] > 0)))
    {
        return;
    }
    else
    {
        switch ([cellTypes count])
        {
            case 1:
                
                self.mainCollectionCellType = [cellTypes objectAtIndex:0];
                
                //[self.mainCollectionView registerClass:NSClassFromString(self.mainCollectionCellType) forCellWithReuseIdentifier:self.mainCollectionCellType];
                
                [self.mainCollectionView registerClass:[CollectionViewDecorationReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindTopDecorationView withReuseIdentifier:@"CollectionViewCustomLayoutElementKindTopDecorationView"];
                
                [self.mainCollectionView registerClass:[CollectionViewHeaderReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionHeader withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionHeader"];
                
                [self.mainCollectionView registerClass:[CollectionViewFooterReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionFooter withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionFooter"];
                
                break;
                
            case 2:
                
                self.mainCollectionCellType = [cellTypes objectAtIndex:0];
                
                //[self.mainCollectionView registerClass:NSClassFromString(self.mainCollectionCellType) forCellWithReuseIdentifier:self.mainCollectionCellType];
                
                [self.mainCollectionView registerClass:[CollectionViewDecorationReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindTopDecorationView withReuseIdentifier:@"CollectionViewCustomLayoutElementKindTopDecorationView"];
                
                [self.mainCollectionView registerClass:[CollectionViewHeaderReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionHeader withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionHeader"];
                
                [self.mainCollectionView registerClass:[CollectionViewFooterReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionFooter withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionFooter"];
                
                self.secondCollectionCellType = [cellTypes objectAtIndex:1];
                
                //[self.secondCollectionView registerClass:NSClassFromString(self.secondCollectionCellType) forCellWithReuseIdentifier:self.secondCollectionCellType];
                
                [self.secondCollectionView registerClass:[CollectionViewDecorationReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindTopDecorationView withReuseIdentifier:@"CollectionViewCustomLayoutElementKindTopDecorationView"];

                [self.secondCollectionView registerClass:[CollectionViewHeaderReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionHeader withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionHeader"];
                
                [self.secondCollectionView registerClass:[CollectionViewFooterReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionFooter withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionFooter"];
                
                break;
                
            case 3:
                
                self.mainCollectionCellType = [cellTypes objectAtIndex:0];
                
                //[self.mainCollectionView registerClass:NSClassFromString(self.mainCollectionCellType) forCellWithReuseIdentifier:self.mainCollectionCellType];
                
                [self.mainCollectionView registerClass:[CollectionViewDecorationReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindTopDecorationView withReuseIdentifier:@"CollectionViewCustomLayoutElementKindTopDecorationView"];
                
                [self.mainCollectionView registerClass:[CollectionViewHeaderReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionHeader withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionHeader"];
                
                [self.mainCollectionView registerClass:[CollectionViewFooterReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionFooter withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionFooter"];
                
                
                self.secondCollectionCellType = [cellTypes objectAtIndex:1];
                
                //[self.secondCollectionView registerClass:NSClassFromString(self.secondCollectionCellType) forCellWithReuseIdentifier:self.secondCollectionCellType];
                
                [self.secondCollectionView registerClass:[CollectionViewDecorationReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindTopDecorationView withReuseIdentifier:@"CollectionViewCustomLayoutElementKindTopDecorationView"];
                
                [self.secondCollectionView registerClass:[CollectionViewHeaderReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionHeader withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionHeader"];
                
                [self.secondCollectionView registerClass:[CollectionViewFooterReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionFooter withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionFooter"];
                
                
                self.thirdCollectionCellType = [cellTypes objectAtIndex:2];
                
                //[self.thirdCollectionView registerClass:NSClassFromString(self.thirdCollectionCellType) forCellWithReuseIdentifier:self.thirdCollectionCellType];
                
                [self.thirdCollectionView registerClass:[CollectionViewDecorationReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindTopDecorationView withReuseIdentifier:@"CollectionViewCustomLayoutElementKindTopDecorationView"];
                
                [self.thirdCollectionView registerClass:[CollectionViewHeaderReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionHeader withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionHeader"];
                
                [self.thirdCollectionView registerClass:[CollectionViewFooterReusableView class] forSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionFooter withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionFooter"];
                
                break;
                
            default:
                break;
        }
    }
}

// Get collection view for a given Cell Type
- (UICollectionView *)getCollectionViewForCellType:(NSString *)cellType
{
    if(cellType == self.mainCollectionCellType)
    {
        return self.mainCollectionView;
    }
    else if(cellType == self.secondCollectionCellType)
    {
        return self.secondCollectionView;
    }
    else if(cellType == self.thirdCollectionCellType)
    {
        return self.thirdCollectionView;
    }
    
    return nil;
}

// Get cell type for a given Collection View
- (NSString *)getCellTypeForCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.mainCollectionView)
    {
        return self.mainCollectionCellType;
    }
    else if (collectionView == self.secondCollectionView)
    {
        return self.secondCollectionCellType;
    }
    else if (collectionView == self.thirdCollectionView)
    {
        return self.thirdCollectionCellType;
    }
    
    return nil;
}

// Get Collection View Layout for a given Collection View
- (CollectionViewCustomLayout *)getLayoutForCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.mainCollectionView)
    {
        return self.mainCollectionViewLayout;
    }
    else if (collectionView == self.secondCollectionView)
    {
        return self.secondCollectionViewLayout;
    }
    else if (collectionView == self.thirdCollectionView)
    {
        return self.thirdCollectionViewLayout;
    }
    
    return nil;
}

// Get the layout properties for a given Cell type
- (layoutProperties)getlayoutPropertiesForCellType:(NSString *)cellType
{
    layoutProperties lyProperties;
    
    if ([cellType isEqualToString:@"ResultCell"])
    {
        lyProperties.numberOfColumns = kResultNumberOfColumns;
        lyProperties.itemHeight = kResultItemHeight;
        lyProperties.itemWidth = kResultItemWidth;
        lyProperties.verticalSpacing = kResultVerticalSpacing;
        lyProperties.topInset = kResultTopInset;
        lyProperties.bottomInset = kResultBottomInset;
        lyProperties.sideInset = kResultSideInset;
        lyProperties.horizontalSpacing = kResultHorizontalSpacing;
        lyProperties.headerHeight = kResultHeaderHeight;
        lyProperties.footerHeight = kResultFooterHeight;
        lyProperties.headerAndFooterInset = kResultHeaderAndFooterInset;
        lyProperties.adjustTopInset = kResultAdjustTopInset;
        lyProperties.adjustBottomInset = kResultAdjustBottomInset;
        lyProperties.adjustSideInset = kResultAdjustSideInset;
        lyProperties.forceStagging = kResultForceStagging;
        lyProperties.forceEqualHeights = kResultForceEqualHeights;
        lyProperties.allowMultipleSelection = kResultAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"WardrobeCell"])
    {
        lyProperties.numberOfColumns = kWardrobeNumberOfColumns;
        lyProperties.itemHeight = kWardrobeItemHeight;
        lyProperties.itemWidth = kWardrobeItemWidth;
        lyProperties.verticalSpacing = kWardrobeVerticalSpacing;
        lyProperties.topInset = kWardrobeTopInset;
        lyProperties.bottomInset = kWardrobeBottomInset;
        lyProperties.sideInset = kWardrobeSideInset;
        lyProperties.horizontalSpacing = kWardrobeHorizontalSpacing;
        lyProperties.headerHeight = kWardrobeHeaderHeight;
        lyProperties.footerHeight = kWardrobeFooterHeight;
        lyProperties.headerAndFooterInset = kWardrobeHeaderAndFooterInset;
        lyProperties.adjustTopInset = kWardrobeAdjustTopInset;
        lyProperties.adjustBottomInset = kWardrobeAdjustBottomInset;
        lyProperties.adjustSideInset = kWardrobeAdjustSideInset;
        lyProperties.forceStagging = kWardrobeForceStagging;
        lyProperties.forceEqualHeights = kWardrobeForceEqualHeights;
        lyProperties.allowMultipleSelection = kWardrobeAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        lyProperties.numberOfColumns = kWardrobeBinNumberOfColumns;
        lyProperties.itemHeight = kWardrobeBinItemHeight;
        lyProperties.itemWidth = kWardrobeBinItemWidth;
        lyProperties.verticalSpacing = kWardrobeBinVerticalSpacing;
        lyProperties.topInset = kWardrobeBinTopInset;
        lyProperties.bottomInset = kWardrobeBinBottomInset;
        lyProperties.sideInset = kWardrobeBinSideInset;
        lyProperties.horizontalSpacing = kWardrobeBinHorizontalSpacing;
        lyProperties.headerHeight = kWardrobeBinHeaderHeight;
        lyProperties.footerHeight = kWardrobeBinFooterHeight;
        lyProperties.headerAndFooterInset = kWardrobeBinHeaderAndFooterInset;
        lyProperties.adjustTopInset = kWardrobeBinAdjustTopInset;
        lyProperties.adjustBottomInset = kWardrobeBinAdjustBottomInset;
        lyProperties.adjustSideInset = kWardrobeBinAdjustSideInset;
        lyProperties.forceStagging = kWardrobeBinForceStagging;
        lyProperties.forceEqualHeights = kWardrobeBinForceEqualHeights;
        lyProperties.allowMultipleSelection = kWardrobeBinAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"ContentCell"])
    {
        lyProperties.numberOfColumns = kContentNumberOfColumns;
        lyProperties.itemHeight = kContentItemHeight;
        lyProperties.itemWidth = kContentItemWidth;
        lyProperties.verticalSpacing = kContentVerticalSpacing;
        lyProperties.topInset = kContentTopInset;
        lyProperties.bottomInset = kContentBottomInset;
        lyProperties.sideInset = kContentSideInset;
        lyProperties.horizontalSpacing = kContentHorizontalSpacing;
        lyProperties.headerHeight = kContentHeaderHeight;
        lyProperties.footerHeight = kContentFooterHeight;
        lyProperties.headerAndFooterInset = kContentHeaderAndFooterInset;
        lyProperties.adjustTopInset = kContentAdjustTopInset;
        lyProperties.adjustBottomInset = kContentAdjustBottomInset;
        lyProperties.adjustSideInset = kContentAdjustSideInset;
        lyProperties.forceStagging = kContentForceStagging;
        lyProperties.forceEqualHeights = kContentForceEqualHeights;
        lyProperties.allowMultipleSelection = kContentAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"ReviewCell"])
    {
        lyProperties.numberOfColumns = kReviewNumberOfColumns;
        lyProperties.itemHeight = kReviewItemHeight;
        lyProperties.itemWidth = kReviewItemWidth;
        lyProperties.verticalSpacing = kReviewVerticalSpacing;
        lyProperties.topInset = kReviewTopInset;
        lyProperties.bottomInset = kReviewBottomInset;
        lyProperties.sideInset = kReviewSideInset;
        lyProperties.horizontalSpacing = kReviewHorizontalSpacing;
        lyProperties.headerHeight = kReviewHeaderHeight;
        lyProperties.footerHeight = kReviewFooterHeight;
        lyProperties.headerAndFooterInset = kReviewHeaderAndFooterInset;
        lyProperties.adjustTopInset = kReviewAdjustTopInset;
        lyProperties.adjustBottomInset = kReviewAdjustBottomInset;
        lyProperties.adjustSideInset = kReviewAdjustSideInset;
        lyProperties.forceStagging = kReviewForceStagging;
        lyProperties.forceEqualHeights = kReviewForceEqualHeights;
        lyProperties.allowMultipleSelection = kReviewAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"CommentCell"])
    {
        lyProperties.numberOfColumns = kCommentNumberOfColumns;
        lyProperties.itemHeight = kCommentItemHeight;
        lyProperties.itemWidth = kCommentItemWidth;
        lyProperties.verticalSpacing = kCommentVerticalSpacing;
        lyProperties.topInset = kCommentTopInset;
        lyProperties.sideInset = kCommentSideInset;
        lyProperties.bottomInset = kCommentBottomInset;
        lyProperties.horizontalSpacing = kCommentHorizontalSpacing;
        lyProperties.headerHeight = kCommentHeaderHeight;
        lyProperties.footerHeight = kCommentFooterHeight;
        lyProperties.headerAndFooterInset = kCommentHeaderAndFooterInset;
        lyProperties.adjustTopInset = kCommentAdjustTopInset;
        lyProperties.adjustBottomInset = kCommentAdjustBottomInset;
        lyProperties.adjustSideInset = kCommentAdjustSideInset;
        lyProperties.forceStagging = kCommentForceStagging;
        lyProperties.forceEqualHeights = kCommentForceEqualHeights;
        lyProperties.allowMultipleSelection = kCommentAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"NotificationCell"])
    {
        lyProperties.numberOfColumns = kNotificationNumberOfColumns;
        lyProperties.itemHeight = kNotificationItemHeight;
        lyProperties.itemWidth = kNotificationItemWidth;
        lyProperties.verticalSpacing = kNotificationVerticalSpacing;
        lyProperties.topInset = kNotificationTopInset;
        lyProperties.bottomInset = kNotificationBottomInset;
        lyProperties.sideInset = kNotificationSideInset;
        lyProperties.horizontalSpacing = kNotificationHorizontalSpacing;
        lyProperties.headerHeight = kNotificationHeaderHeight;
        lyProperties.footerHeight = kNotificationFooterHeight;
        lyProperties.headerAndFooterInset = kNotificationHeaderAndFooterInset;
        lyProperties.adjustTopInset = kNotificationAdjustTopInset;
        lyProperties.adjustBottomInset = kNotificationAdjustBottomInset;
        lyProperties.adjustSideInset = kNotificationAdjustSideInset;
        lyProperties.forceStagging = kNotificationForceStagging;
        lyProperties.forceEqualHeights = kNotificationForceEqualHeights;
        lyProperties.allowMultipleSelection = kNotificationAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        lyProperties.numberOfColumns = kWardrobeContentNumberOfColumns;
        lyProperties.itemHeight = kWardrobeContentItemHeight;
        lyProperties.itemWidth = kWardrobeContentItemWidth;
        lyProperties.verticalSpacing = kWardrobeContentVerticalSpacing;
        lyProperties.topInset = kWardrobeContentTopInset;
        lyProperties.bottomInset = kWardrobeContentBottomInset;
        lyProperties.sideInset = kWardrobeContentSideInset;
        lyProperties.horizontalSpacing = kWardrobeContentHorizontalSpacing;
        lyProperties.headerHeight = kWardrobeContentHeaderHeight;
        lyProperties.footerHeight = kWardrobeContentFooterHeight;
        lyProperties.headerAndFooterInset = kWardrobeContentHeaderAndFooterInset;
        lyProperties.adjustTopInset = kWardrobeContentAdjustTopInset;
        lyProperties.adjustBottomInset = kWardrobeContentAdjustBottomInset;
        lyProperties.adjustSideInset = kWardrobeContentAdjustSideInset;
        lyProperties.forceStagging = kWardrobeContentForceStagging;
        lyProperties.forceEqualHeights = kWardrobeContentForceEqualHeights;
        lyProperties.allowMultipleSelection = kWardrobeContentAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"FeatureCell"] || [cellType isEqualToString:@"ProductCategoryCell"])
    {
        lyProperties.numberOfColumns = kFeatureNumberOfColumns;
        lyProperties.itemHeight = kFeatureItemHeight;
        lyProperties.itemWidth = kFeatureItemWidth;
        lyProperties.verticalSpacing = kFeatureVerticalSpacing;
        lyProperties.topInset = kFeatureTopInset;
        lyProperties.bottomInset = kFeatureBottomInset;
        lyProperties.sideInset = kFeatureSideInset;
        lyProperties.horizontalSpacing = kFeatureHorizontalSpacing;
        lyProperties.headerHeight = kFeatureHeaderHeight;
        lyProperties.footerHeight = kFeatureFooterHeight;
        lyProperties.headerAndFooterInset = kFeatureHeaderAndFooterInset;
        lyProperties.adjustTopInset = kFeatureAdjustTopInset;
        lyProperties.adjustBottomInset = kFeatureAdjustBottomInset;
        lyProperties.adjustSideInset = kFeatureAdjustSideInset;
        lyProperties.forceStagging = kFeatureForceStagging;
        lyProperties.forceEqualHeights = kFeatureForceEqualHeights;
        lyProperties.allowMultipleSelection = YES;//kFeatureAllowMultipleSelection;
    }
    
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        lyProperties.numberOfColumns = kSearchFeatureNumberOfColumns;
        lyProperties.itemHeight = kSearchFeatureItemHeight;
        lyProperties.itemWidth = kSearchFeatureItemWidth;
        lyProperties.verticalSpacing = kSearchFeatureVerticalSpacing;
        lyProperties.topInset = kSearchFeatureTopInset;
        lyProperties.bottomInset = kSearchFeatureBottomInset;
        lyProperties.sideInset = kSearchFeatureSideInset;
        lyProperties.horizontalSpacing = kSearchFeatureHorizontalSpacing;
        lyProperties.headerHeight = kSearchFeatureHeaderHeight;
        lyProperties.footerHeight = kSearchFeatureFooterHeight;
        lyProperties.headerAndFooterInset = kSearchFeatureHeaderAndFooterInset;
        lyProperties.adjustTopInset = kSearchFeatureAdjustTopInset;
        lyProperties.adjustBottomInset = kSearchFeatureAdjustBottomInset;
        lyProperties.adjustSideInset = kSearchFeatureAdjustSideInset;
        lyProperties.forceStagging = kSearchFeatureForceStagging;
        lyProperties.forceEqualHeights = kSearchFeatureForceEqualHeights;
        lyProperties.allowMultipleSelection = kSearchFeatureAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"PostCell"])
    {
        lyProperties.numberOfColumns = kPostNumberOfColumns;
        lyProperties.itemHeight = kPostItemHeight;
        lyProperties.itemWidth = kPostItemWidth;
        lyProperties.verticalSpacing = kPostVerticalSpacing;
        lyProperties.topInset = kPostTopInset;
        lyProperties.bottomInset = kPostBottomInset;
        lyProperties.sideInset = kPostSideInset;
        lyProperties.horizontalSpacing = kPostHorizontalSpacing;
        lyProperties.headerHeight = kPostHeaderHeight;
        lyProperties.footerHeight = kPostFooterHeight;
        lyProperties.headerAndFooterInset = kPostHeaderAndFooterInset;
        lyProperties.adjustTopInset = kPostAdjustTopInset;
        lyProperties.adjustBottomInset = kPostAdjustBottomInset;
        lyProperties.adjustSideInset = kPostAdjustSideInset;
        lyProperties.forceStagging = kPostForceStagging;
        lyProperties.forceEqualHeights = kPostForceEqualHeights;
        lyProperties.allowMultipleSelection = kPostAllowMultipleSelection;
    }
    else if ([cellType isEqualToString:@"PageCell"])
    {
        lyProperties.numberOfColumns = kPageNumberOfColumns;
        lyProperties.itemHeight = kPageItemHeight;
        lyProperties.itemWidth = kPageItemWidth;
        lyProperties.verticalSpacing = kPageVerticalSpacing;
        lyProperties.topInset = kPageTopInset;
        lyProperties.bottomInset = kPageBottomInset;
        lyProperties.sideInset = kPageSideInset;
        lyProperties.horizontalSpacing = kPageHorizontalSpacing;
        lyProperties.headerHeight = kPageHeaderHeight;
        lyProperties.footerHeight = kPageFooterHeight;
        lyProperties.headerAndFooterInset = kPageHeaderAndFooterInset;
        lyProperties.adjustTopInset = kPageAdjustTopInset;
        lyProperties.adjustBottomInset = kPageAdjustBottomInset;
        lyProperties.adjustSideInset = kPageAdjustSideInset;
        lyProperties.forceStagging = kPageForceStagging;
        lyProperties.forceEqualHeights = kPageForceEqualHeights;
        lyProperties.allowMultipleSelection = kPageAllowMultipleSelection;
    }
    
    
    return lyProperties;
}

//Init Layout properties for the given collection view
- (void) initLayoutforCollectionView:(UICollectionView *)collectionView
{
    // Setup Layout appearance
    layoutProperties lyProperties = [self getlayoutPropertiesForCellType:[self getCellTypeForCollectionView:collectionView]];

    UICollectionViewLayout * collectionViewLayout = [self getLayoutForCollectionView:collectionView];
    
    if (lyProperties.adjustTopInset || lyProperties.adjustBottomInset)
    {
        CGFloat topInset = ((lyProperties.adjustTopInset) ? (lyProperties.topInset) : (collectionView.contentInset.top));
        CGFloat bottomInset = ((lyProperties.adjustBottomInset) ? (lyProperties.bottomInset) : (collectionView.contentInset.bottom));
        CGFloat sideInset = collectionView.contentInset.left;
        if (IS_IPHONE_6)
        {
            sideInset = ((lyProperties.adjustSideInset) ? (lyProperties.sideInset) : (collectionView.contentInset.left));
        }
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(topInset, sideInset, bottomInset, sideInset);
        [collectionView setContentInset:edgeInsets];
    }
    
    [collectionView setAllowsMultipleSelection:lyProperties.allowMultipleSelection];
    
    if(!collectionViewLayout)
        return;
    
    CollectionViewCustomLayout * customCollectionViewLayout = (CollectionViewCustomLayout *)collectionViewLayout;
    
    [customCollectionViewLayout setSectionInset:UIEdgeInsetsMake(lyProperties.horizontalSpacing, lyProperties.verticalSpacing, lyProperties.horizontalSpacing, lyProperties.verticalSpacing)];
    
    [customCollectionViewLayout setNumberOfColumns:lyProperties.numberOfColumns];
    [customCollectionViewLayout setItemRenderDirection:CollectionViewCustomLayoutItemRenderDirectionShortestFirst];
    [customCollectionViewLayout setMinimumContentHeight:lyProperties.itemHeight];
    [customCollectionViewLayout setMinimumHorizontalSpacing:lyProperties.horizontalSpacing];
    [customCollectionViewLayout setMinimumVerticalSpacing:lyProperties.verticalSpacing];
    [customCollectionViewLayout setForceStagging:lyProperties.forceStagging];
    [customCollectionViewLayout setForceEqualHeights:lyProperties.forceEqualHeights];
    
    [customCollectionViewLayout setHeaderHeight:lyProperties.headerHeight];
    [customCollectionViewLayout setFooterHeight:lyProperties.footerHeight];
    [customCollectionViewLayout setHeaderInset:UIEdgeInsetsMake(lyProperties.headerAndFooterInset, lyProperties.headerAndFooterInset, lyProperties.headerAndFooterInset, lyProperties.headerAndFooterInset)];
    [customCollectionViewLayout setFooterInset:UIEdgeInsetsMake(lyProperties.headerAndFooterInset, lyProperties.headerAndFooterInset, lyProperties.headerAndFooterInset, lyProperties.headerAndFooterInset)];
}


#pragma mark - UICollectionViewDelegateCustomLayout

//Return Cell type
- (NSString*)getCellType:(UICollectionView*)collectionView {
    return [self getCellTypeForCollectionView:collectionView];
}

- (NSInteger)getAdNums:(UICollectionView *)collecionView {
    return [self getADcount];
}


// Size for a given cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ResultCell"])
    {
        resultCellLayout layout = [self getLayoutTypeForCellWithType:@"ResultCell" AtIndexPath:indexPath];
        
        CGSize rctSizeInitial = [self getSizeForImageInCellWithType:@"ResultCell" AtIndexPath:indexPath];
        
        if ((!(rctSizeInitial.height > 0)) || (!(rctSizeInitial.width > 0)))
        {
            if (layout == POSTLAYOUT)
            {
                return CGSizeMake(kResultItemWidth-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0)), (kResultItemWidth-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0)))*kResultCellPostLayoutAspectRatio);
            }
            else
            {
                return CGSizeMake(kResultItemWidth - (kResultCellBorderLeft + kResultCellBorderRight)-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0)), kResultItemHeight + ((layout == PRODUCTLAYOUT) * (kResultExtraBottomSpace + kResultSpaceBetweenCellImageAndCellTitles + kResultAdditionalHeightForPrice)) + kResultSpaceBetweenCellImageAndCellTitles + ((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (((layout == PRODUCTLAYOUT) ? (kResultAdditionalHeightForTitle) : (((layout == POSTLAYOUT) ? (kPostAdditionalHeightForTitle) : (kResultAdditionalHeightForTitle/2)))))));
            }
        }
        else
        {
            CGSize rctSizeFinal = CGSizeMake(rctSizeInitial.width,rctSizeInitial.width * kResultCellDefaultAspectRatio);
            
            CGFloat percentage = 0;
            
            CollectionViewCustomLayout * collectionViewLayout = [self getLayoutForCollectionView:collectionView];
            
            if (indexPath.section == 0 && (indexPath.item % ADNUM == ADNUM - 1)) {
                if (indexPath.item / ADNUM < [self getADcount]) {
                    double columnWidth = collectionView.bounds.size.width - [collectionViewLayout sectionInset].left - [collectionViewLayout sectionInset].right;
                    
                    double scale = columnWidth / rctSizeInitial.width;
                    
                    rctSizeFinal = CGSizeMake(rctSizeInitial.width * scale, rctSizeInitial.height * scale);
                    
                    return rctSizeFinal;
                }
            }
            
            if (!([collectionViewLayout forceEqualHeights]))
            {
                double columnWidth = ((collectionView.bounds.size.width - [collectionViewLayout sectionInset].left - [collectionViewLayout sectionInset].right) - (([collectionViewLayout numberOfColumns] - 1) * [collectionViewLayout minimumHorizontalSpacing]))/([collectionViewLayout numberOfColumns]);
                
                double scale = (columnWidth - ((layout == POSTLAYOUT) ? (0) : (kResultCellBorderLeft + kResultCellBorderRight))) / rctSizeInitial.width;
                
                rctSizeFinal = CGSizeMake(rctSizeInitial.width * scale,rctSizeInitial.height * scale);
                
                percentage = (([collectionViewLayout forceStagging]) ? ([collectionViewLayout.randomPercentages[(indexPath.section * 3 + indexPath.item) % 32] floatValue]) : (0));
            }
            
            rctSizeFinal.height = (rctSizeFinal.height * (1.0f + percentage));
            
            if (!(layout == POSTLAYOUT))
            {
                rctSizeFinal.height += (kResultSpaceBetweenCellImageAndCellTitles + ((layout == PRODUCTLAYOUT) * (kResultExtraBottomSpace + kResultSpaceBetweenCellImageAndCellTitles + kResultAdditionalHeightForPrice)) + kResultSpaceBetweenCellImageAndCellTitles + ((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (((layout == PRODUCTLAYOUT) ? (kResultAdditionalHeightForTitle) : (((layout == POSTLAYOUT) ? (kPostAdditionalHeightForTitle) : (kResultAdditionalHeightForTitle/2)))))));
            }
            
            return rctSizeFinal;
        }
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeContentCell"])
    {
        resultCellLayout layout = [self getLayoutTypeForCellWithType:@"WardrobeContentCell" AtIndexPath:indexPath];
        
        CGSize rctSizeInitial = [self getSizeForImageInCellWithType:@"WardrobeContentCell" AtIndexPath:indexPath];
        
        if ((!(rctSizeInitial.height > 0)) || (!(rctSizeInitial.width > 0)))
        {
            if (layout == POSTLAYOUT)
            {
                return CGSizeMake(kWardrobeContentItemWidth-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0)), (kWardrobeContentItemWidth-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0)))*kResultCellPostLayoutAspectRatio);
            }
            else
            {
                return CGSizeMake(kWardrobeContentItemWidth - (kWardrobeContentCellBorderLeft + kWardrobeContentCellBorderRight)-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0)), kWardrobeContentItemHeight + (((layout == PRODUCTLAYOUT) * (kWardrobeContentExtraBottomSpace + kWardrobeContentSpaceBetweenCellImageAndCellTitles + kWardrobeContentAdditionalHeightForPrice)) + kWardrobeContentSpaceBetweenCellImageAndCellTitles + ((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (kWardrobeContentAdditionalHeightForTitle))));
                //
                //            return CGSizeMake(kWardrobeContentItemWidth, kWardrobeContentItemHeight+kWardrobeContentAdditionalHeightForTitle + kWardrobeContentSpaceBetweenCellImageAndCellTitles + kWardrobeContentAdditionalHeightForPrice + kWardrobeContentSpaceBetweenCellImageAndCellTitles);
            }
        }
        else
        {
            CGSize rctSizeFinal = CGSizeMake(rctSizeInitial.width,rctSizeInitial.width * kWardrobeContentCellDefaultAspectRatio);
            
            CGFloat percentage = 0;
            
            CollectionViewCustomLayout * collectionViewLayout = [self getLayoutForCollectionView:collectionView];
            
            if (!([collectionViewLayout forceEqualHeights]))
            {
                double columnWidth = ((collectionView.bounds.size.width - [collectionViewLayout sectionInset].left - [collectionViewLayout sectionInset].right) - (([collectionViewLayout numberOfColumns] - 1) * [collectionViewLayout minimumHorizontalSpacing]))/([collectionViewLayout numberOfColumns]);
                
                double scale = (columnWidth - ((layout == POSTLAYOUT) ? (0) : (kWardrobeContentCellBorderLeft + kWardrobeContentCellBorderRight))) / rctSizeInitial.width;
                
                rctSizeFinal = CGSizeMake(rctSizeInitial.width * scale,rctSizeInitial.height * scale);
                
                percentage = (([collectionViewLayout forceStagging]) ? ([collectionViewLayout.randomPercentages[(indexPath.section * 3 + indexPath.item) % 32] floatValue]) : (0));
            }
            
            rctSizeFinal.height = (rctSizeFinal.height * (1.0f + percentage));

            
            if (!(layout == POSTLAYOUT))
            {
                rctSizeFinal.height += (kWardrobeContentSpaceBetweenCellImageAndCellTitles + ((layout == PRODUCTLAYOUT) * (kWardrobeContentExtraBottomSpace + kWardrobeContentSpaceBetweenCellImageAndCellTitles + kWardrobeContentAdditionalHeightForPrice)) + kWardrobeContentSpaceBetweenCellImageAndCellTitles + ((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (kWardrobeContentAdditionalHeightForTitle)));
                
                //            rctSizeFinal.height += (kWardrobeContentAdditionalHeightForTitle + kWardrobeContentSpaceBetweenCellImageAndCellTitles + kWardrobeContentAdditionalHeightForPrice + kWardrobeContentSpaceBetweenCellImageAndCellTitles);
            }
            
            return rctSizeFinal;
        }
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeCell"])
    {
        return CGSizeMake(kWardrobeItemWidth, kWardrobeItemHeight+kWardrobeAdditionalHeightForTitle + kWardrobeSpaceBetweenCellImageAndCellTitles);
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeBinCell"])
    {
        //CGSize rctSizeInitial = [self getSizeForImageInCellWithType:@"WardrobeBinCell" AtIndexPath:indexPath];
        
        //if ((!(rctSizeInitial.height > 0)) && (!(rctSizeInitial.width > 0)))
        //{
        //    return CGSizeMake(kWardrobeBinItemWidth, kWardrobeBinItemHeight+kWardrobeBinAdditionalHeightForTitle + kWardrobeBinSpaceBetweenCellImageAndCellTitles);
        //}
        //else
        //{
        //    if (rctSizeInitial.height > kWardrobeBinItemHeight)
        //    {
        CGSize rctSizeInitial = CGSizeMake(kWardrobeBinItemWidth, kWardrobeBinItemHeight);
        //    }
        
        CGSize rctSizeFinal = CGSizeMake(rctSizeInitial.width,rctSizeInitial.width * kWardrobeBinCellDefaultAspectRatio);
        
        CGFloat percentage = 0;
        
        CollectionViewCustomLayout * collectionViewLayout = [self getLayoutForCollectionView:collectionView];
        
        if (!([collectionViewLayout forceEqualHeights]))
        {
            double columnWidth = ((collectionView.bounds.size.width - [collectionViewLayout sectionInset].left - [collectionViewLayout sectionInset].right) - (([collectionViewLayout numberOfColumns] - 1) * [collectionViewLayout minimumHorizontalSpacing]))/([collectionViewLayout numberOfColumns]);
            
            double scale = (columnWidth - (kWardrobeBinCellBorderLeft + kWardrobeBinCellBorderRight)) / rctSizeInitial.width;
            
            rctSizeFinal = CGSizeMake(rctSizeInitial.width * scale,rctSizeInitial.height * scale);
            
            percentage = (([collectionViewLayout forceStagging]) ? ([collectionViewLayout.randomPercentages[(indexPath.section * 3 + indexPath.item) % 32] floatValue]) : (0));
        }
        
        rctSizeFinal.height = (rctSizeFinal.height * (1.0f + percentage));
        
        rctSizeFinal.height += (kWardrobeBinAdditionalHeightForTitle + kWardrobeBinSpaceBetweenCellImageAndCellTitles);
        
        return rctSizeFinal;
        //}
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ContentCell"])
    {
        return CGSizeMake(kContentItemWidth, kContentItemHeight-1);
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ReviewCell"])
    {
        return CGSizeMake(kReviewItemWidth, kReviewItemHeight);
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"CommentCell"])
    {
        return CGSizeMake(kCommentItemWidth, kCommentItemHeight);
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"NotificationCell"])
    {
        return CGSizeMake(kNotificationItemWidth, kNotificationItemHeight);
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"FeatureCell"] ||
             [[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ProductCategoryCell"])
    {
        //        CGSize size = [self getSizeForImageInCellWithType:[self getCellTypeForCollectionView:collectionView] AtIndexPath:indexPath];
        //        if (size.height == -1)
        if (self.parentViewController != nil)
        {
            if (self.parentViewController.parentViewController != nil )
            {
                return CGSizeMake(kFeatureItemWidthEmbeded, kFeatureItemHeightEmbeded);
            }
        }
        return CGSizeMake(kFeatureItemWidth, kFeatureItemHeight);
        //        else
        //            return CGSizeMake(kFeatureItemWidth, kFeatureItemHeightOnlyLabel);
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"SearchFeatureCell"])
    {
        //CGSize size = [self getSizeForImageInCellWithType:[self getCellTypeForCollectionView:collectionView] AtIndexPath:indexPath];
        //if (size.height == -1)
        return CGSizeMake(kSearchFeatureItemWidth, kSearchFeatureItemHeight);
        //else
        //  return CGSizeMake(kSearchFeatureItemWidth, kSearchFeatureItemHeightOnlyLabel);
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"PostCell"])
    {
        CGSize rctSizeInitial = [self getSizeForImageInCellWithType:@"PostCell" AtIndexPath:indexPath];
        
        if ((!(rctSizeInitial.height > 0)) || (!(rctSizeInitial.width > 0)))
        {
            return CGSizeMake(kPostItemWidth-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0)), (kPostItemWidth-((IS_IPHONE_6P) ? ((8/kResultNumberOfColumns)) : (0))) * 1.00);
        }
        else
        {
            CGSize rctSizeFinal = CGSizeMake(rctSizeInitial.width,rctSizeInitial.width * kPostCellDefaultAspectRatio);
            
            CGFloat percentage = 0;
            
            CollectionViewCustomLayout * collectionViewLayout = [self getLayoutForCollectionView:collectionView];
            
            if (!([collectionViewLayout forceEqualHeights]))
            {
                double columnWidth = ((collectionView.bounds.size.width - [collectionViewLayout sectionInset].left - [collectionViewLayout sectionInset].right) - (([collectionViewLayout numberOfColumns] - 1) * [collectionViewLayout minimumHorizontalSpacing]))/([collectionViewLayout numberOfColumns]);
                
                double scale = (columnWidth /*- (kPostCellBorderLeft + kPostCellBorderRight)*/) / rctSizeInitial.width;
                
                rctSizeFinal = CGSizeMake(rctSizeInitial.width * scale,MAX(rctSizeInitial.height * scale, kPostItemHeight));
                
                percentage = (([collectionViewLayout forceStagging]) ? ([collectionViewLayout.randomPercentages[(indexPath.section * 3 + indexPath.item) % 32] floatValue]) : (0));
            }
            
            rctSizeFinal.height = (rctSizeFinal.height * (1.0f + percentage));
            
            //rctSizeFinal.height += (kPostSpaceBetweenCellImageAndCellTitles + kPostAdditionalHeightForTitle);
            
            return rctSizeFinal;
        }
    }
    else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"PageCell"])
    {
        CGSize rctSizeInitial = [self getSizeForImageInCellWithType:@"PageCell" AtIndexPath:indexPath];
        
        if ((!(rctSizeInitial.height > 0)) || (!(rctSizeInitial.width > 0)))
        {
            return CGSizeMake(kPageItemWidth, kPageItemHeight + kPageSpaceBetweenCellImageAndCellTitles + kPageAdditionalHeightForTitle);
        }
        else
        {
            CGSize rctSizeFinal = CGSizeMake(rctSizeInitial.width,rctSizeInitial.width * kPageCellDefaultAspectRatio);
            
            CGFloat percentage = 0;
            
            CollectionViewCustomLayout * collectionViewLayout = [self getLayoutForCollectionView:collectionView];
            
            if (!([collectionViewLayout forceEqualHeights]))
            {
                double columnWidth = ((collectionView.bounds.size.width - [collectionViewLayout sectionInset].left - [collectionViewLayout sectionInset].right) - (([collectionViewLayout numberOfColumns] - 1) * [collectionViewLayout minimumHorizontalSpacing]))/([collectionViewLayout numberOfColumns]);
                
                double scale = (columnWidth - (kPageCellBorderLeft + kPageCellBorderRight)) / rctSizeInitial.width;
                
                rctSizeFinal = CGSizeMake(rctSizeInitial.width * scale,MAX(rctSizeInitial.height * scale, kPageItemHeight));
                
                percentage = (([collectionViewLayout forceStagging]) ? ([collectionViewLayout.randomPercentages[(indexPath.section * 3 + indexPath.item) % 32] floatValue]) : (0));
            }
            
            rctSizeFinal.height = (rctSizeFinal.height * (1.0f + percentage));
            
            rctSizeFinal.height += (kPageSpaceBetweenCellImageAndCellTitles + kPageAdditionalHeightForTitle);
            
            return rctSizeFinal;
        }
    }
    
    return CGSizeMake(0, 0);
}

- (BOOL)shouldShowDecorationInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
{
    BOOL bReturn = [self shouldShowDecorationViewForCollectionView:collectionView];
    
    return bReturn;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
    BOOL bShouldReportResults = [self shouldReportResultsforSection:(int)section];
    
    if (bShouldReportResults)
    {
        if([self numberOfSectionsForCollectionViewWithCellType:[self getCellTypeForCollectionView:collectionView]] > 1)
        {
            if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"SearchFeatureCell"])
            {
                return kSearchFeatureHeaderHeight;
            }
            
            if (!([[self getFetchedResultsControllerForCellType:[self getCellTypeForCollectionView:collectionView]] sections] == nil))
            {
                //Calculate the actual section in FetchedResultsController
                int frcSection = [self getFetchedResultsControllerSectionForSection:(int)section];
                
                if(frcSection >= 0)
                {
                    if (!([[self getFetchedResultsControllerForCellType:[self getCellTypeForCollectionView:collectionView]] sections] == nil))
                    {
                        if(!(([[[self getFetchedResultsControllerForCellType:[self getCellTypeForCollectionView:collectionView]] sections] count]) == 0))
                        {
                            if(!(frcSection > ([[[self getFetchedResultsControllerForCellType:[self getCellTypeForCollectionView:collectionView]] sections] count] - 1)))
                            {
                                if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ResultCell"])
                                {
                                    return kResultHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeContentCell"])
                                {
                                    return kWardrobeContentHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeCell"])
                                {
                                    return kWardrobeHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeBinCell"])
                                {
                                    return kWardrobeBinHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ContentCell"])
                                {
                                    return kContentHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ReviewCell"])
                                {
                                    return kReviewHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"CommentCell"])
                                {
                                    return kCommentHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"NotificationCell"])
                                {
                                    return kNotificationHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"FeatureCell"] ||
                                         [[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ProductCategoryCell"])
                                {
                                    return kFeatureHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"SearchFeatureCell"])
                                {
                                    return kSearchFeatureHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"PostCell"])
                                {
                                    return kPostHeaderHeight;
                                }
                                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"PageCell"])
                                {
                                    return kPageHeaderHeight;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
    if([self numberOfSectionsForCollectionViewWithCellType:[self getCellTypeForCollectionView:collectionView]] > 1)
    {
        if (!([[self getFetchedResultsControllerForCellType:[self getCellTypeForCollectionView:collectionView]] sections] == nil))
        {
            if(!(section > ([[[self getFetchedResultsControllerForCellType:[self getCellTypeForCollectionView:collectionView]] sections] count] - 1)))
            {
                if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ResultCell"])
                {
                    return kResultFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeContentCell"])
                {
                    return kWardrobeContentFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeCell"])
                {
                    return kWardrobeFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeBinCell"])
                {
                    return kWardrobeBinFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ContentCell"])
                {
                    return kContentFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ReviewCell"])
                {
                    return kReviewFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"CommentCell"])
                {
                    return kCommentFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"NotificationCell"])
                {
                    return kNotificationFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"FeatureCell"] ||
                         [[self getCellTypeForCollectionView:collectionView] isEqualToString:@"ProductCategoryCell"])
                {
                    return kFeatureFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"SearchFeatureCell"])
                {
                    return kSearchFeatureFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"PostCell"])
                {
                    return kPostFooterHeight;
                }
                else if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"PageCell"])
                {
                    return kPageFooterHeight;
                }
            }
        }
    }
    
    return 0;
}

// Delegate function: column width
//- (CGFloat)columnWidthForCollectionView:(UICollectionView *)collectionView
//{
//    return [[self getLayoutForCollectionView:collectionView] columnWidth];
//}

// Delegate function: number of columns
- (NSUInteger)numberOfColumnsForCollectionView:(UICollectionView *)collectionView
{
    if ([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeBinCell"])
    {
        return kWardrobeBinNumberOfColumns;
    }
    else
    {
        return [[self getLayoutForCollectionView:collectionView] numberOfColumns];
    }
}


#pragma mark – UICollectionViewDataSource


// Update collection view data
- (void)updateCollectionViewWithCellType:(NSString *)cellType fromItem:(int)startItem toItem:(int)endItem deleting:(BOOL)deleting
{
    UICollectionView *collectionView = [self getCollectionViewForCellType:cellType];
    
    //    if (startItem >= endItem)
    {
        [collectionView reloadData];
    }
    //    else
    //    {
    //        [collectionView performBatchUpdates:^{
    //
    //            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
    //
    //            for (int i = startItem; i < endItem; i++)
    //            {
    //                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    //            }
    //
    //            ((deleting) ? ([collectionView deleteItemsAtIndexPaths:arrayWithIndexPaths]) : ([collectionView insertItemsAtIndexPaths:arrayWithIndexPaths])); ;
    //        }
    //                                 completion:^(BOOL finished){
    //
    //                                     [collectionView reloadData];
    //
    //                                 }];
    //
    //    }
}

// Number of sections to be shown: as many as results given
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self numberOfSectionsForCollectionViewWithCellType:[self getCellTypeForCollectionView:collectionView]];
}

// Number of items in each section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self numberOfItemsInSection:section forCollectionViewWithCellType:[self getCellTypeForCollectionView:collectionView]];
    return [self numberOfItemsInSection:section forCollectionViewWithCellType:[self getCellTypeForCollectionView:collectionView]];
}

- (id) completeContentForCell:(id)currentCell forItemAtIndexPath:(NSIndexPath *)indexPath withType:(NSString *)cellType andContent:(NSArray *)cellContent andSize:(CGSize)rctSizeFinal
{
    CGRect buttonFrame = CGRectMake(0,0,0,0);
    
    if (([cellType isEqualToString:@"ResultCell"]) || ([cellType isEqualToString:@"WardrobeContentCell"]))
    {
        resultCellLayout layout = [self getLayoutTypeForCellWithType:cellType AtIndexPath:indexPath];

        if (!(cellContent == nil))
        {
            if ([cellContent count] > 1)
            {
                if(!([cellType isEqualToString:@"WardrobeContentCell"]))
                {
                    if ([[cellContent objectAtIndex:1] isKindOfClass:[NSNumber class]])
                    {
                        NSNumber *numberShowHangerOrHeart = [cellContent objectAtIndex:1];
                        if ([numberShowHangerOrHeart boolValue])
                        {
                            if ([cellContent count] > 2)
                            {
                                // Setup hanger or heart button
                                if ([[cellContent objectAtIndex:2] isKindOfClass:[NSNumber class]])
                                {
                                    if (layout == STYLISTLAYOUT)
                                    {
                                        buttonFrame = CGRectMake(rctSizeFinal.width-(kHeartWidth+kHeartHInset), kHeartVInset, kHeartWidth, kHeartHeight);
                                        
                                        [currentCell setupHeartButtonAtIndexPath:indexPath selected:[[cellContent objectAtIndex:2] boolValue] inFrame:buttonFrame];
                                        
                                        [[currentCell heartButton] addTarget:self action:@selector(onTapFollowButton:) forControlEvents:UIControlEventTouchUpInside];
                                    }
                                    else
                                    {
                                        if(layout == POSTLAYOUT)
                                        {
                                            buttonFrame = CGRectMake(rctSizeFinal.width-(kHangerWidth+kHangerHInset+10), kHangerVInset, kHangerWidth, kHangerHeight);
                                        }
                                        else
                                        {
                                            buttonFrame = CGRectMake(rctSizeFinal.width-(kHangerWidth+kHangerHInset), kHangerVInset, kHangerWidth, kHangerHeight);
                                        }
                                        
                                        [currentCell setupHangerButtonAtIndexPath:indexPath selected:[[cellContent objectAtIndex:2] boolValue] inFrame:buttonFrame];
                                        
                                        [[currentCell hangerButton] addTarget:self action:@selector(onTapAddToWardrobeButton:) forControlEvents:UIControlEventTouchUpInside];
                                    }
                                }
                            }
                        }
                    }
                }
                
                if ([cellContent count] > 3)
                {
                    // Setup Title
                    if ([[cellContent objectAtIndex:3] isKindOfClass:[NSString class]])
                    {
                        if(layout == POSTLAYOUT)
                        {
                            [currentCell setupTitleWithText:[cellContent objectAtIndex:3] forCellLayout:layout inFrame:CGRectMake(2,rctSizeFinal.height-(kResultAdditionalHeightForTitle/2)-kResultSpaceBetweenCellImageAndCellTitles, rctSizeFinal.width-4, (kResultAdditionalHeightForTitle/2))];
                        }
                        else
                        {
                            [currentCell setupTitleWithText:[cellContent objectAtIndex:3] forCellLayout:layout inFrame:CGRectMake(kResultCellBorderLeft,kResultCellBorderTop + ((layout == STYLISTLAYOUT) ? (kResultCellStylistExtraBorderTop-5) : (0)) + rctSizeFinal.height + kResultSpaceBetweenCellImageAndCellTitles,rctSizeFinal.width+0.5/*-kResultCellBorderLeft*//*-kResultCellBorderRight*/,((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (((layout == PRODUCTLAYOUT) ? (kResultAdditionalHeightForTitle) : (((layout == POSTLAYOUT) ? (kPostAdditionalHeightForTitle) : (kResultAdditionalHeightForTitle/2)))))))];
                        }
                    }
                    
                    if(layout == PRODUCTLAYOUT)
                    {
                        if ([cellContent count] > 4)
                        {
                            // Setup Price
                            if ([[cellContent objectAtIndex:4] isKindOfClass:[NSString class]])
                            {
                                [currentCell setupPriceWithValue:[cellContent objectAtIndex:4] andFrame:CGRectMake(kResultCellBorderLeft,kResultCellBorderTop + rctSizeFinal.height + kResultSpaceBetweenCellImageAndCellTitles + kResultAdditionalHeightForTitle,rctSizeFinal.width+0.5,kResultAdditionalHeightForPrice)];
                            }
                        }
                    }
                    else if (/*(layout == ARTICLELAYOUT) || (layout == TUTORIALLAYOUT) || (layout == REVIEWLAYOUT)*/ (layout == POSTLAYOUT) || (layout == PAGELAYOUT) || (layout == WARDROBELAYOUT))
                    {
                        if ([cellContent count] > 4)
                        {
                            // Setup Upper Title
                            if ([[cellContent objectAtIndex:4] isKindOfClass:[NSString class]])
                            {
                                if(layout == POSTLAYOUT)
                                {
                                    [currentCell setupUpperTitleWithText:[cellContent objectAtIndex:4] forCellLayout:layout inFrame:CGRectMake(2,rctSizeFinal.height-(kResultAdditionalHeightForTitle/2)-kResultSpaceBetweenCellImageAndCellTitles-(kResultAdditionalHeightForTitle/2)-kResultSpaceBetweenCellImageAndCellTitles, rctSizeFinal.width-4, (kResultAdditionalHeightForTitle/2))];
                                }
                                else
                                {
                                    [currentCell setupUpperTitleWithText:[cellContent objectAtIndex:4] forCellLayout:layout inFrame:CGRectMake(kResultCellBorderLeft,(kResultCellBorderTop + rctSizeFinal.height + kResultSpaceBetweenCellImageAndCellTitles)-(kResultAdditionalHeightForTitle/2),rctSizeFinal.width+0.5,(kResultAdditionalHeightForTitle/2))];
                                }
                            }
                            
                        }
                        
                        if(layout == POSTLAYOUT)
                        {
                            if ([cellContent count] > 6)
                            {
                                if ([[cellContent objectAtIndex:6] isKindOfClass:[NSNumber class]])
                                {
                                    CGRect infoFrame = CGRectMake(0, kHangerVInset, kHangerWidth, kHangerHeight);
                                    [currentCell setupNumImages:[cellContent objectAtIndex:6]  inFrame:infoFrame];
                                }
                                
                                if ([cellContent count] > 7)
                                {
                                    BOOL bImages = ([((NSNumber*)[cellContent objectAtIndex:6]) intValue] > 0);
                                    
                                    if ([[cellContent objectAtIndex:7] isKindOfClass:[NSNumber class]])
                                    {
                                        CGRect infoFrame = CGRectMake(0+(kHangerWidth*bImages), kHangerVInset, kHangerWidth, kHangerHeight);
                                        [currentCell setupNumLikes:[cellContent objectAtIndex:7]  inFrame:infoFrame];
                                        
                                    }
                                    
                                    BOOL bLikes = ([((NSNumber*)[cellContent objectAtIndex:7]) intValue] > 0);
                                    
                                    if ([cellContent count] > 8)
                                    {
                                        if ([[cellContent objectAtIndex:8] isKindOfClass:[NSNumber class]])
                                        {
                                            CGRect infoFrame = CGRectMake(0 + ((bImages+bLikes)*kHangerWidth), kHangerVInset, kHangerWidth, kHangerHeight);
                                            [currentCell setupNumComments:[cellContent objectAtIndex:8]  inFrame:infoFrame];
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if (layout == STYLISTLAYOUT)
                    {
                        if ([cellContent count] > 5)
                        {
                            if ([[cellContent objectAtIndex:5] isKindOfClass:[NSNumber class]])
                            {
                                if (((NSNumber *)[cellContent objectAtIndex:5]).boolValue)
                                {
                                    buttonFrame = CGRectMake(10+kHangerHInset, kHangerVInset, kHangerWidth, kHangerHeight);
                                    [currentCell setupVerifiedBadgeInFrame:buttonFrame];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if([cellType isEqualToString:@"WardrobeContentCell"])
        {
            int iState = 1;
            
            if (!(cellContent == nil))
            {
                if (((layout != POSTLAYOUT) && ([cellContent count] > 5)) || ((layout = POSTLAYOUT) && ([cellContent count] > 8)))
                {
                    if(layout == POSTLAYOUT)
                    {
                        if ([[cellContent objectAtIndex:8] isKindOfClass:[NSNumber class]])
                        {
                            NSNumber * number = [cellContent objectAtIndex:8];
                            iState = number.intValue;
                        }
                    }
                    else
                    {
                        if ([[cellContent objectAtIndex:5] isKindOfClass:[NSNumber class]])
                        {
                            NSNumber * number = [cellContent objectAtIndex:5];
                            iState = number.intValue;
                        }
                    }
                    
                    if(iState == 0)
                    {
                        // Setup view button
                        
                        buttonFrame = CGRectMake((2*kCreateViewMoveDeleteAddToButtonsInset)/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                        
                        [currentCell setupViewButtonAtIndexPath:indexPath inFrame:buttonFrame];
                        
                        [[currentCell viewButton] addTarget:self action:@selector(onTapView:) forControlEvents:UIControlEventTouchUpInside];
                        
                        // Setup move button
                        
                        buttonFrame = CGRectMake((2*kCreateViewMoveDeleteAddToButtonsInset)/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2)+(kCreateViewMoveDeleteAddToButtonsInset+kCreateViewMoveDeleteAddToButtonsHeight), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                        
                        [currentCell setupMoveButtonAtIndexPath:indexPath inFrame:buttonFrame];
                        
                        [[currentCell moveButton] addTarget:self action:@selector(onTapMoveWardrobeElement:) forControlEvents:UIControlEventTouchUpInside];
                        
                        // Setup delete button
                        
                        buttonFrame = CGRectMake((2*kCreateViewMoveDeleteAddToButtonsInset)/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2)+((kCreateViewMoveDeleteAddToButtonsInset+kCreateViewMoveDeleteAddToButtonsHeight)*2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                        
                        [currentCell setupDeleteButtonAtIndexPath:indexPath inFrame:buttonFrame];
                        
                        [[currentCell deleteButton] addTarget:self action:@selector(onTapDelete:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if(iState == 1)
                    {
                        // Hmmm nothing to do?
                        buttonFrame = CGRectMake(rctSizeFinal.width-(kHangerWidth+kHangerHInset), kHangerVInset, kHangerWidth, kHangerHeight);
                    
                        [currentCell setupHangerButtonAtIndexPath:indexPath selected:[[cellContent objectAtIndex:2] boolValue] inFrame:buttonFrame];
                    
                        [[currentCell hangerButton] addTarget:self action:@selector(onTapAddToWardrobeButton:) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"WardrobeCell"])
    {
        int iState = 1;
        
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * number = [cellContent objectAtIndex:0];
                    iState = number.intValue;
                }
                
                if(iState >= 1)
                {
                    if([cellContent count] > 2)
                    {
                        // Setup Title
                        if ([[cellContent objectAtIndex:2] isKindOfClass:[NSString class]])
                        {
                            // Setup edit wardrobe title button
                            
                            
                            //                            (kWardrobeItemWidth, kWardrobeItemHeight+kWardrobeAdditionalHeightForTitle + kWardrobeSpaceBetweenCellImageAndCellTitles
                            //
                            //
                            //                            CGRectMake(kResultCellBorderLeft,kResultCellBorderTop + rctSizeFinal.height + kResultSpaceBetweenCellImageAndCellTitles,rctSizeFinal.width-kResultCellBorderLeft-kResultCellBorderRight,((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (kResultAdditionalHeightForTitle)))
                            
                            buttonFrame = CGRectMake(kWardrobeCellBorderLeft, ( (IS_IPHONE_6P) ? (rctSizeFinal.height - kWardrobeCellBorderTop - kWardrobeCellBorderBottom - kWardrobeSpaceBetweenCellImageAndCellTitles) : (kResultCellBorderTop + rctSizeFinal.height + kResultSpaceBetweenCellImageAndCellTitles) ), rctSizeFinal.width-(((IS_IPHONE_6P) ? (2) : (1))*(kWardrobeCellBorderLeft+kWardrobeCellBorderRight)), kWardrobeAdditionalHeightForTitle);
                            
                            [currentCell setupEditWardrobeTitleButtonWithTitle:[cellContent objectAtIndex:2] atIndexPath:indexPath inFrame:buttonFrame];
                            
                            [[currentCell editWardrobeTitleButton] addTarget:self action:@selector(onTapEditWardrobeTitle:) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                }
            }
        }
        
        switch (iState)
        {
            case 0:
            {
                // Setup create new wardrobe button
                
                //                buttonFrame = CGRectMake(rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset), ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 1) + (kCreateViewMoveDeleteAddToButtonsInset * 0))) / 2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                buttonFrame = CGRectMake(kWardrobeCellBorderLeft, kWardrobeCellBorderTop, rctSizeFinal.width-kWardrobeCellBorderLeft-kWardrobeCellBorderRight, rctSizeFinal.height+kWardrobeAdditionalHeightForTitle-kWardrobeCellBorderBottom-kWardrobeCellBorderTop);
                
                
                [currentCell setupCreateNewElementButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell createNewElementButton] addTarget:self action:@selector(onTapCreateNewElement:) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
            case 1:
            {
                // Setup view button
                
                CGRect buttonFrame = CGRectMake(rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+(2*kCreateViewMoveDeleteAddToButtonsInset)), ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 2) + (kCreateViewMoveDeleteAddToButtonsInset * 1))) / 2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupViewButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell viewButton] addTarget:self action:@selector(onTapView:) forControlEvents:UIControlEventTouchUpInside];
                
                // Setup delete button
                
                buttonFrame = CGRectMake(rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+(2*kCreateViewMoveDeleteAddToButtonsInset)), ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 2) + (kCreateViewMoveDeleteAddToButtonsInset * 1))) / 2)+((kCreateViewMoveDeleteAddToButtonsInset+kCreateViewMoveDeleteAddToButtonsHeight)*1), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupDeleteButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell deleteButton] addTarget:self action:@selector(onTapDelete:) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
            case 2:
            {
                // Setup create new wardrobe button
                
                buttonFrame = CGRectMake(rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset), ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 1) + (kCreateViewMoveDeleteAddToButtonsInset * 0))) / 2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupAddBinContentToWardrobeButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell addBinContentToWardrobeButton] addTarget:self action:@selector(onTapAddBinContentToWardrobe:) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
            default:
                break;
        }
    }
    else if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 1)
            {
                // Setup Title
                if ([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                {
                    [currentCell setupTitleWithText:[cellContent objectAtIndex:1] forCellLayout:maxResultCellLayouts inFrame:CGRectMake(kWardrobeBinCellBorderLeft,kWardrobeBinCellBorderTop + rctSizeFinal.height,rctSizeFinal.width,kWardrobeBinAdditionalHeightForTitle)];
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"ContentCell"])
    {
        
    }
    else if ([cellType isEqualToString:@"ReviewCell"])
    {
        ReviewCell * currentReviewCell = (ReviewCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 1)
            {
                // Setup User Name
                if ([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                {
                    NSString * userName = [cellContent objectAtIndex:1];
                    [currentReviewCell.userName setText:userName];
                }
                
                if ([cellContent count] > 2)
                {
                    // Setup User Location
                    if ([[cellContent objectAtIndex:2] isKindOfClass:[NSString class]])
                    {
                        NSString * userLocation = [cellContent objectAtIndex:2];
                        [currentReviewCell.userLocation setText:userLocation];
                    }
                    
                    if ([cellContent count] > 3)
                    {
                        // Setup Review Text
                        if ([[cellContent objectAtIndex:3] isKindOfClass:[NSString class]])
                        {
                            NSString * reviewText = [cellContent objectAtIndex:3];
                            [currentReviewCell.reviewStr setText:reviewText];
                        }
                        
                        if ([cellContent count] > 4)
                        {
                            // Setup Ratings
                            if ([[cellContent objectAtIndex:4] isKindOfClass:[NSNumber class]])
                            {
                                NSNumber * rating = [cellContent objectAtIndex:4];
                                [currentReviewCell.overallRateView setRating:[rating floatValue]];
                            }
                            
                            if ([cellContent count] > 5)
                            {
                                if ([[cellContent objectAtIndex:5] isKindOfClass:[NSNumber class]])
                                {
                                    NSNumber * rating = [cellContent objectAtIndex:5];
                                    [currentReviewCell.comfortRateView setRating:[rating floatValue]];
                                }
                                
                                if ([cellContent count] > 6)
                                {
                                    if ([[cellContent objectAtIndex:6] isKindOfClass:[NSNumber class]])
                                    {
                                        NSNumber * rating = [cellContent objectAtIndex:6];
                                        [currentReviewCell.qualityRateView setRating:[rating floatValue]];
                                    }
                                    
                                    if ([cellContent count] > 7)
                                    {
                                        if ([[cellContent objectAtIndex:7] isKindOfClass:[NSString class]])
                                        {
                                            [currentReviewCell setVideoURL: [cellContent objectAtIndex:7] andIndex:indexPath.item];
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
    else if ([cellType isEqualToString:@"CommentCell"])
    {
        CommentCell * currentCommentCell = (CommentCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 1)
            {
                // Setup User Name
                if ([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                {
                    NSString * userName = [cellContent objectAtIndex:1];
                    [currentCommentCell.userName setText:userName];
                }
                
                if ([cellContent count] > 2)
                {
                    // Setup User Location
                    if ([[cellContent objectAtIndex:2] isKindOfClass:[NSString class]])
                    {
                        NSString * userLocation = [cellContent objectAtIndex:2];
                        [currentCommentCell.userLocation setText:userLocation];
                    }
                    
                    if ([cellContent count] > 3)
                    {
                        // Setup Review Text
                        if ([[cellContent objectAtIndex:3] isKindOfClass:[NSString class]])
                        {
                            NSString * reviewText = [cellContent objectAtIndex:3];
                            [currentCommentCell.commentStr setText:reviewText];
                            [currentCommentCell.commentStr scrollRangeToVisible:NSMakeRange(0, 1)];
                        }
                        
                        if ([cellContent count] > 4)
                        {
                            // Setup Video Review
                            if ([[cellContent objectAtIndex:4] isKindOfClass:[NSString class]])
                            {
                                [currentCommentCell setVideoURL: [cellContent objectAtIndex:4] andIndex:indexPath.item];
                            }
                        }
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"NotificationCell"])
    {
        NotificationCell * currentNotificationCell = (NotificationCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 1)
            {
                // Setup Type
                if ([[cellContent objectAtIndex:1] isKindOfClass:[NSAttributedString class]])
                {
//                    NSString * notificationType = [cellContent objectAtIndex:1];
//                    [currentNotificationCell.notificationType setText:notificationType];
                    NSAttributedString * notificationType = [cellContent objectAtIndex:1];
                    [currentNotificationCell.notificationType setAttributedText:notificationType];
                }
                
                if ([cellContent count] > 2)
                {
                    // Setup Date
                    if ([[cellContent objectAtIndex:2] isKindOfClass:[NSString class]])
                    {
                        NSString * notificationDate = [cellContent objectAtIndex:2];
                        [currentNotificationCell.notificationDate setText:notificationDate];
                    }
                    
                    if ([cellContent count] > 3)
                    {
//                        // Setup Text
//                        if ([[cellContent objectAtIndex:3] isKindOfClass:[NSAttributedString class]])
//                        {
//                            NSAttributedString * notificationMessage = [cellContent objectAtIndex:3];
//                            [currentNotificationCell.notificationMessage setAttributedText:notificationMessage];
//                        }
//                        
//                        if ([cellContent count] > 4)
//                        {
                            // Setup Follow button
                            if ([[cellContent objectAtIndex:3] isKindOfClass:[NSNumber class]])
                            {
                                [currentNotificationCell setupFollowButtonAtIndexPath:indexPath selected:[[cellContent objectAtIndex:3] boolValue]];
                                
                                [[currentNotificationCell actionButton] addTarget:self action:@selector(onTapActionButton:) forControlEvents:UIControlEventTouchUpInside];
//                            }
                        }
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"FeatureCell"] || [cellType isEqualToString:@"ProductCategoryCell"])
    {
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 3)
            {
                // Setup zoom button
                if ([[cellContent objectAtIndex:3] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * numberValue = (NSNumber *)[cellContent objectAtIndex:3];
                    BOOL bShowZoomButton = [numberValue boolValue];
                    if (bShowZoomButton)
                    {
//                        buttonFrame = CGRectMake(rctSizeFinal.width-(kSearchFeatureZoomWidth+kSearchFeatureZoomInset), kSearchFeatureZoomInset, kSearchFeatureZoomWidth, kSearchFeatureZoomHeight);
                        buttonFrame = CGRectMake((kFeatureZoomInset), rctSizeFinal.height-(kFeatureZoomHeight+kFeatureZoomInset), kFeatureZoomWidth, kFeatureZoomHeight);
                        
                        [currentCell setupZoomButtonAtIndexPath:indexPath inFrame:buttonFrame];
                        
                        [[currentCell zoomButton] addTarget:self action:@selector(onTapFeatureZoomButton:) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
            }
        }
        
    }
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 3)
            {
                // Setup zoom button
                if ([[cellContent objectAtIndex:3] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * numberValue = (NSNumber *)[cellContent objectAtIndex:3];
                    BOOL bShowZoomButton = [numberValue boolValue];
                    if (bShowZoomButton)
                    {
//                        buttonFrame = CGRectMake(rctSizeFinal.width-(kHangerWidth+kHangerInset), kHangerInset, kHangerWidth, kHangerHeight);
//                        buttonFrame = CGRectMake((kSearchFeatureZoomInset), rctSizeFinal.height-(kSearchFeatureZoomHeight+kSearchFeatureZoomInset+(kSearchFeatureVerticalSpacing/2.0)), kSearchFeatureZoomWidth, kSearchFeatureZoomHeight);
                        buttonFrame = CGRectMake(rctSizeFinal.width - kSearchFeatureZoomWidth - kSearchFeatureZoomInset -(kSearchFeatureHorizontalSpacing/2.0) ,kSearchFeatureZoomInset, kSearchFeatureZoomWidth, kSearchFeatureZoomHeight);
                        
                        [currentCell setupZoomButtonAtIndexPath:indexPath inFrame:buttonFrame];
                        [[currentCell zoomButton] addTarget:self action:@selector(onTapFeatureZoomButton:) forControlEvents:UIControlEventTouchUpInside];
                        if ([cellContent count] > 4)
                        {
                            NSNumber * numberValue = (NSNumber *)[cellContent objectAtIndex:4];
                            BOOL bShowExpandButton = [numberValue boolValue];
                            if (bShowExpandButton)
                            {
                                // for the expand button the frame is the frame of featureViewLabel used, not this one
                                buttonFrame = CGRectMake(rctSizeFinal.width - kSearchFeatureExpandWidth - kSearchFeatureZoomInset -(kSearchFeatureHorizontalSpacing/2.0) ,kSearchFeatureZoomInset, kSearchFeatureExpandWidth, kSearchFeatureExpandHeight);
                                
                                [currentCell setupExpandButtonAtIndexPath:indexPath inFrame:buttonFrame expanded:(numberValue.intValue > 1)];
                                [[currentCell expandButton] addTarget:self action:@selector(onTapFeatureExpandButton:) forControlEvents:UIControlEventTouchUpInside];
                            }
                        }
                        
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"PostCell"])
    {
        int iState = 1;
        
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * number = [cellContent objectAtIndex:0];
                    iState = number.intValue;
                }
                
                if(iState >= 1)
                {
                    if([cellContent count] > 2)
                    {
                        if ([[cellContent objectAtIndex:2] isKindOfClass:[NSNumber class]])
                        {
                            if([[cellContent objectAtIndex:2] boolValue] == YES)
                            {
                                if([cellContent count] > 3)
                                {
                                    // Setup hanger button
                                    if ([[cellContent objectAtIndex:3] isKindOfClass:[NSNumber class]])
                                    {
                                        buttonFrame = CGRectMake(rctSizeFinal.width-(kHangerWidth+kHangerHInset+10), kHangerVInset, kHangerWidth, kHangerHeight);
                                        
                                        [currentCell setupHangerButtonAtIndexPath:indexPath selected:[[cellContent objectAtIndex:3] boolValue] inFrame:buttonFrame];
                                        
                                        [[currentCell hangerButton] addTarget:self action:@selector(onTapAddToWardrobeButton:) forControlEvents:UIControlEventTouchUpInside];
                                    }
                                }
                            }
                            
                        }
                        
                        if ([cellContent count] > 4)
                        {
                            // Setup Title
                            if ([[cellContent objectAtIndex:4] isKindOfClass:[NSString class]])
                            {
                                [currentCell setupTitleWithText:[cellContent objectAtIndex:4] forCellLayout:POSTLAYOUT inFrame:CGRectMake(2,rctSizeFinal.height-(kResultAdditionalHeightForTitle/2)-kResultSpaceBetweenCellImageAndCellTitles, rctSizeFinal.width-4, (kResultAdditionalHeightForTitle/2))];
                            }
                            
                            if ([cellContent count] > 5)
                            {
                                // Setup Upper Title
                                if ([[cellContent objectAtIndex:5] isKindOfClass:[NSString class]])
                                {
                                    [currentCell setupUpperTitleWithText:[cellContent objectAtIndex:5] forCellLayout:POSTLAYOUT inFrame:CGRectMake(2,rctSizeFinal.height-(kResultAdditionalHeightForTitle/2)-kResultSpaceBetweenCellImageAndCellTitles-(kResultAdditionalHeightForTitle/2)-kResultSpaceBetweenCellImageAndCellTitles, rctSizeFinal.width-4, (kResultAdditionalHeightForTitle/2))];
                                }
                                
                                if ([cellContent count] > 6)
                                {
                                    if ([[cellContent objectAtIndex:6] isKindOfClass:[NSNumber class]])
                                    {
                                        CGRect infoFrame = CGRectMake(0, kHangerVInset, kHangerWidth, kHangerHeight);
                                        [currentCell setupNumImages:[cellContent objectAtIndex:6]  inFrame:infoFrame];
                                    }
                                    
                                    if ([cellContent count] > 7)
                                    {
                                        BOOL bImages = ([((NSNumber*)[cellContent objectAtIndex:6]) intValue] > 0);

                                        if ([[cellContent objectAtIndex:7] isKindOfClass:[NSNumber class]])
                                        {
                                            CGRect infoFrame = CGRectMake(0+(kHangerWidth*bImages), kHangerVInset, kHangerWidth, kHangerHeight);
                                            [currentCell setupNumLikes:[cellContent objectAtIndex:7]  inFrame:infoFrame];

                                        }
                                        
                                        BOOL bLikes = ([((NSNumber*)[cellContent objectAtIndex:7]) intValue] > 0);
                                        
                                        if ([cellContent count] > 8)
                                        {
                                            if ([[cellContent objectAtIndex:8] isKindOfClass:[NSNumber class]])
                                            {
                                                CGRect infoFrame = CGRectMake(0 + ((bImages+bLikes)*kHangerWidth), kHangerVInset, kHangerWidth, kHangerHeight);
                                                [currentCell setupNumComments:[cellContent objectAtIndex:8]  inFrame:infoFrame];
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
        
        switch (iState)
        {
            case 0:
            {
                // Setup create new post button
                
                buttonFrame = CGRectMake(kPostCellBorderLeft, kPostCellBorderTop, rctSizeFinal.width-kPostCellBorderLeft-kPostCellBorderRight, rctSizeFinal.height-kPostAdditionalHeightForTitle-kPostCellBorderBottom-kPostCellBorderTop);
                
                [currentCell setupCreateNewElementButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell createNewElementButton] addTarget:self action:@selector(onTapCreateNewElement:) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
            case 2:
            {
                // Setup view button
                
                CGRect buttonFrame = CGRectMake(kCreateViewMoveDeleteAddToButtonsInset+(kCreateViewMoveDeleteAddToButtonsInset)/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupViewButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell viewButton] addTarget:self action:@selector(onTapView:) forControlEvents:UIControlEventTouchUpInside];
                
                // Setup edit button
                
                buttonFrame = CGRectMake(kCreateViewMoveDeleteAddToButtonsInset+(kCreateViewMoveDeleteAddToButtonsInset)/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2)+(kCreateViewMoveDeleteAddToButtonsInset+kCreateViewMoveDeleteAddToButtonsHeight), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupEditButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell editButton] addTarget:self action:@selector(onTapEditElement:) forControlEvents:UIControlEventTouchUpInside];
                
                // Setup delete button
                
                buttonFrame = CGRectMake(kCreateViewMoveDeleteAddToButtonsInset+(kCreateViewMoveDeleteAddToButtonsInset)/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2)+((kCreateViewMoveDeleteAddToButtonsInset+kCreateViewMoveDeleteAddToButtonsHeight)*2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupDeleteButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell deleteButton] addTarget:self action:@selector(onTapDelete:) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
                
            case 1:
            default:
                break;
        }
    }
    else if ([cellType isEqualToString:@"PageCell"])
    {
        int iState = 1;
        
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * number = [cellContent objectAtIndex:0];
                    iState = number.intValue;
                }
                
                if(iState >= 1)
                {
                    if([cellContent count] > 2)
                    {
                        if ([[cellContent objectAtIndex:2] isKindOfClass:[NSNumber class]])
                        {
                            if([[cellContent objectAtIndex:2] boolValue] == YES)
                            {
                                if([cellContent count] > 3)
                                {
                                    // Setup hanger button
                                    if ([[cellContent objectAtIndex:3] isKindOfClass:[NSNumber class]])
                                    {
                                        buttonFrame = CGRectMake(rctSizeFinal.width-(kHangerWidth+kHangerHInset), kHangerVInset, kHangerWidth, kHangerHeight);
                                        
                                        [currentCell setupHangerButtonAtIndexPath:indexPath selected:[[cellContent objectAtIndex:3] boolValue] inFrame:buttonFrame];
                                        
                                        [[currentCell hangerButton] addTarget:self action:@selector(onTapAddToWardrobeButton:) forControlEvents:UIControlEventTouchUpInside];
                                    }
                                }
                            }
                        }
                        
                        if ([cellContent count] > 4)
                        {
                            // Setup Title
                            if ([[cellContent objectAtIndex:4] isKindOfClass:[NSString class]])
                            {
                                [currentCell setupTitleWithText:[cellContent objectAtIndex:4] forCellLayout:PAGELAYOUT inFrame:CGRectMake(kPageCellBorderLeft,kPageCellBorderTop + rctSizeFinal.height + kPageSpaceBetweenCellImageAndCellTitles,rctSizeFinal.width-kPageCellBorderLeft-kPageCellBorderRight,kPageAdditionalHeightForTitle)];
                            }
                            
                            if ([cellContent count] > 5)
                            {
                                // Setup Upper Title
                                if ([[cellContent objectAtIndex:5] isKindOfClass:[NSString class]])
                                {
                                    [currentCell setupUpperTitleWithText:[cellContent objectAtIndex:4] forCellLayout:PAGELAYOUT inFrame:CGRectMake(kPageCellBorderLeft,(kPageCellBorderTop + rctSizeFinal.height + kPageSpaceBetweenCellImageAndCellTitles)-kPageAdditionalHeightForTitle,rctSizeFinal.width,kPageAdditionalHeightForTitle)];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        switch (iState)
        {
            case 0:
            {
                // Setup create new post button
                
                buttonFrame = CGRectMake(kPageCellBorderLeft, kPageCellBorderTop, rctSizeFinal.width-kPageCellBorderLeft-kPageCellBorderRight, rctSizeFinal.height+kPageAdditionalHeightForTitle-kPageCellBorderBottom-kWardrobeCellBorderTop);
                
                [currentCell setupCreateNewElementButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell createNewElementButton] addTarget:self action:@selector(onTapCreateNewElement:) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
            case 2:
            {
                // Setup view button
                
                CGRect buttonFrame = CGRectMake(kCreateViewMoveDeleteAddToButtonsInset/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupViewButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell viewButton] addTarget:self action:@selector(onTapView:) forControlEvents:UIControlEventTouchUpInside];
                
                // Setup edit button
                
                buttonFrame = CGRectMake(kCreateViewMoveDeleteAddToButtonsInset/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2)+(kCreateViewMoveDeleteAddToButtonsInset+kCreateViewMoveDeleteAddToButtonsHeight), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupEditButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell editButton] addTarget:self action:@selector(onTapEditElement:) forControlEvents:UIControlEventTouchUpInside];
                
                // Setup delete button
                
                buttonFrame = CGRectMake(kCreateViewMoveDeleteAddToButtonsInset/*rctSizeFinal.width-(kCreateViewMoveDeleteAddToButtonsWidth+kCreateViewMoveDeleteAddToButtonsInset)*/, ((rctSizeFinal.height - ((kCreateViewMoveDeleteAddToButtonsHeight * 3) + (kCreateViewMoveDeleteAddToButtonsInset * 2))) / 2)+((kCreateViewMoveDeleteAddToButtonsInset+kCreateViewMoveDeleteAddToButtonsHeight)*2), kCreateViewMoveDeleteAddToButtonsWidth, kCreateViewMoveDeleteAddToButtonsHeight);
                
                [currentCell setupDeleteButtonAtIndexPath:indexPath inFrame:buttonFrame];
                
                [[currentCell deleteButton] addTarget:self action:@selector(onTapDelete:) forControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
                
            case 1:
            default:
                break;
        }
    }
    
    return currentCell;
}

- (id) setupContentForCell:(id)currentCell forItemAtIndexPath:(NSIndexPath *)indexPath withType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"ResultCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f] andBorderColor:[UIColor clearColor] andBorderWith:0.0f andShadowColor:[UIColor clearColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        if (!(cellContent == nil))
        {
            resultCellLayout layout = [self getLayoutTypeForCellWithType:@"ResultCell" AtIndexPath:indexPath];
            
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            if (indexPath.section == 0 && (indexPath.item % ADNUM == ADNUM - 1)) {
                if (indexPath.item / ADNUM < [self getADcount]) {
                    
                }
                else {
                    if(!(layout == POSTLAYOUT))
                    {
                        rctSizeFinal.height -= (((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (((layout == PRODUCTLAYOUT) ? (kResultAdditionalHeightForTitle) : (((layout == POSTLAYOUT) ? (kPostAdditionalHeightForTitle) : (kResultAdditionalHeightForTitle/2)))))) + kResultSpaceBetweenCellImageAndCellTitles  + ((layout == PRODUCTLAYOUT) * (kResultExtraBottomSpace + kResultSpaceBetweenCellImageAndCellTitles + kResultAdditionalHeightForPrice)) + kResultSpaceBetweenCellImageAndCellTitles);
                    }
                }
            }
            else {
                if(!(layout == POSTLAYOUT))
                {
                    rctSizeFinal.height -= (((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (((layout == PRODUCTLAYOUT) ? (kResultAdditionalHeightForTitle) : (((layout == POSTLAYOUT) ? (kPostAdditionalHeightForTitle) : (kResultAdditionalHeightForTitle/2)))))) + kResultSpaceBetweenCellImageAndCellTitles  + ((layout == PRODUCTLAYOUT) * (kResultExtraBottomSpace + kResultSpaceBetweenCellImageAndCellTitles + kResultAdditionalHeightForPrice)) + kResultSpaceBetweenCellImageAndCellTitles);
                }
            }
            
            if([cellContent count] > 0)
            {
                [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([UIImage isCached:[cellContent objectAtIndex:0]])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"no_image.png"];
                        }
                        
                        CGRect frame = CGRectZero;
                        
                        if(layout == POSTLAYOUT)
                        {
                            frame = CGRectMake(2,2,rctSizeFinal.width-4,rctSizeFinal.height-4);
                        }
                        else
                        {
                            frame = CGRectMake(kResultCellBorderLeft,kResultCellBorderTop + ((layout == STYLISTLAYOUT) ? (kResultCellStylistExtraBorderTop) : (0)) ,rctSizeFinal.width,rctSizeFinal.height);
                        }
                        
                        [currentCell setupImageWithImage:image andFrame:frame forCellLayout:layout];
                        
                        //                        [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    }
                    else
                    {
                        // Load cell contents in the background
                        
                        __weak BaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"no_image.png"];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                
                                if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                {
                                    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                    
                                    currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                    
                                    CGRect frame = CGRectZero;
                                    
                                    if(layout == POSTLAYOUT)
                                    {
                                        frame = CGRectMake(2,2,rctSizeFinal.width-4,rctSizeFinal.height-4);
                                    }
                                    else
                                    {
                                        frame = CGRectMake(kResultCellBorderLeft,kResultCellBorderTop + ((layout == STYLISTLAYOUT) ? (kResultCellStylistExtraBorderTop) : (0)) ,rctSizeFinal.width,rctSizeFinal.height);
                                    }

                                    if (indexPath.section == 0 && (indexPath.item % ADNUM == ADNUM - 1)) {
                                        if (indexPath.item / ADNUM < [self getADcount]) {
                                            frame.origin.x = 0;
                                            frame.origin.y = 0;
                                        }
                                    }
                                    [currentCell setupImageWithImage:image andFrame:frame forCellLayout:layout];
                                    
                                    //                                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.imagesQueue addOperation:operation];
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
    }
    else if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f] andBorderColor:[UIColor clearColor] andBorderWith:0.0f andShadowColor:[UIColor clearColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        resultCellLayout layout = [self getLayoutTypeForCellWithType:@"WardrobeContentCell" AtIndexPath:indexPath];
        
        __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
        
        if(!(layout == POSTLAYOUT))
        {
            rctSizeFinal.height -= (((layout == PRODUCTLAYOUT) * (kWardrobeContentExtraBottomSpace + kWardrobeContentSpaceBetweenCellImageAndCellTitles + kWardrobeContentAdditionalHeightForPrice)) + kWardrobeContentSpaceBetweenCellImageAndCellTitles + ((layout == WARDROBELAYOUT) ? (kWardrobeAdditionalHeightForTitle) : (kWardrobeContentAdditionalHeightForTitle)));
            
            //            rctSizeFinal.height -= (kWardrobeContentAdditionalHeightForTitle + kWardrobeContentSpaceBetweenCellImageAndCellTitles + kWardrobeContentAdditionalHeightForPrice + kWardrobeContentSpaceBetweenCellImageAndCellTitles);
        }
        
        if (!(cellContent == nil))
        {
            if ([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([UIImage isCached:[cellContent objectAtIndex:0]])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"no_image.png"];
                        }
                        
                        CGRect frame = CGRectZero;
                        
                        if(layout == POSTLAYOUT)
                        {
                            frame = CGRectMake(2,2,rctSizeFinal.width-4,rctSizeFinal.height-4);
                        }
                        else
                        {
                            frame = CGRectMake(kWardrobeContentCellBorderLeft,kWardrobeContentCellBorderTop,rctSizeFinal.width,rctSizeFinal.height);
                        }
                        
                        [currentCell setupImageWithImage:image andFrame:frame forCellLayout:layout];
                        
                        //                        [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    }
                    else
                    {
                        // Load cell contents in the background
                        
                        __weak BaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"no_image.png"];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                
                                if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                {
                                    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                    
                                    currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                    
                                    CGRect frame = CGRectZero;
                                    
                                    if(layout == POSTLAYOUT)
                                    {
                                        frame = CGRectMake(2,2,rctSizeFinal.width-4,rctSizeFinal.height-4);
                                    }
                                    else
                                    {
                                        frame = CGRectMake(kWardrobeContentCellBorderLeft,kWardrobeContentCellBorderTop,rctSizeFinal.width,rctSizeFinal.height);
                                    }
                                    
                                    [currentCell setupImageWithImage:image andFrame:frame forCellLayout:layout];
                                    
                                    //                                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.imagesQueue addOperation:operation];
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
        
        [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
    }
    else if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f] andBorderColor:[UIColor clearColor] andBorderWith:0.0f andShadowColor:[UIColor clearColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        if (!(cellContent == nil))
        {
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            rctSizeFinal.height -= (kWardrobeBinAdditionalHeightForTitle + kWardrobeBinSpaceBetweenCellImageAndCellTitles);
            
            if([cellContent count] > 0)
            {
                [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([UIImage isCached:[cellContent objectAtIndex:0]])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"no_image.png"];
                        }
                        
                        [currentCell setupImageWithImage:image andFrame:CGRectMake(kWardrobeBinCellBorderLeft,kWardrobeBinCellBorderTop,rctSizeFinal.width,rctSizeFinal.height) forCellLayout:maxResultCellLayouts];
                        
                        //                        [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    }
                    else
                    {
                        // Load cell contents in the background
                        
                        __weak BaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"no_image.png"];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                
                                if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                {
                                    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                    
                                    currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                    
                                    [currentCell setupImageWithImage:image andFrame:CGRectMake(kWardrobeBinCellBorderLeft,kWardrobeBinCellBorderTop,rctSizeFinal.width,rctSizeFinal.height) forCellLayout:maxResultCellLayouts];
                                    
                                    //                                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.imagesQueue addOperation:operation];
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
    }
    else if ([cellType isEqualToString:@"WardrobeCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f] andBorderColor:[UIColor clearColor] andBorderWith:0.0f andShadowColor:[UIColor clearColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
        
        rctSizeFinal.height -= (kWardrobeAdditionalHeightForTitle + kWardrobeSpaceBetweenCellImageAndCellTitles);
        
        if (!(cellContent == nil))
        {
            int iState = 1;
            
            if ([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * number = [cellContent objectAtIndex:0];
                    iState = number.intValue;
                }
                
                if(iState >= 1)
                {
                    if ([cellContent count] > 1)
                    {
                        if (!([cellContent objectAtIndex:1] == nil))
                        {
                            // Setup Image
                            if ([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                            {
                                if ([UIImage isCached:[cellContent objectAtIndex:1]])
                                {
                                    UIImage * image = [UIImage cachedImageWithURL/*ForceReload*/:[cellContent objectAtIndex:1]];
                                    
                                    if(image == nil)
                                    {
                                        image = [UIImage imageNamed:@"no_image.png"];
                                    }
                                    
                                    [currentCell setupImageWithImage:image andFrame:CGRectMake(kWardrobeCellBorderLeft,kWardrobeCellBorderTop,rctSizeFinal.width-(((IS_IPHONE_6P) ? (2) : (1))*(kWardrobeCellBorderLeft+kWardrobeCellBorderRight)),rctSizeFinal.height) forCellLayout:maxResultCellLayouts];
                                    
                                    //                                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                                else
                                {
                                    // Load cell contents in the background
                                    
                                    __weak BaseViewController *weakSelf = self;
                                    
                                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                        
                                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:1]];
                                        
                                        if(image == nil)
                                        {
                                            image = [UIImage imageNamed:@"no_image.png"];
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            // Then set them via the main queue if the cell is still visible.
                                            UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                            
                                            if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                            {
                                                id newCurrentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                                
                                                newCurrentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                                
                                                [newCurrentCell setupImageWithImage:image andFrame:CGRectMake(kWardrobeCellBorderLeft,kWardrobeCellBorderTop,rctSizeFinal.width-(((IS_IPHONE_6P) ? (2) : (1))*(kWardrobeCellBorderLeft+kWardrobeCellBorderRight)),rctSizeFinal.height) forCellLayout:maxResultCellLayouts];
                                                
                                                //                                                /self completeContentForCell:newCurrentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                            }
                                        });
                                    }];
                                    
                                    operation.queuePriority = NSOperationQueuePriorityHigh;
                                    
                                    [self.imagesQueue addOperation:operation];
                                }
                            }
                        }
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
        
        [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
    }
    else if ([cellType isEqualToString:@"ContentCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor clearColor] andBorderColor:[UIColor grayColor] andBorderWith:0.5f andShadowColor:[UIColor grayColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        if (!(cellContent == nil))
        {
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            if([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([UIImage isCached:[cellContent objectAtIndex:0]])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"no_image.png"];
                        }
                        
                        [currentCell setupImageWithImage:image andFrame:CGRectMake(kContentCellBorderLeft,kContentCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                    }
                    else
                    {
                        // Load cell contents in the background
                        
                        __weak BaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"no_image.png"];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                
                                if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                {
                                    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                    
                                    currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                    
                                    [currentCell setupImageWithImage:image andFrame:CGRectMake(kContentCellBorderLeft,kContentCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                                }
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.imagesQueue addOperation:operation];
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"ReviewCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor whiteColor] andBorderColor:[UIColor whiteColor] andBorderWith:0.0f andShadowColor:[UIColor whiteColor] andImageContentMode:UIViewContentModeScaleAspectFit];
        
        // Contents: 0. Profile image, 1. User name, 2. User location, 3. Review text, 4. Review overall rating, 5. Review comfort rating, 6. Review quality rating
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        ReviewCell * currentReviewCell = (ReviewCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            if ([cellContent count] > 0)
            {
                [self completeContentForCell:currentReviewCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                
                
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([UIImage isCached:[cellContent objectAtIndex:0]])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"portrait.png"];
                        }
                        
                        [currentReviewCell.userPic setImage:image];
                        
                        
                        
                        //                        [self completeContentForCell:currentReviewCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    }
                    else
                    {
                        // Load cell contents in the background
                        
                        __weak BaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"portrait.png"];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                
                                if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                {
                                    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                    
                                    currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                    
                                    ReviewCell * currentReviewCell = (ReviewCell*)currentCell;
                                    
                                    [currentReviewCell.userPic setImage:image];
                                    
                                    //                                    [self completeContentForCell:currentReviewCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.imagesQueue addOperation:operation];
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentReviewCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
    }
    else if ([cellType isEqualToString:@"CommentCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor whiteColor] andBorderColor:[UIColor whiteColor] andBorderWith:0.0f andShadowColor:[UIColor whiteColor] andImageContentMode:UIViewContentModeScaleAspectFit];
        
        // Contents: 0. Profile image, 1. User name, 2. User location, 3. Review text, 4. Review Video
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        CommentCell * currentCommentCell = (CommentCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            if ([cellContent count] > 0)
            {
                [self completeContentForCell:currentCommentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                
                
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([UIImage isCached:[cellContent objectAtIndex:0]])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"portrait.png"];
                        }
                        
                        [currentCommentCell.userPic setImage:image];
                        
                        
                        
                        //                        [self completeContentForCell:currentCommentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    }
                    else
                    {
                        // Load cell contents in the background
                        
                        __weak BaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"portrait.png"];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                
                                if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                {
                                    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                    
                                    currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                    
                                    CommentCell * currentCommentCell = (CommentCell*)currentCell;
                                    
                                    [currentCommentCell.userPic setImage:image];
                                    
                                    //                                    [self completeContentForCell:currentCommentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.imagesQueue addOperation:operation];
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentCommentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
    }
    else if ([cellType isEqualToString:@"NotificationCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor whiteColor] andBorderColor:[UIColor whiteColor] andBorderWith:0.0f andShadowColor:[UIColor whiteColor] andImageContentMode:UIViewContentModeScaleAspectFit];
        
        // Contents: 0. Profile image, 1. User name, 2. User location, 3. Review text, 4. Review Video
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        NotificationCell * currentNotificationCell = (NotificationCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            if ([cellContent count] > 0)
            {
                [self completeContentForCell:currentNotificationCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                
                
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([UIImage isCached:[cellContent objectAtIndex:0]])
                    {
                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                        
                        if(image == nil)
                        {
                            image = [UIImage imageNamed:@"portrait.png"];
                        }
                        
                        [currentNotificationCell setupNotificationIconWithImage:image];
                        
                        //                        [self completeContentForCell:currentNotificationCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    }
                    else
                    {
                        // Load cell contents in the background
                        
                        __weak BaseViewController *weakSelf = self;
                        
                        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                            
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"portrait.png"];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // Then set them via the main queue if the cell is still visible.
                                UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                
                                if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                {
                                    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                    
                                    currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                    
                                    NotificationCell * currentNotificationCell = (NotificationCell*)currentCell;
                                    
                                    [currentNotificationCell setupNotificationIconWithImage:image];
                                    
                                    //                                    [self completeContentForCell:currentNotificationCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                            });
                        }];
                        
                        operation.queuePriority = NSOperationQueuePriorityHigh;
                        
                        [self.imagesQueue addOperation:operation];
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentNotificationCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
    }
    else if ([cellType isEqualToString:@"FeatureCell"] || [cellType isEqualToString:@"ProductCategoryCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor whiteColor] andBorderColor:[UIColor grayColor] andBorderWith:0.5f andShadowColor:[UIColor grayColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        FeatureCell * currentFeatureCell = (FeatureCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            if(cellContent.count < 3)
            {
                return currentCell;
            }
            
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            if (rctSizeFinal.height == kFeatureItemHeightOnlyLabel)
            {
                if([cellContent count] > 0)
                {
                    [self completeContentForCell:currentFeatureCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    
                    if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                    {
                        NSString * label = @"-";
                        UIColor * labelBackgroundColor = [UIColor clearColor];
                        
                        if ([cellContent count] > 1)
                        {
                            if([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                            {
                                label = [cellContent objectAtIndex:1];
                            }
                            
                            if([cellContent count] > 2)
                            {
                                if([[cellContent objectAtIndex:2] isKindOfClass:[UIColor class]])
                                {
                                    labelBackgroundColor = [cellContent objectAtIndex:2];
                                }
                            }
                        }
                        [currentFeatureCell setupImageWithImage:nil andLabel:label andLabelBackgroundColor:labelBackgroundColor andFrame:CGRectMake(kFeatureCellBorderLeft,kFeatureCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                    }
                }
            }
            else
            {
                if([cellContent count] > 0)
                {
                    [self completeContentForCell:currentFeatureCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    
                    if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                    {
                        if ([UIImage isCached:[cellContent objectAtIndex:0]])
                        {
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"addkw.png"];
                            }
                            
                            NSString * label = @"-";
                            UIColor * labelBackgroundColor = [UIColor clearColor];
                            
                            if ([cellContent count] > 1)
                            {
                                if([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                                {
                                    label = [cellContent objectAtIndex:1];
                                }
                                
                                if([cellContent count] > 2)
                                {
                                    if([[cellContent objectAtIndex:2] isKindOfClass:[UIColor class]])
                                    {
                                        labelBackgroundColor = [cellContent objectAtIndex:2];
                                    }
                                }
                            }
                            
                            [currentFeatureCell setupImageWithImage:image andLabel:label andLabelBackgroundColor:labelBackgroundColor andFrame:CGRectMake(kFeatureCellBorderLeft,kFeatureCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                        }
                        else
                        {
                            // Load cell contents in the background
                            
                            __weak BaseViewController *weakSelf = self;
                            
                            NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
                                UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                                
                                if(image == nil)
                                {
                                    image = [UIImage imageNamed:@"addkw.png"];
                                    
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSString * key = [cellContent objectAtIndex:0];
                                    NSOperation * currentOperation = [operationsLoadImages valueForKey:key];
                                    
                                    if (currentOperation != nil)
                                    {
                                        if (currentOperation.isCancelled == NO)
                                        {
                                            // Then set them via the main queue if the cell is still visible.
                                            UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                            
                                            if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                            {
                                                id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                                
                                                currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                                
                                                FeatureCell* currentFeatureCell = (FeatureCell*)currentCell;
                                                
                                                NSString * label = @"-";
                                                UIColor * labelBackgroundColor = [UIColor clearColor];
                                                
                                                if ([cellContent count] > 1)
                                                {
                                                    if([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                                                    {
                                                        label = [cellContent objectAtIndex:1];
                                                    }
                                                    
                                                    if([cellContent count] > 2)
                                                    {
                                                        if([[cellContent objectAtIndex:2] isKindOfClass:[UIColor class]])
                                                        {
                                                            labelBackgroundColor = [cellContent objectAtIndex:2];
                                                        }
                                                    }
                                                }
                                                
                                                [currentFeatureCell setupImageWithImage:image andLabel:label andLabelBackgroundColor:labelBackgroundColor andFrame:CGRectMake(kFeatureCellBorderLeft,kFeatureCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                                            }
                                        }
                                        else
                                        {
                                            NSLog(@"Image Queue Operation getMainQueue %@ Cancelled", currentOperation);
                                        }
                                    }
                                    else
                                    {
                                        NSLog(@"Image Queue Operation Not found. %@", key);
                                    }
                                });
                            }];
                            
                            operation.queuePriority = NSOperationQueuePriorityHigh;
                            
                            [operationsLoadImages setValue:operation forKey:[cellContent objectAtIndex:0]];
                            
                            [self.imagesQueue addOperation:operation];
                        }
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        // Setup general appearance
        //        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"FiltersRibbonButtonBackground.png"]] andBorderColor:[UIColor grayColor] andBorderWith:0.5f andShadowColor:[UIColor grayColor]];
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor whiteColor] andBorderColor:[UIColor clearColor] andBorderWith:0.0f andShadowColor:[UIColor grayColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        SearchFeatureCell * currentFeatureCell = (SearchFeatureCell*)currentCell;
        
        if (!(cellContent == nil))
        {
            if(cellContent.count < 3)
            {
                return currentCell;
            }
            
            __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
            
            if (rctSizeFinal.height == kSearchFeatureItemHeightOnlyLabel)
            {
                if([cellContent count] > 0)
                {
                    [self completeContentForCell:currentFeatureCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    
                    if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                    {
                        NSString * label = @"-";
                        UIColor * labelBackgroundColor = [UIColor whiteColor];
                        
                        
                        if ([cellContent count] > 1)
                        {
                            if([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                            {
                                label = [cellContent objectAtIndex:1];
                            }
                            
                            if([cellContent count] > 2)
                            {
                                if([[cellContent objectAtIndex:2] isKindOfClass:[UIColor class]])
                                {
                                    labelBackgroundColor = [cellContent objectAtIndex:2];
                                }
                            }
                        }
                        [currentFeatureCell setupImageWithImage:nil andLabel:label andLabelBackgroundColor:labelBackgroundColor andFrame:CGRectMake(kSearchFeatureCellBorderLeft,kSearchFeatureCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                    }
                }
            }
            else
            {
                if([cellContent count] > 0)
                {
                    [self completeContentForCell:currentFeatureCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                    
                    if ([[cellContent objectAtIndex:0] isKindOfClass:[NSString class]])
                    {
                        NSString * sImage = [cellContent objectAtIndex:0];
                        
                        if (([UIImage isCached:[cellContent objectAtIndex:0]]) || ([sImage isEqualToString:@"no_image.png"]))
                        {
                            UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                            
                            if(image == nil)
                            {
                                image = [UIImage imageNamed:@"addkw.png"];
                            }
                            
                            NSString * label = @"-";
                            UIColor * labelBackgroundColor = [UIColor whiteColor];
                            
                            if ([cellContent count] > 1)
                            {
                                if([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                                {
                                    label = [cellContent objectAtIndex:1];
                                }
                                
                                if([cellContent count] > 2)
                                {
                                    if([[cellContent objectAtIndex:2] isKindOfClass:[UIColor class]])
                                    {
                                        labelBackgroundColor = [cellContent objectAtIndex:2];
                                    }
                                }
                            }
                            
                            [currentFeatureCell setupImageWithImage:image andLabel:label andLabelBackgroundColor:labelBackgroundColor andFrame:CGRectMake(kSearchFeatureCellBorderLeft,kSearchFeatureCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                        }
                        else
                        {
                            // Load cell contents in the background
                            
                            __weak BaseViewController *weakSelf = self;
                            
                            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                
                                //UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0]];
                                NSURL *noImageFileURL = [[NSBundle mainBundle] URLForResource: @"addkw" withExtension:@"png"];
                                UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:0] withNoImageFileURL:noImageFileURL];
                                
                                if(image == nil)
                                {
                                    image = [UIImage imageNamed:@"addkw.png"];
                                    
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSString * key = [cellContent objectAtIndex:0];
                                    NSOperation * currentOperation = [operationsLoadImages valueForKey:key];
                                    
                                    if (currentOperation != nil)
                                    {
                                        if (currentOperation.isCancelled == NO)
                                        {
                                            // Then set them via the main queue if the cell is still visible.
                                            UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                            
                                            if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                            {
                                                id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                                
                                                currentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                                
                                                FeatureCell* currentFeatureCell = (FeatureCell*)currentCell;
                                                
                                                NSString * label = @"-";
                                                UIColor * labelBackgroundColor = [UIColor whiteColor];
                                                
                                                if ([cellContent count] > 1)
                                                {
                                                    if([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                                                    {
                                                        label = [cellContent objectAtIndex:1];
                                                    }
                                                    
                                                    if([cellContent count] > 2)
                                                    {
                                                        if([[cellContent objectAtIndex:2] isKindOfClass:[UIColor class]])
                                                        {
                                                            labelBackgroundColor = [cellContent objectAtIndex:2];
                                                        }
                                                    }
                                                }
                                                
                                                [currentFeatureCell setupImageWithImage:image andLabel:label andLabelBackgroundColor:labelBackgroundColor andFrame:CGRectMake(kSearchFeatureCellBorderLeft,kSearchFeatureCellBorderTop,rctSizeFinal.width,rctSizeFinal.height-1)];
                                            }
                                        }
                                        else
                                        {
                                            NSLog(@"Image Queue Operation getMainQueue %@ Cancelled", currentOperation);
                                        }
                                    }
                                    else
                                    {
                                        NSLog(@"Image Queue Operation Not found. %@", key);
                                    }
                                    
                                });
                            }];
                            
                            operation.queuePriority = NSOperationQueuePriorityHigh;
                            
                            [operationsLoadImages setValue:operation forKey:[cellContent objectAtIndex:0]];
                            
                            [self.imagesQueue addOperation:operation];
                        }
                    }
                }
            }
        }
    }
    else if ([cellType isEqualToString:@"PostCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f] andBorderColor:[UIColor clearColor] andBorderWith:0.0f andShadowColor:[UIColor clearColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
        
        //rctSizeFinal.height -= (kPostAdditionalHeightForTitle + kPostSpaceBetweenCellImageAndCellTitles);
        
        if (!(cellContent == nil))
        {
            int iState = 1;
            
            if ([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * number = [cellContent objectAtIndex:0];
                    iState = number.intValue;
                }
                
                if(iState >= 1)
                {
                    if ([cellContent count] > 1)
                    {
                        if (!([cellContent objectAtIndex:1] == nil))
                        {
                            // Setup Image
                            if ([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                            {
                                if ([UIImage isCached:[cellContent objectAtIndex:1]])
                                {
                                    UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:1]];
                                    
                                    if(image == nil)
                                    {
                                        image = [UIImage imageNamed:@"no_image.png"];
                                    }
                                    
//                                    [currentCell setupImageWithImage:image andFrame:CGRectMake(kPostCellBorderLeft,kPostCellBorderTop,rctSizeFinal.width,rctSizeFinal.height) forCellLayout:maxResultCellLayouts];

                                    [currentCell setupImageWithImage:image andFrame:CGRectMake(2,2,rctSizeFinal.width-4,rctSizeFinal.height-4) forCellLayout:maxResultCellLayouts];

                                    //                                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                                else
                                {
                                    // Load cell contents in the background
                                    
                                    __weak BaseViewController *weakSelf = self;
                                    
                                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                        
                                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:1]];
                                        
                                        if(image == nil)
                                        {
                                            image = [UIImage imageNamed:@"no_image.png"];
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            // Then set them via the main queue if the cell is still visible.
                                            UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                            
                                            if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                            {
                                                id newCurrentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                                
                                                newCurrentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                                
//                                                [newCurrentCell setupImageWithImage:image andFrame:CGRectMake(kPostCellBorderLeft,kPostCellBorderTop,rctSizeFinal.width,rctSizeFinal.height) forCellLayout:maxResultCellLayouts];
                                                
                                                [newCurrentCell setupImageWithImage:image andFrame:CGRectMake(2,2,rctSizeFinal.width-4,rctSizeFinal.height-4) forCellLayout:maxResultCellLayouts];
                                                
                                                //                                                self completeContentForCell:newCurrentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                            }
                                        });
                                    }];
                                    
                                    operation.queuePriority = NSOperationQueuePriorityHigh;
                                    
                                    [self.imagesQueue addOperation:operation];
                                }
                            }
                        }
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
        
        [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
    }
    else if ([cellType isEqualToString:@"PageCell"])
    {
        // Setup general appearance
        [currentCell setAppearanceForCellOfType:cellType withBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f] andBorderColor:[UIColor clearColor] andBorderWith:0.0f andShadowColor:[UIColor clearColor]];
        
        NSArray * cellContent= [self getContentForCellWithType:cellType AtIndexPath:indexPath];
        
        __block CGSize rctSizeFinal = [self collectionView:[self getCollectionViewForCellType:cellType] layout:[self getLayoutForCollectionView:[self getCollectionViewForCellType:cellType]] sizeForItemAtIndexPath:indexPath];
        
        rctSizeFinal.height -= (kPageAdditionalHeightForTitle + kPageSpaceBetweenCellImageAndCellTitles);
        
        if (!(cellContent == nil))
        {
            int iState = 1;
            
            if ([cellContent count] > 0)
            {
                if ([[cellContent objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    NSNumber * number = [cellContent objectAtIndex:0];
                    iState = number.intValue;
                }
                
                if(iState >= 1)
                {
                    if ([cellContent count] > 1)
                    {
                        if (!([cellContent objectAtIndex:1] == nil))
                        {
                            // Setup Image
                            if ([[cellContent objectAtIndex:1] isKindOfClass:[NSString class]])
                            {
                                if ([UIImage isCached:[cellContent objectAtIndex:1]])
                                {
                                    UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:1]];
                                    
                                    if(image == nil)
                                    {
                                        image = [UIImage imageNamed:@"no_image.png"];
                                    }
                                    
                                    [currentCell setupImageWithImage:image andFrame:CGRectMake(kPageCellBorderLeft,kPageCellBorderTop,rctSizeFinal.width,rctSizeFinal.height) forCellLayout:maxResultCellLayouts];
                                    
                                    //                                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                }
                                else
                                {
                                    // Load cell contents in the background
                                    
                                    __weak BaseViewController *weakSelf = self;
                                    
                                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                        
                                        UIImage * image = [UIImage cachedImageWithURL:[cellContent objectAtIndex:1]];
                                        
                                        if(image == nil)
                                        {
                                            image = [UIImage imageNamed:@"no_image.png"];
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            // Then set them via the main queue if the cell is still visible.
                                            UICollectionView *collectionView = [weakSelf getCollectionViewForCellType:cellType];
                                            
                                            if ([collectionView.indexPathsForVisibleItems containsObject:indexPath])
                                            {
                                                id newCurrentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
                                                
                                                newCurrentCell = [collectionView cellForItemAtIndexPath:indexPath];
                                                
                                                [newCurrentCell setupImageWithImage:image andFrame:CGRectMake(kPageCellBorderLeft,kPageCellBorderTop,rctSizeFinal.width,rctSizeFinal.height) forCellLayout:maxResultCellLayouts];
                                                
                                                //                                                self completeContentForCell:newCurrentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                                            }
                                        });
                                    }];
                                    
                                    operation.queuePriority = NSOperationQueuePriorityHigh;
                                    
                                    [self.imagesQueue addOperation:operation];
                                }
                            }
                        }
                    }
                }
                //                else
                //                {
                //                    [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
                //                }
            }
        }
        
        [self completeContentForCell:currentCell forItemAtIndexPath:indexPath withType:cellType andContent:cellContent andSize:rctSizeFinal];
    }
    
    
    return currentCell;
}

// Return the cell filled with its content
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id currentCell = [[NSClassFromString([self getCellTypeForCollectionView:collectionView]) alloc] init];
    
    currentCell = [collectionView dequeueReusableCellWithReuseIdentifier:[self getCellTypeForCollectionView:collectionView] forIndexPath:indexPath];
    
    [self setupContentForCell:currentCell forItemAtIndexPath:indexPath withType:[self getCellTypeForCollectionView:collectionView]];
    
    return currentCell;
}

// Return the header title
- (id) setupContentForHeader:(id)currentHeader atIndexPath:(NSIndexPath *)indexPath withType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"ResultCell"])
    {
        NSString * headerTitle = [self getHeaderTitleForCellWithType:cellType AtIndexPath:indexPath];
        
        if (!(headerTitle == nil))
        {
            if(!([headerTitle isEqualToString:@""]))
            {
                [currentHeader setHeaderTitleText:headerTitle];
            }
        }
    }
    else if ([cellType isEqualToString:@"SearchFeatureCell"])
    {
        NSString * headerTitle = [self getHeaderTitleForCellWithType:cellType AtIndexPath:indexPath];
        [currentHeader setupSearchFeatureCellHeader:headerTitle];
    }
    
    return currentHeader;
}

// Return the footer (has no content)
- (id) setupContentForFooter:(id)currentFooter atIndexPath:(NSIndexPath *)indexPath withType:(NSString *)cellType
{
    return currentFooter;
}

// Return the reusable view filled with its content
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    id reusableView = nil;
    
    if ([kind isEqualToString:CollectionViewCustomLayoutElementKindTopDecorationView])
    {
        reusableView = (CollectionViewDecorationReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                              withReuseIdentifier:@"CollectionViewCustomLayoutElementKindTopDecorationView"
                                                                                                     forIndexPath:indexPath];
//        [self setupContentForHeader:reusableView atIndexPath:indexPath  withType:[self getCellTypeForCollectionView:collectionView]];
    }
    else if ([kind isEqualToString:CollectionViewCustomLayoutElementKindSectionHeader])
    {
        reusableView = (CollectionViewHeaderReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                              withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionHeader"
                                                                                                     forIndexPath:indexPath];
        
        [self setupContentForHeader:reusableView atIndexPath:indexPath  withType:[self getCellTypeForCollectionView:collectionView]];
    }
    else if ([kind isEqualToString:CollectionViewCustomLayoutElementKindSectionFooter])
    {
        reusableView = (CollectionViewFooterReusableView *) [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                               withReuseIdentifier:@"CollectionViewCustomLayoutElementKindSectionFooter"
                                                                                                      forIndexPath:indexPath];
        
        [self setupContentForFooter:reusableView atIndexPath:indexPath  withType:[self getCellTypeForCollectionView:collectionView]];
    }
    
    return reusableView;
}

// Action to perform if an item in a collection is selected
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self actionForSelectionOfCellWithType:[self getCellTypeForCollectionView:collectionView] AtIndexPath:indexPath];
    
    // Perform multiple selection only for "WardrobeBinCell", so otherwise deselect the cell
//    if (!([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeBinCell"]))
//    {
//        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    }
    
    return;
}

// Action to perform if an item in a collection is deselected
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform multiple selection only for "WardrobeBinCell", so deselection only makes sense when working with that ckind of cell
    if (([[self getCellTypeForCollectionView:collectionView] isEqualToString:@"WardrobeBinCell"]))
    {
        [self actionForDeselectionOfCellWithType:[self getCellTypeForCollectionView:collectionView] AtIndexPath:indexPath];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

// Scroll MainCollectionView to top
- (void)scrollMainCollectionViewToTop
{
    [self.mainCollectionView setContentOffset: CGPointMake(0, -self.mainCollectionView.contentInset.top) animated:YES];
}

// Action to perform if the user press the 'Hanger' button on a ResultsCell
- (void)onTapAddToWardrobeButton:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Heart' button on a NotificationsCell
- (void)onTapActionButton:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Heart' button on a ResultsCell (STYLISTSLAYOUT)
- (void)onTapFollowButton:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Zoom' button on a FeatureCell or ProductCategoryCell
- (void)onTapFeatureZoomButton:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Expand' button on a searchFeatureCell
- (void)onTapFeatureExpandButton:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}


// Action to perform if the user press the 'View' button on a WardrobeContentCell
- (void)onTapView:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Move' button on a WardrobeContentCell
- (void)onTapMoveWardrobeElement:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Edit' button on a PostCell
- (void)onTapEditElement:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Delete' button on a WardrobeContentCell
- (void)onTapDelete:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'CreateNewWardrobe' button on a WardrobeContentCell
- (void)onTapCreateNewElement:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Delete' button on a WardrobeContentCell
- (void)onTapEditWardrobeTitle:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if the user press the 'Delete' button on a WardrobeContentCell
- (void)onTapAddBinContentToWardrobe:(UIButton *)sender
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

//Calculate the actual section in FetchedResultsController based on the Result Groups
- (int) getFetchedResultsControllerSectionForSection:(int) section
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");

    return section;
}

// Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return 1;
}

// Number of items in each section for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return 0;
}

// Return the layout to be shown in a cell for a collection view
- (resultCellLayout)getLayoutTypeForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return PRODUCTLAYOUT;
}

// Return the size of the image to be shown in a cell for a collection view
- (CGSize)getSizeForImageInCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return CGSizeMake(0, 0);
}

// Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return nil;
}

// Return if the collection view should show decoration view
- (BOOL)shouldShowDecorationViewForCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return NO;
}

// Return if the first section is empty and it should, therefore, be notified to the user
- (BOOL)shouldReportResultsforSection:(int)section
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return NO;
}

// Return the title to be shown in section header for a collection view
- (NSString *)getHeaderTitleForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    return nil;
}

// Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

// Action to perform if an item in a collection view is deselected
- (void)actionForDeselectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"XXXX This is an abstract method and should be overridden XXXX");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_COULDNOTPERFORMACTION_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    return;
}

@end
