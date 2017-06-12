
//
//  FilterSearchViewController.m
//  GoldenSpear
//
//  Created by Alberto Seco on 9/6/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FilterSearchViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "SearchBaseViewController.h"
#import "ProductGroup+Manage.h"
#import "FashionistaPostViewController.h"
#import "CoreDataQuery.h"
#import "TabSlideView.h"

#import "NSObject+ButtonSlideView.h"

#import "BDKCollectionIndexView.h"

#define kMarginBetweenBars 10.0f
#define kHeightTopFilter 40.0f
#define kHeightBars 40.0f

#define kGenderMandatory NO
#define kTopConstraintWithGender 50
#define kTopConstraintWithOutGender 0

#define kIndexBrands 1
#define kIndexStyles 0

@interface FilterSearchViewController ()

struct IdxSubProductCategory
{
    int iIdxProductCategory;
    int iIdxSubProductCategory;
};

@end

@implementation FilterSearchViewController
{
    // variables for advanced search
    float fPosY;
    int iTabSelected;
    int productDepth;
    SlideButtonView*  genderSlideView;
    SlideButtonView*  selectedProductSlideView;
    SlideButtonView*  styleAndFeaturesSlideView;
    
    
    // variable to store the selection of the user
    ProductGroup * selectedProductCategory;
    NSMutableArray * arSelectedSubProductCategory;
    NSMutableArray * arSelectedBrandsProductCategory;
    
    BOOL bSelectedSubProductCategoryAny;
    FeatureGroup * selectedFeatureGroup;
    BOOL animatingAdvancedSearch;  // set if the advanced search is animated
    BOOL selectedFemale;
    NSMutableArray * brandsSelectedProductCategory;
    NSMutableArray * childrenSelectedProductCategory;
    NSMutableArray * childrenSelectedSubProductCategory;
    
    NSMutableArray * featureGroupsSelectedProductCategory;
    
    NSMutableArray * featuresSelectedFeatureGroup;
    NSMutableArray * featuresIdSelectedFeatureGroup;
    NSMutableArray * arr;
    NSMutableArray * selectedProductTermsList;
    NSMutableArray * selectedProductTermsObjectList;
    NSMutableArray * topProductGroups;
    NSMutableArray * btnProductGroups;
    AppDelegate * appDelegate;
    
    int iGenderSelected;
    
    int iNumSubProductCatgeoriesShowing;
    
    BDKCollectionIndexView *scrollBrandAlphabetBDK;
    NSMutableDictionary * dictAlphabet;
}

- (void)viewDidLoad {
    //get the appDelegate
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    /// init the array of suproduct category selected
    arSelectedSubProductCategory = [[NSMutableArray alloc] init];
    arSelectedBrandsProductCategory = [[NSMutableArray alloc] init];
    selectedProductTermsList= [[NSMutableArray alloc] init];
    btnProductGroups = [[NSMutableArray alloc] init];
    // Init the Gesture Recognizer
    [self initGestureRecognizer];
    
    // Init the images operation queue (to load them in the background)
    [self initImagesQueue];
    
    [self initProductFeatureTermsCollectionView];
    
    animatingAdvancedSearch = NO;
    
    self.SuggestedFiltersRibbonView = nil;
    
    iGenderSelected = 0;
    appDelegate.productGroups = [[CoreDataQuery sharedCoreDataQuery] getAllProductGroup];
    topProductGroups = [[NSMutableArray alloc] initWithArray:appDelegate.productGroups.mutableCopy];
    [self resetProductCategories:appDelegate.productGroups];
    
    [self initZoomView];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    selectedProductTermsObjectList = [[NSMutableArray alloc]initWithArray: _selectedProducts];
    
    [self finishedLoadingInfo];
}

-(NSMutableArray*)getSelectedProductGroup {
    return selectedProductTermsObjectList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetProductCategories:(NSMutableArray *)productGroups
{
    for(ProductGroup * pg in productGroups)
    {
        pg.selected = NO;
//        [self resetProductCategories:[pg getChildrenReloading]];
        [self resetProductCategories:[pg getAllDescendants]];
    }
}

#pragma mark - Download
// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    switch (connection)
    {
        case GET_ALLPRODUCTCATEGORIES:
        {
            
            [self setupAllProductCategoriesWithMapping: mappingResult];
            
            [self loadBrandsPriority];
            
            break;
        }
        case GET_PRIORITYBRANDS:
        {
            [self setupBrandsWithMapping: mappingResult];
            
            [self finishedLoadingInfo];
            
            break;
        }
        case GET_ALLFEATURES:
        {
            [self setupAllFeaturesWithMapping: mappingResult];
            
            [self loadAllFeatureGroups];
            
            break;
        }
        case GET_ALLFEATUREGROUPS:
        {
            [self setupAllFeatureGroupsWithMapping: mappingResult];
            
            [self loadAllProductCategory];
            
            break;
        }
            
        default:
            break;
    }
}

// Rest answer not reached
- (void)processRestConnection:(connectionType)connection WithErrorMessage:(NSArray*)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    appDelegate.bLoadingFilterInfo = NO;
    
    [super processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
}

#pragma mark - Advanced Search - Load data from server new approach

-(void) startLoadingInfoFromServer
{
    appDelegate.bLoadingFilterInfo = YES;
    
    // if the searchview is not hidden then we must show the activity indicator
    [self showActivityFeedback];
    
    [self loadAllFeatures];
}

-(void) loadAllProductCategory
{
    
    // make two requests to the server,
    
    // Get all product catgeories: "http://192.168.1.99:1337/productcategory?parent=null&limit=-1&populate=featuresGroup,productCategories"
    // one to get all the product categories with all its producta category children and features groups
    // the second one to get all the features from the server, with the featuresgroups
    // http://192.168.1.99:1337/feature?limit=-1&populate=featureGroup
    
    NSLog(@"Loading all product categories info");
    
    // get all product categories
    [self performRestGet:GET_ALLPRODUCTCATEGORIES withParamaters:nil];
}

-(void) setupAllProductCategoriesWithMapping:(NSArray *)productCategoriesMapping
{
    // remove all features group with gender
}

-(void) loadAllFeatures
{
    NSLog(@"Loading features info");
    // get all product categories
    [self performRestGet:GET_ALLFEATURES withParamaters:nil];
}

-(void) setupAllFeaturesWithMapping:(NSArray *)featureGroupMapping
{
}

-(void) loadAllFeatureGroups
{
    NSLog(@"Loading feature groups info");
    // get all product categories
    [self performRestGet:GET_ALLFEATUREGROUPS withParamaters:nil];
}

-(void) setupAllFeatureGroupsWithMapping:(NSArray *)featureGroupMapping
{
}

-(void) loadBrandsPriority
{
    
    // make two requests to the server,
    
    // Get all brands "http://209.133.201.250:8080/brand?where={"priority":{"$gt":0}}&sort=priority desc&limit=-1"
    
    NSLog(@"Loading brands info");
    
    // get all product categories
    [self performRestGet:GET_PRIORITYBRANDS withParamaters:nil];
}

-(void) setupBrandsWithMapping:(NSArray *)featureGroupMapping
{
    
}

-(void) finishedLoadingInfo
{
    appDelegate.bLoadingFilterInfo = NO;
    appDelegate.bLoadedFilterInfo = YES;
    
    
    appDelegate.productGroups = [NSMutableArray arrayWithArray:[self fetchProductCategories]];
    
    [self filterProductCategoryByFeatureGroupAndGender: appDelegate.productGroups];
    
    [self showFilters];
    
    [self stopParentActivityFeedback];
    
}

-(void) checkDebugFeatureGroup
{
    // get coredata context
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // test query
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity to look for
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FeatureGroup" inManagedObjectContext:currentContext];
    
    [fetchRequest setEntity:entity];
    
    // Filter results
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentId = nil" ]];
    
    NSError *error;
    
    //self.productGroups
    NSArray * pFeaturesGroup = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Num featureGroup %ld ---------------------------", (unsigned long)pFeaturesGroup.count);
    for(int i = 0; i < pFeaturesGroup.count; i++)
    {
        // Buscamos a los hijos (addPcSubGroupsObject)
        FeatureGroup * fg = [pFeaturesGroup objectAtIndex:i];
        
        NSLog(@"FeatureGroup ---------------------------");
        NSLog(@"Name: %@", fg.name);
        NSLog(@"Num children: %ld", (unsigned long)fg.featureGroups.count);
        NSLog(@"Num features: %ld", (unsigned long)fg.features.count);
        NSLog(@"----------------------------------------");
    }
    
}

-(void) checkDebugProductGroup
{
    // get coredata context
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // test query
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity to look for
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductGroup" inManagedObjectContext:currentContext];
    
    [fetchRequest setEntity:entity];
    
    // Filter results
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentId = nil" ]];
    
    NSError *error;
    
    //self.productGroups
    NSArray * pProductGroup = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Num ProductGroup %ld ---------------------------", (unsigned long)pProductGroup.count);
    for(int i = 0; i < pProductGroup.count; i++)
    {
        // Buscamos a los hijos (addPcSubGroupsObject)
        ProductGroup * pg = [pProductGroup objectAtIndex:i];
        
        NSLog(@"ProductGroup ---------------------------");
        NSLog(@"Name: %@", pg.name);
        NSLog(@"Icon: %@", pg.icon);
        NSLog(@"IconPath: %@", pg.iconPath);
        NSLog(@"Num children: %ld", (unsigned long)pg.productGroups.count);
        NSLog(@"Num product group: %ld", (unsigned long)pg.featuresGroup.count);
        NSLog(@"----------------------------------------");
    }
    
}

-(NSArray *) fetchProductCategories
{
    // get coredata context
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // test query
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity to look for
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductGroup" inManagedObjectContext:currentContext];
    
    [fetchRequest setEntity:entity];
    
    // Filter results
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parentId = nil" ]];
    
    // sort by name
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error;
    
    //self.productGroups
    NSArray * pProductGroup = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    return pProductGroup;
}

-(void) checkDebugBrands
{
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // test query
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity to look for
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Brand" inManagedObjectContext:currentContext];
    
    [fetchRequest setEntity:entity];
    
    // sort by name
    NSSortDescriptor *sortDescriptorPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorPriority, sortDescriptorName, nil]];
    
    NSError *error;
    
    //self.productGroups
    NSArray * arBrands = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Num Brands %ld ---------------------------", (unsigned long)arBrands.count);
    for(int i = 0; i < arBrands.count; i++)
    {
        // Buscamos a los hijos (addPcSubGroupsObject)
        Brand * b = [arBrands objectAtIndex:i];
        
        NSLog(@"Brand ---------------------------");
        NSLog(@"Name: %@", b.name);
        NSLog(@"Num product group: %ld", (unsigned long)b.productGroups.count);
        NSLog(@"----------------------------------------");
    }
    
}

-(NSArray *) fetchBrands
{
    // get coredata context
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    // test query
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity to look for
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Brand" inManagedObjectContext:currentContext];
    
    [fetchRequest setEntity:entity];
    
    // sort by name
    NSSortDescriptor *sortDescriptorPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptorPriority, sortDescriptorName, nil]];
    
    NSError *error;
    
    //self.productGroups
    NSArray * arBrands = [currentContext executeFetchRequest:fetchRequest error:&error];
    
    return arBrands;
}

-(void) filterProductCategoryByFeatureGroupAndGender:(NSMutableArray *)productCategories
{
    NSMutableArray * copyProductCategories = [[NSMutableArray alloc] initWithArray:productCategories];
    [productCategories removeAllObjects];
    // looping all product categories filtering the product ctagoeries withour featuregroup
    for(ProductGroup * pg in copyProductCategories)
    {
        
        if ((pg.visible == nil) || ((pg.visible != nil) && ([pg.visible boolValue])))
        {
            int iNumFeatures = [pg getNumFeaturesGroup];
            if (iNumFeatures > 1)
            {
                if ([pg checkGender:iGenderSelected])
                {
                    [productCategories addObject:pg];
                }
            }
            else if (iNumFeatures == 1)
            {
                // only one featureGRoup, check if is gender
                if (![pg existsFeatureGroupByName:@"gender"])
                {
                    if ([pg checkGender:iGenderSelected])
                    {
                        [productCategories addObject:pg];
                    }
                }
                else
                {
                    NSLog(@"Product category con un solo feature group y es gender. %@", pg.name);
                }
                
            }
        }
    }
}

-(void) filterProductCategoryByGender:(NSMutableArray *)productCategories
{
    NSMutableArray * copyProductCategories = [[NSMutableArray alloc] initWithArray:productCategories];
    [productCategories removeAllObjects];
    // looping all product categories filtering the product ctagoeries without featuregroup
    for(ProductGroup * pg in copyProductCategories)
    {
        if ((pg.visible == nil) || ((pg.visible != nil) && ([pg.visible boolValue])))
        {
            if ([pg checkGender:iGenderSelected])
            {
                [productCategories addObject:pg];
            }
        }
    }
}


#pragma mark - Advanced Search - Gender & Product Category
-(void) showViewGenderAndProductCategory: (BOOL) bAnimated
{
    self.viewGenderAndProductCategory.hidden = NO;
    genderSlideView.hidden = NO;
    self.viewSubProductAndFeatures.hidden = YES;
    styleAndFeaturesSlideView.hidden = YES;
    
    
//    [self.secondCollectionView reloadData];
    [self reloadDataForCollectionView:self.secondCollectionView];
    
}

