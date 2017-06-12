//
//  BaseViewController+StoryboardManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 16/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import <objc/runtime.h>

#import "SearchBaseViewController.h"
#import "ProductSheetViewController.h"
#import "ProductFeatureSearchViewController.h"
#import "FashionistaPostViewController.h"
#import "WardrobeContentViewController.h"
#import "WardrobeViewController.h"
#import "FashionistaMainPageViewController.h"
#import "FashionistaProfileViewController.h"
#import "FashionistaPostViewController.h"
#import "GSFashionistaPostViewController.h"
#import "FashionistaCoverPageViewController.h"
#import "MagazineTappedViewController.h"

#import "GSModalContainerView.h"
#import "FashionistaUserListViewController.h"
#import "GSTaggingViewController.h"

#define kTransitionDuration 0.2

static char FROMVIEWCONTROLLER_KEY;
static char MODALVIEWCONTAINER_KEY;
static char MODALVIEWCONTROLLER_KEY;
static char MODALPRESENTER_KEY;

@implementation BaseViewController (StoryboardManagement)

BOOL bComingFromSwipeLeft = NO;


#pragma mark - Storyboard navigation

// Getter and setter for fromViewController
- (BaseViewController *)fromViewController
{
    return objc_getAssociatedObject(self, &FROMVIEWCONTROLLER_KEY);
}

