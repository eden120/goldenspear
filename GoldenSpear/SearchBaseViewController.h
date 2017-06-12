//
//  SearchBaseViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

// Possible search contexts
typedef enum searchContext
{
    PRODUCT_SEARCH,
    TRENDING_SEARCH,
    BRANDS_SEARCH,
    FASHIONISTAS_SEARCH,
    FASHIONISTAS_LIKE,
    FASHIONISTAPOSTS_SEARCH,
    NOTIFICATIONS_SEARCH,
    HISTORY_SEARCH,
    STYLES_SEARCH,
    
    maxSearchContexts
}
searchContext;

// Periods available for history search
typedef enum historyPeriod
{
    TODAY,
    PASTWEEK,
    PASTMONTH,
    SIXMONTHS,
    ONEYEAR,
    
    maxHistoryPeriods
}
historyPeriod;

// Types available for fashionista search
typedef enum fashionistaPostType
{
    ALLPOSTS,
    ARTICLE,
    TUTORIAL,
    REVIEW,
    
//    WARDROBE,
    
    maxFashionistaPostTypes
}
fashionistaPostType;

// Follows filters for Fashionistas SearchstringForBarTitle
typedef enum followingRelationships
{
    ALLSTYLISTS,
    FOLLOWED,
    FOLLOWERS,
    LIKEUSERS,
    SUGGESTED,
    SOCIAL_NETWORK,
//    FOLLOWEDBYMYFOLLOWED,
    
    maxFollowingRelationships
}
followingRelationships;

#ifndef _OSAMA_
@protocol SearchBaseViewDelegate;
#endif

@interface SearchBaseViewController : BaseViewController <SlideButtonViewDelegate, UITextFieldDelegate>

// Search queue
@property NSMutableArray * searchQueue;
@property NSMutableArray * forwardSearchQueue;


@property int vcName;

// Search Context
@property searchContext searchContext;
-(NSString *) getSearchContextString;

// History period
@property historyPeriod searchPeriod;

// Fashionista Post Type
@property fashionistaPostType searchPostType;

// Fashionista Relationships
@property followingRelationships searchStylistRelationships;

// Current Ad shown
@property BackgroundAd * currentBackgroundAd;

// Reference Product to get the looks
@property GSBaseElement * getTheLookReferenceProduct;

// Specific info for Following/Followers searches
@property NSArray * fashionistasMappingResult;
@property NSNumber * fashionistasOperation;

// Suggested filters
@property NSMutableArray * suggestedFilters;
@property NSMutableArray * suggestedFiltersFound;
@property NSMutableArray * suggestedFiltersObject;

// Successful terms
@property NSMutableArray * successfulTerms;
@property NSMutableArray * inspireTerms;
@property NSMutableArray * successfulTermsObject;
@property NSString * notSuccessfulTerms;
@property NSMutableArray * successfulTermProductCategory;
@property NSMutableArray * successfulTermIdProductCategory;

// Search results
@property GSBaseElement * selectedResult;
@property GSBaseElement * productTagItem;
@property SearchQuery * currentSearchQuery;
@property NSMutableArray * resultsGroups;
@property NSMutableArray * resultsArray;

// Fetch current user wardrobes to properly show the hanger button
@property NSFetchedResultsController * wardrobesFetchedResultsController;
@property NSFetchRequest * wardrobesFetchRequest;

// Fetch current user follows
@property NSFetchedResultsController * followsFetchedResultsController;
@property NSFetchRequest * followsFetchRequest;

@property NSMutableArray * userWardrobesElements;

// Manage adding an item to a wardrobe
@property NSString * addingProductsToWardrobeID;
@property Wardrobe * addingProductsToWardrobe;
@property BOOL bAddingProductsToPostContentWardrobe;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *addToWardrobeVCContainerView;
- (void)closeAddingItemToWardrobeHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;

// Manage searching by filter
@property (weak, nonatomic) IBOutlet UIView *filterSearchVCContainerView;
-(void) hideFilterSearch;

// 'Add Search Term' textfield
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraints;
@property (weak, nonatomic) IBOutlet UITextField *addTermTextField;

