//
//  FilterManager.m
//  GoldenSpear
//
//  Created by Alberto Seco on 27/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "FilterManager.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+StoryboardManagement.h"

#import "BDKCollectionIndexView.h"
#import "CoreDataQuery.h"

/*
 @interface SectionProductType : NSObject
 @property (nonatomic) NSArray * arElements;
 @property (nonatomic) int iLevel;
 @end
 
 @implementation SectionProductType
 @end
 */

#define kConstraintTopSearchFilterViewVisible 0
#define kConstraintTopSearchFilterViewVisibleStylist 25
#define kConstraintTopSearchFilterViewHidden -0-35
#define kConstraintTopSearchFilterViewVisibleWhenEmbedded -30
#define kConstraintTopSearchFilterViewHiddenWhenEmbedded -30-35

@implementation FilterManager
{
    // Suggested filters
    NSMutableArray * suggestedFilters;
    NSMutableArray * suggestedFiltersObject;
    NSMutableArray * suggestedFiltersFound;
    NSMutableDictionary * foundSuggestions; // array with the suggestions from the server
    NSMutableArray * filteredFilters;       // array with the filters that will be shown
    
    NSMutableArray * arSectionsFilter;
    
    // array of product group selected. When the suggested filters comes from other conectext it can be more than one product group parent selected
    NSMutableArray * arSelectedProductGroups;
    
    // number of sub product categories selected
    int iNumSubProductGroups;
    
    // array de las sub product ctagoeries seleccionadas
    NSMutableArray * arSelectedSubProductGroup;
    
    // array de las categories expandidas
    NSMutableArray * arExpandedSubProductGroup;
    
    // array que contiene las fetures de precios
    NSMutableArray * arrayFeaturesPrices;
    
    
    NSMutableArray * productGroupsParentForSuggestedKeywords;
    
    // successfulTerms
    NSMutableArray * successfulTermProductGroup;
    NSMutableArray * successfulTermIdProductGroup;
    
    BOOL bUpdatingSelectionColor; // variable to set that it is only for change the color of the selection of the collection view where the filters are shown
    
    // variables que indican que tab se ha seleccionado
    int iLastSelectedSlide;
    NSString * sLastSelectedSlide;
    
    BDKCollectionIndexView *scrollBrandAlphabetBDK;
    NSMutableDictionary * dictAlphabet;
    BOOL scrollByAlphabet;
    
    // bottom shadow of the filters
    UIView * viewBottomFilterShadow;
}

//#pragma mark - Singleton
//+ (FilterManager *)sharedFilterManager
//{
//    static FilterManager *sharedMyFilterManager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedMyFilterManager = [[self alloc] init];
//    });
//    return sharedMyFilterManager;
//}

- (id)init
{
    if (self = [super init])
    {
        // init properties with default values
        
        suggestedFiltersObject = nil;
        suggestedFiltersFound = nil;
        foundSuggestions = nil; // array with the suggestions from the server
        filteredFilters = nil;       // array with the filters that will be shown
        
        arSectionsFilter = nil;
        
        // array of product group selected. When the suggested filters comes from other conectext it can be more than one product group parent selected
        arSelectedProductGroups = nil;
        
        // array que contiene las fetures de precios
        arrayFeaturesPrices = nil;
        
        productGroupsParentForSuggestedKeywords = nil;
        
        // successfulTerms
        successfulTermProductGroup = nil;
        successfulTermIdProductGroup = nil;
        
        self.zoomView = nil;
        
        arSelectedSubProductGroup = [[NSMutableArray alloc] init];
        
        arExpandedSubProductGroup = [[NSMutableArray alloc] init];
        
        _filtersCollectionView = nil;
        _filtersView = nil;
        
        [self initAllStructures];
    }
    return self;
}

-(void) initAllStructures
{
    _iGenderSelected = 0;
    
    _bSuggestedKeywordsFromSearch = YES;
    
    _selectedProductGroup = nil;
    
    bUpdatingSelectionColor = NO;
    
    scrollByAlphabet = NO;
    
    [self initSelectedSlide];
    
    [self initFilters];
    
    [self initFoundSuggestions];
    
    [self initBottomShadow];
    
    [self initSelectedProductGroups];
    
    [self initStructuresForSuggestedKeywords];
}

- (void)dealloc
{
    // Should never be called, but just here for clarity really.
}

-(void) initFilters
{
    if(suggestedFilters == nil)
    {
        suggestedFilters = [[NSMutableArray alloc] init];
    }
    if(suggestedFiltersObject == nil)
    {
        suggestedFiltersObject = [[NSMutableArray alloc] init];
    }
    
    [suggestedFilters removeAllObjects];
    [suggestedFiltersObject removeAllObjects];
}

-(void) initBottomShadow
{
    viewBottomFilterShadow = [[UIView alloc] initWithFrame:CGRectMake(0,_filtersView.frame.size.height - 1, _filtersView.frame.size.width, 10.0)];
    viewBottomFilterShadow.hidden = YES;
    viewBottomFilterShadow.alpha = 0.0;
    viewBottomFilterShadow.backgroundColor = [UIColor whiteColor];
    viewBottomFilterShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
    viewBottomFilterShadow.layer.shadowOffset = CGSizeMake(0,-5);
    viewBottomFilterShadow.layer.shadowRadius = 5.0;
    viewBottomFilterShadow.layer.shadowOpacity = 0.5;
    
    [_filtersView addSubview:viewBottomFilterShadow];
}

-(void) initSelectedSlide
{
    sLastSelectedSlide = @"";
    iLastSelectedSlide = 0;
}

-(void) initFoundSuggestions
{
    if (foundSuggestions != nil)
    {
        [foundSuggestions removeAllObjects];
    }
    else
    {
        foundSuggestions = [[NSMutableDictionary alloc]init];
    }
}

-(void) initSelectedProductGroups
{
    if (arSelectedProductGroups == nil)
    {
        arSelectedProductGroups = [[NSMutableArray alloc] init];
    }
    else
    {
        [arSelectedProductGroups removeAllObjects];
    }
}

-(void) initStructuresForSuggestedKeywords
{
    if (productGroupsParentForSuggestedKeywords != nil)
    {
        [productGroupsParentForSuggestedKeywords removeAllObjects];
    }
    else
    {
        productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
    }
    
    if (arrayFeaturesPrices != nil)
    {
        [arrayFeaturesPrices removeAllObjects];
    }
    else
    {
        arrayFeaturesPrices = [[NSMutableArray alloc] init];
    }
    
    if (successfulTermProductGroup != nil)
    {
        [successfulTermProductGroup removeAllObjects];
    }
    else
    {
        successfulTermProductGroup = [[NSMutableArray alloc]init];
    }
    
    if (successfulTermIdProductGroup != nil)
    {
        [successfulTermIdProductGroup removeAllObjects];
    }
    else
    {
        successfulTermIdProductGroup = [[NSMutableArray alloc]init];
    }
    
    if (_selectedProductGroup != nil)
    {
        //        [_successfulTermProductGroup addObject:_selectedProductGroup];
        //        [successfulTermIdProductGroup addObject:_selectedProductGroup.idProductGroup];
        if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
        {
            NSMutableArray * arDescendants = [_selectedProductGroup getAllDescendants];
            for(ProductGroup * pg in arDescendants)
            {
                [successfulTermProductGroup addObject:pg];
                [successfulTermIdProductGroup addObject:pg.idProductGroup];
            }
        }
        else
        {
            for (ProductGroup * pgParent in arSelectedProductGroups)
            {
                //                [successfulTermProductGroup addObject:pgParent];
                //                [successfulTermIdProductGroup addObject:pgParent.idProductGroup];
                
                NSMutableArray * arDescendants = [pgParent getAllDescendants];
                for(ProductGroup * pg in arDescendants)
                {
                    [successfulTermProductGroup addObject:pg];
                    [successfulTermIdProductGroup addObject:pg.idProductGroup];
                }
            }
        }
        
    }
    //    else
    //    {
    //        if (self.searchBaseVC.searchContext != PRODUCT_SEARCH)
    //        {
    //            for (ProductGroup * pgParent in arSelectedProductGroups)
    //            {
    //                [successfulTermProductGroup addObject:pgParent];
    //                [successfulTermIdProductGroup addObject:pgParent.idProductGroup];
    //
    //                NSMutableArray * arDescendants = [pgParent getAllDescendants];
    //                for(ProductGroup * pg in arDescendants)
    //                {
    //                    [successfulTermProductGroup addObject:pg];
    //                    [successfulTermIdProductGroup addObject:pg.idProductGroup];
    //                }
    //            }
    //        }
    //
    //    }
    
}

-(void) restartSearch
{
    _bRestartingSearch = YES;
    
    _selectedProductGroup = nil;
    iNumSubProductGroups = 0;
    [arSelectedSubProductGroup removeAllObjects];
    
    [self initSelectedSlide];
    
    [self initFilters];
    
    [self initFoundSuggestions];
    
}