- (void)setFromViewController:(BaseViewController *)fromViewController
{
    objc_setAssociatedObject(self, &FROMVIEWCONTROLLER_KEY, fromViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for currentModalViewController
- (UIViewController *)currentModalViewController
{
    return objc_getAssociatedObject(self, &MODALVIEWCONTROLLER_KEY);
}

- (void)setCurrentModalViewController:(UIViewController *)currentModalViewController
{
    objc_setAssociatedObject(self, &MODALVIEWCONTROLLER_KEY, currentModalViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for currentModalViewController
- (UIViewController *)currentPresenterViewController
{
    return objc_getAssociatedObject(self, &MODALPRESENTER_KEY);
}

- (void)setCurrentPresenterViewController:(UIViewController *)currentPresenterViewController
{
    objc_setAssociatedObject(self, &MODALPRESENTER_KEY, currentPresenterViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for modalContainer
- (GSModalContainerView *)modalContainerView
{
    return objc_getAssociatedObject(self, &MODALVIEWCONTAINER_KEY);
}

- (void)setModalContainerView:(GSModalContainerView *)modalView
{
    objc_setAssociatedObject(self, &MODALVIEWCONTAINER_KEY, modalView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Custom animation to present view controller
- (void)presentViewController: (UIViewController *)nextViewController
{
    nextViewController.view.hidden = YES;
    [self presentViewController:nextViewController animated:NO completion:^{
        CATransition * transition = [CATransition animation];
        
        transition.duration = kTransitionDuration;
        
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        transition.type = kCATransitionPush;
        
        transition.subtype = kCATransitionFromRight;
        
        [nextViewController.view.window.layer addAnimation:transition forKey:nil];
        nextViewController.view.hidden = NO;
    }];
}

// Custom animation to dismiss view controller
- (void)dismissViewController
{
    CATransition * transition = [CATransition animation];
    
    transition.duration = kTransitionDuration;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromLeft;
    
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(([self.restorationIdentifier isEqualToString:[@(PRODUCTSHEET_VC) stringValue]]) ||
       ([self.restorationIdentifier isEqualToString:[@(STYLIST_VC) stringValue]]) ||
       ([self.restorationIdentifier isEqualToString:[@(FASHIONISTAPOST_VC) stringValue]]) ||
       ([self.restorationIdentifier isEqualToString:[@(WARDROBECONTENT_VC) stringValue]])
       )
    {
        if(
           (([self.restorationIdentifier isEqualToString:[@(STYLIST_VC) stringValue]]) &&
            ([((FashionistaProfileViewController *)self) bEditionMode] == YES)
            )
           ||
           (([self.restorationIdentifier isEqualToString:[@(WARDROBECONTENT_VC) stringValue]]) &&
            ([((WardrobeContentViewController *)self) bEditionMode] == YES)
            )
           )
        {
            [appDelegate.tmpVCQueue removeAllObjects];
            [appDelegate.tmpParametersQueue removeAllObjects];
            [appDelegate.lastDismissedVCQueue removeAllObjects];
            [appDelegate.lastDismissedParametersQueue removeAllObjects];
        }
        else
        {
            NSNumber * dismissedVC = [appDelegate.tmpVCQueue lastObject];
            NSArray  * dismissedParameters = [appDelegate.tmpParametersQueue lastObject];
            
            if((dismissedVC) && (dismissedParameters))
            {
                [appDelegate.lastDismissedVCQueue addObject:dismissedVC];
                [appDelegate.lastDismissedParametersQueue addObject:dismissedParameters];
                
                [appDelegate.tmpVCQueue removeLastObject];
                [appDelegate.tmpParametersQueue removeLastObject];
            }
        }
    }
    else
    {
        [appDelegate.tmpVCQueue removeAllObjects];
        [appDelegate.tmpParametersQueue removeAllObjects];
        [appDelegate.lastDismissedVCQueue removeAllObjects];
        [appDelegate.lastDismissedParametersQueue removeAllObjects];
    }
}

//- (void)dismissAllViewControllers:(NSNotification *)notification
//{
// Dismiss all view controllers in the navigation stack
//    [self dismissViewControllerAnimated:YES completion:^{}];

//    [self setFromViewController:nil];
//}

// Set the proper parameters depending on the destination view controller
- (void)prepareViewController: (BaseViewController*)nextViewController withParameters:(NSArray*)parameters
{
    if (parameters == nil)
    {
        return;
    }
    
    SearchBaseViewController *resultsVC;
    ProductSheetViewController *productSheetVC;
    ProductFeatureSearchViewController *productFeatureSearchVC;
//    FashionistaPostViewController * newfashionistaPostVC;
     GSTaggingViewController * newfashionistaPostVC;
    GSFashionistaPostViewController * fashionistaPostVC;
    WardrobeContentViewController *wardrobeContentVC;
    FashionistaMainPageViewController * fashionistaMainPageVC;
    FashionistaProfileViewController * fashionistaProfileVC;
    FashionistaCoverPageViewController* fashionistaCoverPageVC;
    MagazineTappedViewController* magazineTappedVC;
    
    NSLog(@"nextViewController Identifier %d", [nextViewController.restorationIdentifier intValue]);
    switch ([nextViewController.restorationIdentifier intValue])
    {
        case SEARCH_VC:
        case USERLIST_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Search View Controller needs at least 3 parameter XXXX");
                
                return;
            }
            
            if([parameters count] > 1)
            {
                resultsVC = (SearchBaseViewController *)nextViewController;
                
                if (!([parameters objectAtIndex:0] == nil))
                {
                    if ([[parameters objectAtIndex:0] isKindOfClass:[SearchQuery class]])
                    {
                        [resultsVC setCurrentSearchQuery:[parameters objectAtIndex:0]];
                    }
                    else if ([[parameters objectAtIndex:0] isKindOfClass:[NSArray class]])
                    {
                        [resultsVC setFashionistasMappingResult:[parameters objectAtIndex:0]];
                    }
                }
                
                if (!([parameters objectAtIndex:1] == nil))
                {
                    if ([[parameters objectAtIndex:1] isKindOfClass:[NSArray class]])
                    {
                        [resultsVC setResultsArray:[parameters objectAtIndex:1]];
                    }
                    else if ([[parameters objectAtIndex:1] isKindOfClass:[NSNumber class]])
                    {
                        [resultsVC setFashionistasOperation:[parameters objectAtIndex:1]];
                    }
                }
                
                if([parameters count] > 2)
                {
                    if (!([parameters objectAtIndex:2] == nil))
                    {
                        if ([[parameters objectAtIndex:2] isKindOfClass:[NSArray class]])
                        {
                            [resultsVC setResultsGroups:[parameters objectAtIndex:2]];
                        }
                    }
                    
                    if ([parameters count] > 3)
                    {
                        if (!([parameters objectAtIndex:3] == nil))
                        {
                            if ([[parameters objectAtIndex:3] isKindOfClass:[NSArray class]])
                            {
                                [resultsVC setSuccessfulTerms:[parameters objectAtIndex:3]];
                            }
                            else if ([[parameters objectAtIndex:3] isKindOfClass:[GSBaseElement class]])
                            {
                                [resultsVC setGetTheLookReferenceProduct:[parameters objectAtIndex:3]];
                            }
                        }
                        
                        if([parameters count] > 4)
                        {
                            if (!([parameters objectAtIndex:4] == nil))
                            {
                                if ([[parameters objectAtIndex:4] isKindOfClass:[NSString class]])
                                {
                                    [resultsVC setNotSuccessfulTerms:[parameters objectAtIndex:4]];
                                }
                            }
                            
                            if ([parameters count] > 5) {
                                if (!([parameters objectAtIndex:5] == nil)) {
                                    if ([[parameters objectAtIndex:5] isKindOfClass:[NSNumber class]]) {
                                        [resultsVC setBFromTagSearch:[[parameters objectAtIndex:5] boolValue]];
                                    }
                                }
                                
                                if ([parameters count] > 6) {
                                    if (!([parameters objectAtIndex:6] == nil)) {
                                        if ([[parameters objectAtIndex:6] isKindOfClass:[NSMutableArray class]]) {
                                            [resultsVC setCategoryTerms:[parameters objectAtIndex:6]];
                                        }
                                    }
                                    
                                    if ([parameters count] > 7) {
                                        if (!([parameters objectAtIndex:7] == nil)) {
                                            if ([[parameters objectAtIndex:7] isKindOfClass:[NSArray class]]) {
                                                [resultsVC setInspireParams:[parameters objectAtIndex:7]];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
            break;
        }
        case PRODUCTSHEET_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Product Sheet View Controller needs at least 2 parameters XXXX");
                
                return;
            }
            
            productSheetVC = (ProductSheetViewController *)nextViewController;
            
            if ([parameters count] > 0)
            {
                if ([[parameters objectAtIndex:0] isKindOfClass:[GSBaseElement class]])
                {
                    [productSheetVC setShownGSBaseElement:[parameters objectAtIndex:0]];
                }
                else if ([[parameters objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if ([((NSString *)[parameters objectAtIndex:0]) isEqualToString:@"ProductAdd"])
                    {
                        [productSheetVC setShownGSBaseElement:nil];
                    }
                }
                
                if([parameters count] > 1)
                {
                    if ([[parameters objectAtIndex:1] isKindOfClass:[Product class]])
                    {
                        [productSheetVC setShownProduct:[parameters objectAtIndex:1]];
                    }
                    
                    if([parameters count] > 2)
                    {
                        if ([[parameters objectAtIndex:2] isKindOfClass:[NSMutableArray class]])
                        {
                            [productSheetVC setProductContent:[parameters objectAtIndex:2]];
                        }
                        
                        if([parameters count] > 3)
                        {
                            if ([[parameters objectAtIndex:3] isKindOfClass:[NSMutableArray class]])
                            {
                                [productSheetVC setProductReviews:[parameters objectAtIndex:3]];
                            }
                            
                            if([parameters count] > 4)
                            {
                                if ([[parameters objectAtIndex:4] isKindOfClass:[NSMutableArray class]])
                                {
                                    [productSheetVC setProductAvailabilies:[parameters objectAtIndex:4]];
                                }
                                
                                if ([parameters count] > 5)
                                {
                                    if ([[parameters objectAtIndex:5] isKindOfClass:[NSMutableArray class]])
                                    {
                                        [productSheetVC setReviews:[parameters objectAtIndex:5]];
                                    }
                                    if ([parameters count] > 6) {
                                        if ([[parameters objectAtIndex:6] isKindOfClass:[SearchQuery class]])
                                        {
                                            [productSheetVC setSearchQuery:[parameters objectAtIndex:6]];
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            
            break;
        }
        case PRODUCTFEATURESEARCH_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Product Feature Search View Controller needs at least 2 parameters XXXX");
                
                return;
            }
            
            productFeatureSearchVC = (ProductFeatureSearchViewController *)nextViewController;
            
            if ([parameters count] > 1)
            {
                if ([[parameters objectAtIndex:0] isKindOfClass:[Product class]])
                {
                    [productFeatureSearchVC setShownProduct:[parameters objectAtIndex:0]];
                }
                
                if ([[parameters objectAtIndex:1] isKindOfClass:[UIImage class]])
                {
                    [productFeatureSearchVC setShownImage:[parameters objectAtIndex:1]];
                }
            }
            
            break;
        }
        case CREATEPOST_VC:
        case TAGGING_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Fashionista Post View Controller needs at least 3 parameters XXXX");
                
                return;
            }
            
//            newfashionistaPostVC = (FashionistaPostViewController *)nextViewController;
              newfashionistaPostVC = (GSTaggingViewController *)nextViewController;
            if ([parameters count] > 0)
            {
                if ([[parameters objectAtIndex:0] isKindOfClass:[GSBaseElement class]])
                {
                    [newfashionistaPostVC setShownGSBaseElement:[parameters objectAtIndex:0]];
                }
                else if ([[parameters objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    [newfashionistaPostVC setBEditingMode:[((NSNumber *)[parameters objectAtIndex:0]) boolValue]];
                }
                
                if([parameters count] > 1)
                {
                    if ([[parameters objectAtIndex:1] isKindOfClass:[FashionistaPost class]])
                    {
                        [newfashionistaPostVC setShownPost:[parameters objectAtIndex:1]];
                    }
                    else if ([[parameters objectAtIndex:1] isKindOfClass:[FashionistaPage class]])
                    {
                        [newfashionistaPostVC setParentFashionistaPage:[parameters objectAtIndex:1]];
                    }
                    
                    if([parameters count] > 2)
                    {
                        if ([[parameters objectAtIndex:2] isKindOfClass:[NSMutableArray class]])
                        {
                            [newfashionistaPostVC setShownFashionistaPostContent:[parameters objectAtIndex:2]];
                        }
                        
                        if([parameters count] > 3)
                        {
                            if ([[parameters objectAtIndex:3] isKindOfClass:[NSMutableArray class]])
                            {
                                [newfashionistaPostVC setPostComments:[parameters objectAtIndex:3]];
                            }
                            else if ([[parameters objectAtIndex:3] isKindOfClass:[SearchQuery class]])
                            {
                                [newfashionistaPostVC setSearchQuery:[parameters objectAtIndex:3]];
                            }
                            else if ([[parameters objectAtIndex:3] isKindOfClass:[NSNumber class]])
                            {
                                [newfashionistaPostVC setBEditingMode:[((NSNumber *)[parameters objectAtIndex:3]) boolValue]];
                            }
                            else if ([[parameters objectAtIndex:3] isKindOfClass:[User class]])
                            {
                                [newfashionistaPostVC setShownPostUser:[parameters objectAtIndex:3]];
                            }
                            
                            if([parameters count] > 4)
                            {
                                if ([[parameters objectAtIndex:4] isKindOfClass:[SearchQuery class]])
                                {
                                    [newfashionistaPostVC setSearchQuery:[parameters objectAtIndex:4]];
                                }
                                else if ([[parameters objectAtIndex:4] isKindOfClass:[NSNumber class]])
                                {
                                    [newfashionistaPostVC setBEditingMode:[((NSNumber *)[parameters objectAtIndex:4]) boolValue]];
                                }
                                
                                if([parameters count] > 5)
                                {
                                    if ([[parameters objectAtIndex:5] isKindOfClass:[NSNumber class]])
                                    {
                                        [newfashionistaPostVC setPostLikesNumber:[parameters objectAtIndex:5]];
                                    }
                                    else if ([[parameters objectAtIndex:5] isKindOfClass:[NSString class]])
                                    {
                                        [newfashionistaPostVC setParentFashionistaPage:[parameters objectAtIndex:5]];
                                    }
                                    
                                    if([parameters count] > 6)
                                    {
                                        if ([[parameters objectAtIndex:6] isKindOfClass:[NSString class]])
                                        {
                                            [newfashionistaPostVC setParentFashionistaPage:[parameters objectAtIndex:6]];
                                        }
                                        else if ([[parameters objectAtIndex:6] isKindOfClass:[User class]])
                                        {
                                            [newfashionistaPostVC setShownPostUser:[parameters objectAtIndex:6]];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            break;

        }
        case FASHIONISTAPOST_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Fashionista Post View Controller needs at least 3 parameters XXXX");
                
                return;
            }
            
            fashionistaPostVC = (GSFashionistaPostViewController *)nextViewController;
            
            if ([parameters count] > 0)
            {
                fashionistaPostVC.postParameters = parameters;
                /*
                if ([[parameters objectAtIndex:0] isKindOfClass:[GSBaseElement class]])
                {
                    [fashionistaPostVC setShownGSBaseElement:[parameters objectAtIndex:0]];
                }
                else if ([[parameters objectAtIndex:0] isKindOfClass:[NSNumber class]])
                {
                    [fashionistaPostVC setBEditingMode:[((NSNumber *)[parameters objectAtIndex:0]) boolValue]];
                }
                
                if([parameters count] > 1)
                {
                    if ([[parameters objectAtIndex:1] isKindOfClass:[FashionistaPost class]])
                    {
                        [fashionistaPostVC setShownPost:[parameters objectAtIndex:1]];
                    }
                    else if ([[parameters objectAtIndex:1] isKindOfClass:[FashionistaPage class]])
                    {
                        [fashionistaPostVC setParentFashionistaPage:[parameters objectAtIndex:1]];
                    }
                    
                    if([parameters count] > 2)
                    {
                        if ([[parameters objectAtIndex:2] isKindOfClass:[NSMutableArray class]])
                        {
                            [fashionistaPostVC setShownFashionistaPostContent:[parameters objectAtIndex:2]];
                        }
                        
                        if([parameters count] > 3)
                        {
                            if ([[parameters objectAtIndex:3] isKindOfClass:[NSMutableArray class]])
                            {
                                [fashionistaPostVC setPostComments:[parameters objectAtIndex:3]];
                            }
                            else if ([[parameters objectAtIndex:3] isKindOfClass:[SearchQuery class]])
                            {
                                [fashionistaPostVC setSearchQuery:[parameters objectAtIndex:3]];
                            }
                            else if ([[parameters objectAtIndex:3] isKindOfClass:[NSNumber class]])
                            {
                                [fashionistaPostVC setBEditingMode:[((NSNumber *)[parameters objectAtIndex:3]) boolValue]];
                            }
                            else if ([[parameters objectAtIndex:3] isKindOfClass:[User class]])
                            {
                                [fashionistaPostVC setShownPostUser:[parameters objectAtIndex:3]];
                            }
                            
                            if([parameters count] > 4)
                            {
                                if ([[parameters objectAtIndex:4] isKindOfClass:[SearchQuery class]])
                                {
                                    [fashionistaPostVC setSearchQuery:[parameters objectAtIndex:4]];
                                }
                                else if ([[parameters objectAtIndex:4] isKindOfClass:[NSNumber class]])
                                {
                                    [fashionistaPostVC setBEditingMode:[((NSNumber *)[parameters objectAtIndex:4]) boolValue]];
                                }
                                
                                if([parameters count] > 5)
                                {
                                    if ([[parameters objectAtIndex:5] isKindOfClass:[NSNumber class]])
                                    {
                                        [fashionistaPostVC setPostLikesNumber:[parameters objectAtIndex:5]];
                                    }
                                    else if ([[parameters objectAtIndex:5] isKindOfClass:[NSString class]])
                                    {
                                        [fashionistaPostVC setParentFashionistaPage:[parameters objectAtIndex:5]];
                                    }
                                    
                                    if([parameters count] > 6)
                                    {
                                        if ([[parameters objectAtIndex:6] isKindOfClass:[NSString class]])
                                        {
                                            [fashionistaPostVC setParentFashionistaPage:[parameters objectAtIndex:6]];
                                        }
                                        else if ([[parameters objectAtIndex:6] isKindOfClass:[User class]])
                                        {
                                            [fashionistaPostVC setShownPostUser:[parameters objectAtIndex:6]];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                 */
            }
            
            break;
        }
        case FASHIONISTACOVERPAGE_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Fashionista Post View Controller needs at least 3 parameters XXXX");
                
                return;
            }
            
            fashionistaCoverPageVC = (FashionistaCoverPageViewController *)nextViewController;
            
            if ([parameters count] > 0)
            {
                fashionistaCoverPageVC.postParameters = parameters;
            }
            break;
        }
        case MAGAGINETAPPEDVIEW_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Fashionista Post View Controller needs at least 3 parameters XXXX");
                
                return;
            }
            
            magazineTappedVC = (MagazineTappedViewController *)nextViewController;
            
            if ([parameters count] > 0)
            {
                magazineTappedVC.postParameters = parameters;
            }
            break;
        }
        case WARDROBECONTENT_VC:
        {
            if([parameters count] < 1)
            {
                NSLog(@"XXXX Wardrobe Content View Controller needs at least 1 parameter XXXX");
                
                return;
            }
            
            if([parameters count] > 0)
            {
                wardrobeContentVC = (WardrobeContentViewController *)nextViewController;
                
                if (!([parameters objectAtIndex:0] == nil))
                {
                    if ([[parameters objectAtIndex:0] isKindOfClass:[Wardrobe class]])
                    {
                        [wardrobeContentVC setShownWardrobe:[parameters objectAtIndex:0]];
                    }
                }
            }
            if([parameters count] > 1)
            {
                if (!([parameters objectAtIndex:1] == nil))
                {
                    if ([[parameters objectAtIndex:1] isKindOfClass:[NSNumber class]])
                    {
                        [wardrobeContentVC setBEditionMode:[((NSNumber *)[parameters objectAtIndex:1]) boolValue]];
                    }
                }
            }
            if([parameters count] > 2)
            {
                if (!([parameters objectAtIndex:2] == nil))
                {
                    if ([[parameters objectAtIndex:2] isKindOfClass:[GSBaseElement class]])
                    {
                        [wardrobeContentVC setShownElement:[parameters objectAtIndex:2]];
                    }
                }
            }
            
            break;
        }
        case FASHIONISTAMAINPAGE_VC:
        {
            if([parameters count] < 1)
            {
                NSLog(@"XXXX Fashionista Main Page View Controller needs at least 1 parameter XXXX");
                
                return;
            }
            
            if([parameters count] > 0)
            {
                fashionistaMainPageVC = (FashionistaMainPageViewController *)nextViewController;
                
                if (!([parameters objectAtIndex:0] == nil))
                {
                    if ([[parameters objectAtIndex:0] isKindOfClass:[FashionistaPage class]])
                    {
                        [fashionistaMainPageVC setShownFashionistaPage:[parameters objectAtIndex:0]];
                    }
                    else if ([[parameters objectAtIndex:0] isKindOfClass:[NSNumber class]])
                    {
                        [fashionistaMainPageVC setBEditionMode:[((NSNumber *)[parameters objectAtIndex:0]) boolValue]];
                    }
                }
                
                if([parameters count] > 1)
                {
                    if (!([parameters objectAtIndex:1] == nil))
                    {
                        if ([[parameters objectAtIndex:1] isKindOfClass:[NSNumber class]])
                        {
                            [fashionistaMainPageVC setBEditionMode:[((NSNumber *)[parameters objectAtIndex:1]) boolValue]];
                        }
                    }
                    
                }
                
            }
            
            break;
        }
        case STYLIST_VC:
        case USERPROFILE_VC:
        {
            if([parameters count] < 2)
            {
                NSLog(@"XXXX Fashionista Profile View Controller needs at least 2 parameters XXXX");
                
                return;
            }
            
            if([parameters count] > 0)
            {
                fashionistaProfileVC = (FashionistaProfileViewController *)nextViewController;
                
                if (!([parameters objectAtIndex:0] == nil))
                {
                    if ([[parameters objectAtIndex:0] isKindOfClass:[User class]])
                    {
                        [fashionistaProfileVC setShownStylist:[parameters objectAtIndex:0]];
                    }
                }
                
                if([parameters count] > 1)
                {
                    if (!([parameters objectAtIndex:1] == nil))
                    {
                        if ([[parameters objectAtIndex:1] isKindOfClass:[NSNumber class]])
                        {
                            [fashionistaProfileVC setBEditionMode:[((NSNumber *)[parameters objectAtIndex:1]) boolValue]];
                        }
                    }
                    
                    if([parameters count] > 2)
                    {
                        if (!([parameters objectAtIndex:2] == nil))
                        {
                            if ([[parameters objectAtIndex:2] isKindOfClass:[SearchQuery class]])
                            {
                                //[fashionistaPostVC setSearchQuery:[parameters objectAtIndex:2]];
                            }else if([[parameters objectAtIndex:2] isKindOfClass:[NSNumber class]]){
                                fashionistaProfileVC.showVideos = [[parameters objectAtIndex:2] boolValue];
                            }
                        }
                    }
                }
                
            }
            
            break;
        }
            
        default:
            
            break;
    }
}

- (int)searchContextFromDestinationVC:(int)destinationVC{
    int searchContext;
    switch (destinationVC) {
        case STYLES_VC:
            searchContext = STYLES_SEARCH;
            break;
        case HISTORY_VC:
            searchContext = HISTORY_SEARCH;
            break;
        case TRENDING_VC:
            searchContext = TRENDING_SEARCH;
            break;
        case FASHIONISTAS_VC:
            searchContext = FASHIONISTAS_SEARCH;
            break;
        case FASHIONISTAPOSTS_VC:
            searchContext = FASHIONISTAPOSTS_SEARCH;
            break;
        case SEARCH_VC:
            searchContext = PRODUCT_SEARCH;
            break;
        case BRAND_VC:
            searchContext = BRANDS_SEARCH;
            break;
        default:
            searchContext = destinationVC;
            break;
    }
    return searchContext;
}

// Perform transition to next view controller
- (void)transitionToViewController:(int) destinationVC withParameters:(NSArray *)parameters
{
    [self transitionToViewController:destinationVC withParameters:parameters fromViewController:nil];
}

- (void)transitionToViewController:(int) destinationVC withParameters:(NSArray *)parameters fromViewController:(BaseViewController *) fromViewController
{
    //[self showMainMenu:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:-1] forKey:GSLastTabSelected];
    [defaults synchronize];
    
    BOOL bDestinationEqualsOrigin = ([self.restorationIdentifier isEqualToString:[@(destinationVC) stringValue]]);
    
    BOOL bDestinationEqualsContext = NO;
    int searchContext = -1;
    
    if (destinationVC == SEARCH_VC ||
        destinationVC == HISTORY_VC ||
        destinationVC == TRENDING_VC ||
        destinationVC == FASHIONISTAS_VC ||
        destinationVC == FASHIONISTAPOSTS_VC ||
        destinationVC == STYLES_VC ||
        destinationVC == BRAND_VC
        )
    {
        searchContext = [self searchContextFromDestinationVC:destinationVC];
    }
    if([self isKindOfClass:[SearchBaseViewController class]])
    {
        
        bDestinationEqualsContext = ([((SearchBaseViewController*) self) searchContext] == searchContext);
    }
    
    if ([self isKindOfClass:[ProductSheetViewController class]]) {
        bDestinationEqualsOrigin = false;
    }
    if([self isKindOfClass:[FashionistaProfileViewController class]])
    {
        if(!(parameters == nil))
        {
            if([parameters count] > 1)
            {
                if (!([parameters objectAtIndex:1] == nil))
                {
                    if ([[parameters objectAtIndex:1] isKindOfClass:[NSNumber class]])
                    {
                        if((!([parameters objectAtIndex:0] == nil)) && (!([[parameters objectAtIndex:0] isKindOfClass:[NSArray class]])))
                        {
                            bDestinationEqualsContext = [[(FashionistaProfileViewController*) self shownStylist].idUser isEqualToString:((User *)[parameters objectAtIndex:0]).idUser];
                        }
                    }
                }
            }
        }else{
            //Trying to go to self profile
            bDestinationEqualsContext = [((FashionistaProfileViewController*) self) bEditionMode]&&(destinationVC==USERPROFILE_VC);
        }
    }
    
    BOOL bPerformTransition = !bDestinationEqualsOrigin;
    
    if([self isKindOfClass:[SearchBaseViewController class]] || [self isKindOfClass:[FashionistaProfileViewController class]])
    {
        bPerformTransition = ( (bDestinationEqualsOrigin && !bDestinationEqualsContext) || (!bDestinationEqualsOrigin && !bDestinationEqualsContext) );
    }
    
    if(destinationVC == FASHIONISTAPOST_VC || destinationVC == FASHIONISTACOVERPAGE_VC || destinationVC == MAGAGINETAPPEDVIEW_VC)// || destinationVC == USERPROFILE_VC)
    {
        bPerformTransition = YES;
    }
    
    if([self isKindOfClass:[FashionistaPostViewController class]])
    {
        bPerformTransition = [((FashionistaPostViewController *) self) checkPostEditionBeforeTransition];
    }
    
    BOOL goBack = NO;
    if (destinationVC == USERPROFILE_VC) {
        BaseViewController* checkVc = self;
        if([self isKindOfClass:[GSDoubleDisplayViewController class]]){
            checkVc = (BaseViewController*)((GSDoubleDisplayViewController*)self).delegate;
        }
        FashionistaProfileViewController* theProfileController = nil;
        if([checkVc.fromViewController isKindOfClass:[FashionistaProfileViewController class]]){
            theProfileController = (FashionistaProfileViewController*)checkVc.fromViewController;
        }
        if([checkVc isKindOfClass:[FashionistaProfileViewController class]]){
            theProfileController = (FashionistaProfileViewController*)checkVc;
        }
        if([theProfileController.shownStylist.idUser isEqualToString:((User*)[parameters objectAtIndex:0]).idUser]){
            if(![checkVc isKindOfClass:[FashionistaProfileViewController class]]){
                goBack = YES;
            }
            bPerformTransition = NO;
        }
    }
    
    if ( bPerformTransition )
    {
        NSString * destinationStoryboard = @"BasicScreens";
        
        int vcName = -1;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        switch (destinationVC)
        {
            case HISTORY_VC:
                
                if ((appDelegate.currentUser == nil))
                {
                    // Must be logged!
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    
                    return;
                }
                
                // If user is logged in, continue:
                
            case SEARCH_VC:
            case TRENDING_VC:
            case FASHIONISTAS_VC:
            case FASHIONISTAPOSTS_VC:
            case STYLES_VC:
            case BRAND_VC:
                
                destinationStoryboard = @"Search";
                vcName = destinationVC;
                destinationVC = SEARCH_VC;
                
                [appDelegate.tmpVCQueue removeAllObjects];
                [appDelegate.tmpParametersQueue removeAllObjects];
                [appDelegate.lastDismissedVCQueue removeAllObjects];
                [appDelegate.lastDismissedParametersQueue removeAllObjects];
                
                break;
                
            case PRODUCTFEATURESEARCH_VC:
            case VISUALSEARCH_VC:
            case SEARCHFILTERS_VC:
            case SOCIALNETWORKLIST_VC:
                destinationStoryboard = @"Search";
                
                [appDelegate.tmpVCQueue removeAllObjects];
                [appDelegate.tmpParametersQueue removeAllObjects];
                [appDelegate.lastDismissedVCQueue removeAllObjects];
                [appDelegate.lastDismissedParametersQueue removeAllObjects];
                
                break;
                
            case PRODUCTSHEET_VC:
                
                destinationStoryboard = @"ProductSheet";
                
                if(!(bComingFromSwipeLeft))
                {
                    NSNumber * dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                    
                    if(dismissedVC)
                    {
                        if(
                           (([dismissedVC intValue] == PRODUCTSHEET_VC) && ([self.restorationIdentifier isEqualToString:[@(WARDROBECONTENT_VC) stringValue]]))
                           ||
                           (([dismissedVC intValue] == FASHIONISTAPOST_VC) && ([self.restorationIdentifier isEqualToString:[@(WARDROBECONTENT_VC) stringValue]]))
                           )
                        {
                            [appDelegate.lastDismissedVCQueue removeLastObject];
                            [appDelegate.lastDismissedParametersQueue removeLastObject];
                        }
                        else
                        {
                            [appDelegate.tmpVCQueue removeAllObjects];
                            [appDelegate.tmpParametersQueue removeAllObjects];
                            [appDelegate.lastDismissedVCQueue removeAllObjects];
                            [appDelegate.lastDismissedParametersQueue removeAllObjects];
                        }
                    }
                }
                bComingFromSwipeLeft = NO;
                
                [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                
                break;
                
            case SIGNIN_VC:
            case REQUIREDPROFILESTYLIST_VC:
            case SIGNUP_VC:
            case EMAILVERIFY_VC:
            case FORGOTPWD_VC:
            case ACCOUNT_VC:
            case WHO_ARE_YOU_VC:
            case CHANGEPASSWORD_VC:
            case HELPSUPPORT_VC:
            case LINKACCOUNTS_VC:
            case FRIENDS_VC:
            case SOCIALNETWORKWEBVIEW_VC:
            case DISCOVER_VC:
                if (destinationVC == ACCOUNT_VC)
                {
                    if ((appDelegate.currentUser == nil))
                    {
                        // Must be logged!
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                        
                        [alertView show];
                        
                        return;
                    }
                }
                
                destinationStoryboard = @"UserAccount";
                
                [appDelegate.tmpVCQueue removeAllObjects];
                [appDelegate.tmpParametersQueue removeAllObjects];
                [appDelegate.lastDismissedVCQueue removeAllObjects];
                [appDelegate.lastDismissedParametersQueue removeAllObjects];
                
                break;
                
            case WARDROBECOLLECTIONS_VC:
            case ADDITEMTOWARDROBE_VC:
                
                if ((appDelegate.currentUser == nil))
                {
                    // Must be logged!
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    
                    return;
                }
                
                destinationStoryboard = @"Wardrobe";
                
                [appDelegate.tmpVCQueue removeAllObjects];
                [appDelegate.tmpParametersQueue removeAllObjects];
                [appDelegate.lastDismissedVCQueue removeAllObjects];
                [appDelegate.lastDismissedParametersQueue removeAllObjects];
                
                break;
                
            case WARDROBECONTENT_VC:
                
                destinationStoryboard = @"WardrobeContents";
                
                if(!(bComingFromSwipeLeft))
                {
                    NSNumber * dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                    NSArray  * dismissedParameters = [appDelegate.lastDismissedParametersQueue lastObject];
                    
                    if(dismissedVC)
                    {
                        if(dismissedVC)
                        {
                            if([dismissedVC intValue] == WARDROBECONTENT_VC)
                            {
                                [appDelegate.lastDismissedVCQueue removeLastObject];
                                [appDelegate.lastDismissedParametersQueue removeLastObject];
                                
                                dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                                dismissedParameters = [appDelegate.lastDismissedParametersQueue lastObject];
                                
                                if(dismissedVC)
                                {
                                    if(([dismissedVC intValue] == PRODUCTSHEET_VC) || ([dismissedVC intValue] == FASHIONISTAPOST_VC))
                                    {
                                        [appDelegate.lastDismissedVCQueue removeLastObject];
                                        [appDelegate.lastDismissedParametersQueue removeLastObject];
                                    }
                                }
                            }
                        }
                        else if(([dismissedVC intValue] == PRODUCTSHEET_VC) || ([dismissedVC intValue] == FASHIONISTAPOST_VC))
                        {
                            [appDelegate.lastDismissedVCQueue removeLastObject];
                            [appDelegate.lastDismissedParametersQueue removeLastObject];
                        }
                    }
                }
                bComingFromSwipeLeft = NO;
                
                if(!(parameters == nil))
                {
                    if([parameters count] > 1)
                    {
                        if (!([parameters objectAtIndex:1] == nil))
                        {
                            if ([[parameters objectAtIndex:1] isKindOfClass:[NSNumber class]])
                            {
                                if(!([((NSNumber *)[parameters objectAtIndex:1]) boolValue] == YES))
                                {
                                    [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                    [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                }
                            }
                        }
                    }
                }
                
                break;
            case MAGAGINETAPPEDVIEW_VC:
            case FASHIONISTACOVERPAGE_VC:
            case FASHIONISTAMAINPAGE_VC:
            case FASHIONISTAPOST_VC:
            case ANALYTICS_VC:
            case STYLIST_VC:
            case ADDPOSTTOPAGE_VC:
                //case EDITPROFILE_VC:
            case USERPROFILE_VC:
            case NEWSFEED_VC:
            case LIKES_VC:
            case TAGGEDHISTORY_VC:
            case CREATEPOST_VC:
            case TAGGING_VC:
            {
                if ((destinationVC == STYLIST_VC)||(destinationVC == USERPROFILE_VC))
                {
                    destinationVC = USERPROFILE_VC;
                    if(!(bComingFromSwipeLeft))
                    {
                        [appDelegate.tmpVCQueue removeAllObjects];
                        [appDelegate.tmpParametersQueue removeAllObjects];
                        [appDelegate.lastDismissedVCQueue removeAllObjects];
                        [appDelegate.lastDismissedParametersQueue removeAllObjects];
                    }
                    bComingFromSwipeLeft = NO;
                    
                    if((parameters == nil)&&appDelegate.currentUser!=nil){
                        parameters = [NSArray arrayWithObjects: appDelegate.currentUser, [NSNumber numberWithBool:YES], nil];
                    }
                    
                    if((parameters == nil) || (!([parameters count] > 1)))
                    {
                        // Must be logged!
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                        
                        [alertView show];
                        
                        return;
                    }
                    
                    if(!(parameters == nil))
                    {
                        if([parameters count] > 1)
                        {
                            if (!([parameters objectAtIndex:1] == nil))
                            {
                                if ([[parameters objectAtIndex:1] isKindOfClass:[NSNumber class]])
                                {
                                    if([((NSNumber *)[parameters objectAtIndex:1]) boolValue] == YES)
                                    {
                                        if ((appDelegate.currentUser == nil))
                                        {
                                            // Must be logged!
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                                            
                                            [alertView show];
                                            
                                            return;
                                        }
                                    }
                                    else
                                    {
                                        [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                        [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                else if (destinationVC == FASHIONISTAPOST_VC)
                {
                    if(!(bComingFromSwipeLeft))
                    {
                        NSNumber * dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                        NSArray  * dismissedParameters = [appDelegate.lastDismissedParametersQueue lastObject];
                        
                        if(dismissedVC)
                        {
                            if([dismissedVC intValue] == FASHIONISTAPOST_VC)
                            {
                                [appDelegate.lastDismissedVCQueue removeLastObject];
                                [appDelegate.lastDismissedParametersQueue removeLastObject];
                                
                                dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                                
                                if(dismissedVC)
                                {
                                    if([dismissedVC intValue] == WARDROBECONTENT_VC)
                                    {
                                        [appDelegate.lastDismissedVCQueue removeLastObject];
                                        [appDelegate.lastDismissedParametersQueue removeLastObject];
                                        
                                        dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                                        dismissedParameters = [appDelegate.lastDismissedParametersQueue lastObject];
                                        
                                        if(dismissedVC)
                                        {
                                            if([dismissedVC intValue] == PRODUCTSHEET_VC)
                                            {
                                                [appDelegate.lastDismissedVCQueue removeLastObject];
                                                [appDelegate.lastDismissedParametersQueue removeLastObject];
                                            }
                                        }
                                    }
                                }
                            }
                            else if([dismissedVC intValue] == PRODUCTSHEET_VC)
                            {
                                [appDelegate.lastDismissedVCQueue removeLastObject];
                                [appDelegate.lastDismissedParametersQueue removeLastObject];
                            }
                        }
                    }
                    bComingFromSwipeLeft = NO;
                    
                    if(!(parameters == nil))
                    {
                        if ([parameters count] > 0)
                        {
                            if ([[parameters objectAtIndex:0] isKindOfClass:[GSBaseElement class]])
                            {
                                [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                            }
                            else if ([[parameters objectAtIndex:0] isKindOfClass:[NSNumber class]])
                            {
                                if(!([((NSNumber *)[parameters objectAtIndex:0]) boolValue] == YES))
                                {
                                    [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                    [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                }
                            }
                            else if ([[parameters objectAtIndex:0] isKindOfClass:[FashionistaPost class]])
                            {
                                if([parameters count] > 3)
                                {
                                    if ([[parameters objectAtIndex:3] isKindOfClass:[NSNumber class]])
                                    {
                                        if(!([((NSNumber *)[parameters objectAtIndex:3]) boolValue] == YES))
                                        {
                                            [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                            [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                        }
                                    }
                                    else if([parameters count] > 4)
                                    {
                                        if ([[parameters objectAtIndex:4] isKindOfClass:[NSNumber class]])
                                        {
                                            if(!([((NSNumber *)[parameters objectAtIndex:4]) boolValue] == YES))
                                            {
                                                [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                                [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if (destinationVC == FASHIONISTACOVERPAGE_VC || destinationVC == MAGAGINETAPPEDVIEW_VC) {
                    if(!(bComingFromSwipeLeft))
                    {
                        NSNumber * dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                        NSArray  * dismissedParameters = [appDelegate.lastDismissedParametersQueue lastObject];
                        
                        if(dismissedVC)
                        {
                            if([dismissedVC intValue] == FASHIONISTAPOST_VC)
                            {
                                [appDelegate.lastDismissedVCQueue removeLastObject];
                                [appDelegate.lastDismissedParametersQueue removeLastObject];
                                
                                dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                                
                                if(dismissedVC)
                                {
                                    if([dismissedVC intValue] == WARDROBECONTENT_VC)
                                    {
                                        [appDelegate.lastDismissedVCQueue removeLastObject];
                                        [appDelegate.lastDismissedParametersQueue removeLastObject];
                                        
                                        dismissedVC = [appDelegate.lastDismissedVCQueue lastObject];
                                        dismissedParameters = [appDelegate.lastDismissedParametersQueue lastObject];
                                        
                                        if(dismissedVC)
                                        {
                                            if([dismissedVC intValue] == PRODUCTSHEET_VC)
                                            {
                                                [appDelegate.lastDismissedVCQueue removeLastObject];
                                                [appDelegate.lastDismissedParametersQueue removeLastObject];
                                            }
                                        }
                                    }
                                }
                            }
                            else if([dismissedVC intValue] == PRODUCTSHEET_VC)
                            {
                                [appDelegate.lastDismissedVCQueue removeLastObject];
                                [appDelegate.lastDismissedParametersQueue removeLastObject];
                            }
                        }
                    }
                    bComingFromSwipeLeft = NO;
                    
                    if(!(parameters == nil))
                    {
                        if ([parameters count] > 0)
                        {
                            if ([[parameters objectAtIndex:0] isKindOfClass:[GSBaseElement class]])
                            {
                                [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                            }
                            else if ([[parameters objectAtIndex:0] isKindOfClass:[NSNumber class]])
                            {
                                if(!([((NSNumber *)[parameters objectAtIndex:0]) boolValue] == YES))
                                {
                                    [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                    [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                }
                            }
                            else if ([[parameters objectAtIndex:0] isKindOfClass:[FashionistaPost class]])
                            {
                                if([parameters count] > 3)
                                {
                                    if ([[parameters objectAtIndex:3] isKindOfClass:[NSNumber class]])
                                    {
                                        if(!([((NSNumber *)[parameters objectAtIndex:3]) boolValue] == YES))
                                        {
                                            [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                            [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                        }
                                    }
                                    else if([parameters count] > 4)
                                    {
                                        if ([[parameters objectAtIndex:4] isKindOfClass:[NSNumber class]])
                                        {
                                            if(!([((NSNumber *)[parameters objectAtIndex:4]) boolValue] == YES))
                                            {
                                                [appDelegate.tmpVCQueue addObject:[NSNumber numberWithInt:destinationVC]];
                                                [appDelegate.tmpParametersQueue addObject:((parameters) ? (parameters) : ([[NSArray alloc] init]))];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if (destinationVC == ADDPOSTTOPAGE_VC)
                {
                    if ((appDelegate.currentUser == nil))
                    {
                        // Must be logged!
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                        
                        [alertView show];
                        
                        return;
                    }
                }
                destinationStoryboard = @"FashionistaContents";
                
                if((!(destinationVC == STYLIST_VC)) && (!(destinationVC == FASHIONISTAPOST_VC)) && (!(destinationVC == USERPROFILE_VC)))
                {
                    [appDelegate.tmpVCQueue removeAllObjects];
                    [appDelegate.tmpParametersQueue removeAllObjects];
                    [appDelegate.lastDismissedVCQueue removeAllObjects];
                    [appDelegate.lastDismissedParametersQueue removeAllObjects];
                }
                
                break;
            }
            case NOTIFICATIONS_VC:
            {
                if ((appDelegate.currentUser == nil))
                {
                    // Must be logged!
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    
                    return;
                }
                
                destinationStoryboard = @"BasicScreens";
                
                [appDelegate.tmpVCQueue removeAllObjects];
                [appDelegate.tmpParametersQueue removeAllObjects];
                [appDelegate.lastDismissedVCQueue removeAllObjects];
                [appDelegate.lastDismissedParametersQueue removeAllObjects];
                
                break;
            }
            default:
            {
                // Not yet implemented!
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NOTYETIMPLMENETED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                
                return;
                
                break;
            }
        }
        
        
        UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:destinationStoryboard bundle:nil];
        
        if (nextStoryboard != nil)
        {
            BaseViewController *nextViewController = nil;
            
            @try {
                
                nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(destinationVC) stringValue]];
                
            }
            @catch (NSException *exception) {
                
                return;
                
            }
            
            if (nextViewController != nil)
            {
                
                
                if (fromViewController == nil)
                {
                    if(([self.restorationIdentifier isEqualToString:[@(FORGOTPWD_VC) stringValue]] ||
                        [self.restorationIdentifier isEqualToString:[@(SIGNIN_VC) stringValue]] ||
                        ([nextViewController.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]] && [self.restorationIdentifier isEqualToString:[@(REQUIREDPROFILESTYLIST_VC) stringValue]]) ||
                        ([self.restorationIdentifier isEqualToString:[@(SIGNUP_VC) stringValue]] &&
                         [self.fromViewController.restorationIdentifier isEqualToString:[@(SIGNIN_VC) stringValue]])) &&
                       ([nextViewController.restorationIdentifier isEqualToString:[@(SEARCH_VC) stringValue]] || [nextViewController.restorationIdentifier isEqualToString:[@(REQUIREDPROFILESTYLIST_VC) stringValue]]))
                    {
                        [nextViewController setFromViewController:nil];
                    }
                    else
                    {
                        [nextViewController setFromViewController:self];
                    }
                }
                else
                {
                    [nextViewController setFromViewController:fromViewController];
                }
                
                [self prepareViewController:nextViewController withParameters:parameters];
                
                if (searchContext > -1)
                {
                    [((SearchBaseViewController *)nextViewController) setSearchContext:searchContext];
                }
                if(vcName> -1)
                {
                    [((SearchBaseViewController *)nextViewController) setVcName:vcName];
                }
                
                if([nextViewController isKindOfClass:[WardrobeViewController class]])
                {
                    [((WardrobeViewController *)nextViewController) setBEditionMode:YES];
                }
                
                [self presentViewController:nextViewController];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                nextViewController.mainMenuView.selectedEntry = [[defaults objectForKey:GSLastMenuEntry] intValue];
                //                if (fromViewController != nil){
                //                    NSLog(@"%@", NSStringFromClass([self.presentingViewController class]));
                ////                    [self.navigationController popViewControllerAnimated:NO];
                //                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                //                }
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"DismissAllViewControllers" object:self];
            }
        }
    }else if(goBack){
        [self swipeRightAction];
    }
    [self showMainMenu:nil];
}

// Action to perform when user swipes up
- (void)swipeUpAction
{
    return;
}

// Action to perform when user swipes down
- (void)swipeDownAction
{
    return;
}

// Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    if(self.currentPresenterViewController){
        [self.currentPresenterViewController dismissControllerModal];
    }else{
        if(!(self.hintBackgroundView == nil))
        {
            if(!([self.hintBackgroundView isHidden]))
            {
                [self hintPrevAction:nil];
                
                return;
            }
        }
        
        //Only when going to an (existing) previous view controller or being in the initial 'Sign In' view controller
        if ((self.fromViewController == nil) && ([self.restorationIdentifier isEqualToString:[@(SIGNIN_VC) stringValue]]))
        {
            [self transitionToViewController:HOME_VC withParameters:nil];
        }
        else if (self.fromViewController != nil)
        {
            [self dismissViewController];
        }
    }
}

// Action to perform when user swipes to left: by default, nothign (each VC will override if needed<9
- (void)swipeLeftAction
{
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintNextAction:nil];
        
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSNumber * forwardVC = [appDelegate.lastDismissedVCQueue lastObject];
    NSArray  * forwardParameters = [appDelegate.lastDismissedParametersQueue lastObject];
    
    if((forwardVC) && (forwardParameters))
    {
        [appDelegate.lastDismissedVCQueue removeObject:forwardVC];
        [appDelegate.lastDismissedParametersQueue removeObject:forwardParameters];
        
        bComingFromSwipeLeft = YES;
        
        [self transitionToViewController:forwardVC.intValue withParameters:forwardParameters];
    }
    
    if ((self.fromViewController == nil) && ([self.restorationIdentifier isEqualToString:[@(SIGNIN_VC) stringValue]]))
    {
        [self transitionToViewController:HOME_VC withParameters:nil];
    }
}

// Action to perform when user swipes to right: go to previous screen
- (void)panGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint velocity = [sender velocityInView:self.view];
    
    CGPoint translation = [sender translationInView:self.view];
    
    CGFloat widthPercentage  = fabs(translation.x / CGRectGetWidth(sender.view.bounds));
    
    //    CGFloat heightPercentage  = fabs(translation.y / CGRectGetHeight(sender.view.bounds));
    
    if(sender.state == UIGestureRecognizerStateEnded)
    {
        self.updatingHint = [NSNumber numberWithBool:YES];
        
        // Perform the transition when swipe right
        if (velocity.x > 0)
        {
            if(widthPercentage > 0.1)
            {
                [self swipeRightAction];
            }
        }
        
        // Perform the transition when swipe left
        if (velocity.x < 0)
        {
            if(widthPercentage > 0.1)
            {
                [self swipeLeftAction];
            }
        }
        
        // Show the advanced search when swipe up
        /*        if (velocity.y < 0)
         {
         if(heightPercentage > 0.4)
         {
         [self swipeUpAction];
         }
         }
         
         // Hide the advanced search when swipe up
         if (velocity.y > 0)
         {
         if(heightPercentage > 0.4)
         {
         [self swipeDownAction];
         }
         }
         */    }
}

// Initialize gesture recognizer for navigation
- (void)initGestureRecognizer
{
    // Create the gesture recognizer and set its target method.
    UIPanGestureRecognizer * swipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    swipeRecognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:swipeRecognizer];
}

- (GSModalContainerView*)getCurrentModalViewContainer{
    if (!self.modalContainerView) {
        self.modalContainerView = [GSModalContainerView new];
        [self.view addSubview:self.modalContainerView];
        [self.modalContainerView setupAutolayout];
        [self.view sendSubviewToBack:self.modalContainerView];
        self.modalContainerView.callingController = self;
        self.modalContainerView.hidden = YES;
    }
    return self.modalContainerView;
}

- (void)showViewControllerModal:(UIViewController*)destinationVC{
    [self showViewControllerModal:destinationVC withTopBar:YES];
}

- (void)cleanViewControllerModal{
    [self.currentModalViewController willMoveToParentViewController:nil];
    [self.currentModalViewController.view removeFromSuperview];
    [self.currentModalViewController removeFromParentViewController];
    self.currentModalViewController = nil;
    ((BaseViewController*)self.currentModalViewController).currentPresenterViewController = nil;
}

- (void)showViewControllerModal:(UIViewController*)destinationVC withTopBar:(BOOL)topBarOrNot{
    GSModalContainerView* modalContainerView = [self getCurrentModalViewContainer];
    [self cleanViewControllerModal];
    [destinationVC willMoveToParentViewController:self];
    ((BaseViewController*)destinationVC).currentPresenterViewController = self;
    [modalContainerView setContainedController:destinationVC];
    [self addChildViewController:destinationVC];
    [destinationVC didMoveToParentViewController:self];
    self.currentModalViewController = destinationVC;
    if([self.currentModalViewController respondsToSelector:@selector(createTopBar)]){
        [self.currentModalViewController performSelector:@selector(createTopBar)];
    }

    [modalContainerView hideHeader:!topBarOrNot];
    [modalContainerView.superview bringSubviewToFront:modalContainerView];
    self.modalContainerView.hidden = NO;
}

- (void)dismissControllerModal{
    GSModalContainerView* modalContainerView = [self getCurrentModalViewContainer];
    
    [self cleanViewControllerModal];
    
    [modalContainerView.superview sendSubviewToBack:modalContainerView];
    modalContainerView.modalTitleLabel.text = @"";
    self.modalContainerView.hidden = YES;
    [self showArrows];
    [self setupNotificationsLabel];
}

- (void)setTitleForModal:(NSString*)theTitle{
    if(self.currentPresenterViewController){
        [self.currentPresenterViewController setTitleForModal:[theTitle uppercaseString]];
    }else{
        GSModalContainerView* modalContainerView = [self getCurrentModalViewContainer];
        modalContainerView.modalTitleLabel.text = [theTitle uppercaseString];
    }
}

- (void)showSuggestedUsersController{
    UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    FashionistaUserListViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(USERLIST_VC) stringValue]];
    
    [self prepareViewController:nextViewController withParameters:nil];
    [nextViewController setSearchContext:FASHIONISTAS_SEARCH];
    nextViewController.userListMode = SUGGESTED;
    [self showViewControllerModal:nextViewController];
    [self setTitleForModal:@"SUGGESTED USERS"];
}

@end