@property (weak, nonatomic) IBOutlet UIView *webViewContrainer;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property BOOL fashionistaSearch;

- (void)hideAddSearchTerm;
- (BOOL)shouldCreateSlideLabel;
-(void)hideBackgroundAddButton;
-(void) setBackgroundImage;

// Manage search terms
-(void) addSearchTermWithName:(NSString *) name animated:(BOOL) bAnimated;
-(void) addSearchTermWithObject:(NSObject *) object animated:(BOOL) bAnimated;
-(void) addSearchTermWithObject:(NSObject *) object animated:(BOOL) bAnimated performSearch:(BOOL) bPerformSearch checkSearchTerms:(BOOL) bCheck;
-(void) removeSearchTermAtIndex:(int) iIndex checkSuggestions:(BOOL) bCheck;

// make the call to the server to check the search terms, getting the suggested filters, etc
-(void) checkSearchTerms:(BOOL) afterSearch;
// update the search for the terms that are currently loaded
- (BOOL)updateSearchForTermsChanges;
// hide the filter view
-(void)hideFiltersView: (BOOL) bAnimated;
-(void) hideFiltersView: (BOOL) bAnimated performSearch:(BOOL) bSearch;
// run the update process for the collectionview
-(void)updateCollectionViewFiltersWithPredicate:(NSPredicate *)predicate orEntity:(NSString *)entityPredicate withOrderArray:(NSArray *)_arrSortOrderForSuggestedKeyword andOrdeAscending:(NSArray *)_arrSortAscendingForSuggestedKeyword;
// restarting the search
- (void)restartSearch;
- (void)searchProduct; //search on tagging product search
// Constraints
@property (weak, nonatomic) IBOutlet UIView *selectFeaturesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopSearchFeatureView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMainCollectionViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMainCollectionViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSecondCollectionViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSecondCollectionViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTrailingAlphabet;

// zoom of the filter view
@property UIImageView * zoomView;
@property UIView * zoomBackgroundView;
@property UILabel * zoomLabel;
@property UIButton * btnZoomView;

// check search activity indicator
@property UIActivityIndicatorView *activityIndicatorCheckSearch;
@property UIActivityIndicatorView *activityIndicatorCheckSuggestions;
@property UILabel * activityIndicatorCheckSuggestionsLabel;

@property NSMutableArray * filteredFilters;
@property NSMutableDictionary * foundSuggestionsDirectly;
@property NSMutableDictionary * foundSuggestions;
@property NSMutableDictionary * foundSuggestionsPC;
@property NSMutableDictionary * foundSuggestionsLocations;
@property NSMutableDictionary * foundSuggestionsStyleStylist;
@property NSMutableDictionary * foundSuggestionsBrand;

@property (weak, nonatomic) IBOutlet UIView *tapView;
@property BOOL bFromTagSearch;
@property NSMutableArray * categoryTerms;
@property NSArray *inspireParams;
@property (weak, nonatomic) IBOutlet UIView *inspireView;
@property (weak, nonatomic) IBOutlet UIView *inspireImageContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inspireViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *inspireImageView;
@property (weak, nonatomic) IBOutlet UIButton *inspireButton;
-(void) actionAfterAutoLogIn;

-(void) hideZoomView;
-(BOOL) zoomViewVisible;
-(void) showInspire;

#ifndef _OSAMA_
@property (nonatomic, assign) id <SearchBaseViewDelegate> searchBaseDelegate;
#endif
@end

#ifndef _OSAMA_
@protocol SearchBaseViewDelegate <NSObject>
@optional
-(void) finishItemToWardrobe:(SearchBaseViewController *)viewcontroller Item:(GSBaseElement*)tagProduct WardrobeID:(NSString*)wardrobeID;
@end
#endif

@interface SectionProductType : NSObject
@property (nonatomic) NSArray * arElements;
@property (nonatomic) int iLevel;
@end

@interface IdxAlphabet : NSObject
@property (nonatomic) int iSection;
@property (nonatomic) int iIndex;
@end

