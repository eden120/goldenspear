//
//  FilterManager.h
//  GoldenSpear
//
//  Created by Alberto Seco on 27/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchBaseViewController.h"

@interface FilterManager : NSObject

@property (nonatomic, retain) SearchBaseViewController *    searchBaseVC;                   // search view controller
@property (nonatomic, retain) SlideButtonView * suggestedFiltersRibbonView;                 // suggested filter ribbon
@property (nonatomic, retain) UICollectionView * filtersCollectionView;                      // collection view ehere they are shown
@property (nonatomic, retain) UIView *  filtersView;                                  // view that shows the filters

@property (nonatomic, retain) NSLayoutConstraint *constraintTopSearchFilterView;       // contraint top filters view

// zoom of the filter view
@property UIImageView * zoomView;
@property UIView * zoomBackgroundView;
@property UILabel * zoomLabel;
@property UIButton * btnZoomView;

// gender selected
@property (readonly) int    iGenderSelected;
// product group selected. it is valid when searching product, because it is mandatory to select first the product type
@property (readonly) ProductGroup * selectedProductGroup;

// variables que controlan los filteros de donde se obtienen. Estas variables han de ser asignadas por el controlador searchBaseViewController
@property BOOL bSuggestedKeywordsFromSearch;
@property BOOL bRestartingSearch;

//+ (FilterManager *)sharedFilterManager;

-(void) initAllStructures;

-(void) initFilters;

-(void) initBottomShadow;

-(void) initSelectedSlide;

-(void) initFoundSuggestions;

-(void) initSelectedProductGroups;

-(void) restartSearch;

-(void) getFiltersForProductSearch;  // get filters when the user is searching products

-(void) getFiltersForGeneralSearch;  // get filter in the other search context

-(void) getFiltersWithoutSearch;

-(void) getFiltersGenders;
-(void) getFiltersProductGroupsOfGender:(int) iGender;
-(void) getFiltersForProductGroup:(ProductGroup *) productGroup;

-(void) setupSuggestedFiltersRibbonView;
-(void) hideAlphabet;

// show / hide filters
-(void) showFiltersView:(BOOL) bAnimated;
-(void) hideFiltersView: (BOOL) bAnimated;
-(void) hideFiltersView: (BOOL) bAnimated performSearch:(BOOL) bSearch;


// function for the collection view that shows the filters
-(unsigned long) numberOfSectionsFilterForCelltype:(NSString *)cellType;
-(unsigned long) numberOfItemsInSectionFilter:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType;
-(BOOL)shouldReportResultsforSection:(int)section;
-(NSString *) getHeaderTitleForFilterCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath;
-(NSArray *)getContentFilterForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath;
-(BOOL) actionForFilterSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath;
-(void) expandFilterButton:(UIButton *)sender;
-(void) finishReloadingCollectionView;

// function to load suggestions from arCheckSearchObjects, and return the feature gender if there is only one gender
-(Feature *) loadSuggestionsFromArray:(NSMutableArray *)arCheckQuery;

// setup filters
-(void) setupFiltersOfGender;
-(void) setupFiltersForGender;
-(void) setupFiltersLocallyForObject:(NSObject *) objectRibbon andButtonEntry:(int)buttonEntry;
-(void) setupFiltersFromSearchForObject:(NSObject *) objectRibbon;
-(void) setupFiltersFromSearchSuggested:(NSArray *) mappingResult;

// remove keyword from search
-(void) removeFromFilterObject:(NSObject *)objToRemove andCheckSearch:(BOOL) bCheckSearch;

// alphabet
-(void) initBrandsAlphabet;

// zoom icon view
-(void) initZoomView;
-(void) zoomFilterButton:(UIButton *)sender;
-(void) hideZoomView;
-(BOOL) zoomViewVisible;


@end