-(void) createGenderSlideView
{
    if (genderSlideView == nil)
    {
        // only create the slide if it was nil
        CGRect sliderFrame = CGRectMake(0.0, fPosY, self.view.frame.size.width, kHeightTopFilter);
        genderSlideView = [[SlideButtonView alloc] initWithFrame:sliderFrame];
        genderSlideView.minWidthButton = 50;
        genderSlideView.colorTextButtons =  [UIColor colorWithRed:(161/255.0) green:(161/255.0) blue:(161/255.0) alpha:1.0];
        genderSlideView.colorSelectedTextButtons = [UIColor blackColor];
        genderSlideView.bBoldSelected = YES;
        genderSlideView.colorBackgroundButtons = [UIColor clearColor];
        genderSlideView.fShadowRadius = 1.0;
        genderSlideView.colorShadowButtons = [UIColor clearColor];
        genderSlideView.leftMarginControl = 3;
        genderSlideView.spaceBetweenButtons = 0;
        genderSlideView.sNameButtonImage = @"";
        genderSlideView.sNameButtonImageHighlighted = @"";
        genderSlideView.alphaButtons = 0.9;
        genderSlideView.typeSelection = HIGHLIGHT_TYPE;
        genderSlideView.bMultiselect = YES;
        genderSlideView.bSeparator = YES;
        genderSlideView.colorSeparator = [UIColor colorWithRed:(161/255.0) green:(161/255.0) blue:(161/255.0) alpha:1.0];
        genderSlideView.fHeightSeparator = 20;
        genderSlideView.tag = 0;
        
        
        [self.view addSubview:genderSlideView];
        
        [self drawBorderGenderSlideview];
        
        NSMutableArray * arFeatures = [self getFeaturesOfFeatureGroupByName:@"gender"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [arFeatures sortedArrayUsingDescriptors:sortDescriptors];
        
        arr = [[NSMutableArray alloc] init];
        for(Feature *feat in sortedArray)
        {
            [arr addObject:feat.name];
        }
        [genderSlideView initSlideButtonWithButtons:arr andDelegate:self];

    }
}

-(NSMutableArray *) getFeaturesOfFeatureGroupByName: (NSString *)sNameFeatureGroup
{
    sNameFeatureGroup = [[sNameFeatureGroup lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableArray * arFeaturesOfFeatureGroup = [[NSMutableArray alloc] init];
    // Fetch keywords to force selecting one of them
    NSFetchedResultsController * keywordsFetchedResultsController = nil;
    //BOOL bFirst = YES;
    
    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"name matches[cd] %@" withString:sNameFeatureGroup sortingWithKey:@"idFeatureGroup" ascending:YES];
    //    keywordsFetchedResultsController = [self fetchedResultsControllerWithEntity:@"FeatureGroup" andPredicate:@"idFeatureGroup = %@" withString:sName sortingWithKey:@"idFeatureGroup" ascending:YES];
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
    
}
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
        
        keywordsFetchedResultsController.delegate = self;
    }
    
    if(keywordsFetchedResultsController)
    {
        // Perform fetch
        
        NSError *error = nil;
        
        if (![keywordsFetchedResultsController performFetch:&error])
        {
            // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
            
            NSLog(@"Couldn't fetch elements. Unresolved error: %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return keywordsFetchedResultsController;
}



-(void) drawBorderGenderSlideview
{
    UIColor* color = [UIColor colorWithRed:(161/255.0) green:(161/255.0) blue:(161/255.0) alpha:1.0];
    
    // draw bottom line
    CGPoint p1 = CGPointMake(0, 0);
    CGPoint p2 = CGPointMake(genderSlideView.frame.size.width, 0);
//    [TabSlideView drawLine:genderSlideView topleft:p1 bottomright:p2 withColor:color andLineWidth:0.5];
    
    p1 = CGPointMake(0, genderSlideView.frame.size.height);
    p2 = CGPointMake(genderSlideView.frame.size.width, genderSlideView.frame.size.height);
    [TabSlideView drawLine:genderSlideView topleft:p1 bottomright:p2 withColor:color andLineWidth:0.5];
    
}

-(BOOL) isGenderSelected
{
    if (kGenderMandatory)
        return (genderSlideView.arSelectedButtons.count > 0);
    else
        return YES;
}

// return the integer represented the gender
-(int) iGetGenderSelected
{
    int iGenderSelectedRes = 0;
    for(NSNumber *nsnIdxSelected in genderSlideView.arSelectedButtons)
    {
        NSString * sGender = [genderSlideView.arrayButtons objectAtIndex:[nsnIdxSelected intValue]];
        iGenderSelectedRes += [self getGenderFromName:sGender];
//        if (nsnIdxSelected.intValue == 4) // para kids
//        {
//            iGenderSelectedRes += 32;
//        }
//        else
//        {
//            iGenderSelectedRes += (nsnIdxSelected.intValue)+1;
//        }
    }
    
    return iGenderSelectedRes;
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

- (void)updateProductGroupForGender:(int)iNewGender {
    iGenderSelected = iNewGender;

    appDelegate.productGroups = [[CoreDataQuery sharedCoreDataQuery] getAllProductGroup];
    topProductGroups = [[NSMutableArray alloc] initWithArray:appDelegate.productGroups.mutableCopy];
    [self resetProductCategories:appDelegate.productGroups];
    [self finishedLoadingInfo];

  //  if (self.viewGenderAndProductCategory.hidden == NO)
//    {
//        [self reloadDataForCollectionView:self.secondCollectionView];
//                [self.secondCollectionView reloadData];
//    }
////    else if (self.viewSubProductAndFeatures.hidden == NO)
//    {
//        [self reloadDataForCollectionView:self.mainCollectionView];
//        //        [self.mainCollectionView reloadData];
//    }
}

-(void) updateForGender:(int) iNewGender
{
    // unselect the search terms that no correspond to the gender selected
    if (selectedProductCategory != nil)
    {
        // check if the selected product catgoery has the gender selected linked
        if (![selectedProductCategory checkGender:iNewGender])
        {
            [self unselectProductCategory:NO];
        }
    }
    
    // check that the searchTerms are valid for the gender selected
    // looping through all the subproduct categories selected, removing them
    NSMutableArray * copySelectedSubProductCategory = [[NSMutableArray alloc] initWithArray:arSelectedSubProductCategory]; // copy of the array because in the lopping the arSelectedSubProductCategory can be modified
    for(ProductGroup * subProductCategory in copySelectedSubProductCategory)
    {
        if (![subProductCategory checkGender:iNewGender])
        {
            [self unselectSubProductCategory:subProductCategory andAnimated:NO];
        }
    }
    
    iGenderSelected = iNewGender;
    // make fecth again
    appDelegate.productGroups = [NSMutableArray arrayWithArray:[self fetchProductCategories]];
    // filter the categories
 
    
    [self filterProductCategoryByFeatureGroupAndGender:appDelegate.productGroups];
    [self showStylesAndFeatureGroupRecursive:nil];
    
    //    for (NSMutableArray * children in childrenSelectedProductCategory)
    //    {
    //        if (children != nil)
    //        {
    //            [self filterProductCategoryByGender:children];
    //        }
    //    }
    //    if (childrenSelectedProductCategory != nil)
    //    {
    //        [self filterProductCategoryByGender:childrenSelectedProductCategory];
    //    }
    
    // reload data
    if (self.viewGenderAndProductCategory.hidden == NO)
    {
        [self reloadDataForCollectionView:self.secondCollectionView];
//        [self.secondCollectionView reloadData];
    }
    else if (self.viewSubProductAndFeatures.hidden == NO)
    {
        [self reloadDataForCollectionView:self.mainCollectionView];
//        [self.mainCollectionView reloadData];
    }
}


#pragma mark - Advanced Search - Styles & Features
-(void) showViewStyleAndFeature:(BOOL) bAnimated
{
    
    if (kGenderMandatory)
    {
        self.topConstraintCollectionView.constant = kTopConstraintWithOutGender;
        //  genderSlideView.hidden = YES;
    }
    else
    {
        if (selectedProductTermsObjectList.count > 0)
            self.topConstraintCollectionView.constant = kTopConstraintWithGender;
        else
            self.topConstraintCollectionView.constant = kTopConstraintWithOutGender;

    }
    
    self.viewGenderAndProductCategory.hidden = YES;
    self.viewSubProductAndFeatures.hidden = NO;
    styleAndFeaturesSlideView.hidden = YES;
}

-(void) createStyleAndFeatureSlideView
{
//    styleAndFeaturesSlideView = [self createTabSlideViewGroup:0 withLevelPosY:1];
    // add the tabslideview to the view
  //  [self.view addSubview:styleAndFeaturesSlideView];
  //  self.viewSubProductAndFeatures.frame = styleAndFeaturesSlideView.frame;
    styleAndFeaturesSlideView.hidden = YES;
    selectedProductSlideView = [self createTabSlideViewGroup:0 withLevelPosY:1];
    [self.view addSubview:selectedProductSlideView];
    self.viewSubProductAndFeatures.frame = selectedProductSlideView.frame;
    [self showSelectedProductSlideView];
}

- (void) showSelectedProductSlideView {
    if (selectedProductTermsObjectList.count > 0) {
        self.topConstraintCollectionView.constant = kTopConstraintWithGender;
        self.kTopGenderProductCollectionView.constant = kTopConstraintWithGender;
        selectedProductSlideView.hidden = NO;
        NSMutableArray *pgBtnArry = [[NSMutableArray alloc]init];
        NSMutableArray * arFeatures = [self getFeaturesOfFeatureGroupByName:@"gender"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [arFeatures sortedArrayUsingDescriptors:sortDescriptors];
        
        for(Feature *feat in sortedArray)
        {
            [arr addObject:feat.name];
        }
        if (iGenderSelected == 1 || iGenderSelected == 3) {
            Feature *feat = [sortedArray objectAtIndex:0];
            [pgBtnArry addObject:feat.name];
        }
        if (iGenderSelected == 2 || iGenderSelected == 3) {
            Feature *feat = [sortedArray objectAtIndex:1];
            [pgBtnArry addObject:feat.name];
        }
        
        for (ProductGroup *pg in selectedProductTermsObjectList) {
            [pgBtnArry addObject:pg.app_name];
        }
        
        [selectedProductSlideView initSlideButtonWithButtons:pgBtnArry andDelegate:self];

    } else {
        self.topConstraintCollectionView.constant = kTopConstraintWithOutGender;
        self.kTopGenderProductCollectionView.constant = kTopConstraintWithOutGender;
        selectedProductSlideView.hidden = YES;
    }
}
#pragma mark - Advanced Search - New approach

// show the filters loaded from the server
-(void)showFilters
{
    [self createGenderSlideView];
    [self createStyleAndFeatureSlideView];
    
    // show the first view

    [self showViewGenderAndProductCategory: NO];
    
    // update the GUI to the search terms in searchTerms array
    [self updateGUIToSearchTerms];
}

-(void) showStylesAndFeatureGroup
{
    if (selectedProductCategory != nil)
    {
        NSNumber * iIdxSelected = nil;
        if (styleAndFeaturesSlideView.arSelectedButtons.count > 0)
            iIdxSelected = styleAndFeaturesSlideView.arSelectedButtons[0];
        
        // array of the string with the names of the buttons
        NSMutableArray * arButtons = [[NSMutableArray alloc] init];
        // add any option
        
        [arButtons addObject:NSLocalizedString(@"_STYLE_", nil)];
        // looping through the selected categories adding a tab for it
        
        [arButtons addObject:NSLocalizedString(@"_BRANDS_", nil)];
        
        // load the product groups top in the top bar
        for (FeatureGroup *fg in featureGroupsSelectedProductCategory)
        {
            [arButtons addObject:fg.name];
        }
        
        SlideButtonView *subproductCategoryTabSlideView = styleAndFeaturesSlideView;
        
        // load the data for the new tabslideview
      //  [subproductCategoryTabSlideView initSlideButtonWithButtons:arButtons andDelegate:self];
        
        subproductCategoryTabSlideView.alpha = 1.0;
        subproductCategoryTabSlideView.hidden = YES;
        
        
    }
    
    
}

-(void) updateGUIToSearchTerms
{
    selectedProductCategory = nil;
    [arSelectedSubProductCategory removeAllObjects];
    [arSelectedBrandsProductCategory removeAllObjects];
    featuresSelectedFeatureGroup = nil;
    featuresIdSelectedFeatureGroup = nil;
    // unselect previous elements
    [genderSlideView unselectButtons];
    
    // search the succesfull terms in product groups and subgroups
    NSArray * arraSearchTerms = [NSArray arrayWithArray:_searchTerms];
    
    for(NSString * sTerm in arraSearchTerms)
    {
        int iIdxRes;
        iIdxRes = ([self getIdxInTopFilter:sTerm]);
        if (iIdxRes != -1)
        {
            [genderSlideView forceSelectButton:iIdxRes];
            iGenderSelected = [self iGetGenderSelected];
            [self updateForGender: iGenderSelected];
            continue;
        }
        
        //        NSMutableArray * arIdx = ([self getIdxInSubProductGroupsString:sTerm inProductGroups:appDelegate.productGroups]);
        //        if (arIdx != nil)
        //        {
        //            ProductGroup * pcWhereToSelect = nil;
        //            for (int iIdx = 0; iIdx < arIdx.count; iIdx++)
        //            {
        //                int iIdxSubProductCategorySelected = [arIdx[iIdx] intValue];
        //                [self selectProductCategoryByIndex:iIdxSubProductCategorySelected forLevel:iIdx addingToSearchTerms:NO animated:NO];
        //            }
        //            continue;
        //        }
        
        NSMutableArray * arIdxProductCategory = [self getIdxInSubProductGroupsString:sTerm inProductGroups:appDelegate.productGroups];
        if (arIdxProductCategory != nil)
        {
            [self selectSubProductCategoryByArrayIndex:arIdxProductCategory addingToSearchTerms:NO animated:NO];
            continue;
        }
        //        struct IdxSubProductCategory iIdxSubProduct;
        //        iIdxSubProduct = ([self getIdxInSubproductGroupsString:sTerm]);
        //        if (iIdxSubProduct.iIdxProductCategory != -1)
        //        {
        //            [self selectProductCategoryByIndex:iIdxSubProduct.iIdxProductCategory addingToSearchTerms:NO animated:NO];
        //            [self selectSubProductCategoryByIndex:iIdxSubProduct.iIdxSubProductCategory addingToSearchTerms:NO animated:NO];
        //            continue;
        //        }
        //
        //        iIdxRes = ([self getIdxInProductGroupsString:sTerm]);
        //        if (iIdxRes != -1)
        //        {
        //            [self selectProductCategoryByIndex:iIdxRes addingToSearchTerms:NO animated:NO];
        //            continue;
        //        }
    }
    
    // check for the brand, we must to do after the first looping to be sure that there is a productcategory selected
    if (selectedProductCategory != nil)
    {
        for(NSString * sTerm in _searchTerms)
        {
            int iIdxRes;
            
            iIdxRes = ([self getIdxInBrandString:sTerm inProductGroup:selectedProductCategory]);
            if (iIdxRes != -1)
            {
                [self selectBrandProductCategoryByIndex:iIdxRes addingToSearchTerms:NO animated:NO];
                continue;
            }
        }
    }
    
    // check for the feature group selected
    //    if (selectedFeatureGroup != nil)
    //    {
    //        if (featureGroupsSelectedProductCategory != nil)
    //        {
    //            NSUInteger iIdxFeature = [featureGroupsSelectedProductCategory indexOfObject:selectedFeatureGroup];
    //            if (iIdxFeature != NSNotFound)
    //            {
    //                [styleAndFeaturesSlideView forceSelectButton:(int)iIdxFeature+1];
    //                [self selectProductGroupOfLevel:1 addingToSearchTerms:NO animated:NO];
    //            }
    //            else{
    //                NSLog(@"FeatureGroup %@ not found", selectedFeatureGroup.name);
    //            }
    //        }
    //    }
    
    
    [self reloadDataForCollectionView:self.mainCollectionView];
//    [self.mainCollectionView reloadData];
    
}

-(void) updateGUIToSearchTermsRemovingTerm:(NSString *) sTermRemoved animated:(BOOL) bAnimated
{
    BOOL bContinue = YES;
    int iIdxRes;
    iIdxRes = ([self getIdxInTopFilter:sTermRemoved]);
    
    int iGenderToChange = iGenderSelected;
    
    if (iIdxRes != -1)
    {
        // unselect the button
        [genderSlideView unselectButton:iIdxRes];
        bContinue = FALSE;
        // we must update the gender
        iGenderToChange = [self iGetGenderSelected];
        [self updateForGender:iGenderToChange];
    }
    
    if (bContinue)
    {
        if (selectedProductCategory != nil)
        {
            iIdxRes = [self getIdxInBrandString:sTermRemoved inProductGroup:selectedProductCategory];
            if (iIdxRes != -1)
            {
                [self unselectBrandProductCategory:iIdxRes andAnimated:bAnimated];
            }
        }
    }
    // TODO: change for the array of idx
    if (bContinue)
    {
        NSMutableArray * arIdxProductCategory = [self getIdxInSubProductGroupsString:sTermRemoved inProductGroups:selectedProductCategory.getChildren];
        if (arIdxProductCategory != nil)
        {
            [self unselectSubproductCategoryByArrayIndex:arIdxProductCategory animated:NO];
            bContinue = FALSE;
        }
    }
    
    //    if (bContinue)
    //    {
    //        struct IdxSubProductCategory iIdxSubProduct;
    //        iIdxSubProduct = ([self getIdxInSubproductGroupsString:sTermRemoved]);
    //
    //        if (iIdxSubProduct.iIdxProductCategory != -1)
    //        {
    //            [self unselectSubProductCategoryByIndex:iIdxSubProduct andAnimated:bAnimated];
    //            bContinue = FALSE;x
    //        }
    //    }
    //
    if (bContinue)
    {
        iIdxRes = ([self getIdxInProductGroupsString:sTermRemoved]);
        if (iIdxRes != -1)
        {
            [self unselectProductCategory: bAnimated];
            bContinue = FALSE;
        }
    }
    
    [self reloadDataForCollectionView:self.mainCollectionView];
//    [self.mainCollectionView reloadData];
    
    iGenderSelected = iGenderToChange;
    
}

-(void) selectProductGroupOfLevel:(long) iLevel addingToSearchTerms:(BOOL) bAddToSearchTerm animated:(BOOL) bAnimated
{
    
    // load the data for the new tabslideview
    if ([self getDataOfLevel:iLevel addingToSearchTerms:bAddToSearchTerm andAnimated:bAnimated])
    {
        // only if teh data is already downloaded we show the data in this point, if not, we show the data when de downloaded is complete
        [self showDataOfLevel:iLevel animated:bAnimated];
    }
}

-(void) selectProductCategoryByIndex:(int) iIdxProductCategoryToSelect addingToSearchTerms:(BOOL) bAddToSearchTerm animated:(BOOL) bAnimated
{
    selectedProductCategory = [appDelegate.productGroups objectAtIndex:iIdxProductCategoryToSelect];
    
    [self selectProductGroupOfLevel:0 addingToSearchTerms:bAddToSearchTerm animated:bAnimated];
}

-(void) selectSubProductCategoryByIndex:(int) iIdxProductCategoryToSelect addingToSearchTerms:(BOOL) bAddToSearchTerm animated:(BOOL) bAnimated
{
    [styleAndFeaturesSlideView forceSelectButton:kIndexStyles];
    
    [self selectProductGroupOfLevel:1 addingToSearchTerms:bAddToSearchTerm animated:bAnimated];
    
    if (![arSelectedSubProductCategory containsObject:childrenSelectedProductCategory[iIdxProductCategoryToSelect]])
    {
        // add the sub product category to the array of selected subproducts category
        [arSelectedSubProductCategory addObject:childrenSelectedProductCategory[iIdxProductCategoryToSelect]];
        
        // add the featuregroups of the child selected
        [self loadFeatureGroupsFromSelectedElements:nil];
    }
    
}

-(void) selectBrandProductCategoryByIndex:(int) iIdxBrandProductCategoryToSelect addingToSearchTerms:(BOOL) bAddToSearchTerm animated:(BOOL) bAnimated
{
    //    [styleAndFeaturesSlideView forceSelectButton:kIndexBrands];
    
    //    [self selectProductGroupOfLevel:1 addingToSearchTerms:bAddToSearchTerm animated:bAnimated];
    
    if (![arSelectedBrandsProductCategory containsObject:brandsSelectedProductCategory[iIdxBrandProductCategoryToSelect]])
    {
        // add the sub product category to the array of selected subproducts category
        [arSelectedBrandsProductCategory addObject:brandsSelectedProductCategory[iIdxBrandProductCategoryToSelect]];
    }
    
}

-(void) unselectProductCategory:(BOOL) bAnimated
{
    [styleAndFeaturesSlideView unselectButtons];
    
    // looping through all the subproduct categories selected, removing them
    for(ProductGroup * subProductCategory in arSelectedSubProductCategory)
    {
        subProductCategory.selected = NO;
        [self removeSearchTerm:[subProductCategory getNameForApp] andUpdateGUI:NO animated:bAnimated];
    }
    // remove brands selection
    for(Brand * brand in arSelectedBrandsProductCategory)
    {
        [self removeSearchTerm:brand.name andUpdateGUI:NO animated:bAnimated];
    }
    
    // after the subproduct categories we have to remove the parent
    [self removeSearchTerm:[selectedProductCategory getNameForApp] andUpdateGUI:NO animated:bAnimated];
    
    selectedProductCategory = nil;
    [arSelectedSubProductCategory removeAllObjects];
    [arSelectedBrandsProductCategory removeAllObjects];
    
    selectedFeatureGroup = nil;
    if (featureGroupsSelectedProductCategory != nil)
        [featureGroupsSelectedProductCategory removeAllObjects];
    featureGroupsSelectedProductCategory = nil;
    if (featuresSelectedFeatureGroup != nil)
        [featuresSelectedFeatureGroup removeAllObjects];
    featuresSelectedFeatureGroup = nil;
    if (featuresIdSelectedFeatureGroup != nil)
        [featuresIdSelectedFeatureGroup removeAllObjects];
    featuresIdSelectedFeatureGroup = nil;
    if (childrenSelectedProductCategory != nil)
    {
//        for(ProductGroup * pg in childrenSelectedProductCategory)
//        {
//            pg.selected = NO;
//        }
        [childrenSelectedProductCategory removeAllObjects];
    }
    childrenSelectedProductCategory = nil;
    if (brandsSelectedProductCategory != nil)
        [brandsSelectedProductCategory removeAllObjects];
    brandsSelectedProductCategory = nil;
    // show the first view for selecting category and gender
    [self showViewGenderAndProductCategory:YES];
    
    
    [self reloadDataForCollectionView:self.mainCollectionView];
//    [self.mainCollectionView reloadData];
    
}

-(void) unselectSubProductCategoryByIndex: (struct IdxSubProductCategory)iIdx andAnimated:(BOOL) bAnimated
{
    ProductGroup * subProductCategory = childrenSelectedProductCategory[iIdx.iIdxSubProductCategory];
    
    // remove the subproduct category selected
    [self removeSearchTerm:[subProductCategory getNameForApp] andUpdateGUI:YES animated:bAnimated];
    [arSelectedSubProductCategory removeObject:subProductCategory];
    
    // if we removed all teh subproduct categories then, we must add the product category parent
    if (arSelectedSubProductCategory.count == 0)
    {
        //        [self addSearchTerm:[selectedProductCategory getNameForApp]];
        //        SlideButtonObject * objButton = [SlideButtonObject initFromProductCategory:selectedProductCategory];
        [self addSearchTermObject:selectedProductCategory];
    }
    
    // reload the featuregroups of the product category and sub product category selected
    [self loadFeatureGroupsFromSelectedElements:nil];
}

-(void) unselectSubProductCategory: (ProductGroup *) subProductCategory andAnimated:(BOOL) bAnimated //andAddingParent:(BOOL) bAddingParent
{
    
    // remove the subproduct category selected
    [self removeSearchTerm:[subProductCategory getNameForApp] andUpdateGUI:YES animated:bAnimated];
    [arSelectedSubProductCategory removeObject:subProductCategory];
    
    //    // if we removed all teh subproduct categories then, we must add the product category parent
    //    if (arSelectedSubProductCategory.count == 0)
    //    {
    //        if (bAddingParent)
    //            [self addSearchTerm:[selectedProductCategory getNameForApp]];
    ////        SlideButtonObject * objButton = [SlideButtonObject initFromProductCategory:selectedProductCategory];
    ////        [self addSearchTermObject:objButton];
    //    }
    
    // reload the featuregroups of the product category and sub product category selected
    [self loadFeatureGroupsFromSelectedElements:nil];
    
}

-(void) unselectBrandProductCategory: (int)iIdx andAnimated:(BOOL) bAnimated
{
    Brand * brand = brandsSelectedProductCategory[iIdx];
    
    // remove the subproduct category selected
    [self removeSearchTerm:brand.name andUpdateGUI:YES animated:bAnimated];
    [arSelectedBrandsProductCategory removeObject:brand];
}

-(int) getIdxInTopFilter:(NSString *) sTerm
{
    int iIdxRes = 0;
    NSString * sTermTrimmed = [[sTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    // search in top filter
    for (NSString * sTopTerm in genderSlideView.arrayButtons)
    {
        NSString * sTopTermTrimmed = [[sTopTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        if ([sTermTrimmed isEqualToString:sTopTermTrimmed])
        {
            return iIdxRes;
        }
        iIdxRes++;
    }
    return -1;
}

// return YES if the word is found in group
-(int) getIdxInProductGroupsString:(NSString *)sTerm
{
    NSString * sTermTrimmed = [[sTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    // search in product groups
    int iIdxProd  =0;
    for(ProductGroup * pg in appDelegate.productGroups)
    {
        NSString *pcNameTrimmed = [[[pg getNameForApp].lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        //        NSString *pcNameTrimmed = [[pg.name.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        if ([pcNameTrimmed isEqualToString:sTermTrimmed.lowercaseString])
        {
            return iIdxProd;
        }
        iIdxProd ++;
    }
    return -1;
}

// return YES if the word is found in group
-(struct IdxSubProductCategory) getIdxInSubproductGroupsString:(NSString *)sTerm
{
    struct IdxSubProductCategory iIdxRes;
    iIdxRes.iIdxProductCategory = -1;
    iIdxRes.iIdxSubProductCategory = -1;
    
    NSString * sTermTrimmed = [[sTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    // looping in product groups
    int iIdxProd  =0;
    for(ProductGroup * productGroup in appDelegate.productGroups)
    {
        int iIdxSubPro = 0;
        // search in subproducts
        NSArray * subProducts = [[productGroup.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES]]];
        for(ProductGroup * subProductGroup in subProducts)
        {
            NSString *pcNameTrimmed = [[[subProductGroup getNameForApp] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
            //            NSString *pcNameTrimmed = [[subProductGroup.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
            if ([pcNameTrimmed isEqualToString:sTermTrimmed])
            {
                iIdxRes.iIdxProductCategory = iIdxProd;
                iIdxRes.iIdxSubProductCategory = iIdxSubPro;
                return iIdxRes;
            }
            iIdxSubPro ++;
        }
        iIdxProd ++;
    }
    return iIdxRes;
}

// return YES if the word is found in brands
-(int) getIdxInBrandString:(NSString *)sTerm inProductGroup:(ProductGroup *)productGroup
{
    //    struct IdxSubProductCategory iIdxRes;
    //    iIdxRes.iIdxProductCategory = -1;
    //    iIdxRes.iIdxSubProductCategory = -1;
    
    NSString * sTermTrimmed = [[sTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    //    // looping in product groups
    //    int iIdxProd  =0;
    //    for(ProductGroup * productGroup in appDelegate.productGroups)
    //    {
    int iIdxBrand = 0;
    // search in subproducts
    NSSortDescriptor *sortDescriptorPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray * brands = [[productGroup.brands allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorPriority, sortDescriptorName, nil]];
    for(Brand * brand in brands)
    {
        NSString *pcNameTrimmed = [[brand.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        if ([pcNameTrimmed isEqualToString:sTermTrimmed])
        {
            return iIdxBrand;
            //                iIdxRes.iIdxProductCategory = iIdxProd;
            //                iIdxRes.iIdxSubProductCategory = iIdxBrand;
            //                return iIdxRes;
        }
        iIdxBrand ++;
    }
    //        iIdxProd ++;
    //    }
    return -1;
}

-(void) addSearchTermOfProductGroup:(ProductGroup *)productCategory addingToSearchTerms:(BOOL) bAddingToSearchTerms
{
    [self addSearchTermOfProductGroup:productCategory addingToSearchTerms:bAddingToSearchTerms forcingSelectTab:NO];
}

-(void) addSearchTermOfProductGroup:(ProductGroup *)productCategory addingToSearchTerms:(BOOL) bAddingToSearchTerms forcingSelectTab:(BOOL) bForceSelecting
{
    // check if the product group is in the array of selected product category
    if (![arSelectedSubProductCategory containsObject:productCategory])
    {
        // add the product category to the array of selected
        [arSelectedSubProductCategory addObject:productCategory];
    }
    // first we must remove the product category name of the search terms list view
    [self removeSearchTerm:[selectedProductCategory getNameForApp] andUpdateGUI:NO animated:NO];
    // trim the name of the product category
    NSString * sNameTrimmed = [[productCategory getNameForApp] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // adding the search term to the list
    if (bAddingToSearchTerms)
    {
        [self addSearchTerm:sNameTrimmed andAnimated:NO];
        //    SlideButtonObject * objbutton = [SlideButtonObject initFromProductCategory:productCategory];
        //    [self addSearchTermObject:objbutton andAnimated:NO];
    }
    
    //load featuregroup of the style selected, adding them to the featuregroup array
    if (bForceSelecting)
        [self loadFeatureGroupsFromSelectedElements:productCategory];
    else
        [self loadFeatureGroupsFromSelectedElements:nil];
    
    //
}

-(void) addSearchTermOfBrand:(Brand *)brand
{
    // check if the product group is in the array of selected product category
    if (![arSelectedBrandsProductCategory containsObject:brand])
    {
        // add the product category to the array of selected
        [arSelectedBrandsProductCategory addObject:brand];
    }
    // trim the name of the product category
    NSString * sNameTrimmed = [brand.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // adding the search term to the list
    [self addSearchTerm:sNameTrimmed andAnimated:NO];
}

-(void) addSearchTerm: (NSString * ) sNewTerm
{
    [self addSearchTerm:sNewTerm andAnimated:YES];
}

-(void) addSearchTermObject: (NSObject * ) sNewTerm
{
    [self addSearchTermObject:sNewTerm andAnimated:YES];
}

-(void) addSearchTerm: (NSString * ) sNewTerm andAnimated:(BOOL) bAnimated
{
    NSString * sNewTermTrimmed = [sNewTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if([self parentViewController])
    {
        if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
        {
            [((SearchBaseViewController *)[self parentViewController]) addSearchTermWithName:sNewTermTrimmed animated:bAnimated];
        }
        else if ([[self parentViewController] isKindOfClass:[FashionistaPostViewController class]])
        {
            [((FashionistaPostViewController *)[self parentViewController]) addSearchTermWithName:sNewTermTrimmed animated:bAnimated];
        }
    }
}

-(void) addSearchTermObject: (NSObject * ) sNewTerm andAnimated:(BOOL) bAnimated
{
    if([self parentViewController])
    {
        if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
        {
            [((SearchBaseViewController *)[self parentViewController]) addSearchTermWithObject:sNewTerm animated:bAnimated];
        }
    }
}

-(void) removeSearchTermOfProductGroup:(ProductGroup *)productCategory
{
    // first we must remove the product category name of the search terms list view
    [self removeSearchTerm:[productCategory getNameForApp] andUpdateGUI:NO animated:YES];
    [arSelectedSubProductCategory removeObject:productCategory];
    if (arSelectedSubProductCategory.count == 0)
    {
        // adding the search term to the list
        [self addSearchTerm:[selectedProductCategory getNameForApp] andAnimated:NO];
        //        NSOBject * objButton = [SlideButtonObject initFromProductCategory:selectedProductCategory];
        //        [self addSearchTermObject:objButton andAnimated:NO];
    }
    
    //load featuregroup of the style selected, adding them to the featuregroup array
    [self loadFeatureGroupsFromSelectedElements:nil];
}

-(void) removeSearchTermOfBrand:(Brand *)brand
{
    // first we must remove the product category name of the search terms list view
    [self removeSearchTerm:brand.name andUpdateGUI:NO animated:YES];
    [arSelectedBrandsProductCategory removeObject:brand];
}

-(void) removeSearchTerm:(NSString *) sTermToRemove
{
    [self removeSearchTerm:sTermToRemove andUpdateGUI:(self.view.hidden == NO) animated:YES];
}

-(void) removeSearchTermObject:(NSObject *) objTermToRemove
{
    [self removeSearchTerm:[objTermToRemove toStringButtonSlideView] andUpdateGUI:(self.view.hidden == NO) animated:YES];
}

-(void) removeSearchTerm:(NSString *) sTermToRemove andUpdateGUI:(BOOL) bUpdateGUI animated:(BOOL) bAnimated
{
    // search for the NSString
    NSString * sTrimmedTermToRemove = [[sTermToRemove stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    int iIdx = 0;
    BOOL bFound = NO;
    for(NSString * sTerm in _searchTerms)
    {
        NSString * sTrimmedTerm = [[sTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        if ([sTrimmedTerm isEqualToString:sTrimmedTermToRemove])
        {
            bFound = YES;
            break;
        }
        
        iIdx ++;
    }
    
    if (bFound)
    {
        if([self parentViewController])
        {
            if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
            {
                [((SearchBaseViewController *)[self parentViewController]) removeSearchTermAtIndex:iIdx checkSuggestions:YES];
            }
            else if ([[self parentViewController] isKindOfClass:[FashionistaPostViewController class]])
            {
                [((FashionistaPostViewController *)[self parentViewController]) removeSearchTermAtIndex:iIdx];
            }
            
        }
        
        if (bUpdateGUI)
        {
            [self updateGUIToSearchTermsRemovingTerm:sTrimmedTermToRemove animated:bAnimated];
        }
    }
    
}

-(void) removeSearchTermObject:(NSObject *) objTermToRemove andUpdateGUI:(BOOL) bUpdateGUI animated:(BOOL) bAnimated
{
    // search for the NSString
    NSString * sTrimmedTermToRemove = [[[objTermToRemove toStringButtonSlideView] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    int iIdx = 0;
    BOOL bFound = NO;
    for(NSString * sTerm in _searchTerms)
    {
        NSString * sTrimmedTerm = [[sTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        if ([sTrimmedTerm isEqualToString:sTrimmedTermToRemove])
        {
            bFound = YES;
            break;
        }
        
        iIdx ++;
    }
    
    if (bFound)
    {
        if([self parentViewController])
        {
            if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
            {
                [((SearchBaseViewController *)[self parentViewController]) removeSearchTermAtIndex:iIdx checkSuggestions:YES];
            }
            else if ([[self parentViewController] isKindOfClass:[FashionistaPostViewController class]])
            {
                [((FashionistaPostViewController *)[self parentViewController]) removeSearchTermAtIndex:iIdx];
            }
        }
        
        if (bUpdateGUI)
        {
            [self updateGUIToSearchTermsRemovingTerm:sTrimmedTermToRemove animated:bAnimated];
        }
    }
    
}
-(BOOL) getDataOfLevel:(long) iLevel addingToSearchTerms:(BOOL) bAddToSearchTerm andAnimated:(BOOL) bAnimated
{
    BOOL bLoaded = YES;
    SlideButtonView * _tabSlideView;
    if (iLevel == 0) // clic en product group
    {
        if (appDelegate.productGroups.count > 0)
        {
            // get the featuregroups from the productCategory
            featureGroupsSelectedProductCategory = nil;
            featureGroupsSelectedProductCategory = [selectedProductCategory getFeturesGroupExcept:@"gender"];
            
            // add the terms to the list
            if (bAddToSearchTerm)
            {
                [self addSearchTerm:[selectedProductCategory getNameForApp] andAnimated:bAnimated];
                //                SlideButtonObject * objButton = [SlideButtonObject initFromProductCategory:selectedProductCategory];
                //                [self addSearchTermObject:objButton andAnimated:bAnimated];
            }
            
        }
    }
    else if (iLevel == 1) // click in subproduct group or in feature group
    {
        _tabSlideView = styleAndFeaturesSlideView;
        if ([_tabSlideView.arSelectedButtons count] > 0)
        {
            NSNumber* nsnIdxButtonSelect = [_tabSlideView.arSelectedButtons objectAtIndex:0];
            
            long iIdx = [nsnIdxButtonSelect longValue];
            
            if(iIdx > 1){
                // select a featuregroup
                // we must show the features of the featuregroup
                selectedFeatureGroup = [featureGroupsSelectedProductCategory objectAtIndex:iIdx-2];
                if (featuresSelectedFeatureGroup != nil)
                    [featuresSelectedFeatureGroup removeAllObjects];
                else
                    featuresSelectedFeatureGroup = [[NSMutableArray alloc]init];
                // initi featuresId array
                if (featuresIdSelectedFeatureGroup != nil)
                    [featuresIdSelectedFeatureGroup removeAllObjects];
                else
                    featuresIdSelectedFeatureGroup = [[NSMutableArray alloc]init];
                
                [self getAllFeaturesFromFeatureGroup:selectedFeatureGroup];
                
            }
            else if (iIdx== kIndexStyles) // select style
            {
                // selected Style. Must show the style of the product category
                childrenSelectedProductCategory = nil;
                childrenSelectedProductCategory = [NSMutableArray arrayWithArray:[[selectedProductCategory.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES]]]];
                [self filterProductCategoryByGender:childrenSelectedProductCategory];
                
                // we have selected styles, hat is not a feature group so featuregroup must be unselected
                featuresSelectedFeatureGroup = nil;
                featuresIdSelectedFeatureGroup = nil;
                selectedFeatureGroup = nil;
            }
            else if (iIdx == kIndexBrands) // select brand
            {
                // selected Style. Must show the style of the product category
                brandsSelectedProductCategory = nil;
                // sort by name
//                NSSortDescriptor *sortDescriptorPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
                NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                
                brandsSelectedProductCategory = [NSMutableArray arrayWithArray:[[selectedProductCategory.brands allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorName, nil]]];
                
                // we have selected styles, hat is not a feature group so featuregroup must be unselected
                featuresSelectedFeatureGroup = nil;
                featuresIdSelectedFeatureGroup = nil;
                selectedFeatureGroup = nil;
                childrenSelectedProductCategory = nil;
            }
            
        }
    }
    return bLoaded;
}

-(void) loadFeatureGroupsFromSelectedElements:(ProductGroup *) productGroupToSelect
{
    NSLog(@"loadFeatureGroupsFromSelectedElements");
    if (featureGroupsSelectedProductCategory != nil)
        [featureGroupsSelectedProductCategory removeAllObjects];
    else
        featureGroupsSelectedProductCategory = [[NSMutableArray alloc] init];
    
    // get featureGroups of the productCategory Selected
    if (selectedProductCategory != nil)
    {
        featureGroupsSelectedProductCategory = [selectedProductCategory getFeturesGroupExcept:@"gender"];
    }
    
    // loopping through the subproductCategory selected
    for (ProductGroup * pcSelected in arSelectedSubProductCategory)
    {
        NSMutableArray * featureGroupChild = [pcSelected getFeturesGroupExcept:@"gender"];
        
        for (FeatureGroup *fgToAdd in featureGroupChild)
        {
            if (![self existsFeatureGroupWithName:fgToAdd.name inArray:featureGroupsSelectedProductCategory])
            {
                [featureGroupsSelectedProductCategory addObject:fgToAdd];
            }
        }
    }
    
    // reload the GUI for showing the featuregroups
    [self showStylesAndFeatureGroupRecursive:productGroupToSelect];
    
    [self reloadDataForCollectionView:self.mainCollectionView];
//    [self.mainCollectionView reloadData];
}

-(BOOL) existsFeatureGroupWithName:(NSString *)sFGNameToCheck inArray:(NSMutableArray *)arfeatureGroups
{
    BOOL bRes = NO;
    
    NSString * sFGNameToCheckTrimmed = [[sFGNameToCheck stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    
    for(FeatureGroup *fg in arfeatureGroups)
    {
        NSString * sFGName = [[fg.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        
        if ([sFGName isEqualToString:sFGNameToCheckTrimmed])
        {
            bRes = YES;
            break;
        }
    }
    
    return bRes;
}

-(void) getAllFeaturesFromFeatureGroup:(FeatureGroup *) featureGroup
{
    // traverse with all the children of selectedFeatureGroupstat
    NSArray * featureOfFeatureGroup = [[featureGroup.features allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    [featuresSelectedFeatureGroup addObjectsFromArray:featureOfFeatureGroup];
    
    for(FeatureGroup * fgChild in featureGroup.featureGroups)
    {
        [self getAllFeaturesFromFeatureGroup:fgChild];
    }
    
    
    featuresSelectedFeatureGroup = [NSMutableArray arrayWithArray:[featuresSelectedFeatureGroup sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]]];
    
//    [featuresSelectedFeatureGroup addObjectsFromArray:featureOfFeatureGroup];
    
    
}

-(void)showDataOfLevel:(long) iLevel animated:(BOOL) bAnimated
{
    if (iLevel == 0)
    {
        [self showStylesAndFeatureGroup];
        
        // force to select the style tab
        [styleAndFeaturesSlideView forceSelectButton:0];
        [self selectProductGroupOfLevel:1 addingToSearchTerms:YES animated:YES];
        [self showViewStyleAndFeature:NO];
        
    }
    else if (iLevel == 1) // level feature group
    {
        if (featuresSelectedFeatureGroup != nil)
            [self showFeatures:0];
        else if (childrenSelectedProductCategory != nil)
            [self showSubProductCategoryCollectionView:0];
        else if (brandsSelectedProductCategory != nil)
            [self showBrandsProductCategoryCollectionView:0];
    }
    
}

-(void) showFeatures:(long) iLevel
{
    // the Filters are stored in selectedFeaturesArray
    CGRect frame = self.mainCollectionView.frame;
    CGFloat parentHeight = self.mainCollectionView.superview.frame.size.height;
    float newPosY = fPosY +((kHeightBars+kMarginBetweenBars)*iLevel);
    //    float newPosY = fPosY +((kHeightBars*iLevel)+(kMarginBetweenBars*(iLevel-1)));
    frame.origin.y = newPosY;
    
    frame.size.height = parentHeight - newPosY;
    //    NSLog(@"Rect features y:%f height:%f parentHeight:%f ", frame.origin.y , frame.size.height, parentHeight);
    self.mainCollectionView.frame = frame;
    
    self.mainCollectionView.hidden = YES;
    if (featuresSelectedFeatureGroup != nil)
    {
        self.mainCollectionView.hidden =([featuresSelectedFeatureGroup count] == 0);
        // create the alphabet
        [self initAlphabetFeatures:featuresSelectedFeatureGroup];
    }
    self.lblNoFilters.hidden = !self.mainCollectionView.hidden;
    
    
    // create the collection view
    [self reloadDataForCollectionView:self.mainCollectionView];
//    [self.mainCollectionView layoutIfNeeded];
//    [self.mainCollectionView reloadData];
    
}

-(void) showSubProductCategoryCollectionView:(long) iLevel
{
    // the Filters are stored in selectedFeaturesArray
    CGRect frame = self.mainCollectionView.frame;
    CGFloat parentHeight = self.mainCollectionView.superview.frame.size.height;
    float newPosY = fPosY +((kHeightBars+kMarginBetweenBars)*iLevel);
    //    float newPosY = fPosY +((kHeightBars*iLevel)+(kMarginBetweenBars*(iLevel-1)));
    frame.origin.y = newPosY;
    
    frame.size.height = parentHeight - newPosY;
    self.mainCollectionView.frame = frame;
    
    self.mainCollectionView.hidden = YES;
    if (childrenSelectedProductCategory != nil)
        self.mainCollectionView.hidden =([childrenSelectedProductCategory count] == 0);
    self.lblNoFilters.hidden = !self.mainCollectionView.hidden;
    
    
    // create the collection view
    [self reloadDataForCollectionView:self.mainCollectionView];
//    [self.mainCollectionView reloadData];
}

-(void) showBrandsProductCategoryCollectionView:(long) iLevel
{
    // the Filters are stored in selectedFeaturesArray
    CGRect frame = self.mainCollectionView.frame;
    CGFloat parentHeight = self.mainCollectionView.superview.frame.size.height;
    float newPosY = fPosY +((kHeightBars+kMarginBetweenBars)*iLevel);
    //    float newPosY = fPosY +((kHeightBars*iLevel)+(kMarginBetweenBars*(iLevel-1)));
    frame.origin.y = newPosY;
    
    frame.size.height = parentHeight - newPosY;
    self.mainCollectionView.frame = frame;
    
    self.mainCollectionView.hidden = YES;
    //    if (childrenSelectedProductCategory != nil)
    //        self.mainCollectionView.hidden =([childrenSelectedProductCategory count] == 0);
    //    else
    if (brandsSelectedProductCategory != nil)
    {
        self.mainCollectionView.hidden =([brandsSelectedProductCategory count] == 0);
        // create the alphabet
        [self initAlphabetBrands:brandsSelectedProductCategory];
    }
    self.lblNoFilters.hidden = !self.mainCollectionView.hidden;
    
    
    // create the collection view
    [self reloadDataForCollectionView:self.mainCollectionView];
    
//    [self.mainCollectionView reloadData];
}

//// Clear Terms action
//- (void)clearSearchTerms
//{
//    [self unselectProductCategory:YES];
//    [genderSlideView unselectButtons];
//    [self.mainCollectionView reloadData];
//
////    [self hideSearchTermsListAnimated:YES];
//
////    [_searchTerms removeAllObjects];
////    [[self getSearchTermsListViewParent] removeAllButtons];
//    return;
//}

#pragma mark - Advanced Search - Recursive version

-(void) showStylesAndFeatureGroupRecursive:(ProductGroup *) productCategory
{
    if (selectedProductCategory != nil)
    {
        NSNumber * iIdxSelected = nil;
        if (styleAndFeaturesSlideView.arSelectedButtons.count > 0)
            iIdxSelected = styleAndFeaturesSlideView.arSelectedButtons[0];
        
        // array of the string with the names of the buttons
        NSMutableArray * arButtons = [[NSMutableArray alloc] init];
        // add styles tabs
        iNumSubProductCatgeoriesShowing = 1;
        [arButtons addObject:NSLocalizedString(@"_STYLE_", nil)];
        if (childrenSelectedProductCategory != nil)
            [childrenSelectedProductCategory removeAllObjects];
        else
            childrenSelectedProductCategory = [[NSMutableArray alloc] init];
        
        NSMutableArray * childrenParent = [selectedProductCategory getChildrenReloading];
//        NSMutableArray * childrenParent = [selectedProductCategory getAllDescendants];
        [self filterProductCategoryByGender:childrenParent];
        [childrenSelectedProductCategory addObject:childrenParent];
        
        int iIdxProductCategorySelect = -1;
        int iIdxProductCategory = 1;
        
        for (ProductGroup * pg in childrenParent)
        {
            if (pg.selected)
            {
//                NSMutableArray * children = pg.getChildrenReloading;
                NSMutableArray * children = [pg getAllDescendants];
                [self filterProductCategoryByGender:children];
                
                if ( children.count > 0)
                {
                    //                    SlideButtonObject * objButton = [SlideButtonObject initFromProductCategory:pg];
                    //                    [arButtons addObject:objButton];
                    [arButtons addObject:[pg getNameForApp]];
                    iNumSubProductCatgeoriesShowing++;
                    
                    [childrenSelectedProductCategory addObject:children];
                    
                    if (productCategory != nil)
                    {
                        if ([pg.idProductGroup isEqualToString:productCategory.idProductGroup])
                            iIdxProductCategorySelect = iIdxProductCategory;
                    }
                    iIdxProductCategory++;
                }
            }
        }
        
        // looping through the selected categories adding a tab for it
        [arButtons addObject:NSLocalizedString(@"Brands", nil)];
        
        // load the product groups top in the top bar
        for (FeatureGroup *fg in featureGroupsSelectedProductCategory)
        {
            [arButtons addObject:fg.name];
        }
        
        SlideButtonView *subproductCategoryTabSlideView = styleAndFeaturesSlideView;
        
        // load the data for the new tabslideview
        [subproductCategoryTabSlideView initSlideButtonWithButtons:arButtons andDelegate:self];
        
        subproductCategoryTabSlideView.alpha = 1.0;
        subproductCategoryTabSlideView.hidden = NO;
        
        //        if (iIdxSelected != nil)
        //        {
        //            [subproductCategoryTabSlideView forceSelectButton:iIdxSelected.intValue];
        //        }
        
        if (iIdxProductCategorySelect != -1)
        {
            [subproductCategoryTabSlideView forceSelectButton:iIdxProductCategorySelect];
            
            
            iTabSelected = iIdxProductCategorySelect;//iIdxSelected.intValue;
            
            if (childrenSelectedProductCategory != nil)
            {
                NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
                // create the alphabet
                [self initAlphabetProductCategories:children];
            }
            
        }
        else
        {
            [subproductCategoryTabSlideView forceSelectButton:iNumSubProductCatgeoriesShowing-1];
            
            
            iTabSelected = iNumSubProductCatgeoriesShowing-1;//iIdxSelected.intValue;
            
            if (childrenSelectedProductCategory != nil)
            {
                NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
                // create the alphabet
                [self initAlphabetProductCategories:children];
            }
        }
        
        [self reloadDataForCollectionView:self.mainCollectionView];
//        [self.mainCollectionView reloadData];
    }
    
    
}

-(void) getDataProductCategoryAddingToSearchTerms:(BOOL) bAddToSearchTerm andAnimated:(BOOL) bAnimated
{
    if (appDelegate.productGroups.count > 0)
    {
        // get the featuregroups from the productCategory
        featureGroupsSelectedProductCategory = nil;
        featureGroupsSelectedProductCategory = [selectedProductCategory getFeturesGroupExcept:@"gender"];
        
        // children product category are calculated in showStylesAndFeatureGroupRecursive
        //        // selected Style. Must show the style of the product category
        //        NSMutableArray * children = [selectedProductCategory getChildren];
        //
        //        [self filterProductCategoryByGender:children];
        //        if (childrenSelectedProductCategory == nil)
        //            childrenSelectedProductCategory = [[NSMutableArray alloc] init];
        //        else
        //            [childrenSelectedProductCategory removeAllObjects];
        //
        //        [childrenSelectedProductCategory addObject:children];
        
        // get brands
        // sort by name
        NSSortDescriptor *sortDescriptorPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
        NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        
        brandsSelectedProductCategory = [NSMutableArray arrayWithArray:[[selectedProductCategory.brands allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorPriority,sortDescriptorName, nil]]];
        
        // add the terms to the list
        if (bAddToSearchTerm)
        {
            [self addSearchTerm:[selectedProductCategory getNameForApp] andAnimated:bAnimated];
            //            SlideButtonObject * objectButton = [SlideButtonObject initFromProductCategory:selectedProductCategory];
            //            [self addSearchTermObject:objectButton andAnimated:bAnimated];
        }
        
    }
}

-(void) showDataProductCategory
{
    [self showStylesAndFeatureGroupRecursive:nil];
    
    // force to select the style tab
    [styleAndFeaturesSlideView forceSelectButton:0];
    [self showViewStyleAndFeature:YES];
    
    // we have selected styles, hat is not a feature group so featuregroup must be unselected
    featuresSelectedFeatureGroup = nil;
    featuresIdSelectedFeatureGroup = nil;
    selectedFeatureGroup = nil;
    
    [self showSubProductCategoryCollectionViewRecursive:0];
    
}

-(void) showSubProductCategoryCollectionViewRecursive:(long) iHeight
{
    // the Filters are stored in selectedFeaturesArray
    CGRect frame = self.mainCollectionView.frame;
    CGFloat parentHeight = self.mainCollectionView.superview.frame.size.height;
    float newPosY = fPosY +((kHeightBars+kMarginBetweenBars)*iHeight);
    //    float newPosY = fPosY +((kHeightBars*iLevel)+(kMarginBetweenBars*(iLevel-1)));
    frame.origin.y = newPosY;
    
    frame.size.height = parentHeight - newPosY;
    self.mainCollectionView.frame = frame;
    
    self.mainCollectionView.hidden = YES;
    if (childrenSelectedProductCategory != nil)
    {
        NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
        self.mainCollectionView.hidden =([children count] == 0);
        // create the alphabet
        [self initAlphabetProductCategories:children];
    }
    self.lblNoFilters.hidden = !self.mainCollectionView.hidden;
    
    
    // create the collection view
    [self reloadDataForCollectionView:self.mainCollectionView];
    
//    [self.mainCollectionView reloadData];
}



-(void) getDataFeatureGroupAddingToSearchTerms:(BOOL) bAddToSearchTerm andAnimated:(BOOL) bAnimated
{
    if ([styleAndFeaturesSlideView.arSelectedButtons count] > 0)
    {
        NSNumber* nsnIdxButtonSelect = [styleAndFeaturesSlideView.arSelectedButtons objectAtIndex:0];
        
        long iIdx = [nsnIdxButtonSelect longValue];
        if(iIdx > 1){
            // select a featuregroup
            // we must show the features of the featuregroup
            selectedFeatureGroup = [featureGroupsSelectedProductCategory objectAtIndex:iIdx-(iNumSubProductCatgeoriesShowing+1)];
            if (featuresSelectedFeatureGroup != nil)
                [featuresSelectedFeatureGroup removeAllObjects];
            else
                featuresSelectedFeatureGroup = [[NSMutableArray alloc]init];
            // initi featuresId array
            if (featuresIdSelectedFeatureGroup != nil)
                [featuresIdSelectedFeatureGroup removeAllObjects];
            else
                featuresIdSelectedFeatureGroup = [[NSMutableArray alloc]init];
            
            [self getAllFeaturesFromFeatureGroup:selectedFeatureGroup];
        }
    }
}

-(void) getDataBrandAddingToSearchTerms:(BOOL) bAddToSearchTerm andAnimated:(BOOL) bAnimated
{
    if ([styleAndFeaturesSlideView.arSelectedButtons count] > 0)
    {
        NSNumber* nsnIdxButtonSelect = [styleAndFeaturesSlideView.arSelectedButtons objectAtIndex:0];
        
        long iIdx = [nsnIdxButtonSelect longValue];
        
        if (iIdx == kIndexBrands) // select brand
        {
            // selected Style. Must show the style of the product category
            brandsSelectedProductCategory = nil;
            // sort by name
            NSSortDescriptor *sortDescriptorPriority = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO];
            NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            
            brandsSelectedProductCategory = [NSMutableArray arrayWithArray:[[selectedProductCategory.brands allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorPriority,sortDescriptorName, nil]]];
            
            // we have selected styles, hat is not a feature group so featuregroup must be unselected
            featuresSelectedFeatureGroup = nil;
            featuresIdSelectedFeatureGroup = nil;
            selectedFeatureGroup = nil;
            //            childrenSelectedProductCategory = nil;
        }
        
    }
}

-(void) getDataSubProductCategoryAddingToSearchTerms:(BOOL) bAddToSearchTerm andAnimated:(BOOL) bAnimated
{
    if ([styleAndFeaturesSlideView.arSelectedButtons count] > 0)
    {
        NSNumber* nsnIdxButtonSelect = [styleAndFeaturesSlideView.arSelectedButtons objectAtIndex:0];
        
        long iIdx = [nsnIdxButtonSelect longValue];
        
        if (iIdx == kIndexStyles) // select style
        {
            // selected Style. Must show the style of the product category
            NSMutableArray * children = [selectedProductCategory getChildren];
            [self filterProductCategoryByGender:children];
            if (childrenSelectedProductCategory == nil)
                childrenSelectedProductCategory = [[NSMutableArray alloc] init];
            [childrenSelectedProductCategory addObject:children];
            
            // we have selected styles, hat is not a feature group so featuregroup must be unselected
            featuresSelectedFeatureGroup = nil;
            featuresIdSelectedFeatureGroup = nil;
            selectedFeatureGroup = nil;
        }
    }
    
}

-(void) selectSubProductCategoryByArrayIndex:(NSMutableArray *) arIdxProductCategoriesToSelect addingToSearchTerms:(BOOL) bAddToSearchTerm animated:(BOOL) bAnimated
{
    if (arIdxProductCategoriesToSelect != nil)
    {
        ProductGroup * pcWhereToSelect;
        NSMutableArray * arProductCategories = appDelegate.productGroups;
        for (int iIdx = 0; iIdx < arIdxProductCategoriesToSelect.count; iIdx++)
        {
            NSNumber * nsIdx = arIdxProductCategoriesToSelect[iIdx];
            int iIdxProductCategoryToSelect = [nsIdx intValue];
            if ((iIdxProductCategoryToSelect >= 0) && (iIdxProductCategoryToSelect < arProductCategories.count))
            {
                pcWhereToSelect = [arProductCategories objectAtIndex:[nsIdx intValue]];
                pcWhereToSelect.selected = YES;
                if (iIdx == 0)
                {
                    selectedProductCategory = pcWhereToSelect;
                    
                    [self getDataProductCategoryAddingToSearchTerms:bAddToSearchTerm andAnimated:bAnimated];
                    [self showDataProductCategory];
                    iTabSelected = 0;
                    // select the product category parent
                    [self reloadDataForCollectionView:self.secondCollectionView];
//                    [self.secondCollectionView reloadData];
                }
                else
                {
                    // add new tab
                    pcWhereToSelect.selected = YES;
//                    NSMutableArray * children = [pcWhereToSelect getChildrenReloading];
                    NSMutableArray * children = [pcWhereToSelect getAllDescendants];
                    if (children.count > 0)
                    {
                        // only if the product catgeory has children we add them
                        [self filterProductCategoryByGender:children];
                        [childrenSelectedProductCategory addObject:children];
                    }
                    [self showStylesAndFeatureGroupRecursive:nil];
                    // a subproductcatgeory has been selected
                    [self addSearchTermOfProductGroup:pcWhereToSelect addingToSearchTerms:bAddToSearchTerm];
                    [self reloadDataForCollectionView:self.mainCollectionView];
//                    [self.mainCollectionView reloadData];
                }
                
                if (iIdx < childrenSelectedProductCategory.count)
                    arProductCategories = childrenSelectedProductCategory[iIdx];
            }
            else
            {
                break;
            }
            
        }
    }
}

-(void) unselectSubproductCategoryByArrayIndex:(NSMutableArray *) arIdxProductCategoriesToSelect animated:(BOOL) bAnimated
{
    if ((arIdxProductCategoriesToSelect != nil) && (selectedProductCategory != nil))
    {
        ProductGroup * pcWhereToSelect;
        NSMutableArray * arProductCategories = [selectedProductCategory getChildren];
        int iIdx = 0;
        for (iIdx = 0; iIdx < arIdxProductCategoriesToSelect.count; iIdx++)
        {
            NSNumber * nsIdx = arIdxProductCategoriesToSelect[iIdx];
            int iIdxProductCategoryToSelect = [nsIdx intValue];
            if ((iIdxProductCategoryToSelect >= 0) && (iIdxProductCategoryToSelect < arProductCategories.count))
            {
                pcWhereToSelect = [arProductCategories objectAtIndex:iIdxProductCategoryToSelect];
                arProductCategories = [pcWhereToSelect getChildren];
            }
            else
            {
                break;
            }
            
        }
        
        if ((pcWhereToSelect != nil) && (iIdx == arIdxProductCategoriesToSelect.count))
        {
            pcWhereToSelect.selected = NO;
            // remove the subproduct category selected
            //            SlideButtonObject * objButtonToRemove = [SlideButtonObject initFromProductCategory:pcWhereToSelect];
            //            [self removeSearchTermObject:objButtonToRemove andUpdateGUI:YES animated:bAnimated];
            [self removeSearchTerm:[pcWhereToSelect getNameForApp] andUpdateGUI:YES animated:bAnimated];
            [arSelectedSubProductCategory removeObject:pcWhereToSelect];
            
            // if we removed all teh subproduct categories then, we must add the product category parent
            if (arSelectedSubProductCategory.count == 0)
            {
                [self addSearchTerm:[selectedProductCategory getNameForApp]];
                //                SlideButtonObject * objButton = [SlideButtonObject initFromProductCategory:selectedProductCategory];
                //                [self addSearchTermObject:objButton];
            }
            
            // reload the featuregroups of the product category and sub product category selected
            [self loadFeatureGroupsFromSelectedElements:nil];
        }
        
    }
}



// return YES if the word is found in group
-(NSMutableArray *) getIdxInSubProductGroupsString:(NSString *)sTerm inProductGroups:(NSMutableArray *)productGroups
{
    
    NSMutableArray * arRes = nil;
    
    int iIdxProd = 0;
    
    // recursive call to get to the deepest element product group
    for (ProductGroup* pgChild in productGroups)
    {
        NSMutableArray * children = [pgChild getChildren];
        if (children.count > 0)
        {
            arRes = [self getIdxInSubProductGroupsString:sTerm inProductGroups:[pgChild getChildren]];
            if (arRes != nil)
            {
                [arRes insertObject:[NSNumber numberWithInt:iIdxProd] atIndex:0];
                return arRes;
            }
        }
        
        NSString * sTermTrimmed = [[sTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        NSString *pcNameTrimmed = [[[pgChild getNameForApp] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
        if ([pcNameTrimmed isEqualToString:sTermTrimmed])
        {
            arRes = [[NSMutableArray alloc] init];
            [arRes insertObject:[NSNumber numberWithInt:iIdxProd] atIndex:0];
            return arRes;
        }
        
        if([pgChild.visible boolValue])
        {
            iIdxProd ++;
        }
    }
    
    return arRes;
}



#pragma mark - Access parent controller

-(void) showActivityFeedback
{
    if([self parentViewController])
    {

        if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
        {
            [((SearchBaseViewController *)[self parentViewController]) stopActivityFeedback];
            [((SearchBaseViewController *)[self parentViewController]) startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFILTERS_ACTV_MSG_", nil)];
        }
        else if ([[self parentViewController] isKindOfClass:[FashionistaPostViewController class]])
        {
            [((FashionistaPostViewController *)[self parentViewController]) stopActivityFeedback];
            [((FashionistaPostViewController *)[self parentViewController]) startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFILTERS_ACTV_MSG_", nil)];
        }
    }
}

-(void) stopParentActivityFeedback
{
    if([self parentViewController])
    {
        if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
        {
            [((SearchBaseViewController *)[self parentViewController]) stopActivityFeedback];
            [((SearchBaseViewController *)[self parentViewController]) bringBottomControlsToFront];
        }
        else if ([[self parentViewController] isKindOfClass:[FashionistaPostViewController class]])
        {
            [((FashionistaPostViewController *)[self parentViewController]) stopActivityFeedback];
            [((FashionistaPostViewController *)[self parentViewController]) bringBottomControlsToFront];
        }
    }
}

#pragma mark - Advanced Search - Auxiliar functions

- (CGRect) getRectForViewAtLevel:(long)iLevel
{
    return CGRectMake(0.0f, /*kMarginBetweenBars +*/ (kHeightBars+kMarginBetweenBars)*(iLevel), self.view.frame.size.width, kHeightBars);;
}

-(SlideButtonView *) createTabSlideViewGroup: (long) iLevel withLevelPosY:(long) iLevelPos
{
    CGRect sliderFrame = [self getRectForViewAtLevel:iLevelPos];
    
    SlideButtonView *_slideTabView = [[SlideButtonView alloc] initWithFrame:sliderFrame];
    _slideTabView.minWidthButton = 50;
    _slideTabView.colorTextButtons =  [UIColor colorWithRed:(161/255.0) green:(161/255.0) blue:(161/255.0) alpha:1.0];
    _slideTabView.colorSelectedTextButtons = [UIColor blackColor];
    _slideTabView.bBoldSelected = YES;
    _slideTabView.colorBackgroundButtons = [UIColor clearColor];
    _slideTabView.fShadowRadius = 1.0;
    _slideTabView.colorShadowButtons = [UIColor clearColor];
    _slideTabView.leftMarginControl = 3;
    _slideTabView.spaceBetweenButtons = 0;
    _slideTabView.sNameButtonImage = @"";
    _slideTabView.sNameButtonImageHighlighted = @"";
    _slideTabView.alphaButtons = 0.9;
    _slideTabView.typeSelection = HIGHLIGHT_TYPE;
    _slideTabView.bMultiselect = YES;
    _slideTabView.bSeparator = NO;
    _slideTabView.colorSeparator = [UIColor colorWithRed:(161/255.0) green:(161/255.0) blue:(161/255.0) alpha:1.0];
    _slideTabView.fHeightSeparator = 20;
    _slideTabView.tag = iLevel;

    
//    NSMutableArray * arFeatures = [self getFeaturesOfFeatureGroupByName:@"gender"];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    NSArray *sortedArray = [arFeatures sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *genderArr = [[NSMutableArray alloc] init];
//    for(Feature *feat in sortedArray)
//    {
//        [genderArr addObject:feat.name];
//    }
    
    [_slideTabView initSlideButtonWithButtons:genderArr andDelegate:self];
    [_slideTabView setSpaceBetweenButtons:0];
    [_slideTabView setBShowShadowsSides:YES];
    [_slideTabView setBShowPointRight:YES];
    [_slideTabView setBButtonsCentered:NO];
    
    return _slideTabView;
}

-(long) iIdxFilterSelected:(NSString*) sFilter
{
    long iIdxRes = -1;
    long iIdx = 0;
    
    NSString * sFilterTrimmed = [[sFilter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    for (NSString * searchTerm in _searchTerms)
    {
        NSString * searchTermTrimmed = [[searchTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([searchTermTrimmed.lowercaseString isEqualToString:sFilterTrimmed.lowercaseString])
        {
            iIdxRes = iIdx;
            break;
        }
        iIdx++;
        
    }
    
    return iIdxRes;
}
- (void)updateProductGroupForFilter:(NSString*)trimStr
{
    ProductGroup *selProduct = nil;
    int idx = 0;
    for (idx = 0; idx < btnProductGroups.count; idx++) {
        ProductGroup *product = [btnProductGroups objectAtIndex:idx];
        NSString * sNameTrimmed = [product.app_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
 
        if ([trimStr isEqualToString:sNameTrimmed]) {
            selProduct = product;
            break;
        }
    }
    if (selProduct == nil) return;
    
    ProductGroup *parentProduct = [selProduct getTopParent];
    NSMutableArray *children = [parentProduct getChildren];
    
    if (children.count > 0)
    {
        // only if the product catgeory has children we add them
        [self filterProductCategoryByGender:children];
        [childrenSelectedProductCategory addObject:children];
    }
    [self showStylesAndFeatureGroupRecursive:parentProduct];
    // a subproductcatgeory has been selected
    [self addSearchTermOfProductGroup:parentProduct addingToSearchTerms:YES forcingSelectTab:YES];
    [self reloadDataForCollectionView:self.mainCollectionView];
    
    [btnProductGroups removeObject:selProduct];
    
}
#pragma mark - Delegate slide Button
// SlideButtonViewDelegate function
- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry
{
    //    long iLevel = slideButtonView.tag;
    //productDepth = buttonEntry - 2 < 0 ? 0 : buttonEntry - 2;
    if (slideButtonView == genderSlideView)
    {
        
        NSString * sButton = [genderSlideView sGetNameButtonByIdx:buttonEntry];
        if ([slideButtonView isSelected:buttonEntry])
        {
            // add the item to the searchTermListView
            [self addSearchTerm: sButton ];
        }
        else
        {
            // remove the item to the searchTermListView
            [self removeSearchTerm: sButton];// atIndex:buttonEntry];
            
            
        }
        int iNewGender = [self iGetGenderSelected];
        [self updateForGender:iNewGender];
        
        iGenderSelected = iNewGender;
        [self showSelectedProductSlideView];
    }
    else if(slideButtonView == selectedProductSlideView)
    {
        // select the new product catgeory
        
         NSString * sButton = [selectedProductSlideView sGetNameButtonByIdx:buttonEntry];
        
        NSMutableArray * arFeatures = [self getFeaturesOfFeatureGroupByName:@"gender"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [arFeatures sortedArrayUsingDescriptors:sortDescriptors];
        
        for(int i = 0; i < sortedArray.count; i++)
        {
            Feature *feat = [sortedArray objectAtIndex:i];
            
            if ([sButton isEqualToString:feat.name]) {
//                [selectedProductSlideView removeButton:buttonEntry];
//                if (i == 0) {
//                    if (iGenderSelected == 3) {
//                        iGenderSelected = 2;
//                    } else if (iGenderSelected == 1) {
//                        iGenderSelected = 0;
//                    }
//                }
//                if (i == 1) {
//                    if (iGenderSelected == 3) {
//                        iGenderSelected = 1;
//                    } else if (iGenderSelected == 2) {
//                        iGenderSelected = 0;
//                    }
//                }
//                [self updateForGender:iGenderSelected];
                
                [self showSelectedProductSlideView];
                return;
            }
        }
        
        ProductGroup *selPg = nil;
        
        for (ProductGroup *pg in selectedProductTermsObjectList) {
            if ([pg.app_name isEqualToString:sButton]) {
                selPg = pg;
                break;
            }
        }
        if (selPg != nil) {
            if ([selectedProductTermsObjectList containsObject:selPg])
                [selectedProductTermsObjectList removeObject:selPg];
           
//            if ([selectedProductTermsList containsObject:sButton]) {
//                [selectedProductTermsList removeObject:sButton];
                [self.mainCollectionView reloadData];
             [self showSelectedProductSlideView];
                
//            }
        }
    }
    
    
    NSLog(@"Button clicked: %i. Slidebutton: %ld. TabSelected: %i",buttonEntry, (long)slideButtonView.tag, iTabSelected);
}

#pragma mark - Collection View
// Initilize the Fetched Results Controller and the Collection View to manage and show the product feature terms
-(void)initProductFeatureTermsCollectionView
{
    // Init collection views cell types
    // setup collection view
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"FeatureCell",@"ProductCategoryCell", nil]];
    
    // Setup Collection View
    [self initCollectionViewsLayout];
}

// OVERRIDE: Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
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

// OVERRIDE: Number of items in each section for the main collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"FeatureCell"] || [cellType isEqualToString:@"ProductCategoryCell"])
    {
        NSInteger iCount = 0;
        if (self.viewGenderAndProductCategory.hidden == NO)
        {
            iCount = [appDelegate.productGroups count];
        }
        else if (self.viewSubProductAndFeatures.hidden == NO)
        {
            if (iTabSelected < iNumSubProductCatgeoriesShowing)
            {
                NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
                iCount = [children count];
            }
            else if (iTabSelected == iNumSubProductCatgeoriesShowing)
            {
                iCount = [brandsSelectedProductCategory count];
            }
            else if (iTabSelected > iNumSubProductCatgeoriesShowing)
            {
                iCount = [featuresSelectedFeatureGroup count]; // Number of features in selected group
            }
            
            //            if (featuresSelectedFeatureGroup != nil)
            //                iCount = [featuresSelectedFeatureGroup count]; // Number of features in selected group
            //            else if (childrenSelectedProductCategory != nil)
            //            {
            //                NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
            //                iCount = [children count];
            //            }
            //            else if (brandsSelectedProductCategory != nil)
            //                iCount = [brandsSelectedProductCategory count];
        }
        
        return iCount;
        
    }
    
    return 0;
}
// OVERRIDE: Return the size of the image to be shown in a cell for a collection view
- (CGSize)getSizeForImageInCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"FeatureCell"] || [cellType isEqualToString:@"ProductCategoryCell"])
    {
        //        if (featuresSelectedFeatureGroup != nil)
        if ((iTabSelected > iNumSubProductCatgeoriesShowing) && (featuresSelectedFeatureGroup != nil))
        {
            Feature * feature = nil;
            feature = [featuresSelectedFeatureGroup objectAtIndex:[indexPath indexAtPosition:1]];
            
            if ((feature.icon == nil) || [feature.icon  isEqualToString: @""])
            {
                return CGSizeMake(0, 0);
            }
        }
    }
    
    // left the default value of the height and width
    return CGSizeMake(-1, -1);
    
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"FeatureCell"] || [cellType isEqualToString:@"ProductCategoryCell"])
    {
        NSString * image = @"addkw.png";
        NSString * sName = @"";
        
        // comprobamos el tamaño de la celda, si es por defecto mostramos el zoom in, sino no.
        CGSize rect = [self getSizeForImageInCellWithType:cellType AtIndexPath:indexPath];
        NSNumber * numberShowZoom = [NSNumber numberWithBool:NO];
        if (rect.height == -1)
            numberShowZoom = [NSNumber numberWithBool:YES];
        
        
        Feature * feature = nil;
        ProductGroup * productCategory = nil;
        ProductGroup *subCategory = nil;
        Brand * brand;
        
        if (self.viewGenderAndProductCategory.hidden == NO)
        {
            productCategory = [appDelegate.productGroups objectAtIndex:[indexPath indexAtPosition:1]];
            
            
            //            if (productCategory.icon != nil)
            //            {
            //                if (![productCategory  isEqual: @""])
            //                {
            //                    image = productCategory.icon;
            //                }
            //            }
            image = [productCategory getIconForGender:iGenderSelected byDefault:image];
            sName = [productCategory getNameForApp];
        }
        else if (self.viewSubProductAndFeatures.hidden == NO)
        {
            //            if (featuresSelectedFeatureGroup != nil)
            if (iTabSelected > iNumSubProductCatgeoriesShowing)
            {
                feature = [featuresSelectedFeatureGroup objectAtIndex:[indexPath indexAtPosition:1]];
                
                ProductGroup * subProductCategory = nil;
                if ((arSelectedSubProductCategory.count > 0) && (arSelectedSubProductCategory.count <= 1))
                {
                    subProductCategory = [arSelectedSubProductCategory objectAtIndex:0];
                }
                image = [feature getIconForGender:iGenderSelected andProductCategoryParent:selectedProductCategory andProductCategoryChild:subProductCategory byDefault:@"no_image.png"];
//                if (feature.icon != nil)
//                {
//                    if (![feature.icon  isEqualToString: @""])
//                    {
//                        image = feature.icon;
//                    }
//                }
                sName = feature.name;
            }
            //            else if (childrenSelectedProductCategory != nil)
            else if (iTabSelected < iNumSubProductCatgeoriesShowing)
            {
                NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
                
                productCategory = [children objectAtIndex:[indexPath indexAtPosition:1]];
                
                //                if (productCategory.icon != nil)
                //                {
                //                    if (![productCategory.icon  isEqual: @""])
                //                    {
                //                        image = productCategory.icon;
                //                    }
                //                }
                //                sName = productCategory.name;
                
                image = [productCategory getIconForGender:iGenderSelected byDefault:image];
                subCategory = productCategory;
                sName = [productCategory getNameForApp];
            }
            //            else if (brandsSelectedProductCategory != nil)
            else if (iTabSelected == iNumSubProductCatgeoriesShowing)
            {
                brand = [brandsSelectedProductCategory objectAtIndex:[indexPath indexAtPosition:1]];
                
                if (brand.logo != nil)
                {
                    if (![brand.logo  isEqualToString: @""])
                    {
                        image = brand.logo;
                    }
                }
                sName = brand.name;
                
//                numberShowZoom = [NSNumber numberWithBool:NO];
                
            }
        }
        NSString * sNameTrimmed = [sName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        UIColor *backLabelColor = [UIColor clearColor];
        
        for (ProductGroup *pg in selectedProductTermsObjectList) {
            if (subCategory.idProductGroup != nil && ![subCategory.idProductGroup isEqualToString:@""]) {
                if ([pg.idProductGroup isEqualToString:subCategory.idProductGroup]) {
                    backLabelColor = [UIColor colorWithRed:(244/255.0) green:(206/255.0) blue:(118/255.0) alpha:1.0f];
                    break;

                }

            }
        }

        return [NSArray arrayWithObjects: image, sNameTrimmed, backLabelColor, numberShowZoom, nil];
    }
    
    return nil;
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"FeatureCell"] || [cellType isEqualToString:@"ProductCategoryCell"])
    {
        ProductGroup * productCategory = nil;
        Brand * brand = nil;
        Feature * feature = nil;
        
        NSString * sName = @"";
        if (self.viewGenderAndProductCategory.hidden == NO)
        {
            if ([self isGenderSelected])
            {
                // click in a product category parent, we must select the product category and show its subproducts categories and features
                productCategory = [appDelegate.productGroups objectAtIndex:[indexPath indexAtPosition:1]];
                selectedProductCategory = productCategory;

                
                [self getDataProductCategoryAddingToSearchTerms:YES andAnimated:YES];
                [self showDataProductCategory];
                
                
                //                [self selectProductGroupOfLevel:0 addingToSearchTerms:YES animated:YES];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTGENDERSELECTED_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                
                return;
            }
        }
        else if (self.viewSubProductAndFeatures.hidden == NO)
        {
            if (iTabSelected < iNumSubProductCatgeoriesShowing)
            {
                // showing productcategories
                NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
                productCategory = [children objectAtIndex:[indexPath indexAtPosition:1]];
                NSLog(@"Button clicked: %@.", [productCategory getNameForApp]);
                sName = [productCategory getNameForApp];
                NSMutableArray *chr = productCategory.getChildren;
                if (chr.count <= 0) {
                    if ([selectedProductTermsObjectList containsObject:productCategory]) {
                        [selectedProductTermsObjectList removeObject:productCategory];
                    } else
                        [selectedProductTermsObjectList addObject:productCategory];
                }
                
                [self showSelectedProductSlideView];
            }
            else if (iTabSelected == iNumSubProductCatgeoriesShowing)
            {
                // showing brands
                brand = [brandsSelectedProductCategory objectAtIndex:[indexPath indexAtPosition:1]];
                NSLog(@"Button clicked: %@.", brand.name);
                sName = brand.name;
             //   [selectedProductTermsObjectList addObject:brand];

            }
            else if (iTabSelected > iNumSubProductCatgeoriesShowing)
            {
                // showing features
                feature = [featuresSelectedFeatureGroup objectAtIndex:[indexPath indexAtPosition:1]];
                NSLog(@"Button clicked: %@.", feature.name);
                sName = feature.name;
             //   [selectedProductTermsObjectList addObject:feature];

            }
            
            // add or remove the search term
            NSString * sNameTrimmed = [sName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            
            // if filter is selected, remove from the array
            long iIdxSelected = [self iIdxFilterSelected:sNameTrimmed];
            if (iIdxSelected != -1)
            {
                // remove the search term
                if (productCategory != nil)
                {
                    [_searchTerms addObject:sNameTrimmed];
                    // remove new tab
                    productCategory.selected = NO;
                    if (productCategory.getChildren.count > 0)
                    {
                        [childrenSelectedProductCategory removeObjectAtIndex:(iTabSelected+1)]; // the product category es in the first position
                    }
                    
                    [self showStylesAndFeatureGroupRecursive:nil];
                    // a subproductcatgeory has been selected
                    [self removeSearchTermOfProductGroup:productCategory];
                    [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
                else if (brand != nil)
                {
                    [self removeSearchTermOfBrand:brand];
                    [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
                else
                {
                    [self removeSearchTerm:sNameTrimmed];
                    [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                }

            }
            else
            {
                // add the search term
                if (productCategory != nil)
                {
                    // add new tab
                    productCategory.selected = YES;
                    NSMutableArray * children = productCategory.getChildren;
                    BOOL bUpdateItemCollectionView = YES;
                    if (children.count > 0)
                    {
                        // only if the product catgeory has children we add them
                        [self filterProductCategoryByGender:children];
                        [childrenSelectedProductCategory addObject:children];
                        bUpdateItemCollectionView = NO;
                        productDepth++;
                        [btnProductGroups addObject:productCategory];
                        NSString * sNameTrimmed = [productCategory.app_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        [arr addObject:sNameTrimmed];
                     //   [self createGenderSlideView];

                    }
                    [self showStylesAndFeatureGroupRecursive:productCategory];
                    // a subproductcatgeory has been selected
                    [self addSearchTermOfProductGroup:productCategory addingToSearchTerms:YES forcingSelectTab:YES];
                    if (bUpdateItemCollectionView)
                    {
                        if (_bAutoSwap)
                        {
                            if (iTabSelected < [featureGroupsSelectedProductCategory count] + iNumSubProductCatgeoriesShowing)
                            {
                                [styleAndFeaturesSlideView selectButton:iTabSelected+1];
                                [styleAndFeaturesSlideView scrollToButtonByIndex:iTabSelected+1];
                                [self slideButtonView:styleAndFeaturesSlideView btnClick:iTabSelected+1];
                            }
                            else
                            {
                                [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                            }
                        }
                        else{
                            // only reload the index path if there no children to show, if so, then the tab selection is changed
                            [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                        }
                    }

                }
                else if (brand != nil)
                {
                    [self addSearchTermOfBrand:brand];
                    if (_bAutoSwap)
                    {
                        if (iTabSelected < [featureGroupsSelectedProductCategory count] + iNumSubProductCatgeoriesShowing)
                        {
                            [styleAndFeaturesSlideView selectButton:iTabSelected+1];
                            [styleAndFeaturesSlideView scrollToButtonByIndex:iTabSelected+1];
                            [self slideButtonView:styleAndFeaturesSlideView btnClick:iTabSelected+1];
                        }
                        else
                        {
                            [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                        }
                    }
                    else
                    {
                        [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }
                }
                else
                {
                    if (_bAutoSwap)
                    {
                        if (iTabSelected < [featureGroupsSelectedProductCategory count] + iNumSubProductCatgeoriesShowing)
                        {
                            [styleAndFeaturesSlideView selectButton:iTabSelected+1];
                            [styleAndFeaturesSlideView scrollToButtonByIndex:iTabSelected+1];
                            [self slideButtonView:styleAndFeaturesSlideView btnClick:iTabSelected+1];
                        }
                        else
                        {
                            [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                        }
                    }
                    else{
                        [self.mainCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }
                }
            }
            
        }

    }
}

-(void) reloadDataForCollectionView:(UICollectionView *)collectionView
{
    [self initOperationsLoadingImages];
    [self.imagesQueue cancelAllOperations];
    
    [collectionView layoutIfNeeded];
    [collectionView reloadData];
}

#pragma mark - gesture management

// Action to perform when user swipes down
- (void)swipeDownAction
{
    /*
     if(![[self activityIndicator] isHidden])
     {
     return;
     }
     
     if([self parentViewController])
     {
     if ([[self parentViewController] isKindOfClass:[SearchViewController class]])
     {
     [((SearchViewController *)[self parentViewController]) hideFilterSearch:YES];
     }
     else if ([[self parentViewController] isKindOfClass:[ResultsViewController class]])
     {
     [((ResultsViewController *)[self parentViewController]) hideFilterSearch];
     }
     else if ([[self parentViewController] isKindOfClass:[TrendingViewController class]])
     {
     [((TrendingViewController *)[self parentViewController]) hideFilterSearch];
     }
     else if ([[self parentViewController] isKindOfClass:[HistoryViewController class]])
     {
     [((HistoryViewController *)[self parentViewController]) hideFilterSearch];
     }
     else if ([[self parentViewController] isKindOfClass:[FashionistasViewController class]])
     {
     [((FashionistasViewController *)[self parentViewController]) hideFilterSearch];
     }
     }
     */
}

// Action to perform when user swipes down
- (void)swipeRightAction
{
    if (self.zoomBackgroundView.hidden == NO)
    {
        [self hideZoomView];
        
        return;
    }
    
    if((self.hintBackgroundView != nil) && (!([self.hintBackgroundView isHidden])))
    {
        [self hintPrevAction:nil];
        
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if (self.viewSubProductAndFeatures.hidden == YES){
        if([self parentViewController])
        {
            if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
            {
                [((SearchBaseViewController *)[self parentViewController]) hideFilterSearch];
            }
            else if ([[self parentViewController] isKindOfClass:[FashionistaPostViewController class]])
            {
                [((FashionistaPostViewController *)[self parentViewController]) hideFilterSearch];
            }
        }
    }
    else{
        [self unselectProductCategory:YES];
    }
    
}

// Action to perform when user swipes down
- (void)swipeLeftAction
{
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintNextAction:nil];
        
        return;
    }
    
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    if([self parentViewController])
    {
        if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
        {
            [((SearchBaseViewController *)[self parentViewController]) swipeLeftAction];
        }
        else if ([[self parentViewController] isKindOfClass:[FashionistaPostViewController class]])
        {
            [((FashionistaPostViewController *)[self parentViewController]) swipeLeftAction];
        }
    }
}

/*
// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Left action
- (void)leftAction:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    [super leftAction:sender];
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Right action
- (void)rightAction:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
    {
        return;
    }
    
    [super rightAction:sender];
    
}
*/
// Action to perform when user swipes to right: go to previous screen
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
        
        // Show the advanced search when swipe up
        if (velocity.y < 0)
        {
            if(heightPercentage > 0.3)
            {
                [self swipeUpAction];
            }
        }
        
        // Hide the advanced search when swipe up
        if (velocity.y > 0)
        {
            if(heightPercentage > 0.3)
            {
                [self swipeDownAction];
            }
        }
    }
}

#pragma mark - Zoom View
-(void) initZoomView
{
    // Init the hint view
    self.zoomView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
    self.zoomView.clipsToBounds = NO;
    self.zoomView.contentMode = UIViewContentModeScaleAspectFit;
    self.zoomView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.zoomView.layer.shadowOffset = CGSizeMake(0,5);
    self.zoomView.layer.shadowOpacity = 0.5;
    self.zoomView.hidden = YES;
    
    
    // And the hint background view
    self.zoomBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.zoomBackgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    self.zoomBackgroundView.hidden = YES;
    
    self.zoomLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.zoomLabel.backgroundColor = [UIColor blackColor];
    self.zoomLabel.textColor = [UIColor whiteColor];
    self.zoomLabel.textAlignment = NSTextAlignmentCenter;
    [self.zoomLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:14]];
    [self.zoomBackgroundView addSubview:self.zoomLabel];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changecolor)];
    [self.zoomBackgroundView addGestureRecognizer:singleTap];
    if (self.parentViewController != nil)
    {
        [self.parentViewController.view addSubview:self.zoomView];
        [self.parentViewController.view addSubview:self.zoomBackgroundView];
        
        [self.parentViewController.view bringSubviewToFront:self.zoomBackgroundView];
        [self.parentViewController.view bringSubviewToFront:self.zoomView];
    }
    else
    {
        [self.view addSubview:self.zoomView];
        [self.view addSubview:self.zoomBackgroundView];
        
        [self.view bringSubviewToFront:self.zoomBackgroundView];
        [self.view bringSubviewToFront:self.zoomView];
        
    }
    
}

-(void)changecolor{
    [self hideZoomView];
}

- (void)onTapFeatureZoomButton:(UIButton *)sender
{
    NSLog(@"Click ZoomIn");
    Feature * selectedFeatureToZoom;
    Brand * selectedBrandToZoom;
    ProductGroup * selectedProductCategoryToZoom;
    long iIndex = sender.tag;
    NSString * sNoImage = @"no_image.png";
    NSString * sImage = nil;
    NSString * sTextLabel = @"";
    
    if (self.viewGenderAndProductCategory.hidden == NO)
    {
        // click in a product category parent, we must select the product category and show its subproducts categories and features
        selectedProductCategoryToZoom = [appDelegate.productGroups objectAtIndex:iIndex];
        NSLog(@"Button clicked: %@.", [selectedProductCategoryToZoom getNameForApp]);
        sImage = [selectedProductCategoryToZoom getIconForGender:iGenderSelected byDefault:sNoImage];
        sTextLabel = [selectedProductCategoryToZoom getNameForApp];
        
    }
    else if (self.viewSubProductAndFeatures.hidden == NO)
    {
        if (iTabSelected < iNumSubProductCatgeoriesShowing)
        {
            // showing productcategories
            NSMutableArray * children = childrenSelectedProductCategory[iTabSelected];
            selectedProductCategoryToZoom = [children objectAtIndex:iIndex];
            NSLog(@"Button clicked: %@.", [selectedProductCategoryToZoom getNameForApp]);
            sImage = [selectedProductCategoryToZoom getIconForGender:iGenderSelected byDefault:sNoImage];
            sTextLabel = [selectedProductCategoryToZoom getNameForApp];
        }
        else if (iTabSelected == iNumSubProductCatgeoriesShowing)
        {
            // showing brands
            selectedBrandToZoom = [brandsSelectedProductCategory objectAtIndex:iIndex];
            NSLog(@"Button clicked: %@.", selectedBrandToZoom.name);
            sImage = selectedBrandToZoom.logo;
            sTextLabel = selectedBrandToZoom.name;
        }
        else if (iTabSelected > iNumSubProductCatgeoriesShowing)
        {
            // showing features
            selectedFeatureToZoom = [featuresSelectedFeatureGroup objectAtIndex:iIndex];
            NSLog(@"Button clicked: %@.", selectedFeatureToZoom.name);
            ProductGroup * subProductCategory = nil;
            if ((arSelectedSubProductCategory.count > 0) && (arSelectedSubProductCategory.count <= 1))
            {
                subProductCategory = [arSelectedSubProductCategory objectAtIndex:0];
            }
            sImage = [selectedFeatureToZoom getIconForGender:iGenderSelected andProductCategoryParent:selectedProductCategory andProductCategoryChild:subProductCategory byDefault:@"no_image.png"];
//            sImage = selectedFeatureToZoom.icon;
            sTextLabel = selectedFeatureToZoom.name;
        }
    }
    
    [self loadImageZoomView:sImage andLabel:sTextLabel];
    [self showZoomView];
}


-(void) showZoomView
{
    if (self.zoomView.hidden == NO)
        return;
    
    UIView * view;
    if (self.parentViewController != nil)
    {
        [self.parentViewController.view bringSubviewToFront:self.zoomBackgroundView];
        [self.parentViewController.view bringSubviewToFront:self.zoomView];
        view = self.parentViewController.view;
    }
    else
    {
        [self.view bringSubviewToFront:self.zoomBackgroundView];
        [self.view bringSubviewToFront:self.zoomView];
        view = self.view;
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

-(void) loadImageZoomView:(NSString *) pathImage andLabel:(NSString *) textLabel
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
        
        [self.imagesQueue addOperation:operation];
    }
    
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

#pragma mark - Brands alphabet

#define kDefaultFontSizeAlphabet 10
#define kHeightLetterAlphabet 20
#define kWidthAlphabet 18

// create the alphabet
-(void) initAlphabetProductCategories:(NSMutableArray *)productCategories
{
    NSMutableArray * arElements = [[NSMutableArray alloc] init];
    
    for(ProductGroup *  pg in productCategories)
    {
        [arElements addObject:[pg getNameForApp]];
    }
    
    [self initAlphabetwithArray:arElements];
}

-(void) initAlphabetBrands:(NSMutableArray *) brands
{
    NSMutableArray * arElements = [[NSMutableArray alloc] init];
    for(Brand *  b in brands)
    {
        [arElements addObject:b.name];
    }
    [self initAlphabetwithArray:arElements];
}

-(void) initAlphabetFeatures:(NSMutableArray *) features
{
    NSMutableArray * arElements = [[NSMutableArray alloc] init];
    for(Feature *  feat in features)
    {
        [arElements addObject:feat.name];
    }
    [self initAlphabetwithArray:arElements];
}

-(void) initAlphabetwithArray:(NSMutableArray *)arrayElements
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
    [dictAlphabet setObject:[NSNumber numberWithInt:-1] forKey:@"#"];
    for(int i = 65; i <= 90; i++)
    {
        NSString *stringChar = [NSString stringWithFormat:@"%c", i];
        [dictAlphabet setObject:[NSNumber numberWithInt:-1] forKey:stringChar];
    }
    
    
    // set dictionary of letter with the index
    int iNumLettersInAlphabet = 0;
    int iIdxElementFiltered = 0;
    for (int iIdxElement = 0; iIdxElement < [arrayElements count]; iIdxElement++)
    {
        NSString * tmpElement = [arrayElements objectAtIndex:iIdxElement];
        
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
                NSNumber * iIdx = [dictAlphabet objectForKey:key];
                if ([iIdx intValue] == -1)
                {
                    iIdx = [NSNumber numberWithInt:iIdxElementFiltered];
                    [dictAlphabet setObject:iIdx forKey:key];
                    iNumLettersInAlphabet++;
                }
                iIdxElementFiltered ++;
            }
        }
    }
    
    
    UIFont * fontDefault = [UIFont fontWithName:@"AvenirNext-Regular" size:kDefaultFontSizeAlphabet];
    UIFont * fontZoom = [UIFont fontWithName:@"AvenirNext-Bold" size:(kDefaultFontSizeAlphabet*2.5)];
    
    float fTotalHeight = self.viewSubProductAndFeatures.frame.size.height - fPosY - 60 - 12;
    if (self.fromViewController != nil)
        fTotalHeight = self.viewSubProductAndFeatures.frame.size.height - fPosY -  85 -  12;
    
    scrollBrandAlphabetBDK = [BDKCollectionIndexView indexViewWithFrame:CGRectMake(self.viewSubProductAndFeatures.frame.size.width-kWidthAlphabet, self.SuggestedFiltersRibbonView.frame.size.height + fPosY + kHeightBars, kWidthAlphabet, fTotalHeight) indexTitles:@[]];
    
    scrollBrandAlphabetBDK.touchStatusBackgroundColor = [UIColor grayColor];
    scrollBrandAlphabetBDK.touchStatusViewAlpha = 0.8;
    scrollBrandAlphabetBDK.font = fontDefault;
    scrollBrandAlphabetBDK.fontZoom = fontZoom;
    scrollBrandAlphabetBDK.fontZoomColor = [UIColor whiteColor];
    scrollBrandAlphabetBDK.tintColor = [UIColor whiteColor];
    
    [scrollBrandAlphabetBDK addTarget:self action:@selector(indexViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //    float yPos = 0.0;
    
    //    iIdx = 0;
    NSMutableArray * sortedKeyArray = [[NSMutableArray alloc] initWithArray:[[dictAlphabet allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    NSMutableArray * arIdxBDK = [NSMutableArray new];
    
    for(NSString * key in sortedKeyArray)
    {
        NSNumber * idx = [dictAlphabet objectForKey:key];
        if ([idx intValue] != -1)
        {
            [arIdxBDK addObject:key];
            iIdx++;
        }
    }
    
    scrollBrandAlphabetBDK.indexTitles = arIdxBDK;
    [self.view addSubview:scrollBrandAlphabetBDK];
    [self.view bringSubviewToFront:scrollBrandAlphabetBDK];
    
    NSLog(@"Init Rect Alphabet Origin (%f, %f) Size(%f, %f)", scrollBrandAlphabetBDK.frame.origin.x, scrollBrandAlphabetBDK.frame.origin.y, scrollBrandAlphabetBDK.frame.size.width, scrollBrandAlphabetBDK.frame.size.height);
    
//    self.constraintTrailingAlphabet.constant = fHeightButton+5;
}

-(void) hideAlphabet
{
    if (scrollBrandAlphabetBDK != nil)
    {
        [scrollBrandAlphabetBDK removeFromSuperview];
    }
//    self.constraintTrailingAlphabet.constant = 5;
}

- (IBAction)btnAlphabet: (id)sender
{
    UIButton *button = (UIButton*)sender;
    // highlight the button
    long iIdxElement = (long)button.tag;
    NSLog(@"Alphabet %ld", iIdxElement);
    
    if (iIdxElement > -1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:iIdxElement inSection:0];
        // scrolling here does work
        [self.mainCollectionView scrollToItemAtIndexPath:indexPath
                                          atScrollPosition:UICollectionViewScrollPositionTop
                                                  animated:YES];
    }
}

- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender
{
    NSNumber * idx = [dictAlphabet objectForKey:sender.currentIndexTitle];
    if ([idx intValue] > -1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[idx intValue] inSection:0];
        // scrolling here does work
        [self.mainCollectionView scrollToItemAtIndexPath:indexPath
                                          atScrollPosition:UICollectionViewScrollPositionTop
                                                  animated:YES];
    }
}

@end