-(long) iIdxFilterSelected:(NSString*) sFilter
{
    long iIdxRes = -1;
    long iIdx = 0;
    
    NSString * sFilterTrimmed = [[sFilter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    for (NSObject * searchTerm in self.searchBaseVC.successfulTerms)
    {
        NSString * sSearchTerm = nil;
        NSString * sSearchTermAux = nil;
        if ([searchTerm isKindOfClass:[NSString class]])
        {
            sSearchTerm = (NSString *)searchTerm;
        }
        else if ([searchTerm isKindOfClass:[ProductGroup class]])
        {
            sSearchTerm = ((ProductGroup *)searchTerm).app_name;
            sSearchTermAux =  ((ProductGroup *)searchTerm).name;
        }
        else if ([searchTerm isKindOfClass:[FeatureGroup class]])
        {
            sSearchTerm = ((FeatureGroup *)searchTerm).app_name;
            sSearchTermAux =  ((FeatureGroup *)searchTerm).name;
        }
        else if ([searchTerm isKindOfClass:[Feature class]])
        {
            sSearchTerm = ((Feature *)searchTerm).app_name;
            sSearchTermAux =  ((Feature *)searchTerm).name;
        }
        else if ([searchTerm isKindOfClass:[Brand class]])
        {
            sSearchTerm = ((Brand *)searchTerm).name;
        }
        NSString * searchTermTrimmed = [[sSearchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([searchTermTrimmed.lowercaseString isEqualToString:sFilterTrimmed.lowercaseString])
        {
            iIdxRes = iIdx;
            break;
        }
        
        if (sSearchTermAux != nil)
        {
            NSString * searchTermTrimmed = [[sSearchTermAux stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            if ([searchTermTrimmed.lowercaseString isEqualToString:sFilterTrimmed.lowercaseString])
            {
                iIdxRes = iIdx;
                break;
            }
        }
        iIdx++;
        
    }
    
    return iIdxRes;
}

-(Feature *) loadSuggestionsFromArray:(NSMutableArray *)arCheckQuery
{
    bUpdatingSelectionColor = NO;
    
    [self initFoundSuggestions];
    
    int iGenders = 0;
    Feature * featGender = nil;
    for (CheckSearch *checkSearch in arCheckQuery)
    {
        if(checkSearch.keyword)
        {
            [foundSuggestions setObject:checkSearch.keyword forKey:checkSearch.keyword];
            
            // check if the keyword is a gender
            Feature *feat = [self getFeatureFromId:checkSearch.keyword];
            if (feat != nil)
            {
                NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([sNameFeatureGroup isEqualToString:@"gender"])
                {
                    featGender = feat;
                    iGenders++;
                }
            }
            //            if([checkSearch.results integerValue] == 0)
            //                [foundSuggestions setObject:checkSearch.keyword forKey:checkSearch.keyword];
            //            else if([checkSearch.results integerValue] == -2)
            //                [_foundSuggestionsPC setObject:checkSearch.keyword forKey:checkSearch.keyword];
            //            else if([checkSearch.results integerValue] == -3)
            //                [_foundSuggestionsBrand setObject:checkSearch.keyword forKey:checkSearch.keyword];
            //            long iValue = [checkSearch.results integerValue];
            //            if (iValue < 0)
            //            {
            //                long iIdx = labs(iValue)-1;
            //                NSString * sKey = [NSString stringWithFormat:@"%li", iIdx];
            //                NSMutableArray * arr =[foundSuggestionsDirectly objectForKey:sKey];
            //                if (arr == nil)
            //                {
            //                    NSMutableArray * arrObjects = [[NSMutableArray alloc] init];
            //                    [arrObjects addObject:checkSearch];
            //                    [foundSuggestionsDirectly setObject:arrObjects forKey:sKey];
            //                }
            //                else
            //                {
            //                    [arr addObject:checkSearch];
            //                }
            //
            //
            //            }
        }
    }
    
    if (iGenders == 1)
        return featGender;
    else
        return nil;
}

#pragma mark - Brands alphabet

#define kDefaultFontSizeAlphabet 10
#define kHeightLetterAlphabet 20
#define kWidthAlphabet 20

-(void) initAlphabetwithArray:(NSMutableArray *)arrayElements  withSections:(BOOL) bSections
{
    if (arrayElements.count<= 0)
    {
        [self hideAlphabet];
        return;
    }
    
    if (scrollBrandAlphabetBDK != nil)
    {
        [scrollBrandAlphabetBDK removeFromSuperview];
    }
    
    if (dictAlphabet != nil)
    {
        [dictAlphabet removeAllObjects];
    }
    else
    {
        dictAlphabet = [[NSMutableDictionary alloc] init];
    }
    
    // initi dictionary will all indexes to -1
    int iIdx = 1;
    IdxAlphabet * idxAlphabet= [IdxAlphabet new];
    idxAlphabet.iIndex = -1;
    idxAlphabet.iSection = -1;
    [dictAlphabet setObject:idxAlphabet forKey:@"#"];
    for(int i = 65; i <= 90; i++)
    {
        NSString *stringChar = [NSString stringWithFormat:@"%c", i];
        IdxAlphabet * idxAlphabet= [IdxAlphabet new];
        idxAlphabet.iIndex = -1;
        idxAlphabet.iSection = -1;
        [dictAlphabet setObject:idxAlphabet forKey:stringChar];
    }
    
    NSMutableArray * finalArrayAlphabet = [[NSMutableArray alloc] initWithArray:arrayElements];;
    if (bSections)
    {
        [finalArrayAlphabet removeAllObjects];
        
        int iSection = 0;
        for(SectionProductType * section in arrayElements)
        {
            if (section.iLevel == 0)
            {
                for (ProductGroup * pg in section.arElements)
                {
                    [finalArrayAlphabet addObject:[pg getNameForApp]];
                }
            }
            iSection++;
        }
    }
    
    // set dictionary of letter with the index
    int iNumLettersInAlphabet = 0;
    int iIdxElementFiltered = 0;
    for (int iIdxElement = 0; iIdxElement < [finalArrayAlphabet count]; iIdxElement++)
    {
        NSString * tmpElement = [finalArrayAlphabet objectAtIndex:iIdxElement];
        
        if(!(tmpElement == nil))
        {
            if(!([tmpElement isEqualToString:@""]))
            {
                NSString * initialCharacter =[tmpElement.uppercaseString substringToIndex:1];
                int iChar = [initialCharacter characterAtIndex:0];
                NSString * key = @"";
                if ((iChar >= 65) && (iChar <= 90))
                {
                    key = initialCharacter;
                }
                else
                {
                    key = @"#";
                }
                IdxAlphabet * iIdx = [dictAlphabet objectForKey:key];
                if (iIdx.iSection == -1)
                {
                    iIdx.iSection = 0;
                    iIdx.iIndex = iIdxElementFiltered;
                    //                    iIdx = [NSNumber numberWithInt:iIdxElementFiltered];
                    if (bSections)
                    {
                        int iSection = 0;
                        BOOL bTrobat = NO;
                        // buscar la seccion y index dentro de la seccion
                        for(SectionProductType * section in arrayElements)
                        {
                            if (section.iLevel == 0)
                            {
                                int iIndex = 0;
                                for (ProductGroup * pg in section.arElements)
                                {
                                    if ([[pg getNameForApp] isEqualToString:tmpElement])
                                    {
                                        iIdx.iSection = iSection;
                                        iIdx.iIndex = iIndex;
                                        //                                        [dictAlphabet setObject:idxNew forKey:key];
                                        bTrobat = YES;
                                        break;
                                    }
                                    iIndex++;
                                    
                                }
                            }
                            if (bTrobat)
                            {
                                break;
                            }
                            iSection++;
                        }
                    }
                    //                    else
                    //                    {
                    //                        [dictAlphabet setObject:iIdx forKey:key];
                    //                    }
                    iNumLettersInAlphabet++;
                }
                iIdxElementFiltered ++;
            }
        }
    }
    
    
    UIFont * fontDefault = [UIFont fontWithName:@"AvenirNext-Regular" size:kDefaultFontSizeAlphabet];
    UIFont * fontZoom = [UIFont fontWithName:@"AvenirNext-Bold" size:(kDefaultFontSizeAlphabet*2.5)];
    
    
    float fTotalHeight = _filtersView.frame.size.height - 60 - self.searchBaseVC.topBarHeight- _suggestedFiltersRibbonView.frame.size.height - 4;
    if ([self.searchBaseVC shouldCreateSlideLabel])
        fTotalHeight = _filtersView.frame.size.height - 85 - self.searchBaseVC.topBarHeight - _suggestedFiltersRibbonView.frame.size.height - 4;
    
    float fHeightButton = kHeightLetterAlphabet;
    
    scrollBrandAlphabetBDK = [BDKCollectionIndexView indexViewWithFrame:CGRectMake(_filtersView.frame.size.width-fHeightButton, _suggestedFiltersRibbonView.frame.size.height + _filtersView.frame.origin.y + self.searchBaseVC.topBarHeight + 4, kWidthAlphabet, fTotalHeight) indexTitles:@[]];
    
    [scrollBrandAlphabetBDK.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [scrollBrandAlphabetBDK.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [scrollBrandAlphabetBDK.layer setShadowRadius:0.5];
    [scrollBrandAlphabetBDK.layer setShadowOpacity:0.5];
    
    scrollBrandAlphabetBDK.touchStatusBackgroundColor = [UIColor grayColor];
    scrollBrandAlphabetBDK.touchStatusViewAlpha = 0.8;
    scrollBrandAlphabetBDK.font = fontDefault;
    scrollBrandAlphabetBDK.fontZoom = fontZoom;
    scrollBrandAlphabetBDK.fontZoomColor = [UIColor whiteColor];
    scrollBrandAlphabetBDK.tintColor = [UIColor whiteColor];
    
    [scrollBrandAlphabetBDK addTarget:self action:@selector(indexViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSMutableArray * sortedKeyArray = [[NSMutableArray alloc] initWithArray:[[dictAlphabet allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    NSMutableArray * arIdxBDK = [NSMutableArray new];
    
    for(NSString * key in sortedKeyArray)
    {
        IdxAlphabet * idx = [dictAlphabet objectForKey:key];
        if (idx.iSection != -1)
        {
            [arIdxBDK addObject:key];
            iIdx++;
        }
    }
    
    scrollBrandAlphabetBDK.indexTitles = arIdxBDK;
    [self.searchBaseVC.view addSubview:scrollBrandAlphabetBDK];
    [self.searchBaseVC.view bringSubviewToFront:scrollBrandAlphabetBDK];
    
    [self.searchBaseVC.view layoutIfNeeded];
    
}

-(void) initBrandsAlphabet
{
    NSMutableArray * arElements = [[NSMutableArray alloc] init];
    
    for (int iIdxBrand = 0; iIdxBrand < [[self.searchBaseVC.secondFetchedResultsController fetchedObjects] count]; iIdxBrand++)
    {
        Brand * tmpBrand = [[self.searchBaseVC.secondFetchedResultsController fetchedObjects] objectAtIndex:iIdxBrand];
        
        if(!(tmpBrand == nil))
        {
            if(!(tmpBrand.idBrand == nil))
            {
                if(!([tmpBrand.idBrand isEqualToString:@""]))
                {
                    if([foundSuggestions count] == 0 || [foundSuggestions objectForKey:tmpBrand.idBrand])
                    {
                        [arElements addObject:tmpBrand.name];
                    }
                }
            }
        }
    }
    
    [self initAlphabetwithArray:arElements withSections:NO];
}

-(void) hideAlphabet
{
    if (scrollBrandAlphabetBDK != nil)
    {
        scrollBrandAlphabetBDK.hidden = YES;
        [scrollBrandAlphabetBDK removeFromSuperview];
    }
    [self.searchBaseVC.view layoutIfNeeded];
}

- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender
{
    IdxAlphabet * idx = [dictAlphabet objectForKey:sender.currentIndexTitle];
    //    NSLog(@"Alphabet %i %i", idx.iSection, idx.iIndex);
    if ((idx.iSection > -1) && (idx.iIndex > -1))
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx.iIndex inSection:idx.iSection];
        // scrolling here does work
        scrollByAlphabet = YES;
        [_filtersCollectionView scrollToItemAtIndexPath:indexPath
                                       atScrollPosition:UICollectionViewScrollPositionTop
                                               animated:YES];
    }
}


#pragma mark - Load Filters

-(void) getFiltersGenders
{
    NSMutableArray * arFeatures = [self getFeaturesOfFeatureGroupByName:@"gender"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [arFeatures sortedArrayUsingDescriptors:sortDescriptors];
    
    [self initFilters];
    for(Feature *feat in sortedArray)
    {
        [suggestedFiltersObject addObject:feat];
        [suggestedFilters addObject:feat.idFeature];
    }
}

-(void) getFiltersProductGroupsOfGender:(int) iGender
{
    [self initFilters];
    
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"parent = null"];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicateObject:predicate sortingWithKey:@"app_name" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        if ([tmpProductGroup.visible boolValue])
                        {
                            if ([tmpProductGroup checkGender:iGender])
                            {
                                [suggestedFiltersObject addObject:tmpProductGroup];
                                [suggestedFilters addObject:tmpProductGroup.idProductGroup];
                            }
                            
                        }
                    }
                }
            }
        }
        
        // add the brands
        NSMutableArray * allBrands = [self getAllBrands];
        for(Brand * b in allBrands)
        {
            [suggestedFiltersObject addObject:b];
            [suggestedFilters addObject:b.idBrand];
        }
    }
}

-(void) getFiltersForProductGroup:(ProductGroup *) productGroup
{
    if (productGroup != nil)
    {
        [suggestedFilters removeAllObjects];
        [suggestedFiltersObject removeAllObjects];
        
        
        NSMutableArray * arFeatureGroupsOfProductCategory = [productGroup getFeturesGroupExcept:@""];
        for (FeatureGroup * fg in arFeatureGroupsOfProductCategory)
        {
            if ([fg.name isEqualToString:@"Gender"])
            {
                NSLog(@"FeatureGroup gander");
            }
            for (Feature *feat in fg.features)
            {
                if (![suggestedFilters containsObject:feat.idFeature])
                {
                    [suggestedFilters addObject:feat.idFeature];
                    [suggestedFiltersObject addObject:feat];
                }
            }
            
            NSMutableArray * arFGDescendatns = [fg getAllChildren];
            for (FeatureGroup *fgDescendant in arFGDescendatns)
            {
                for (Feature *feat in fgDescendant.features)
                {
                    if (![suggestedFilters containsObject:feat.idFeature])
                    {
                        [suggestedFilters addObject:feat.idFeature];
                        [suggestedFiltersObject addObject:feat];
                    }
                }
            }
            
            
        }
        
        // get all the style
        if (![suggestedFilters containsObject:productGroup.idProductGroup])
        {
            [suggestedFilters addObject:productGroup.idProductGroup];
            [suggestedFiltersObject addObject:productGroup];
        }
        NSMutableArray * children = [productGroup getAllDescendants];
        // check that there is at least one child visible
        for(ProductGroup * child in children)
        {
            if ([child.visible boolValue])
            {
                if ([child checkGender:_iGenderSelected])
                {
                    if (![suggestedFilters containsObject:child.idProductGroup])
                    {
                        [suggestedFilters addObject:child.idProductGroup];
                        [suggestedFiltersObject addObject:child];
                    }
                    
                    NSMutableArray * arFeatureGroupsOfDescendant = [child getFeturesGroupExcept:@""];
                    for(FeatureGroup * fg in arFeatureGroupsOfDescendant)
                    {
                        NSMutableArray * arFGDescendatns = [fg getAllChildren];
                        for (FeatureGroup *fgDescendant in arFGDescendatns)
                        {
                            for (Feature *feat in fgDescendant.features)
                            {
                                if (![suggestedFilters containsObject:feat.idFeature])
                                {
                                    [suggestedFilters addObject:feat.idFeature];
                                    [suggestedFiltersObject addObject:feat];
                                }
                            }
                        }
                    }
                }
                
                //            NSString * sStyle = NSLocalizedString(@"_STYLE_",nil);
            }
        }
        
        
        NSMutableArray * allbrands = [self getAllBrands];
        for(Brand * brand in allbrands)
        {
            if (![suggestedFilters containsObject:brand.idBrand])
            {
                [suggestedFilters addObject:brand.idBrand];
                [suggestedFiltersObject addObject:brand];
            }
        }
        
        FeatureGroup *fgPrice = [self getFeatureGroupFromName:@"Price"];
        for (Feature *feat in fgPrice.features)
        {
            [suggestedFilters addObject:feat.idFeature];
            [suggestedFiltersObject addObject:feat];
            [arrayFeaturesPrices addObject:feat.idFeature];
        }
    }
}

-(void) getFiltersForProductSearch
{
    ProductGroup * pgSuccess;
    ProductGroup * pgSuccessParent = nil;
    _selectedProductGroup = nil;
    iNumSubProductGroups = 0;
    [arSelectedSubProductGroup removeAllObjects];
    //    [arExpandedSubProductGroup removeAllObjects];
    [self initStructuresForSuggestedKeywords];
    
    _iGenderSelected = 0;
    
    for (NSObject *obj in self.searchBaseVC.searchTermsListView.arrayButtons)
    {
        if ([obj isKindOfClass:[NSString class]])
        {
            NSString * sSuccesfulTerm = (NSString *)obj;
            // la funcion getKeywordElementForName, si el elemento es un product category este se añade al array de product catgeories donde se comprueba que existan los feature groups
            NSObject * object = [self getKeywordElementForName: sSuccesfulTerm];
            if ([object isKindOfClass:[FeatureGroup class]])
            {
                object = [self getFeatureFromName:sSuccesfulTerm];
            }
            
            if ([object isKindOfClass:[ProductGroup class]])
            {
                pgSuccess = (ProductGroup *)object;
                if ([successfulTermProductGroup containsObject:pgSuccess] == NO)
                {
                    [successfulTermProductGroup addObject:pgSuccess];
                }
                if (pgSuccess.parent != nil)
                {
                    if ([arSelectedSubProductGroup containsObject:pgSuccess] == NO)
                    {
                        iNumSubProductGroups++;
                        [arSelectedSubProductGroup addObject:pgSuccess];
                    }
                }
                
                pgSuccessParent = [pgSuccess getTopParent];
            }
            else if ([object isKindOfClass:[Feature class]])
            {
                Feature * feat = (Feature *)object;
                NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([sNameFeatureGroup isEqualToString:@"gender"])
                {
                    int iGender = [self getGenderFromName:feat.name];
                    _iGenderSelected += iGender;
                }
            }
        }
        else if ([obj isKindOfClass:[ProductGroup class]])
        {
            pgSuccess = (ProductGroup *)obj;
            if ([successfulTermProductGroup containsObject:pgSuccess] == NO)
            {
                [successfulTermProductGroup addObject:pgSuccess];
            }
            if (pgSuccess.parent != nil)
            {
                if ([arSelectedSubProductGroup containsObject:pgSuccess] == NO)
                {
                    iNumSubProductGroups++;
                    [arSelectedSubProductGroup addObject:pgSuccess];
                }
            }
            
            pgSuccessParent = [pgSuccess getTopParent];
        }
        else if ([obj isKindOfClass:[Feature class]])
        {
            Feature * feat = (Feature *)obj;
            NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([sNameFeatureGroup isEqualToString:@"gender"])
            {
                int iGender = [self getGenderFromName:feat.name];
                _iGenderSelected += iGender;
            }
        }
        else if ([obj isKindOfClass:[Brand class]])
        {
            
        }
    }
    
    // get all the id of the descendatns of the successful terms
    if (successfulTermIdProductGroup != nil)
    {
        [successfulTermIdProductGroup removeAllObjects];
        successfulTermIdProductGroup = nil;
    }
    
    successfulTermIdProductGroup = [[NSMutableArray alloc] init];
    for(ProductGroup *succesPG in successfulTermProductGroup)
    {
        //                if ([successfulTermIdProductGroup containsObject:succesPG.idProductGroup] == NO)
        //                    [successfulTermIdProductGroup addObject:succesPG.idProductGroup];
        NSMutableArray * temp = [succesPG getAllDescendants];
        for(ProductGroup * descendant in temp)
        {
            if ([successfulTermIdProductGroup containsObject:descendant.idProductGroup] == NO)
                [successfulTermIdProductGroup addObject:descendant.idProductGroup];
        }
    }
    
    
    //    if ((pgSuccessParent != nil) && (self.searchBaseVC.searchContext != FASHIONISTAPOSTS_SEARCH))
    if (pgSuccessParent != nil)
    {
        _selectedProductGroup = pgSuccessParent;
    }
    
    //if there are more than 1 product category then the selectedproduct ctagoery does not appear in the search terms view
    //    if ([_successfulTermProductGroup count] > 1)
    //    {
    //        [self.searchTermsListView removeButtonByObject:_selectedProductGroup];
    //    }
    
    if ((_iGenderSelected == 0) && (_selectedProductGroup == nil))
    {
        [self getFiltersGenders];
        [self hideFiltersView:YES];
    }
    else if ((_iGenderSelected == 0) && (_selectedProductGroup != nil))
    {
        [self getFiltersGenders];
        [self hideFiltersView:YES];
    }
    else if ((_iGenderSelected > 0) && (_selectedProductGroup == nil))
    {
        [self getFiltersProductGroupsOfGender:_iGenderSelected];
        [self hideFiltersView:YES];
    }
    else if ((_iGenderSelected > 0) && (_selectedProductGroup != nil))
    {
        [self getFiltersForProductGroup:_selectedProductGroup];
        [self hideFiltersView:YES];
    }
    
    if ([self.searchBaseVC.successfulTerms count] <= 0)
    {
        [self getFiltersGenders];
        [self hideFiltersView:YES];
    }
    
    [self setupSuggestedFiltersRibbonView];
    
    // operaciones para refrescar la collection view de los filtros
    [self.searchBaseVC initOperationsLoadingImages];
    [self.searchBaseVC.imagesQueue cancelAllOperations];
    [_filtersCollectionView reloadData];
}

-(void) getFiltersWithoutSearch
{
    if (_iGenderSelected < 1)
    {
        [self getFiltersGenders];
    }
    else
    {
        Feature * feat = [self getGenderFeatureFromIndex:_iGenderSelected];
        if (feat != nil)
        {
            [self.searchBaseVC addSearchTermWithObject:feat animated:YES performSearch:NO checkSearchTerms:YES];
            if (_selectedProductGroup == nil)
            {
                [self getFiltersProductGroupsOfGender:_iGenderSelected];
            }
            else
            {
                [self getFiltersForProductGroup:_selectedProductGroup];
            }
        }
        else
        {
            _iGenderSelected = 0;
        }
    }
    
    [self setupSuggestedFiltersRibbonView];
}

-(void) getLettersTo:(NSMutableArray *) arrLetter
{
    if (arrLetter != nil)
        [arrLetter removeAllObjects];
    else
        arrLetter = [[NSMutableArray alloc] init];
    
    [arrLetter addObject:@"#"];
    for(int i = 65; i <= 90; i++)
    {
        NSString *stringChar = [NSString stringWithFormat:@"%c", i];
        [arrLetter addObject:stringChar];
    }
    
}

#pragma mark - Show/hide Filters
-(void) showFiltersView:(BOOL) bAnimated
{
    [_filtersCollectionView setContentOffset:_filtersCollectionView.contentOffset animated:NO];
    //    [_filtersCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    
    //float yOffset = (self.parentViewController == nil) ? (220) : (183);
    if ((self.searchBaseVC.searchContext == FASHIONISTAPOSTS_SEARCH) || (self.searchBaseVC.searchContext == FASHIONISTAS_SEARCH))
    {
        _constraintTopSearchFilterView.constant = ((self.searchBaseVC.parentViewController == nil) ? (kConstraintTopSearchFilterViewVisibleStylist) : (kConstraintTopSearchFilterViewVisibleWhenEmbedded));
    }
    else
    {
        _constraintTopSearchFilterView.constant = ((self.searchBaseVC.parentViewController == nil) ? (kConstraintTopSearchFilterViewVisible) : (kConstraintTopSearchFilterViewVisibleWhenEmbedded));
    }
    [self.searchBaseVC.view layoutIfNeeded];
    
    [self.searchBaseVC.addTermButton setHidden:YES];
    
    
    if ((_filtersView.hidden == YES) || ((_filtersView.hidden == NO) && (_filtersCollectionView.alpha < 1.0)))
    {
        [_filtersCollectionView setAlpha:0.0];
        
        [_filtersView setHidden:NO];
        [_filtersCollectionView setHidden:NO];
        [_filtersView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.0]];
        _constraintTopSearchFilterView.constant = ((![self.searchBaseVC shouldCreateSlideLabel]) ? (kConstraintTopSearchFilterViewHidden) : (kConstraintTopSearchFilterViewHiddenWhenEmbedded));
        [self.searchBaseVC.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             [_filtersView setHidden:NO];
                             [_filtersCollectionView setHidden:NO];
                             
                             [_filtersView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.8]];
                             [_filtersCollectionView setAlpha:1.0];
                             if ((self.searchBaseVC.searchContext == FASHIONISTAPOSTS_SEARCH) || (self.searchBaseVC.searchContext == FASHIONISTAS_SEARCH))
                             {
                                 _constraintTopSearchFilterView.constant = ((self.searchBaseVC.parentViewController == nil) ? (kConstraintTopSearchFilterViewVisibleStylist) : (kConstraintTopSearchFilterViewVisibleWhenEmbedded));
                             }
                             else
                             {
                                 _constraintTopSearchFilterView.constant = ((self.searchBaseVC.parentViewController == nil) ? (kConstraintTopSearchFilterViewVisible) : (kConstraintTopSearchFilterViewVisibleWhenEmbedded));
                             }
                             
                             [_filtersView layoutIfNeeded];
                             
                             if (scrollBrandAlphabetBDK != nil)
                             {
                                 CGRect frameAlphabet = scrollBrandAlphabetBDK.frame;
                                 
                                 frameAlphabet.origin.y =  _suggestedFiltersRibbonView.frame.size.height + _filtersView.frame.origin.y + 4;
                                 float fTotalHeight = _filtersView.frame.size.height - 60 - _suggestedFiltersRibbonView.frame.size.height - 4;
                                 if (self.searchBaseVC.fromViewController != nil)
                                     fTotalHeight = _filtersView.frame.size.height - 85 - _suggestedFiltersRibbonView.frame.size.height - 4;
                                 frameAlphabet.size.height = fTotalHeight;
                                 
                                 scrollBrandAlphabetBDK.frame = frameAlphabet;
                             }
                         }
                         completion:^(BOOL finished) {
                             
                             [((UIImageView *)([self.searchBaseVC.mainCollectionView backgroundView])) setImage:nil];
                             [self.searchBaseVC hideBackgroundAddButton];
                             
                             //                         NSLog(@"Rect Alphabet Origin (%f, %f) Size(%f, %f)", scrollBrandAlphabetBDK.frame.origin.x, scrollBrandAlphabetBDK.frame.origin.y, scrollBrandAlphabetBDK.frame.size.width, scrollBrandAlphabetBDK.frame.size.height);
                             
                             
                             //                         if (scrollBrandAlphabetBDK != nil)
                             //                         {
                             //                             CGRect frameAlphabet = scrollBrandAlphabetBDK.frame;
                             //
                             //                             frameAlphabet.origin.y =  _suggestedFiltersRibbonView.frame.size.height + _filtersView.frame.origin.y;
                             //                             frameAlphabet.size.height = _filtersView.frame.size.height - 60 - _suggestedFiltersRibbonView.frame.size.height;
                             //
                             //                             scrollBrandAlphabetBDK.frame = frameAlphabet;
                             //                         }
                             
                             float fTotalHeight = _filtersView.frame.size.height - 60;// - _suggestedFiltersRibbonView.frame.size.height - 4;
                             if ([self.searchBaseVC shouldCreateSlideLabel])
                                 fTotalHeight = _filtersView.frame.size.height - 80;// - _suggestedFiltersRibbonView.frame.size.height - 4;
                             CGRect frameShadowBottom = viewBottomFilterShadow.frame;
                             frameShadowBottom.size.width = _filtersView.frame.size.width;
                             frameShadowBottom.origin.y = fTotalHeight;
                             viewBottomFilterShadow.frame = frameShadowBottom;
                             [_filtersView bringSubviewToFront:viewBottomFilterShadow];
                             viewBottomFilterShadow.hidden = NO;
                             viewBottomFilterShadow.alpha = 0.0;
                             
                             [UIView animateWithDuration:1.5
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^ {
                                                  viewBottomFilterShadow.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                              }
                              ];
                         }];
    }
}

-(void) hideFiltersView: (BOOL) bAnimated
{
    [self hideFiltersView:bAnimated performSearch:NO];
}

-(void) hideFiltersView: (BOOL) bAnimated performSearch:(BOOL) bSearch
{
    [self hideAlphabet];
    
    if(_filtersView.hidden == YES)
    {
        [_filtersView setHidden:YES];
        [_filtersCollectionView setHidden:YES];
        return;
    }
    
    [self.searchBaseVC.addTermButton setHidden:NO];
    
    if (bSearch)
    {
        [self.searchBaseVC updateSearchForTermsChanges];
    }
    
    [_suggestedFiltersRibbonView unselectButtons];
    
    _constraintTopSearchFilterView.constant = ((self.searchBaseVC.parentViewController == nil) ? (kConstraintTopSearchFilterViewVisible) : (kConstraintTopSearchFilterViewVisibleWhenEmbedded));
    viewBottomFilterShadow.alpha = 0.0;
    viewBottomFilterShadow.hidden = YES;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         [_filtersView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.0]];
                         [_filtersCollectionView setAlpha:0.0];
                         _constraintTopSearchFilterView.constant = ((self.searchBaseVC.parentViewController == nil) ? (kConstraintTopSearchFilterViewHidden) : (kConstraintTopSearchFilterViewHiddenWhenEmbedded));
                         [_filtersView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (!bSearch){
                             [self.searchBaseVC showInspire];
                         }
                         [_filtersView setHidden:YES];
                         [_filtersCollectionView setHidden:YES];
                         [self.searchBaseVC setBackgroundImage];
                         [_suggestedFiltersRibbonView unselectButtons];
                     }];
    
}



#pragma mark - Setup Filters
-(void) setupFiltersOfGender
{
    [self getFiltersGenders];
    [self setupSuggestedFiltersRibbonView];
}
-(void) setupFiltersForGender
{
    [self getFiltersProductGroupsOfGender:_iGenderSelected];
    [self setupSuggestedFiltersRibbonView];
}

-(void) setupFiltersLocallyForObject:(NSObject *) objectRibbon andButtonEntry:(int)buttonEntry
{
    BOOL bPerformSearch = NO;
    __block NSPredicate *predicate = nil;
    __block NSString * entityPredicate = @"";
    __block NSArray * _arrSortOrderForSuggestedKeyword;
    __block NSArray * _arrSortAscendingForSuggestedKeyword;
    
    if ([objectRibbon isKindOfClass:[Feature class]])
    {
        [_suggestedFiltersRibbonView unselectButton:buttonEntry];
        Feature * feat = (Feature*)objectRibbon;
        int beforeGender = _iGenderSelected;
        long iNumSearchTerms = self.searchBaseVC.successfulTerms.count;
        _iGenderSelected = [self getGenderFromName:feat.name];
        [self.searchBaseVC addSearchTermWithObject:objectRibbon animated:YES performSearch:NO  checkSearchTerms:YES];
        if (_selectedProductGroup == nil)
        {
            [self getFiltersProductGroupsOfGender:_iGenderSelected];
        }
        else
        {
            [self getFiltersForProductGroup:_selectedProductGroup];
        }
        
        if ((beforeGender != _iGenderSelected) && (iNumSearchTerms > 0))
        {
            [self.searchBaseVC updateSearchForTermsChanges];
        }
        else
        {
            [self setupSuggestedFiltersRibbonView];
            [self initSelectedSlide];
        }
    }
    else if ([objectRibbon isKindOfClass:[ProductGroup class]])
    {
        if (_selectedProductGroup == nil)
        {
            [_suggestedFiltersRibbonView unselectButton:buttonEntry];
            
            ProductGroup * productGroup = (ProductGroup *)objectRibbon;
            _selectedProductGroup = productGroup;
            
            [self.searchBaseVC addSearchTermWithObject:_selectedProductGroup animated:YES performSearch:NO  checkSearchTerms:YES];
            [self getFiltersForProductGroup:_selectedProductGroup];
            [self initSelectedSlide];
        }
    }
    else
    {
        iLastSelectedSlide = buttonEntry;
        sLastSelectedSlide = [_suggestedFiltersRibbonView sGetNameButtonByIdx:buttonEntry];
        
        // management of collectionview
        if (![_suggestedFiltersRibbonView isSelected:buttonEntry])
        {
            BOOL bPerformSearch = ([self.searchBaseVC.searchTermsListView sameFromLastState] == NO);
            [self hideFiltersView:YES performSearch:bPerformSearch];
        }
        else
        {
            
            if ([objectRibbon isKindOfClass:[FeatureGroup class]])
            {
                entityPredicate = @"Feature";
                FeatureGroup * fg = (FeatureGroup*)objectRibbon;
                NSString * sNameTrimmed = [[fg.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString * sPriceTrimmed = [[NSLocalizedString(@"price",nil) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([sNameTrimmed isEqualToString:sPriceTrimmed])
                {
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
                    // feature group of price
                    predicate = [NSPredicate predicateWithFormat:@"idFeature IN %@",arrayFeaturesPrices];
                }
                else
                {
                    
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
                    
                    NSString * getIdParents = [self getChildrenFeatureGroupIdForPredicate: [fg getAllChildrenId] ];
                    NSPredicate *predicateFilterById = [NSPredicate predicateWithFormat:@"idFeature IN %@",suggestedFilters];
                    
                    if ([getIdParents isEqualToString:@""] == NO)
                    {
                        NSPredicate *predicateParents = [NSPredicate predicateWithFormat:@"featureGroupId IN %@",[fg getAllChildrenId]];
                        NSArray *subpreds = [NSArray arrayWithObjects:predicateFilterById, predicateParents, nil];
                        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpreds];
                    }
                    else
                    {
                        predicate = predicateFilterById;
                    }
                }
            }
            else if ([objectRibbon isKindOfClass:[ProductGroup class]])
            {
                objectRibbon = ((ProductGroup *)objectRibbon).name;
            }
            else if ([objectRibbon isKindOfClass:[NSString class]])
            {
                NSString * sStringRibbon = (NSString *)objectRibbon;
                
                if ([sStringRibbon isEqualToString:NSLocalizedString(@"_BRANDS_",nil)])
                {
                    
                    entityPredicate = @"Brand";
                    //                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority",@"name", nil];
                    //                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
                    //                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"order", @"name", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
                    
                    predicate = [NSPredicate predicateWithFormat:@"(idBrand IN %@)", suggestedFilters];
                }
                else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_STYLE_",nil)] || [sStringRibbon isEqualToString:NSLocalizedString(@"_PRODUCT_TYPE_",nil)])
                {
                    entityPredicate = @"ProductGroup";
                    //                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"app_name", nil];
                    _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"order",@"app_name", nil];
                    _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
                    
                    if ((_selectedProductGroup != nil) || (self.searchBaseVC.searchContext != PRODUCT_SEARCH))
                    {
                        predicate = [NSPredicate predicateWithFormat:@"(visible == TRUE) AND (idProductGroup IN %@) AND (idProductGroup IN %@)", suggestedFilters, successfulTermIdProductGroup];
                    }
                    else if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
                    {
                        predicate = [NSPredicate predicateWithFormat:@"(visible == TRUE) AND (idProductGroup IN %@)", suggestedFilters];
                    }
                }
                else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_LOCATION_",nil)])
                {
                }
                else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_STYLE_STYLIST_",nil)])
                {
                }
                else
                {
                    bPerformSearch = YES;
                }
            }
            
            if (bPerformSearch)
            {
                [self.searchBaseVC addSearchTermWithName:(NSString *)objectRibbon animated:YES];
                [self hideFiltersView:YES];
            }
            else
            {
                [self.searchBaseVC updateCollectionViewFiltersWithPredicate:predicate orEntity:entityPredicate withOrderArray:_arrSortOrderForSuggestedKeyword andOrdeAscending:_arrSortAscendingForSuggestedKeyword ];
            }
        }
    }
    
}

-(void) setupFiltersFromSearchForObject:(NSObject *) objectRibbon
{
    __block NSPredicate *predicate = nil;
    __block NSString * entityPredicate = @"";
    __block NSArray * _arrSortOrderForSuggestedKeyword;
    __block NSArray * _arrSortAscendingForSuggestedKeyword;
    
    BOOL bPerformSearch = NO;
    
    if ([objectRibbon isKindOfClass:[Feature class]])
    {
        Feature * feat = (Feature*)objectRibbon;
        _iGenderSelected = [self getGenderFromName:feat.name];
        [self getFiltersProductGroupsOfGender:_iGenderSelected];
    }
    else if ([objectRibbon isKindOfClass:[FeatureGroup class]])
    {
        entityPredicate = @"Feature";
        FeatureGroup * fg = (FeatureGroup*)objectRibbon;
        NSString * sNameTrimmed = [[fg.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * sPriceTrimmed = [[NSLocalizedString(@"price",nil) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([sNameTrimmed isEqualToString:sPriceTrimmed])
        {
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            // feature group of price
            predicate = [NSPredicate predicateWithFormat:@"idFeature IN %@",arrayFeaturesPrices];
        }
        else{
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            NSString * getIdParents = [self getChildrenFeatureGroupIdForPredicate: [fg getAllChildrenId] ];
            NSPredicate *predicateFilterById = [NSPredicate predicateWithFormat:@"idFeature IN %@",suggestedFilters];
            if (![getIdParents isEqualToString:@""])
            {
                NSPredicate *predicateParents = [NSPredicate predicateWithFormat:@"featureGroupId IN %@",[fg getAllChildrenId]];
                NSArray *subpreds = [NSArray arrayWithObjects:predicateFilterById, predicateParents, nil];
                predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpreds];
            }
            else
            {
                predicate = predicateFilterById;
            }
        }
    }
    else if ([objectRibbon isKindOfClass:[ProductGroup class]])
    {
        bPerformSearch = YES;
        objectRibbon = ((ProductGroup *)objectRibbon).name;
    }
    else if ([objectRibbon isKindOfClass:[NSString class]])
    {
        NSString * sStringRibbon = (NSString *)objectRibbon;
        
        if ([sStringRibbon isEqualToString:NSLocalizedString(@"_BRANDS_",nil)])
        {
            entityPredicate = @"Brand";
            //            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority",@"name", nil];
            //            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:NO],[NSNumber numberWithBool:YES], nil];
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            predicate = [NSPredicate predicateWithFormat:@"(idBrand IN %@)", suggestedFilters];
        }
        else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_STYLE_",nil)]  || [sStringRibbon isEqualToString:NSLocalizedString(@"_PRODUCT_TYPE_",nil)])
        {
            entityPredicate = @"ProductGroup";
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"app_name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            predicate = [NSPredicate predicateWithFormat:@"(visible == TRUE) AND (idProductGroup IN %@) AND (idProductGroup IN %@)", suggestedFilters, successfulTermIdProductGroup];
        }
        else
        {
            bPerformSearch = YES;
        }
    }
    if (bPerformSearch)
    {
        [self.searchBaseVC addSearchTermWithName:(NSString *)objectRibbon animated:YES];
        [self hideFiltersView:YES];
    }
    else
    {
        [self.searchBaseVC updateCollectionViewFiltersWithPredicate:predicate orEntity:entityPredicate withOrderArray:_arrSortOrderForSuggestedKeyword andOrdeAscending:_arrSortAscendingForSuggestedKeyword ];
        
    }}

-(void) setupFiltersFiltersFromSearchForObject:(NSObject *) objectRibbon
{
    __block NSPredicate *predicate = nil;
    __block NSString * entityPredicate = @"";
    __block NSArray * _arrSortOrderForSuggestedKeyword;
    __block NSArray * _arrSortAscendingForSuggestedKeyword;
    
    BOOL bPerformSearch = NO;
    
    if ([objectRibbon isKindOfClass:[Feature class]])
    {
        Feature * feat = (Feature*)objectRibbon;
        _iGenderSelected = [self getGenderFromName:feat.name];
        [self getFiltersProductGroupsOfGender:_iGenderSelected];
    }
    else if ([objectRibbon isKindOfClass:[FeatureGroup class]])
    {
        entityPredicate = @"Feature";
        FeatureGroup * fg = (FeatureGroup*)objectRibbon;
        NSString * sNameTrimmed = [[fg.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * sPriceTrimmed = [[NSLocalizedString(@"price",nil) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([sNameTrimmed isEqualToString:sPriceTrimmed])
        {
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"priority", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            // feature group of price
            predicate = [NSPredicate predicateWithFormat:@"idFeature IN %@",arrayFeaturesPrices];
        }
        else{
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            NSString * getIdParents = [self getChildrenFeatureGroupIdForPredicate: [fg getAllChildrenId] ];
            NSPredicate *predicateFilterById = [NSPredicate predicateWithFormat:@"idFeature IN %@",suggestedFilters];
            if (![getIdParents isEqualToString:@""])
            {
                NSPredicate *predicateParents = [NSPredicate predicateWithFormat:@"featureGroupId IN %@",[fg getAllChildrenId]];
                NSArray *subpreds = [NSArray arrayWithObjects:predicateFilterById, predicateParents, nil];
                predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpreds];
            }
            else
            {
                predicate = predicateFilterById;
            }
        }
    }
    else if ([objectRibbon isKindOfClass:[ProductGroup class]])
    {
        bPerformSearch = YES;
        objectRibbon = ((ProductGroup *)objectRibbon).name;
    }
    else if ([objectRibbon isKindOfClass:[NSString class]])
    {
        NSString * sStringRibbon = (NSString *)objectRibbon;
        
        if ([sStringRibbon isEqualToString:NSLocalizedString(@"_BRANDS_",nil)])
        {
            entityPredicate = @"Brand";
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            predicate = [NSPredicate predicateWithFormat:@"(idBrand IN %@)", suggestedFilters];
        }
        else if ([sStringRibbon isEqualToString:NSLocalizedString(@"_STYLE_",nil)]  || [sStringRibbon isEqualToString:NSLocalizedString(@"_PRODUCT_TYPE_",nil)])
        {
            entityPredicate = @"ProductGroup";
            _arrSortOrderForSuggestedKeyword = [[NSArray alloc] initWithObjects:@"app_name", nil];
            _arrSortAscendingForSuggestedKeyword = [[NSArray alloc] initWithObjects:[NSNumber numberWithBool:YES], nil];
            
            predicate = [NSPredicate predicateWithFormat:@"(visible == TRUE) AND (idProductGroup IN %@) AND (idProductGroup IN %@)", suggestedFilters, successfulTermIdProductGroup];
        }
        else
        {
            bPerformSearch = YES;
        }
    }
    if (bPerformSearch)
    {
        [self.searchBaseVC addSearchTermWithName:(NSString *)objectRibbon animated:YES];
        [self hideFiltersView:YES];
    }
    else
    {
        [self.searchBaseVC updateCollectionViewFiltersWithPredicate:predicate orEntity:entityPredicate withOrderArray:_arrSortOrderForSuggestedKeyword andOrdeAscending:_arrSortAscendingForSuggestedKeyword];
    }
    
}

-(void) setupFiltersFromSearchSuggested:(NSArray *) mappingResult
{
    // Empty old terms array
    [self initFilters];
    
    [self initSelectedProductGroups];
    
    // Add the list of terms that were provided
    BOOL bAllSameParent = true;
    ProductGroup * pgParentTemp = nil;
    
    for (SuggestedKeyword *suggestedKeyword in mappingResult)
    {
        if([suggestedKeyword isKindOfClass:[SuggestedKeyword class]])
        {
            if(!(suggestedKeyword.name == nil))
            {
                if(!([suggestedKeyword.name isEqualToString:@""]))
                {
                    //                            NSString * pene = [[suggestedKeyword.name lowercaseString] capitalizedString];
                    //                            pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    //                            if (!([_suggestedFilters containsObject:pene]))
                    //                            {
                    //                                [_suggestedFilters addObject:pene];
                    //                            }
                    if (!([suggestedFiltersObject containsObject:suggestedKeyword]))
                    {
                        // get the keyword
                        Keyword * keySuggested = [self getKeywordFromId:suggestedKeyword.idSuggestedKeyword];
                        if (keySuggested != nil)
                        {
                            NSString * sObjectId = [keySuggested getIdElement];
                            if (sObjectId != nil)
                            {
                                ProductGroup *pg = [self getProductGroupFromId:sObjectId];
                                Feature *feat = [self getFeatureFromId:sObjectId];
                                Brand * brand = [self getBrandFromId:sObjectId];
                                
                                if (pg != nil)
                                {
                                    [suggestedFiltersObject addObject:pg];
                                    [suggestedFilters addObject:pg.idProductGroup];
                                    
                                    //                                    ProductGroup * pgParent = [pg getTopParent];
                                    //                                    if (pgParentTemp == nil)
                                    //                                    {
                                    //                                        pgParentTemp = pgParent;
                                    //                                    }
                                    //                                    else
                                    //                                    {
                                    //                                        if (bAllSameParent && (pgParentTemp != pgParent))
                                    //                                        {
                                    //                                            bAllSameParent = false;
                                    //                                        }
                                    //                                    }
                                    //
                                    //                                    if (![arSelectedProductGroups containsObject:pgParent])
                                    //                                    {
                                    //                                        [arSelectedProductGroups addObject:pgParent];
                                    //                                    }
                                    _selectedProductGroup = [pg getTopParent];
                                    
                                    if (![arSelectedProductGroups containsObject:_selectedProductGroup])
                                    {
                                        [arSelectedProductGroups addObject:_selectedProductGroup];
                                    }
                                }
                                else if (feat != nil)
                                {
                                    [suggestedFiltersObject addObject:feat];
                                    [suggestedFilters addObject:feat.idFeature];
                                }
                                else if (brand != nil)
                                {
                                    [suggestedFiltersObject addObject:brand];
                                    [suggestedFilters addObject:brand.idBrand];
                                }
                                else
                                {
                                    [suggestedFiltersObject addObject:keySuggested];
                                    [suggestedFilters addObject:sObjectId];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //    if (bAllSameParent)
    //    {
    //        _selectedProductGroup = pgParentTemp;
    //    }
    
    [self setupSuggestedFiltersRibbonView];
}

#pragma mark - Setup Suggested Filter Bar

- (void) setupSuggestedFiltersRibbonView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray * completeSuggestedFiltersList = [[NSMutableArray alloc] init];
    
    BOOL isSelectStyleTab = NO;
    BOOL forceSelectNextStep = NO;
    
    if (self.searchBaseVC.searchContext != BRANDS_SEARCH)
    {
        if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_products"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else if (self.searchBaseVC.searchContext == FASHIONISTAS_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_fashionistas"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else if (self.searchBaseVC.searchContext == FASHIONISTAPOSTS_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_post"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else if (self.searchBaseVC.searchContext == HISTORY_SEARCH)
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_history"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
        else
        {
            NSArray * objs = [appDelegate.config valueForKey:@"order_filter_default"];
            [self setupSuggestedFiltersRibbonView:completeSuggestedFiltersList withOrder:objs andForceSelectNextStep:&forceSelectNextStep andIsSelectStyleTab:&isSelectStyleTab];
        }
    }
    else
    {
        [self getLettersTo:completeSuggestedFiltersList];
    }
    
    [_suggestedFiltersRibbonView initSlideButtonWithButtons:[[[NSOrderedSet orderedSetWithArray:completeSuggestedFiltersList] array] mutableCopy] andDelegate:self.searchBaseVC];
    
    [_suggestedFiltersRibbonView scrollToTheBeginning];
    //    [_suggestedFiltersRibbonView scrollToButtonByIndex:0];
    
    if ([[_suggestedFiltersRibbonView arrayButtons] count] > 0)
    {
        [self.searchBaseVC.noFilterTermsLabel setHidden:YES];
        
        //Show the filter terms ribbon
        [self.searchBaseVC showSuggestedFiltersRibbonAnimated:YES];
    }
    else
    {
        //Hide the filter terms ribbon
        [self.searchBaseVC hideSuggestedFiltersRibbonAnimated:NO];
        
        if(!(self.searchBaseVC.currentSearchQuery == nil))
        {
            [self.searchBaseVC.noFilterTermsLabel setText:NSLocalizedString(@"_NOFILTERTERMS_LBL_", nil)];
            [self.searchBaseVC.noFilterTermsLabel setHidden:NO];
        }
    }
    
    if (forceSelectNextStep && !_bSuggestedKeywordsFromSearch && !_bRestartingSearch)
    {
        
        // Check si solo hay style y brand en los filters
        BOOL bOnlyStyleAndBrands = YES;
        for(NSObject * objSuggested in _suggestedFiltersRibbonView.arrayButtons )
        {
            if ([objSuggested isKindOfClass:[FeatureGroup class]])
            {
                bOnlyStyleAndBrands = NO;
                break;
            }
            
            if ([objSuggested isKindOfClass:[NSString class]])
            {
                NSString * sName = (NSString *)objSuggested;
                if (![sName isEqualToString:NSLocalizedString(@"_BRANDS_",nil)] &&
                    ![sName isEqualToString:NSLocalizedString(@"_STYLE_",nil)] &&
                    ![sName isEqualToString:NSLocalizedString(@"_PRODUCT_TYPE_",nil)])
                {
                    bOnlyStyleAndBrands = NO;
                    break;
                }
            }
            else
            {
                bOnlyStyleAndBrands = NO;
                break;
            }
        }
        
        
        if (bOnlyStyleAndBrands)
        {
            // si solo está style y brand, mostramos siempre el style (que será el primero) si brand no estaba seleccionada
            if ([sLastSelectedSlide isEqualToString:@"Brand"] == NO)
            {
                if (_suggestedFiltersRibbonView.arrayButtons.count > 0)
                {
                    [_suggestedFiltersRibbonView forceSelectButton:0];
                    [self.searchBaseVC slideButtonView:_suggestedFiltersRibbonView btnClick:0];
                }
            }
        }
        else
        {
            // hay feature groups mostrandose o falta style o brand
            
            // obtenemos el indice de la pestaña seleccionada que se guarda su nombre en sLastSelectedSlide
            int iIdx = [_suggestedFiltersRibbonView iGetIndexButtonByName: sLastSelectedSlide];
            
            unsigned long iCount = [_suggestedFiltersRibbonView.arrayButtons count];
            if ((iIdx < 0) || (iIdx >= iCount))
            {
                // el indice está fuera de los limites de los elementos de la suggested bar, miramos si podemos asignarle el iLastSelectedSlide
                if (iLastSelectedSlide >= iCount)
                {
                    if (iCount > 0)
                        iIdx = (int)iCount -1;
                    else
                        iIdx = 0;
                }
                else if (iLastSelectedSlide < 0)
                {
                    iIdx = 0;
                }
                else
                {
                    iIdx = iLastSelectedSlide;
                }
            }
            if (_suggestedFiltersRibbonView.arrayButtons.count > 0)
            {
                [_suggestedFiltersRibbonView forceSelectButton:iIdx];
                [self.searchBaseVC slideButtonView:_suggestedFiltersRibbonView btnClick:iIdx];
            }
            else
            {
                [self hideFiltersView:NO];
            }
            
        }
    }
    else if (forceSelectNextStep && _bSuggestedKeywordsFromSearch && !_bRestartingSearch)
    {
        // obtenemos el indice de la pestaña seleccionada que se guarda su nombre en sLastSelectedSlide
        int iIdx = [_suggestedFiltersRibbonView iGetIndexButtonByName: sLastSelectedSlide];
        
        unsigned long iCount = [_suggestedFiltersRibbonView.arrayButtons count];
        if ((iIdx < 0) || (iIdx >= iCount))
        {
            // el indice está fuera de los limites de los elementos de la suggested bar, miramos si podemos asignarle el iLastSelectedSlide
            if (iLastSelectedSlide >= iCount)
            {
                if (iCount > 0)
                    iIdx = (int)iCount -1;
                else
                    iIdx = 0;
            }
            else if (iLastSelectedSlide < 0)
            {
                iIdx = 0;
            }
            else
            {
                iIdx = iLastSelectedSlide;
            }
        }
        if (_suggestedFiltersRibbonView.arrayButtons.count > 0)
        {
            [_suggestedFiltersRibbonView scrollToButtonByIndex:iIdx];
        }
    }
}

-(void) setupSuggestedFiltersRibbonView:(NSMutableArray *) completeSuggestedFiltersList withOrder:(NSArray *) arOrder andForceSelectNextStep:(BOOL *) bNextStep andIsSelectStyleTab: (BOOL *) bStyleTab
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self initStructuresForSuggestedKeywords];
    
    if ([self allSuggestedProductGroup] && (self.searchBaseVC.searchContext != HISTORY_SEARCH) && (self.searchBaseVC.searchContext != FASHIONISTAS_SEARCH))
    {
        // convertimos los string a objetos product group si es posible, si no dejamos el valor original
        NSMutableArray * arObjectsRibbon = [[NSMutableArray alloc] init];
        for (NSString * sFilter in suggestedFilters)
        {
            
            //                ProductGroup * pg = [self getProductGroupFromName:sFilter];
            ProductGroup * pg = [self getProductGroupParentFromId:sFilter];
            if (pg != nil)
            {
                if ([pg.visible boolValue])
                    [arObjectsRibbon addObject:pg];
            }
        }
        
        [completeSuggestedFiltersList addObjectsFromArray:arObjectsRibbon];
    }
    else
    {
        NSDate *methodstart = [NSDate date];
        //                NSLog(@"################### After initFoundSuggestions 1: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        methodstart = [NSDate date];
        
        
        suggestedFiltersFound = [[NSMutableArray alloc]initWithArray:suggestedFilters];
        NSMutableArray * filteredSuggestedFilters = suggestedFilters;
        
        if([foundSuggestions count] > 0)
        {
            [suggestedFiltersFound removeAllObjects];
            
            for(NSString * objid in suggestedFilters)
            {
                if([foundSuggestions objectForKey:objid])
                {
                    [suggestedFiltersFound addObject:objid];
                }
                else
                {
                    // Caso PC, los añadiremos también al ser una búsqueda OR de PC
                    if([self getProductGroupFromId:objid])
                    {
                        if((foundSuggestions.count == 0) || ([foundSuggestions objectForKey:objid]))
                        {
                            [suggestedFiltersFound addObject:objid];
                        }
                    }
                    if([self getBrandFromId:objid])
                    {
                        if((foundSuggestions.count == 0) || ([foundSuggestions objectForKey:objid]))
                        {
                            [suggestedFiltersFound addObject:objid];
                        }
                    }
                }
            }
            
            filteredSuggestedFilters = suggestedFiltersFound;
        }
        
        //                NSLog(@"################### After initFoundSuggestions 2: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        methodstart = [NSDate date];
        
        FeatureGroup * featureGroup = [self allSuggestedFromSameFeatureGroup];
        //                NSLog(@"################### After initFoundSuggestions 3: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        methodstart = [NSDate date];
        if ((featureGroup != nil) && (self.searchBaseVC.searchContext == PRODUCT_SEARCH))
        {
            
            NSMutableArray * arObjectsRibbon = [[NSMutableArray alloc] init];
            for (NSString * sFilter in filteredSuggestedFilters)
            {
                //                ProductGroup * pg = [self getProductGroupFromName:sFilter];
                Feature * feat = [self getFeatureFromId:sFilter];
                if (feat != nil)
                {
                    [arObjectsRibbon addObject:feat];
                }
            }
            [completeSuggestedFiltersList addObjectsFromArray:arObjectsRibbon];
        }
        else
        {
            *bNextStep = YES;
            NSDate *methodstart = [NSDate date];
            
            int iIdx = 0;
            for(NSString * sObj in arOrder)
            {
                unsigned long  iNumTabs = completeSuggestedFiltersList.count;
                if ([sObj isEqualToString:@"gender"])
                {
                    if ((_iGenderSelected <= 0) || (self.searchBaseVC.searchContext == FASHIONISTAPOSTS_SEARCH) || (self.searchBaseVC.searchContext == FASHIONISTAS_SEARCH))
                    {
                        //                        [self addFeatureGroupWithName:@"gender" from:filteredSuggestedFilters to:completeSuggestedFiltersList checkingGenderInProductCategory:((self.searchBaseVC.searchContext != FASHIONISTAS_SEARCH) && (_selectedProductGroup != nil))];
                        [self addFeatureGroupWithName:@"gender" from:filteredSuggestedFilters to:completeSuggestedFiltersList checkingGenderInProductCategory:(self.searchBaseVC.searchContext != FASHIONISTAS_SEARCH)];
                    }
                }
                else if ([sObj isEqualToString:@"style"])
                {
                    [self addProductGroupFrom:filteredSuggestedFilters to: completeSuggestedFiltersList];
                    if (completeSuggestedFiltersList.count == (iNumTabs + 1))
                    {
                        // the style tab is added
                        *bStyleTab = YES;
                    }
                }
                else if ([sObj isEqualToString:@"brands"])
                {
                    [self addBrandsFrom:filteredSuggestedFilters to: completeSuggestedFiltersList];
                }
                else if ([sObj isEqualToString:@"color"])
                {
                    [self addFeatureGroupWithName:@"color" from:filteredSuggestedFilters to:completeSuggestedFiltersList];
                }
                else if ([sObj isEqualToString:@"prices"])
                {
                    [self addPricesGroupFrom:filteredSuggestedFilters to: completeSuggestedFiltersList];
                }
                else if ([sObj isEqualToString:@"features"])
                {
                    NSMutableArray * arFeatureGroupsOfProductCategory = [self getFeaturesOfProductGroupSelectedExcept:@"gender"];
                    
                    [self addFeatureGroupFrom:filteredSuggestedFilters to: completeSuggestedFiltersList orderBy:arFeatureGroupsOfProductCategory];
                }
                else if ([sObj isEqualToString:@"history"])
                {
                    for (int i = 0; i < maxHistoryPeriods; i++)
                    {
                        if (!(i == self.searchBaseVC.searchPeriod))
                        {
                            [completeSuggestedFiltersList addObject:NSLocalizedString(([NSString stringWithFormat:@"_HISTORYPERIOD_%i",i]), nil)];
                        }
                    }
                }
                /*
                 else if ([sObj isEqualToString:@"stylestylist"])
                 {
                 if (foundSuggestionsStyleStylist.count > 0)
                 {
                 NSString * sStyleStylist = NSLocalizedString(@"_STYLE_STYLIST_",nil);
                 if (![completeSuggestedFiltersList containsObject:sStyleStylist])
                 {
                 [completeSuggestedFiltersList addObject:sStyleStylist];
                 break;
                 }
                 }
                 }
                 else if ([sObj isEqualToString:@"location"])
                 {
                 if (foundSuggestionsLocations.count > 0)
                 {
                 NSString * sLocation = NSLocalizedString(@"_LOCATION_",nil);
                 if (![completeSuggestedFiltersList containsObject:sLocation])
                 {
                 [completeSuggestedFiltersList addObject:sLocation];
                 break;
                 }
                 }
                 }
                 */
                else if ([sObj isEqualToString:@"follower"])
                {
                    if (!(appDelegate.currentUser == nil))
                    {
                        for (int i = 0; i < maxFollowingRelationships; i++)
                        {
                            if (!(i == self.searchBaseVC.searchStylistRelationships))
                            {
                                [completeSuggestedFiltersList addObject:NSLocalizedString(([NSString stringWithFormat:@"_STYLISTFOLLOW_%i",i]), nil)];
                            }
                        }
                    }
                }
                else if ([sObj isEqualToString:@"posttype"])
                {
                    //for (int i = 0; i < maxFashionistaPostTypes; i++)
                    {
                        //if (!(i == _searchPostType))
                        {
                            //[completeSuggestedFiltersList addObject:NSLocalizedString(([NSString stringWithFormat:@"_FASHIONISTAPOSTTYPE_%i",i]), nil)];
                        }
                    }
                }
                else
                {
                    // grupo de filtro no tratada
                    
                    //                    NSString * sKey = [NSString stringWithFormat:@"%i", iIdx ];
                    //                    NSMutableArray *arrObjects = [foundSuggestionsDirectly objectForKey:sKey];
                    //                    if (arrObjects != nil)
                    //                    {
                    //                        if (arrObjects.count > 0)
                    //                        {
                    //                            NSString * sName = NSLocalizedString(sObj,nil);
                    //                            if (![completeSuggestedFiltersList containsObject:sName])
                    //                            {
                    //                                [completeSuggestedFiltersList addObject:sName];
                    //                                break;
                    //                            }
                    //                        }
                    //                    }
                }
                iIdx++;
            }
            
            
            NSLog(@"################### Process SuggestedKeywords: %f", [[NSDate date] timeIntervalSinceDate:methodstart]);
        }
    }
}

-(void) addProductGroupFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name IN %@", arElements];
    NSPredicate * predicate = nil;
    if (successfulTermIdProductGroup != nil)
    {
        predicate = [NSPredicate predicateWithFormat:@"(idProductGroup IN %@) AND (idProductGroup IN %@)", arElements, successfulTermIdProductGroup];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"(idProductGroup IN %@)", arElements];
    }
    predicate = [NSPredicate predicateWithFormat:@"(idProductGroup IN %@)", arElements];
    
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicateObject:predicate sortingWithKey:@"idProductGroup" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpProductGroup == nil))
            {
                if(!(tmpProductGroup.idProductGroup == nil))
                {
                    if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
                    {
                        // save the productGroup parent in the array
                        ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
                        if (productGroupsParentForSuggestedKeywords == nil)
                        {
                            productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
                        }
                        
                        if (![productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
                            [productGroupsParentForSuggestedKeywords addObject:productGroupParent];
                        
                        if ([tmpProductGroup.visible boolValue])
                        {
                            //                            if (bFirst)
                            //                            {
                            //                                bFirst = NO;
                            //                                continue;
                            //                            }
                            if ((_selectedProductGroup == nil) ||
                                ((_selectedProductGroup != nil) && ([tmpProductGroup.idProductGroup isEqualToString:_selectedProductGroup.idProductGroup] == NO))
                                )
                            {
                                if ([successfulTermIdProductGroup count] > 0)
                                {
                                    // check that the product category is a child of the succesful product category, only if there are product category as successful terms
                                    if ([successfulTermIdProductGroup containsObject:tmpProductGroup.idProductGroup])
                                    {
                                        NSString * sStyle = NSLocalizedString(@"_STYLE_",nil);
                                        //                                    if ((_selectedProductGroup == nil) && (_searchBaseVC.searchContext == PRODUCT_SEARCH))
                                        if (_selectedProductGroup == nil)
                                            sStyle = NSLocalizedString(@"_PRODUCT_TYPE_",nil);
                                        if (![completeSuggestedFiltersList containsObject:sStyle])
                                        {
                                            [completeSuggestedFiltersList addObject:sStyle];
                                            break;
                                        }
                                    }
                                }
                                else{
                                    NSString * sStyle = NSLocalizedString(@"_STYLE_",nil);
                                    //                                    if ((_selectedProductGroup == nil) && (_searchBaseVC.searchContext == PRODUCT_SEARCH))
                                    if (_selectedProductGroup == nil)
                                        sStyle = NSLocalizedString(@"_PRODUCT_TYPE_",nil);
                                    if (![completeSuggestedFiltersList containsObject:sStyle])
                                    {
                                        [completeSuggestedFiltersList addObject:sStyle];
                                        break;
                                    }
                                }
                            }
                        }
                        
                        //                        break;
                    }
                }
            }
        }
    }
}

-(void) addFeatureGroupFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList orderBy: (NSMutableArray *) featureGroupsOrdered
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name IN %@", arElements];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"idFeature IN %@", arElements];
    
    NSDictionary * _kwFeatures = [[NSMutableDictionary alloc]init];
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicateObject:predicate sortingWithKey:@"idFeature" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeature == nil))
            {
                if(!(tmpFeature.idFeature == nil))
                {
                    if(!([tmpFeature.idFeature isEqualToString:@""]))
                    {
                        if ([tmpFeature isVisibleForGender:_iGenderSelected andProductCategory:_selectedProductGroup andSubProductCategories:arSelectedSubProductGroup])
                        {
                            // get the feature group parent
                            FeatureGroup * fgParent = [tmpFeature.featureGroup getTopParent];
                            NSString * sNameFG = [fgParent.name.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([sNameFG isEqualToString:@"gender"] == NO)
                            {
                                NSMutableArray* objNumFeatures = [_kwFeatures valueForKey:fgParent.name];
                                if (objNumFeatures != nil)
                                {
                                    [objNumFeatures addObject:fgParent];
                                }
                                else
                                {
                                    objNumFeatures = [[NSMutableArray alloc] initWithObjects:fgParent, nil];
                                    [_kwFeatures setValue:objNumFeatures forKey:fgParent.name];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // recorrido por el diccionario y añadiendo solo aquellos elementos con mas de 1 elemento
    NSArray * allKey = [_kwFeatures allKeys];
    NSMutableArray * sortedKeyArray = [[NSMutableArray alloc] initWithArray:[allKey sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    // bucle recorriendo los featuregroup ordenados
    for(FeatureGroup * fgOrdered in featureGroupsOrdered)
    {
        for (NSString* key in  sortedKeyArray) {
            NSMutableArray * objNumFeatures = [_kwFeatures objectForKey:key];
            //int iIntValue = (int)[objNumFeatures count];
            FeatureGroup * fgParent =objNumFeatures[0] ;
            if (fgParent.idFeatureGroup == fgOrdered.idFeatureGroup)
            {
                if (![completeSuggestedFiltersList containsObject:[fgParent getTopParent]])
                {
                    [completeSuggestedFiltersList addObject:[fgParent getTopParent]];
                }
                [sortedKeyArray removeObject:key];
                break;
            }
        }
    }
}

-(void) addPricesGroupFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:@"Price" sortingWithKey:@"idFeatureGroup" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        for (Feature *f in tmpFeatureGroup.features)
                        {
                            for(NSString * sElement in arElements)
                            {
                                //                                if ([f.name isEqualToString:sElement])
                                if ([f.idFeature isEqualToString:sElement])
                                {
                                    [arrayFeaturesPrices addObject:f.idFeature];
                                    //                                    if (bFirst)
                                    //                                    {
                                    //                                        bFirst = NO;
                                    //                                        continue;
                                    //                                    }
                                    if (![completeSuggestedFiltersList containsObject:tmpFeatureGroup])
                                    {
                                        [completeSuggestedFiltersList addObject:tmpFeatureGroup];
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void) addFeatureGroupWithName:(NSString *)sName from:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    [self addFeatureGroupWithName:sName from:arElements to:completeSuggestedFiltersList checkingGenderInProductCategory:YES];
}


-(void) addFeatureGroupWithName:(NSString *)sName from:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList checkingGenderInProductCategory:(BOOL) bCheckInProductCategory
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:sName sortingWithKey:@"idFeatureGroup" ascending:YES];
    
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpFeatureGroup == nil))
            {
                if(!(tmpFeatureGroup.idFeatureGroup == nil))
                {
                    if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                    {
                        for (Feature *f in tmpFeatureGroup.features)
                        {
                            for(NSString * sElement in arElements)
                            {
                                if ([f.idFeature isEqualToString:sElement])
                                {
                                    if ([sName isEqualToString:@"gender"])
                                    {
                                        if (bCheckInProductCategory)
                                        {
                                            if ([self isGenderInProductCategorySuccess:f.name])
                                            {
                                                if (![completeSuggestedFiltersList containsObject:tmpFeatureGroup])
                                                {
                                                    [completeSuggestedFiltersList addObject:tmpFeatureGroup];
                                                }
                                                break;
                                            }
                                            else
                                            {
                                                NSLog(@"Gender not in successProductCategory %@", f.name);
                                                // remove the gender not in success product category
                                                [arElements removeObject:sElement];
                                                break;
                                            }
                                        }
                                        else
                                        {
                                            if (![completeSuggestedFiltersList containsObject:tmpFeatureGroup])
                                            {
                                                [completeSuggestedFiltersList addObject:tmpFeatureGroup];
                                            }
                                            break;
                                        }
                                        
                                    }
                                    else
                                    {
                                        if (![completeSuggestedFiltersList containsObject:tmpFeatureGroup])
                                        {
                                            [completeSuggestedFiltersList addObject:tmpFeatureGroup];
                                        }
                                        break;
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

-(void) addBrandsFrom:(NSMutableArray *) arElements to:(NSMutableArray *) completeSuggestedFiltersList
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    //    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name IN %@", arElements];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"idBrand IN %@", arElements];
    
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicateObject:predicate sortingWithKey:@"idBrand" ascending:YES];
    if (!(keywordsFetchedResultsController == nil))
    {
        for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
        {
            Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
            
            if(!(tmpBrand == nil))
            {
                if(!(tmpBrand.idBrand == nil))
                {
                    if(!([tmpBrand.idBrand isEqualToString:@""]))
                    {
                        NSString * sBrand = NSLocalizedString(@"_BRANDS_",nil);
                        if (![completeSuggestedFiltersList containsObject:sBrand])
                        {
                            [completeSuggestedFiltersList addObject:sBrand];
                        }
                        break;
                    }
                }
            }
        }
    }
}

-(void) removeFromFilterObject:(NSObject *)objToRemove andCheckSearch:(BOOL) bCheckSearch
{
    BOOL bElementRemovedIsProductGroup = NO;
    
    
    if (bCheckSearch)
    {
        
        bElementRemovedIsProductGroup = [objToRemove isKindOfClass:[ProductGroup class]];
        
        if ([objToRemove isKindOfClass:[Feature class]])
        {
            // check that there is not any gender selected
            [self getGenderSelected];
            
            if (_suggestedFiltersRibbonView.arSelectedButtons.count > 0)
            {
                int iIdxSelected = [_suggestedFiltersRibbonView.arSelectedButtons[0] intValue];
                NSObject *obj = _suggestedFiltersRibbonView.arrayButtons[iIdxSelected];
                [self getFiltersForProductGroup:_selectedProductGroup];
                [self setupFiltersLocallyForObject: obj andButtonEntry:iIdxSelected];
            }
            [self updateSuccessulTermsForGender];
        }
        if ([objToRemove isKindOfClass:[ProductGroup class]])
        {
            ProductGroup * pg = (ProductGroup *)objToRemove;
            if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
            {
                if ([pg.idProductGroup isEqualToString:_selectedProductGroup.idProductGroup])
                {
                    _selectedProductGroup = nil;
                    iNumSubProductGroups = 0;
                    [arSelectedSubProductGroup removeAllObjects];
                    [self updateSuccessulTermsForGender];
                }
                else
                {
                    iNumSubProductGroups--;
                    [arSelectedSubProductGroup removeObject:pg];
                    if (iNumSubProductGroups <= 0)
                    {
                        iNumSubProductGroups = 0;
                        [self.searchBaseVC addSearchTermWithObject:_selectedProductGroup animated:YES performSearch:NO checkSearchTerms:bCheckSearch];
                    }
                }
            }
            else
            {
                _selectedProductGroup = nil;
                iNumSubProductGroups--;
                [arSelectedSubProductGroup removeObject:pg];
                if (iNumSubProductGroups <= 0)
                {
                    iNumSubProductGroups = 0;
                    [arSelectedSubProductGroup removeAllObjects];
                }
                else
                {
                    _selectedProductGroup = [[arSelectedSubProductGroup objectAtIndex:iNumSubProductGroups-1] getTopParent];
                }
                [self updateSuccessulTermsForGender];
            }
        }
        if ([objToRemove isKindOfClass:[Keyword class]])
        {
            Keyword *key = (Keyword *)objToRemove;
            ProductGroup * pg = [self getProductGroupParentFromId:key.productCategoryId];
            Feature * feat = [self getFeatureFromId:key.featureId];
            if (pg != nil)
            {
                if ([pg.idProductGroup isEqualToString:_selectedProductGroup.idProductGroup])
                {
                    _selectedProductGroup = nil;
                    iNumSubProductGroups = 0;
                    [arSelectedSubProductGroup removeAllObjects];
                    [self updateSuccessulTermsForGender];
                }
                else
                {
                    iNumSubProductGroups--;
                    [arSelectedSubProductGroup removeObject:pg];
                    if (iNumSubProductGroups <= 0)
                    {
                        iNumSubProductGroups = 0;
                        [self.searchBaseVC addSearchTermWithObject:_selectedProductGroup animated:YES performSearch:NO  checkSearchTerms:bCheckSearch];
                    }
                }
            }
            if (feat != nil)
            {
                // check that there is not any gender selected
                [self getGenderSelected];
                
                if (_suggestedFiltersRibbonView.arSelectedButtons.count > 0)
                {
                    if (_suggestedFiltersRibbonView.arSelectedButtons.count > 0)
                    {
                        int iIdxSelected = [_suggestedFiltersRibbonView.arSelectedButtons[0] intValue];
                        NSObject *obj = _suggestedFiltersRibbonView.arrayButtons[iIdxSelected];
                        [self getFiltersForProductGroup:_selectedProductGroup];
                        [self setupFiltersLocallyForObject: obj andButtonEntry:iIdxSelected];
                    }
                }
                [self updateSuccessulTermsForGender];
            }
        }
    }
    BOOL bUpdatingSearch = NO;
    
    if ((self.searchBaseVC.searchContext == PRODUCT_SEARCH) && (bElementRemovedIsProductGroup) && (arSelectedSubProductGroup.count == 0))
    {
        // open style tab
        [self initSelectedSlide];
    }
    else
    {
        if ((_filtersCollectionView.alpha < 1.0) || ([_filtersCollectionView isHidden]))
        {
            bUpdatingSearch = [self.searchBaseVC updateSearchForTermsChanges];
        }
        else
        {
            if (self.searchBaseVC.searchContext == FASHIONISTAPOSTS_SEARCH)
            {
                [self hideFiltersView:YES performSearch:YES];
            }
        }
    }
    
    if ((self.searchBaseVC.searchContext == PRODUCT_SEARCH) && (bUpdatingSearch == NO))
    {
        if (_iGenderSelected == 0) //&& (selectedProductCategory == nil))
        {
            [self getFiltersGenders];
            [self setupSuggestedFiltersRibbonView];
            [self hideFiltersView:YES];
        }
        if ((_iGenderSelected > 0) && (_selectedProductGroup == nil))
        {
            [self getFiltersProductGroupsOfGender:_iGenderSelected];
            [self setupSuggestedFiltersRibbonView];
            [self initFoundSuggestions];
            
        }
        
        if ([self.searchBaseVC.successfulTerms count] <= 0)
        {
            [self.searchBaseVC restartSearch];
        }
    }
}

#pragma mark - CollectionView
-(unsigned long) numberOfSectionsFilterForCelltype:(NSString *)cellType
{
    [self getGenderSelected];
    
    if (arSectionsFilter != nil)
    {
        [arSectionsFilter removeAllObjects];
    }
    else
    {
        arSectionsFilter = [[NSMutableArray alloc] init];
    }
    
    BOOL bOrderByProductGroup = NO;
    NSMutableArray * arrayProductType = [[NSMutableArray alloc] init];
    for(NSObject * obj in [[self.searchBaseVC getFetchedResultsControllerForCellType:cellType] fetchedObjects])
    {
        if([obj isKindOfClass:[ProductGroup class]])
        {
            ProductGroup *pg = (ProductGroup *)obj;
            BOOL bAdd = YES;
            if (_selectedProductGroup != nil)
            {
                bAdd = NO;
                
                if (bAdd == NO)
                {
                    for (ProductGroup * pgSelected in arExpandedSubProductGroup)
                    {
                        if ([pgSelected isChild:pg])
                        {
                            bAdd = YES;
                            break;
                        }
                    }
                    
                    if (bAdd == NO)
                    {
                        if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
                        {
                            bAdd = ([_selectedProductGroup isChild:pg]);
                        }
                        else
                        {
                            for(ProductGroup * pgSelected in arSelectedProductGroups)
                            {
                                //                                if (([pgSelected isChild:pg]) || ([pg.idProductGroup isEqualToString:pgSelected.idProductGroup]))
                                if ([pgSelected isChild:pg])
                                {
                                    bAdd = YES;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            
            if (bAdd)
            {
                if(foundSuggestions.count == 0 || [foundSuggestions objectForKey:pg.idProductGroup])
                {
                    if ([arrayProductType containsObject:obj] == NO)
                    {
                        NSMutableArray * arParents = [pg getAllParents];
                        for(ProductGroup * pgToAdd in arParents)
                        {
                            if ([arrayProductType containsObject:pgToAdd] == NO)
                            {
                                [arrayProductType addObject:pgToAdd];
                            }
                        }
                    }
                }
            }
            bOrderByProductGroup = YES;
        }
    }
    
    if ((_selectedProductGroup != nil) && (bOrderByProductGroup))
    {
        NSMutableArray * arrayToOrder = [[NSMutableArray alloc] initWithArray:arrayProductType];
        [arrayProductType removeAllObjects];
        if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
        {
            arrayProductType = [self orderProductGroup:_selectedProductGroup usingArray:arrayToOrder level:0];
        }
        else
        {
            for(ProductGroup * pgSelected in arSelectedProductGroups)
            {
                NSMutableArray * arrayTemp = [self orderProductGroup:pgSelected usingArray:arrayToOrder level:0];
                [arrayProductType addObjectsFromArray:arrayTemp];
            }
            
            //            NSMutableArray * arrayRest = [[NSMutableArray alloc] init];
            //            NSMutableArray * arrayThisChild = [[NSMutableArray alloc] init];
            //
            //            for(ProductGroup * pgSelected in arSelectedProductGroups)
            //            {
            //                [arrayThisChild addObject:pgSelected];
            //                [arrayRest addObject:pgSelected];
            //                NSMutableArray * temp = [self orderProductGroup:pgSelected usingArray:arrayToOrder level:0];
            //
            //                if (temp.count > 0)
            //                {
            //                    // new array for the sections
            //                    NSArray * arObjects = [[NSArray alloc] initWithArray:arrayThisChild copyItems:NO];
            //                    SectionProductType * newSection = [SectionProductType new];
            //                    newSection.iLevel = 0;
            //                    NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
            //                    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
            //                    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil];
            //                    NSArray *sortedArray = [arObjects sortedArrayUsingDescriptors:sortDescriptors];
            //                    newSection.arElements = sortedArray;
            //                    [arSectionsFilter insertObject:newSection atIndex:arSectionsFilter.count-1];
            //                    [arrayThisChild removeAllObjects];
            //                }
            //            }
            //            if (arrayThisChild.count > 0 )
            //            {
            //                NSArray * arObjects = [[NSArray alloc] initWithArray:arrayThisChild copyItems:NO];
            //                SectionProductType * newSection = [SectionProductType new];
            //                newSection.iLevel = 0;
            //
            //                NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
            //                NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
            //                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil];
            //                NSArray *sortedArray = [arObjects sortedArrayUsingDescriptors:sortDescriptors];
            //
            //                newSection.arElements = sortedArray;
            //
            //                [arSectionsFilter addObject:newSection];
            //            }
        }
        
        
        return arSectionsFilter.count;
    }
    
    return 1;
    
}

-(BOOL)shouldReportResultsforSection:(int)section
{
    if (arSectionsFilter != nil)
    {
        if (arSectionsFilter.count > 1)
        {
            if (section > 0)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

-(NSString *) getHeaderTitleForFilterCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if(!([self numberOfSectionsFilterForCelltype:cellType] > 1))
    {
        return nil;
    }
    
    if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
    {
        if (indexPath.section == 1)
        {
            if (arExpandedSubProductGroup != nil)
            {
                if (arExpandedSubProductGroup.count > 0)
                {
                    ProductGroup * pg = (ProductGroup *)([arExpandedSubProductGroup objectAtIndex:0]);
                    NSString * sTitleSecion = [NSString stringWithFormat:NSLocalizedString(@"_SUBSTYLE_HEADER_SECTION",nil), [pg getNameForApp]];
                    return sTitleSecion;
                }
            }
        }
    }
    
    return nil;
}

-(unsigned long) numberOfItemsInSectionFilter:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    if(!filteredFilters)
    {
        filteredFilters = [[NSMutableArray alloc]init];
    }
    
    [filteredFilters removeAllObjects];
    
    BOOL bOrderByProductGroup = NO;
    for(NSObject * obj in [[self.searchBaseVC getFetchedResultsControllerForCellType:cellType] fetchedObjects])
    {
        if([obj isKindOfClass:[ProductGroup class]])
        {
            ProductGroup *pg = (ProductGroup *)obj;
            BOOL bAdd = YES;
            if ((_selectedProductGroup != nil) && (!(bUpdatingSelectionColor)))
            {
                bAdd = NO;
                for (ProductGroup * pgSelected in arExpandedSubProductGroup)
                {
                    if ([pgSelected isChild:pg])
                    {
                        bAdd = YES;
                        break;
                    }
                }
                
                if (bAdd == NO)
                {
                    if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
                    {
                        bAdd = ([_selectedProductGroup isChild:pg]);
                    }
                    else
                    {
                        for(ProductGroup * pgSelected in arSelectedProductGroups)
                        {
                            //                            if (([pgSelected isChild:pg]) || ([pg.idProductGroup isEqualToString:pgSelected.idProductGroup]))
                            if ([pgSelected isChild:pg])
                            {
                                bAdd = YES;
                                break;
                            }
                        }
                    }
                }
            }
            
            if (bAdd)
            {
                if(foundSuggestions.count == 0 || [foundSuggestions objectForKey:pg.idProductGroup])
                    [filteredFilters addObject:obj];
            }
            bOrderByProductGroup = YES;
        }
        else if([obj isKindOfClass:[Feature class]])
        {
            Feature * cs = (Feature*)obj;
            int iGender = [self getGenderFromName:cs.name];
            if(iGender != 0 || [foundSuggestions count] == 0 || [foundSuggestions objectForKey:cs.idFeature])
            {
                if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
                {
                    if ([cs isVisibleForGender:_iGenderSelected andProductCategory:_selectedProductGroup andSubProductCategories:arSelectedSubProductGroup])
                    {
                        [filteredFilters addObject:obj];
                    }
                }
                else if (self.searchBaseVC.searchContext == FASHIONISTAS_SEARCH)
                {
                    [filteredFilters addObject:obj];
                }
                //                else if (self.searchBaseVC.searchContext == FASHIONISTAPOSTS_SEARCH)
                //                {
                //                    [filteredFilters addObject:obj];
                //                }
                else
                {
                    for (ProductGroup * pg in arSelectedProductGroups)
                    {
                        if ([cs isVisibleForGender:_iGenderSelected andProductCategory:pg andSubProductCategories:arSelectedSubProductGroup])
                        {
                            [filteredFilters addObject:obj];
                            break;
                        }
                    }
                }
            }
        }
        else if([obj isKindOfClass:[Brand class]])
        {
            Brand * cs = (Brand*)obj;
            if([foundSuggestions count] == 0 || [foundSuggestions objectForKey:cs.idBrand])
                [filteredFilters addObject:obj];
        }
        
    }
    
    if ((bOrderByProductGroup) && (_selectedProductGroup != nil) && (!(bUpdatingSelectionColor)))
    {
        SectionProductType * objSection = [arSectionsFilter objectAtIndex:section];
        NSArray * arObjects = objSection.arElements;
        unsigned long iNum = [arObjects count];//[[[self getFetchedResultsControllerForCellType:cellType] sections][0] numberOfObjects];
        NSLog(@" ------- > %lu", iNum);
        
        return iNum;
    }
    //        return [[[self getFetchedResultsControllerForCellType:cellType] sections][0] numberOfObjects];
    return filteredFilters.count;
}

-(NSArray *)getContentFilterForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *backLabelColor = [UIColor whiteColor];
    long iIdxSelected = -1;
    
    NSObject * tmpResult = nil;
    if (indexPath.item < filteredFilters.count)
    {
        tmpResult = [filteredFilters objectAtIndex:indexPath.item];
    }
    SectionProductType * objSection = nil;
    if ((arSectionsFilter.count > indexPath.section) && (!(bUpdatingSelectionColor)))
    {
        objSection = [arSectionsFilter objectAtIndex:indexPath.section];
        NSArray * arElements = objSection.arElements;
        if (indexPath.item < arElements.count)
        {
            tmpResult = [arElements objectAtIndex:indexPath.item];
        }
    }
    
    if (tmpResult == nil)
    {
        return [NSArray new];
    }
    
    NSString * image = @"no_image.png";
    NSString * sName = @"";
    NSString * sNameCheck = @"";
    
    // comprobamos el tamaño de la celda, si es por defecto mostramos el zoom in, sino no.
    NSNumber * numberShowZoom = [NSNumber numberWithBool:YES];
    NSNumber * numberShowExpand = [NSNumber numberWithBool:NO];
    
    if ([tmpResult isKindOfClass:[ Brand class]])
    {
        Brand * brand = (Brand *)tmpResult;
        sNameCheck = sName = brand.name;
        if(brand.logo)
            image = brand.logo;
    }
    else if ([tmpResult isKindOfClass:[ Feature class]])
    {
        Feature * feature = (Feature *)tmpResult;
        sName = [feature getNameForApp];
        sNameCheck = feature.name;
        ProductGroup * subProductCategory = nil;
        if ((arSelectedSubProductGroup.count > 0) && (arSelectedSubProductGroup.count <= 1))
        {
            subProductCategory = [arSelectedSubProductGroup objectAtIndex:0];
        }
        image = [feature getIconForGender:_iGenderSelected andProductCategoryParent:_selectedProductGroup andSubProductCategories:arSelectedSubProductGroup byDefault:@"no_image.png"];
    }
    else if ([tmpResult isKindOfClass:[ ProductGroup class]])
    {
        ProductGroup * productCategory = (ProductGroup *)tmpResult;
        
        sName = [productCategory getNameForApp];
        sNameCheck = productCategory.name;
        image = [productCategory getIconForGender:_iGenderSelected byDefault:@"no_image.png"];
        
        if (productCategory == _selectedProductGroup)
        {
            backLabelColor = [UIColor colorWithRed:(244/255.0) green:(206/255.0) blue:(118/255.0) alpha:1.0f];
            iIdxSelected = 0;
        }
        
        if ((_selectedProductGroup != nil) && (!(bUpdatingSelectionColor)))
        {
            // check if some of the children are in found suggestions
            //            if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
            {
                if ([productCategory getChildrenInFoundSuggestions:foundSuggestions forGender:_iGenderSelected].count > 0)
                {
                    numberShowExpand = [NSNumber numberWithInt:1];
                    if ([arExpandedSubProductGroup containsObject:productCategory])
                    {
                        numberShowExpand = [NSNumber numberWithInt:2];
                    }
                }
            }
        }
        
    }
    else
    {
        NSLog(@"%@", NSStringFromClass([tmpResult class]));
    }
    
    NSString * sNameTrimmed = [sName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * sNameCheckTrimmed = [sNameCheck stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (iIdxSelected == -1)
    {
        iIdxSelected =[self iIdxFilterSelected:sNameCheckTrimmed];
        
        if (iIdxSelected != -1)
        {
            backLabelColor = [UIColor colorWithRed:(244/255.0) green:(206/255.0) blue:(118/255.0) alpha:1.0f];
        }
        else
        {
            if ([tmpResult isKindOfClass:[ ProductGroup class]])
            {
                ProductGroup * productCategory = (ProductGroup *)tmpResult;
                if (objSection != nil)
                {
                    if (objSection.iLevel == 0)
                    {
                        // check, buscando si el objeto tiene algun hijo seleccionado. Bucle recorrriendo el array de subcategorias selecionadas irando si alguno es hijo
                        // si tiene algun hijo seleccionado lo marcamos con color mas atenuado
                        for(ProductGroup  * pg in arSelectedSubProductGroup)
                        {
                            if ([productCategory isChild:pg])
                            {
                                backLabelColor = [UIColor colorWithRed:(254/255.0) green:(230/255.0) blue:(190/255.0) alpha:1.0f];
                                break;
                            }
                        }
                    }
                    else
                    {
                        ProductGroup * pgParent = productCategory.parent;
                        
                        // comprobamos que el padre está seleccionado
                        BOOL bParentSelected = NO;
                        for (ProductGroup * pgSelected in arSelectedSubProductGroup)
                        {
                            if ([pgSelected.idProductGroup isEqualToString:pgParent.idProductGroup])
                            {
                                bParentSelected = YES;
                                break;
                            }
                        }
                        
                        if (bParentSelected)
                        {
                            BOOL bSiblingSelected = NO;
                            for (ProductGroup * pg in pgParent.getChildren)
                            {
                                for (ProductGroup * pgSelected in arSelectedSubProductGroup)
                                {
                                    if ([pgSelected.idProductGroup isEqualToString:pg.idProductGroup])
                                    {
                                        bSiblingSelected = YES;
                                        break;
                                    }
                                }
                                
                                if (bSiblingSelected)
                                    break;
                            }
                            
                            if (bSiblingSelected == NO)
                            {
                                backLabelColor = [UIColor colorWithRed:(254/255.0) green:(230/255.0) blue:(190/255.0) alpha:1.0f];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return [NSArray arrayWithObjects: image, sNameTrimmed.uppercaseString, backLabelColor, numberShowZoom, numberShowExpand, nil];
}

-(BOOL)actionForFilterSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    BOOL bUpdateBottomBar = YES;
    NSObject * obj = nil;
    
    if (indexPath.item < filteredFilters.count)
    {
        obj = [filteredFilters objectAtIndex:indexPath.item];
    }
    if (arSectionsFilter.count > 0)
    {
        if (indexPath.section < arSectionsFilter.count)
        {
            SectionProductType * objSection = [arSectionsFilter objectAtIndex:indexPath.section];
            NSArray * arObjects = objSection.arElements;
            if (indexPath.item < arObjects.count)
            {
                obj = [arObjects objectAtIndex:indexPath.item];
            }
        }
    }
    
    BOOL bCheckSearchTerms = (self.searchBaseVC.searchContext == PRODUCT_SEARCH);
    
    int iIdx = INT_MAX;
    if ([obj isKindOfClass:[NSString class]])
    {
        iIdx = (int)[self iIdxFilterSelected:(NSString *)obj];
        if (iIdx > -1)
        {
            [self.searchBaseVC removeSearchTermAtIndex:iIdx checkSuggestions:YES];
        }
        else
        {
            [self.searchBaseVC addSearchTermWithObject:obj animated:YES performSearch:NO checkSearchTerms:bCheckSearchTerms];
        }
        
        [_filtersCollectionView reloadData];
    }
    else if ([obj isKindOfClass:[ProductGroup class]])
    {
        ProductGroup *pg = (ProductGroup *)obj;
        
        if (self.searchBaseVC.searchContext != PRODUCT_SEARCH)
        {
            // the product category already exists
            iIdx = (int)[self iIdxFilterSelected:pg.app_name];
            if (iIdx > -1)
            {
                [self.searchBaseVC removeSearchTermAtIndex:iIdx checkSuggestions:YES];
            }
            else
            {
                iIdx = (int)[self iIdxFilterSelected:pg.name];
                if (iIdx > -1)
                {
                    [self.searchBaseVC removeSearchTermAtIndex:iIdx checkSuggestions:YES];
                }
            }
            
            if (iIdx <= -1)
            {
                [self.searchBaseVC addSearchTermWithObject:pg animated:YES performSearch:NO checkSearchTerms:NO];
            }
            
            [_filtersCollectionView reloadData];
            
        }
        else
        {
            if (_selectedProductGroup == nil)
            {
                _selectedProductGroup = pg;
                
                [self.searchBaseVC addSearchTermWithObject:_selectedProductGroup animated:YES performSearch:NO checkSearchTerms:YES];
                [self getFiltersForProductGroup:_selectedProductGroup];
                [self initSelectedSlide];
                
                // check if there are any child with the expanded property to true, if there is one, we need to expand it
                NSMutableArray *pgChildren = [pg getChildrenInFoundSuggestions:foundSuggestions forGender:_iGenderSelected];
                for(ProductGroup *pgchild in pgChildren)
                {
                    if ([pgchild checkExpandedForGender:_iGenderSelected])
                    {
                        [arExpandedSubProductGroup removeAllObjects];
                        [arExpandedSubProductGroup addObject:pgchild];
                        break;
                    }
                }
                
                bUpdatingSelectionColor = YES;
                
                [_filtersCollectionView reloadData];
            }
            else
            {
                ProductGroup * pgParent = [pg getTopParent];
                if ([pgParent.idProductGroup isEqualToString:_selectedProductGroup.idProductGroup])
                {
                    [self manageClickInProductGroup:pg];
                }
            }
            
            bUpdateBottomBar = NO;
        }
    }
    else if ([obj isKindOfClass:[Brand class]])
    {
        Brand *brand = (Brand *)obj;
        iIdx = (int)[self iIdxFilterSelected:brand.name];
        if (iIdx > -1)
        {
            [self.searchBaseVC removeSearchTermAtIndex:iIdx checkSuggestions:YES];
        }
        else
        {
            [self.searchBaseVC addSearchTermWithObject:obj animated:YES performSearch:NO checkSearchTerms:bCheckSearchTerms];
        }
        [_filtersCollectionView reloadData];
    }
    else if ([obj isKindOfClass:[Feature class]])
    {
        Feature *feature = (Feature *)obj;
        iIdx = (int)[self iIdxFilterSelected:feature.name];
        if (iIdx > -1)
        {
            [self.searchBaseVC removeSearchTermAtIndex:iIdx checkSuggestions:YES];
        }
        else
        {
            [self.searchBaseVC addSearchTermWithObject:obj animated:YES performSearch:NO checkSearchTerms:bCheckSearchTerms];
        }
        
        if (bCheckSearchTerms)
        {
            NSString * sFeatureGroupName = [[feature.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([sFeatureGroupName isEqualToString:@"gender"])
            {
                if (_selectedProductGroup != nil)
                {
                    [self getGenderSelected];
                    [self getFiltersForProductGroup:_selectedProductGroup];
                    [self.searchBaseVC initOperationsLoadingImages];
                    [self.searchBaseVC.imagesQueue cancelAllOperations];
                    [_filtersCollectionView reloadData];
                    
                    [self updateSuccessulTermsForGender];
                }
            }
        }
        [_filtersCollectionView reloadData];
    }
    else
    {
        NSLog(@"Search, Element not recognized %@", NSStringFromClass([obj class]));
    }
    
    return bUpdateBottomBar;
}

#pragma mark - Expand button
-(void) expandFilterButton:(UIButton *)sender
{
    long iIndex = sender.tag;
    int iSection = (int)iIndex / OFFSET;
    int iItem = iIndex % OFFSET;
    
    NSObject * obj = [filteredFilters objectAtIndex:iItem];
    if (arSectionsFilter.count > 0)
    {
        SectionProductType * objSection = [arSectionsFilter objectAtIndex:iSection];
        NSArray * arObjects = objSection.arElements;
        obj = [arObjects objectAtIndex:iItem];
    }
    
    if (obj != nil)
    {
        if ([arExpandedSubProductGroup containsObject:obj])
        {
            [arExpandedSubProductGroup removeObject:obj];
        }
        else
        {
            [arExpandedSubProductGroup removeAllObjects];
            [arExpandedSubProductGroup addObject:obj];
        }
        
        [_filtersCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_filtersCollectionView reloadData];
        });
        
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
{
    // You will get here when the reloadData finished
    if ([keyPath isEqualToString:@"contentSize"])
    {
        [self finishReloadingCollectionView];
    }
    
    [_filtersCollectionView removeObserver:self forKeyPath:@"contentSize" context:NULL];
    
}
-(void) finishReloadingCollectionView
{
    if (arSectionsFilter.count > 0)
    {
        if (arExpandedSubProductGroup.count > 0)
        {
            ProductGroup * pgExpanded = [arExpandedSubProductGroup objectAtIndex:0];
            
            SectionProductType * sectionPG = [arSectionsFilter objectAtIndex:0];
            int iItemScrollTo = 0;
            BOOL bTrobat = NO;
            for(ProductGroup * pg in sectionPG.arElements)
            {
                if ([pg.idProductGroup isEqualToString:pgExpanded.idProductGroup])
                {
                    bTrobat = YES;
                    break;
                }
                iItemScrollTo++;
            }
            if (bTrobat)
            {
                // volver a buscar el item para obtener la nueva seccion y item
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:iItemScrollTo inSection:0];
                [_filtersCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            }
        }
    }
}


#pragma mark - Zoom view

-(void) initZoomView
{
    if (self.zoomView == nil)
    {
        if (self.searchBaseVC.parentViewController != nil)
        {
            // Init the hint view
            self.zoomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.searchBaseVC.parentViewController.view.frame.size.width, self.searchBaseVC.parentViewController.view.frame.size.height)];
            self.zoomBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.searchBaseVC.parentViewController.view.frame.size.width, self.searchBaseVC.parentViewController.view.frame.size.height)];
        }
        else
        {
            self.zoomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.searchBaseVC.view.frame.size.width, self.searchBaseVC.view.frame.size.height)];
            self.zoomBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.searchBaseVC.view.frame.size.width, self.searchBaseVC.view.frame.size.height)];
        }
        
        
        self.zoomView.clipsToBounds = NO;
        self.zoomView.contentMode = UIViewContentModeScaleAspectFit;
        self.zoomView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.zoomView.layer.shadowOffset = CGSizeMake(0,5);
        self.zoomView.layer.shadowOpacity = 0.5;
        self.zoomView.hidden = YES;
        
        
        // And the hint background view
        self.zoomBackgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        self.zoomBackgroundView.hidden = YES;
        
        self.zoomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.zoomLabel.backgroundColor = [UIColor blackColor];
        self.zoomLabel.textColor = [UIColor whiteColor];
        self.zoomLabel.textAlignment = NSTextAlignmentCenter;
        [self.zoomLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:14]];
        [self.zoomBackgroundView addSubview:self.zoomLabel];
        
        if (self.searchBaseVC.parentViewController != nil)
        {
            [self.searchBaseVC.parentViewController.view addSubview:self.zoomView];
            [self.searchBaseVC.parentViewController.view addSubview:self.zoomBackgroundView];
            
            [self.searchBaseVC.parentViewController.view bringSubviewToFront:self.zoomBackgroundView];
            [self.searchBaseVC.parentViewController.view bringSubviewToFront:self.zoomView];
        }
        else
        {
            [self.searchBaseVC.view addSubview:self.zoomView];
            [self.searchBaseVC.view addSubview:self.zoomBackgroundView];
            
            [self.searchBaseVC.view bringSubviewToFront:self.zoomBackgroundView];
            [self.searchBaseVC.view bringSubviewToFront:self.zoomView];
            
        }
    }
}

-(void) zoomFilterButton:(UIButton *)sender
{
    UIButton * btn = (UIButton *)sender;
    [self loadImageZoomView:[btn imageForState:UIControlStateApplication] andLabel:[btn titleForState:UIControlStateApplication]];
    [self showZoomView];
}

-(void) showZoomView
{
    if (self.zoomView.hidden == NO)
        return;
    
    UIView * view;
    if (self.searchBaseVC.parentViewController != nil)
    {
        [self.searchBaseVC.parentViewController.view bringSubviewToFront:self.zoomBackgroundView];
        [self.searchBaseVC.parentViewController.view bringSubviewToFront:self.zoomView];
        view = self.searchBaseVC.parentViewController.view;
    }
    else
    {
        [self.searchBaseVC.view bringSubviewToFront:self.zoomBackgroundView];
        [self.searchBaseVC.view bringSubviewToFront:self.zoomView];
        view = self.searchBaseVC.view;
    }
    
    // load the image
    //    [self.zoomView setImage:[UIImage imageNamed:@"Wardrobes.jpg"]];
    float fNewW = view.frame.size.width * 0.8;
    float fNewH = view.frame.size.height * 0.8;
    float fOffX = view.frame.size.width * 0.1;
    float fOffY = view.frame.size.height * 0.1;
    
    self.zoomLabel.userInteractionEnabled = YES;
    self.zoomLabel.alpha = 0.0;
    self.zoomLabel.hidden = NO;
    self.zoomLabel.frame = CGRectMake(fOffX, fOffY-40, fNewW, 40);
    self.zoomView.hidden = NO;
    self.zoomView.alpha = 0.0;
    self.zoomBackgroundView.hidden = NO;
    self.zoomBackgroundView.alpha = 0.0;
    
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.zoomView.frame = CGRectMake(fOffX, fOffY, fNewW, fNewH);
                         self.zoomView.alpha = 1.0;
                         self.zoomBackgroundView.alpha = 1.0;
                         self.zoomLabel.alpha = 1.0;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void) loadImageZoomViewFromPath:(NSString *) pathImage andLabel:(NSString *) textLabel
{
    self.zoomLabel.text = textLabel;
    
    if ([UIImage isCached:pathImage])
    {
        UIImage * image = [UIImage cachedImageWithURL:pathImage];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        [self.zoomView setImage:image];
        
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:pathImage];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.zoomView setImage:image];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.searchBaseVC.imagesQueue addOperation:operation];
    }
    
}

-(void) loadImageZoomView:(UIImage *) image andLabel:(NSString *)textLabel
{
    self.zoomLabel.text = textLabel;
    
    [self.zoomView setImage:image];
    
}

-(void) hideZoomView
{
    if (self.zoomView.hidden == YES)
        return;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         self.zoomView.alpha = 0.0;
                         self.zoomBackgroundView.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         self.zoomView.hidden = YES;
                         self.zoomBackgroundView.hidden = YES;
                     }];
    
}

-(BOOL) zoomViewVisible
{
    return (self.zoomView.hidden == NO);
}


#pragma mark - Gender

-(void) getGenderSelected
{
    _iGenderSelected = 0;
    for (NSObject *obj in self.searchBaseVC.searchTermsListView.arrayButtons)
    {
        if ([obj isKindOfClass:[Feature class]])
        {
            Feature * feat = (Feature *)obj;
            NSString * sNameFeatureGroup = [[feat.featureGroup.name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([sNameFeatureGroup isEqualToString:@"gender"])
            {
                int iGender = [self getGenderFromName:feat.name];
                _iGenderSelected += iGender;
            }
        }
    }
}

-(Feature *)getGenderFeatureFromIndex:(int) iIdxGender
{
    NSString * sTextGender = @"";
    if (iIdxGender == pow(2,0))
    {
        sTextGender = @"Men";
    }
    else if (iIdxGender == pow(2,1))
    {
        sTextGender = @"Women";
    }
    else if (iIdxGender == pow(2,2))
    {
        sTextGender = @"Boy";
    }
    else if (iIdxGender == pow(2,3))
    {
        sTextGender = @"Girl";
    }
    else if (iIdxGender == pow(2,4))
    {
        sTextGender = @"Unisex";
    }
    else if (iIdxGender == pow(2,5))
    {
        sTextGender = @"Kids";
    }
    
    return [self getFeatureFromName:sTextGender];
}

-(int)getGenderFromName:(NSString *)sGender
{
    int iGender = 0;
    
    NSString * sGenderTrimmer = [[sGender lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([sGenderTrimmer isEqualToString:@"men"])
    {
        iGender = pow(2,0); // 1
    }
    else if ([sGenderTrimmer isEqualToString:@"women"])
    {
        iGender = pow(2,1); // 2
    }
    else if ([sGenderTrimmer isEqualToString:@"boy"])
    {
        iGender = pow(2,2); // 4
    }
    else if ([sGenderTrimmer isEqualToString:@"girl"])
    {
        iGender = pow(2,3); // 8
    }
    else if ([sGenderTrimmer isEqualToString:@"unisex"])
    {
        iGender = pow(2,4); // 16
    }
    else if ([sGenderTrimmer isEqualToString:@"kids"])
    {
        iGender = pow(2,5); // 32
    }
    
    return iGender;
    
}

-(void) updateSuccessulTermsForGender
{
    int iFixedButtons = 0;
    
    if(self.searchBaseVC.searchContext == HISTORY_SEARCH)
        iFixedButtons = 1;
    else if(self.searchBaseVC.searchContext == FASHIONISTAS_SEARCH)
        iFixedButtons = 1;
    else if(self.searchBaseVC.searchContext == FASHIONISTAPOSTS_SEARCH)
        iFixedButtons = 1;
    
    NSMutableIndexSet *mutableIndexSetSuccessfulTerms = [[NSMutableIndexSet alloc] init];
    
    NSMutableArray *copy = [[NSMutableArray alloc] initWithArray:self.searchBaseVC.searchTermsListView.arrayButtons copyItems:NO];
    
    int iIdx = 0;
    for (NSObject *obj in copy)
    {
        if ([obj isKindOfClass:[ProductGroup class]])
        {
            ProductGroup * pg = (ProductGroup *)obj;
            if (_selectedProductGroup == nil)
            {
                // the selectedproduct ctagoery parent is null, so we muste remove all the product catgoeries from the successul terms
                [self.searchBaseVC.searchTermsListView removeButtonByObject:obj];
                [mutableIndexSetSuccessfulTerms addIndex:iIdx-iFixedButtons];
            }
            else if (_selectedProductGroup != nil)
            {
                if (self.searchBaseVC.searchContext == PRODUCT_SEARCH)
                {
                    if ([pg.idProductGroup isEqualToString:_selectedProductGroup.idProductGroup] == NO)
                    {
                        if ([pg checkGender:_iGenderSelected] == NO)
                        {
                            [self.searchBaseVC.searchTermsListView removeButtonByObject:obj];
                            [mutableIndexSetSuccessfulTerms addIndex:iIdx-iFixedButtons];
                        }
                    }
                }
                else
                {
                    for (ProductGroup * pgParent in arSelectedProductGroups)
                    {
                        if ([pg.idProductGroup isEqualToString:pgParent.idProductGroup] == NO)
                        {
                            if ([pg checkGender:_iGenderSelected] == NO)
                            {
                                [self.searchBaseVC.searchTermsListView removeButtonByObject:obj];
                                [mutableIndexSetSuccessfulTerms addIndex:iIdx-iFixedButtons];
                            }
                        }
                    }
                }
            }
        }
        
        iIdx ++;
    }
    
    [self.searchBaseVC.successfulTerms removeObjectsAtIndexes:mutableIndexSetSuccessfulTerms];
    
    [self.searchBaseVC checkSearchTerms:NO];
}


#pragma mark - CoreData queries

// Initialize a specific Fetched Results Controller to fetch the local keywords in order to force user to select one
- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate withString:(NSString *)stringForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    NSFetchRequest * keywordssFetchRequest = nil;
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    if (keywordssFetchRequest == nil)
    {
        if(!(stringForPredicate == nil))
        {
            if(!([stringForPredicate isEqualToString:@""]))
            {
                keywordssFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [keywordssFetchRequest setEntity:entity];
                
                // Filter results
                
                [keywordssFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, stringForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [keywordssFetchRequest setFetchBatchSize:20];
            }
        }
    }
    
    if(keywordssFetchRequest)
    {
        // Initialize Fetched Results Controller
        
        //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        keywordsFetchedResultsController = fetchedResultsController;
        
        //        keywordsFetchedResultsController.delegate = self;
    }
    
    if(keywordsFetchedResultsController)
    {
        // Perform fetch
        
        NSError *error = nil;
        
        if (![keywordsFetchedResultsController performFetch:&error])
        {
            NSLog(@"Couldn't fetch elements. Unresolved error: %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return keywordsFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsControllerWithEntity:(NSString *)entityName andPredicateObject:(NSPredicate *)predicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    NSFetchRequest * keywordssFetchRequest = nil;
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    if (keywordssFetchRequest == nil)
    {
        if(!(predicate == nil))
        {
            keywordssFetchRequest = [[NSFetchRequest alloc] init];
            
            // Entity to look for
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
            
            [keywordssFetchRequest setEntity:entity];
            
            // Filter results
            
            [keywordssFetchRequest setPredicate:predicate];
            
            // Sort results
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
            
            [keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            [keywordssFetchRequest setFetchBatchSize:20];
        }
    }
    
    if(keywordssFetchRequest)
    {
        // Initialize Fetched Results Controller
        
        //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        keywordsFetchedResultsController = fetchedResultsController;
        
        //        keywordsFetchedResultsController.delegate = self;
    }
    
    if(keywordsFetchedResultsController)
    {
        // Perform fetch
        
        NSError *error = nil;
        
        if (![keywordsFetchedResultsController performFetch:&error])
        {
            NSLog(@"Couldn't fetch elements. Unresolved error: %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return keywordsFetchedResultsController;
}

#pragma mark - [ProductGroup]

-(ProductGroup *) getProductGroupFromName:(NSString *) name
{
    ProductGroup * tmpProductGroup = [[CoreDataQuery sharedCoreDataQuery] getProductGroupFromName:name];
    
    if (tmpProductGroup != nil)
    {
        ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
        
        if (productGroupsParentForSuggestedKeywords == nil)
        {
            productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
        }
        
        if (![productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
            [productGroupsParentForSuggestedKeywords addObject:productGroupParent];
        
        
        return tmpProductGroup;
    }
    
    return nil;
    
    /*
     if (dictProductGroupsByName != nil)
     {
     ProductGroup * tmpProductGroup = [dictProductGroupsByName objectForKey:name];
     if (tmpProductGroup == nil)
     {
     if (dictProductGroupsByAppName != nil)
     {
     tmpProductGroup = [dictProductGroupsByAppName objectForKey:name];
     }
     }
     
     if (tmpProductGroup != nil)
     {
     ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
     
     if (productGroupsParentForSuggestedKeywords == nil)
     {
     productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
     }
     
     if (![productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
     [productGroupsParentForSuggestedKeywords addObject:productGroupParent];
     
     
     return tmpProductGroup;
     }
     
     return nil;
     }
     
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     //    NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     if ([[keywordsFetchedResultsController fetchedObjects] count] == 0)
     {
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"app_name matches[cd] %@" withString:name sortingWithKey:@"idProductGroup" ascending:YES];
     
     }
     
     
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpProductGroup == nil))
     {
     if(!(tmpProductGroup.idProductGroup == nil))
     {
     if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
     {
     ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
     
     if (productGroupsParentForSuggestedKeywords == nil)
     {
     productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
     }
     
     if (![productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
     [productGroupsParentForSuggestedKeywords addObject:productGroupParent];
     
     
     //                        if (tmpProductGroup.parent != nil)
     //                            return tmpProductGroup.parent;
     //
     //                        return productGroupParent;
     
     return tmpProductGroup;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(ProductGroup *) getProductGroupFromId:(NSString *) idProductGroup
{
    return [[CoreDataQuery sharedCoreDataQuery] getProductGroupFromId:idProductGroup];
    /*
     if (dictProductGroupsById != nil)
     {
     return [dictProductGroupsById objectForKey:idProductGroup];
     }
     
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"ProductGroup" andPredicate:@"idProductGroup = %@" withString:idProductGroup sortingWithKey:@"idProductGroup" ascending:YES];
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     ProductGroup * tmpProductGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpProductGroup == nil))
     {
     if(!(tmpProductGroup.idProductGroup == nil))
     {
     if(!([tmpProductGroup.idProductGroup isEqualToString:@""]))
     {
     return tmpProductGroup;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(ProductGroup *) getProductGroupParentFromId:(NSString *) idProductGroup
{
    ProductGroup * tmpProductGroup = [[CoreDataQuery sharedCoreDataQuery] getProductGroupParentFromId:idProductGroup];
    if (tmpProductGroup != nil)
    {
        if (productGroupsParentForSuggestedKeywords == nil)
        {
            productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
        }
        
        if (![productGroupsParentForSuggestedKeywords containsObject:tmpProductGroup])
            [productGroupsParentForSuggestedKeywords addObject:tmpProductGroup];
        
        return tmpProductGroup;
    }
    
    return nil;
    /*
     ProductGroup * tmpProductGroup = [self getProductGroupFromId:idProductGroup];
     
     if (tmpProductGroup != nil)
     {
     ProductGroup * productGroupParent = [tmpProductGroup getTopParent];
     
     if (productGroupsParentForSuggestedKeywords == nil)
     {
     productGroupsParentForSuggestedKeywords = [[NSMutableArray alloc] init];
     }
     
     if (![productGroupsParentForSuggestedKeywords containsObject:productGroupParent])
     [productGroupsParentForSuggestedKeywords addObject:productGroupParent];
     
     return productGroupParent;
     }
     
     return nil;
     */
}

-(BOOL) allSuggestedProductGroup
{
    for (NSString * sSuggestedkeyword in suggestedFilters)
    {
        //        ProductGroup * pg = [self getProductGroupFromName:sSuggestedkeyword];
        ProductGroup * pg = [self getProductGroupFromId:sSuggestedkeyword];
        if (pg == nil)
            return NO;
    }
    
    return (suggestedFilters.count > 0);
}

-(BOOL) isGenderInProductCategorySuccess:(NSString *)sGender
{
    int iGender = [self getGenderFromName:sGender];
    for(ProductGroup * pgSuccess in successfulTermProductGroup)
    {
        if ([pgSuccess checkGender:iGender])
        {
            return YES;
        }
    }
    
    if ([_selectedProductGroup checkGender:iGender])
    {
        return YES;
    }
    
    return NO;
}

-(NSMutableArray *) orderProductGroup:(ProductGroup *) pgParam usingArray:(NSMutableArray *)arrayToOrder level:(int) iLevel
{
    NSMutableArray * arrayRest = [[NSMutableArray alloc] init];
    NSMutableArray * arrayThisChild = [[NSMutableArray alloc] init];
    NSMutableArray  * arChildren = [pgParam getChildren];
    for(ProductGroup * pg in arChildren)
    {
        if ([arrayToOrder containsObject:pg])
        {
            if ([pg checkGender:_iGenderSelected] == NO)
            {
                continue;
            }
            
            [arrayThisChild addObject:pg];
            [arrayRest addObject:pg];
            NSMutableArray * temp = [self orderProductGroup:pg usingArray:arrayToOrder level:iLevel+1];
            
            if (temp.count > 0)
            {
                // new array for the sections
                NSArray * arObjects = [[NSArray alloc] initWithArray:arrayThisChild copyItems:NO];
                SectionProductType * newSection = [SectionProductType new];
                newSection.iLevel = iLevel;
                NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
                NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil];
                NSArray *sortedArray = [arObjects sortedArrayUsingDescriptors:sortDescriptors];
                newSection.arElements = sortedArray;
                [arSectionsFilter insertObject:newSection atIndex:arSectionsFilter.count-1];
                [arrayThisChild removeAllObjects];
            }
            
            [arrayRest addObjectsFromArray:temp];
        }
    }
    if (arrayThisChild.count > 0 )
    {
        NSArray * arObjects = [[NSArray alloc] initWithArray:arrayThisChild copyItems:NO];
        SectionProductType * newSection = [SectionProductType new];
        newSection.iLevel = iLevel;
        
        NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
        NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil];
        NSArray *sortedArray = [arObjects sortedArrayUsingDescriptors:sortDescriptors];
        
        newSection.arElements = sortedArray;
        
        [arSectionsFilter addObject:newSection];
    }
    
    return arrayRest;
    
}

-(NSMutableArray *) arGetChildrenProductGroupSelected:(NSMutableArray *) arChildren
{
    NSMutableArray * arChildrenSelected = [NSMutableArray new];
    
    for(ProductGroup * pg in arChildren)
    {
        if ([self.searchBaseVC.searchTermsListView.arrayButtons containsObject:pg] == YES)
        {
            [arChildrenSelected addObject:pg];
        }
    }
    
    return arChildrenSelected;
}


-(void) manageClickInProductGroup:(ProductGroup *)pg
{
    if (_selectedProductGroup != nil)
    {
        if (pg.parent == _selectedProductGroup)
        {
            // the product category is parent
            NSMutableArray * arChildren = [pg getAllDescendantsInFoundSuggestions:foundSuggestions forGender:_iGenderSelected];
            NSMutableArray * arChildrenSelected = [self arGetChildrenProductGroupSelected:arChildren];
            if ([self.searchBaseVC.searchTermsListView.arrayButtons containsObject:pg] == NO)
            {
                // el padre NO esta seleccionado
                
                // hacemos que se colapsen lo que hubiera abierto
                if (arExpandedSubProductGroup != nil)
                {
                    if (arExpandedSubProductGroup.count > 0)
                    {
                        ProductGroup * pgExpanded = [arExpandedSubProductGroup objectAtIndex:0];
                        if ([pg.idProductGroup isEqualToString:pgExpanded.idProductGroup] == NO)
                        {
                            [arExpandedSubProductGroup removeAllObjects];
                        }
                    }
                    
                    // expandimos automaticamente el padre
                    if (arExpandedSubProductGroup.count == 0)
                    {
                        [arExpandedSubProductGroup addObject:pg];
                    }
                }
                
                // no seleccionado el objeto
                if (arChildrenSelected.count == 0)
                {
                    // numero de hijos seleccionado es 0
                }
                else
                {
                    // numero de hijos seleccionados no es 0
                    
                    // deseleccionar todos los hijos seleccionados
                    for(ProductGroup * pgSelected in arChildrenSelected)
                    {
                        [self removeFromSearchTermProductGroup:pgSelected checkSearchTerms:NO];
                    }
                }
                
                // seleccionamos el padre
                [self.searchBaseVC addSearchTermWithObject:pg animated:YES performSearch:NO checkSearchTerms:YES];
                iNumSubProductGroups++;
                [arSelectedSubProductGroup addObject:pg];
            }
            else
            {
                // el padre ya está seleccionado
                
                // deseleccionar todos los hijos seleccionados
                for(ProductGroup * pgSelected in arChildrenSelected)
                {
                    [self removeFromSearchTermProductGroup:pgSelected checkSearchTerms:NO];
                }
                // deseleccionamos el padre
                [self removeFromSearchTermProductGroup:pg checkSearchTerms:YES];
            }
        }
        else
        {
            ProductGroup * pgParent = pg.parent;
            NSMutableArray * arSiblings = [pgParent getAllDescendantsInFoundSuggestions:foundSuggestions forGender:_iGenderSelected];
            
            // la product category es un substyle
            if ([self.searchBaseVC.searchTermsListView.arrayButtons containsObject:pg] == NO)
            {
                // el product category NO está seleccionado
                
                // chequeamos si el padre esta seleccionado o no
                if ([self.searchBaseVC.searchTermsListView.arrayButtons containsObject:pgParent] == YES)
                {
                    // padre seleccionado
                    
                    // seleccionamos hermanos
                    for (ProductGroup * pgSibling in arSiblings)
                    {
                        if ([pgSibling.idProductGroup isEqualToString:pg.idProductGroup] == NO)
                        {
                            [self.searchBaseVC addSearchTermWithObject:pgSibling animated:YES performSearch:NO checkSearchTerms:NO];
                            iNumSubProductGroups++;
                            [arSelectedSubProductGroup addObject:pgSibling];
                        }
                    }
                    // deseleccionamos padre
                    [self removeFromSearchTermProductGroup:pgParent checkSearchTerms:YES];
                }
                else
                {
                    // padre no seleccionado
                    
                    
                    // seleccionamos el product category
                    [self.searchBaseVC addSearchTermWithObject:pg animated:YES performSearch:NO checkSearchTerms:NO];
                    iNumSubProductGroups++;
                    [arSelectedSubProductGroup addObject:pg];
                    // comprobamos si todos los hijos estan seleccionados
                    NSMutableArray * arChildrenSelected = [self arGetChildrenProductGroupSelected:arSiblings];
                    if (arSiblings.count == arChildrenSelected.count)
                    {
                        // tenemos todos los hijos seleccionados
                        
                        // deseleccionar todos los hijos seleccionados
                        for(ProductGroup * pgSelected in arChildrenSelected)
                        {
                            [self removeFromSearchTermProductGroup:pgSelected checkSearchTerms:NO];
                        }
                        
                        // dejamos seleccionado solo el padre
                        [self.searchBaseVC addSearchTermWithObject:pgParent animated:YES performSearch:NO checkSearchTerms:YES];
                        iNumSubProductGroups++;
                        [arSelectedSubProductGroup addObject:pgParent];
                    }
                    else
                    {
                        // no todos los hijos estan seleccionados
                        // ya se ha seleccionado el product category
                        [self.searchBaseVC checkSearchTerms:NO];
                    }
                }
                
            }
            else
            {
                // el product category está seleccionado
                [self removeFromSearchTermProductGroup:pg checkSearchTerms:YES];
            }
        }
    }
    [_filtersCollectionView reloadData];
}

-(void) removeFromSearchTermProductGroup:(ProductGroup *)pgDelete checkSearchTerms:(BOOL) bCheckSearchTerms
{
    int iIdx = (int)[self iIdxFilterSelected:pgDelete.app_name];
    if (iIdx > -1)
    {
        [arSelectedSubProductGroup removeObject:pgDelete];
        iNumSubProductGroups--;
        if (iNumSubProductGroups < 0)
            iNumSubProductGroups = 0;
        [self.searchBaseVC removeSearchTermAtIndex:iIdx checkSuggestions:bCheckSearchTerms];
    }
    else
    {
        iIdx = (int)[self iIdxFilterSelected:pgDelete.name];
        if (iIdx > -1)
        {
            [arSelectedSubProductGroup removeObject:pgDelete];
            iNumSubProductGroups--;
            if (iNumSubProductGroups < 0)
                iNumSubProductGroups = 0;
            [self.searchBaseVC removeSearchTermAtIndex:iIdx checkSuggestions:bCheckSearchTerms];
        }
    }
}

#pragma mark - [Features]

-(NSMutableArray *) getFeaturesOfFeatureGroupByName: (NSString *)sNameFeatureGroup
{
    return [[CoreDataQuery sharedCoreDataQuery] getFeaturesOfFeatureGroupByName:sNameFeatureGroup];
    /*
     sNameFeatureGroup = [[sNameFeatureGroup lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     
     NSMutableArray * arFeaturesOfFeatureGroup = [[NSMutableArray alloc] init];
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:sNameFeatureGroup sortingWithKey:@"idFeatureGroup" ascending:YES];
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpFeatureGroup == nil))
     {
     if(!(tmpFeatureGroup.idFeatureGroup == nil))
     {
     if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
     {
     NSMutableArray * allChildrenOfFeatureGroup = [tmpFeatureGroup getAllChildren];
     for (FeatureGroup * fg in allChildrenOfFeatureGroup)
     {
     for (Feature *f in fg.features)
     {
     if ([arFeaturesOfFeatureGroup containsObject:f] == NO)
     {
     [arFeaturesOfFeatureGroup addObject:f];
     }
     }
     }
     }
     }
     }
     }
     }
     
     return arFeaturesOfFeatureGroup;
     */
    
}

-(NSMutableArray *) getFeaturesOfProductGroupSelectedExcept:(NSString *)sFeatureGroupToIgnore
{
    NSMutableArray * arFeatureGrups = [[NSMutableArray alloc] init];
    NSMutableArray * arFeatureGroupOrder;
    
    if (_selectedProductGroup != nil)
    {
        arFeatureGroupOrder = [NSMutableArray arrayWithArray:[_selectedProductGroup.featuresGroupOrder allObjects]];// sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
        NSMutableArray * arPGParents = [_selectedProductGroup getAllParents];
        for (ProductGroup * pgParent in arPGParents)
        {
            
            NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgParent.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
            
            for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
            {
                if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                {
                    [arFeatureGroupOrder addObject:fgOrder];
                }
            }
        }
        
        // si no hay subproduct category seleccionado seleccionamos los descendiente de la selected product category
        if (arSelectedSubProductGroup.count == 0)
        {
            NSMutableArray * arPGDescendatns = [_selectedProductGroup getAllDescendants];
            for (ProductGroup * pgDescendant in arPGDescendatns)
            {
                
                NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgDescendant.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
                
                for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
                {
                    if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                    {
                        [arFeatureGroupOrder addObject:fgOrder];
                    }
                }
            }
        }
        
        
        //looping through all the sub product categories selected
        for(ProductGroup * pgSelected in arSelectedSubProductGroup)
        {
            NSMutableArray * arPGParents = [pgSelected getAllParents];
            for (ProductGroup * pgParent in arPGParents)
            {
                
                NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgParent.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
                
                for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
                {
                    if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                    {
                        [arFeatureGroupOrder addObject:fgOrder];
                    }
                }
            }
            NSMutableArray * arPGDescendatns = [pgSelected getAllDescendants];
            for (ProductGroup * pgDescendant in arPGDescendatns)
            {
                
                NSMutableArray * arFeatureGroupOrderTmp = [NSMutableArray arrayWithArray:[pgDescendant.featuresGroupOrder allObjects]] ;//] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
                
                for (FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrderTmp)
                {
                    if ([arFeatureGroupOrder containsObject:fgOrder] == NO)
                    {
                        [arFeatureGroupOrder addObject:fgOrder];
                    }
                }
            }
        }
        
    }
    
    // sort the mutable array
    NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"featureGroup.name" ascending:YES];
    
    arFeatureGroupOrder = [NSMutableArray arrayWithArray:[arFeatureGroupOrder sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];
    NSString * sFeatureGroupToIgnoreTrimmed = [sFeatureGroupToIgnore stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // looping all product categories filtering the product ctagoeries withour featuregroup
    for(FeatureGroupOrderProductGroup * fgOrder in arFeatureGroupOrder)
    {
        if (fgOrder.order > 0)
        {
            FeatureGroup * fg = [fgOrder.featureGroup getTopParent];
            // check the num features for each featuregroup
            int iNumFeatures = [fg getNumTotalFeatures];
            if (iNumFeatures > 0)
            {
                // check the name of the featuregroup, if is equal to the parameter
                NSString *sFeatureGroupNameTrimmed = [fg.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (![sFeatureGroupToIgnoreTrimmed.lowercaseString isEqualToString:sFeatureGroupNameTrimmed.lowercaseString])
                {
                    if (![arFeatureGrups containsObject:fg])
                    {
                        [arFeatureGrups addObject:fg];
                    }
                }
            }
        }
    }
    
    
    return arFeatureGrups;
}

-(Feature *)getFeatureFromId:(NSString *)idFeature
{
    return [[CoreDataQuery sharedCoreDataQuery] getFeatureFromId:idFeature];
    /*
     if (dictFeaturesById)
     {
     return [dictFeaturesById objectForKey:idFeature];
     }
     
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"idFeature = %@" withString:idFeature sortingWithKey:@"idFeature" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpFeature == nil))
     {
     if(!(tmpFeature.idFeature == nil))
     {
     if(!([tmpFeature.idFeature isEqualToString:@""]))
     {
     return tmpFeature;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(Feature *)getFeatureFromName:(NSString *)sName
{
    return [[CoreDataQuery sharedCoreDataQuery] getFeatureFromName:sName];
    /*
     if (dictFeaturesByName != nil)
     {
     Feature * tmpFeature = [dictFeaturesByName objectForKey:sName];
     return tmpFeature;
     }
     
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"name matches[cd] %@" withString:sName sortingWithKey:@"idFeature" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpFeature == nil))
     {
     if(!(tmpFeature.idFeature == nil))
     {
     if(!([tmpFeature.idFeature isEqualToString:@""]))
     {
     return tmpFeature;
     }
     }
     }
     }
     }
     return nil;
     */
}

#pragma mark - [FeatureGroup]

-(FeatureGroup *)getFeatureGroupFromName:(NSString *)name
{
    return [[CoreDataQuery sharedCoreDataQuery] getFeatureGroupFromName:name];
    /*
     if (dictFeatureGroupsByName != nil)
     {
     FeatureGroup * tmpFeatureGroup = [dictFeatureGroupsByName objectForKey:name];
     return tmpFeatureGroup;
     }
     
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idFeatureGroup" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpFeatureGroup == nil))
     {
     if(!(tmpFeatureGroup.idFeatureGroup == nil))
     {
     if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
     {
     return tmpFeatureGroup;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(FeatureGroup *) getFeatureGroupFromFeatureName:(NSString *) name
{
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    
    if([name isEqualToString:@"< $50"] || [name isEqualToString:@"$50-$200"]  || [name isEqualToString:@"$200$-$500"]  || [name isEqualToString:@"> $500"] )
    {
        keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:@"Price" sortingWithKey:@"idFeatureGroup" ascending:YES];
        if (!(keywordsFetchedResultsController == nil))
        {
            for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
            {
                FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
                
                if(!(tmpFeatureGroup == nil))
                {
                    if(!(tmpFeatureGroup.idFeatureGroup == nil))
                    {
                        if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
                        {
                            for (Feature *f in tmpFeatureGroup.features)
                            {
                                if ([f.name isEqualToString:name])
                                {
                                    [arrayFeaturesPrices addObject:f.idFeature];
                                    break;
                                }
                            }
                            //if ([self isFeatureGroup:tmpFeatureGroup inProductGroups:productGroupsParentForSuggestedKeywords])
                            return tmpFeatureGroup;
                        }
                    }
                }
            }
        }
    }
    
    
    FeatureGroup * fg = [[CoreDataQuery sharedCoreDataQuery] getFeatureGroupFromFeatureName:name];
    
    if (fg != nil)
    {
        if ([productGroupsParentForSuggestedKeywords count] > 0)
        {
            if ([self isFeatureGroup:fg inProductGroups:productGroupsParentForSuggestedKeywords])
                return fg;
        }
        else
        {
            return fg;
        }
    }
    return nil;
    
    /*
     //    NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Feature" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idFeature" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     Feature * tmpFeature = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpFeature == nil))
     {
     if(!(tmpFeature.idFeature == nil))
     {
     if(!([tmpFeature.idFeature isEqualToString:@""]))
     {
     if ([productGroupsParentForSuggestedKeywords count] > 0)
     {
     if ([self isFeatureGroup:[tmpFeature.featureGroup getTopParent] inProductGroups:productGroupsParentForSuggestedKeywords])
     return [tmpFeature.featureGroup getTopParent];
     }
     else
     {
     return [tmpFeature.featureGroup getTopParent];
     }
     //                        return tmpFeature.featureGroup;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(FeatureGroup *)getFeatureGroupFromId:(NSString *)idFeatureGroup
{
    return [[CoreDataQuery sharedCoreDataQuery] getFeatureGroupFromId:idFeatureGroup];
    /*
     
     if (dictFeatureGroupsById != nil)
     {
     return [dictFeatureGroupsById objectForKey:idFeatureGroup];
     }
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"idFeatureGroup = %@" withString:idFeatureGroup sortingWithKey:@"idFeatureGroup" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     FeatureGroup * tmpFeatureGroup = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpFeatureGroup == nil))
     {
     if(!(tmpFeatureGroup.idFeatureGroup == nil))
     {
     if(!([tmpFeatureGroup.idFeatureGroup isEqualToString:@""]))
     {
     return tmpFeatureGroup;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(NSString *) getChildrenFeatureGroupIdForPredicate:(NSMutableArray *) childrenFeatureGroupId
{
    NSString * sFilter = @"";
    
    int iIdx = 0;
    for (NSString * sIdFeatureGroup in childrenFeatureGroupId)
    {
        NSString *sFilterName;
        if (iIdx == 0)
        {
            sFilterName = [NSString stringWithFormat:@"(featureGroupId=='%@')", sIdFeatureGroup];
        }
        else{
            sFilterName = [NSString stringWithFormat:@" OR (featureGroupId=='%@')", sIdFeatureGroup];
        }
        sFilter = [sFilter stringByAppendingString:sFilterName];
        
        iIdx++;
    }
    
    return sFilter;
}


-(BOOL) isFeatureGroup:(FeatureGroup *)fg inProductGroups:(NSMutableArray *)productGroups
{
    for(ProductGroup *pg in productGroups)
    {
        if ([pg existsFeatureGroupByName:fg.name])
            return YES;
    }
    return NO;
}

-(FeatureGroup *) allSuggestedFromSameFeatureGroup
{
    FeatureGroup * featureGroupOfFeature = nil;
    for (NSString * sSuggestedkeyword in suggestedFilters)
    {
        //        ProductGroup * pg = [self getProductGroupFromName:sSuggestedkeyword];
        Feature * feat = [self getFeatureFromId:sSuggestedkeyword];
        if (feat == nil)
            return nil;
        
        if (featureGroupOfFeature == nil)
        {
            featureGroupOfFeature = feat.featureGroup;
            continue;
        }
        
        if ([featureGroupOfFeature.idFeatureGroup isEqualToString:feat.featureGroupId] == NO)
        {
            return nil;
        }
        
    }
    
    return featureGroupOfFeature;
}


#pragma mark - [Brand]

-(Brand *) getBrandFromName:(NSString *)name
{
    return [[CoreDataQuery sharedCoreDataQuery] getBrandFromName:name];
    /*
     if (dictBrandsByName != nil)
     {
     Brand * tmpBrand = [dictBrandsByName objectForKey:name];
     return tmpBrand;
     }
     
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpBrand == nil))
     {
     if(!(tmpBrand.idBrand == nil))
     {
     if(!([tmpBrand.idBrand isEqualToString:@""]))
     {
     return tmpBrand;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(Brand *) getBrandFromId:(NSString *)idBrand
{
    return [[CoreDataQuery sharedCoreDataQuery] getBrandFromId:idBrand];
    /*
     
     if (dictBrandsById != nil)
     {
     return [dictBrandsById objectForKey:idBrand];
     }
     
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     //NSString *regexString  = [NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
     
     //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"name matches[cd] %@" withString:name sortingWithKey:@"idBrand" ascending:YES];
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"idBrand = %@" withString:idBrand sortingWithKey:@"idBrand" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpBrand == nil))
     {
     if(!(tmpBrand.idBrand == nil))
     {
     if(!([tmpBrand.idBrand isEqualToString:@""]))
     {
     return tmpBrand;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(NSMutableArray *) getAllBrands
{
    return [[CoreDataQuery sharedCoreDataQuery] getAllBrands];
    /*
     NSMutableArray * arrAllbrands = [[NSMutableArray alloc] init];
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Brand" andPredicate:@"NOT (idBrand = %@)" withString:@"0" sortingWithKey:@"idBrand" ascending:YES];
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     Brand * tmpBrand = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpBrand == nil))
     {
     if(!(tmpBrand.idBrand == nil))
     {
     if(!([tmpBrand.idBrand isEqualToString:@""]))
     {
     [arrAllbrands addObject:tmpBrand];
     }
     }
     }
     }
     }
     return arrAllbrands;
     */
}

#pragma mark - [Keyword]

-(Keyword *) getKeywordFromId:(NSString *)idKeyword
{
    return [[CoreDataQuery sharedCoreDataQuery] getKeywordFromId:idKeyword];
    /*
     // Fetch keywords to force selecting one of them
     NSFetchedResultsController * keywordsFetchedResultsController = nil;
     
     NSString *regexString  = idKeyword; //[NSString stringWithFormat:@"%@.*", [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
     
     keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"Keyword" andPredicate:@"idKeyword = %@" withString:regexString sortingWithKey:@"idKeyword" ascending:YES];
     
     
     if (!(keywordsFetchedResultsController == nil))
     {
     for (int i = 0; i < [[keywordsFetchedResultsController fetchedObjects] count]; i++)
     {
     Keyword * tmpKeyword = [[keywordsFetchedResultsController fetchedObjects] objectAtIndex:i];
     
     if(!(tmpKeyword == nil))
     {
     if(!(tmpKeyword.idKeyword == nil))
     {
     if(!([tmpKeyword.idKeyword isEqualToString:@""]))
     {
     return tmpKeyword;
     }
     }
     }
     }
     }
     return nil;
     */
}

-(NSObject *) getKeywordElementForName:(NSString *) sNameKeyword
{
    return [[CoreDataQuery sharedCoreDataQuery] getKeywordElementForName:sNameKeyword];
    /*
     //get the appDelegate
     
     Brand* brand = [self getBrandFromName:sNameKeyword];
     if (brand != nil)
     {
     return brand;
     }
     
     ProductGroup* pg = [self getProductGroupFromName:sNameKeyword];
     if (pg != nil)
     {
     return pg;
     }
     
     FeatureGroup* fg = [self getFeatureGroupFromFeatureName:sNameKeyword];
     if (fg!= nil)
     {
     return fg;
     }
     
     return nil;
     */
}

@end
