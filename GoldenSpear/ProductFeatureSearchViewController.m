//
//  ProductFeatureSearchViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 20/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "ProductFeatureSearchViewController.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "SearchBaseViewController.h"


#define kMinWidthButton 50
#define kMinPanGestureLenght 0.2

@interface ProductFeatureSearchViewController ()

@end

@implementation ProductFeatureSearchViewController

AppDelegate * appDelegate;
// Property to control when the product feature terms view is shown/hidden
BOOL bExpandedProductFeatureTermsView = NO;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //Get the appDelegate to maintain the global search terms list
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Alloc and Init the data arrays
    _selectedSearchTerms = [[NSMutableArray alloc] init];
    _shownProductFeatureTerms = [[NSMutableArray alloc] init];
    _productFeaturesList = [[NSMutableArray alloc] init];
    _featureTermsList = [[NSMutableArray alloc] init];
    
    // Init the collection view
    [self initProductFeatureTermsCollectionView];

    // Get product features
    [self getFeaturesForProductId:_shownProduct];
    
    // Setup the product image
    [self.productImageView setImage:self.shownImage];
    
    // Hide the product feature terms view until a product feature is selected
    [self.productFeatureTermsView setHidden:YES];
    bExpandedProductFeatureTermsView = NO;
    [self.productFeatureTermsView setAlpha:0.85];
    self.productFeatureTermsViewBottomSpaceConstraint.constant = -150;
    
    // Hide the Filter terms Ribbon View until features are loaded
    if (!([self.SuggestedFiltersRibbonView isHidden]))
    {
        [self hideSuggestedFiltersRibbonAnimated:NO];
    }
    
    // Hide the Search terms List View until terms are loaded
    if (!([self.searchTermsListView isHidden]))
    {
        [self hideSearchTermsListAnimated:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Views Initialization

// Setup and init the search terms list
-(void)initSearchTermsListView
{
    // Setup the search terms list
    
    [self.searchTermsListView setMinWidthButton:kMinWidthButton];
    [self.searchTermsListView setSpaceBetweenButtons:0];
    [self.searchTermsListView setBShowShadowsSides:YES];
    [self.searchTermsListView setBShowPointRight:YES];
    [self.searchTermsListView setBButtonsCentered:NO];
    [self.searchTermsListView setColorTextButtons:[UIColor grayColor]];
    [self.searchTermsListView setColorSelectedTextButtons:[UIColor grayColor]];
    [self.searchTermsListView setFont:[UIFont fontWithName:@"AvantGarde-Book" size:16]];

    //[self.searchTermsListView setSNameButtonImage:@"TermsListButtonBackground.png"];
    //[self.searchTermsListView setSNameButtonImageHighlighted:@"termListButtonBackground.png"];
    
    [self.searchTermsListView initSlideButtonWithButtons:_selectedSearchTerms andDelegate:self];
    
    if([self.searchTermsListView.arrayButtons count] > 0)
    {
        if ([self.searchTermsListView isHidden])
        {
            [self showSearchTermsListAnimated:YES];
        }
    }
}

// Setup and init the filter terms ribbon
-(void)initSuggestedFiltersRibbonView
{
    // Setup the features list
    
    // Get the NAMES of list of features

    NSMutableArray *featuresNames = [[NSMutableArray alloc] init];
    
    for (int i=0; i < [_productFeaturesList count]; i++)
    {
        [featuresNames addObject:[[_productFeaturesList objectAtIndex:i] name]];
    }
    
    [self.SuggestedFiltersRibbonView setMinWidthButton:kMinWidthButton];
    [self.SuggestedFiltersRibbonView setSpaceBetweenButtons:0];
    [self.SuggestedFiltersRibbonView setSNameButtonImage:@"FiltersRibbonButtonBackground.png"];
    [self.SuggestedFiltersRibbonView setSNameButtonImageHighlighted:@"FiltersRibbonButtonBackground.png"];
    [self.SuggestedFiltersRibbonView setBMultiselect:NO];
    [self.SuggestedFiltersRibbonView setTypeSelection:TAB_TYPE];
    [self.SuggestedFiltersRibbonView setBUnselectWithClick:NO];
    [self.SuggestedFiltersRibbonView setFTabHeight:0.9];
    [self.SuggestedFiltersRibbonView setColorBackgroundButtons:[UIColor clearColor]];
    [self.SuggestedFiltersRibbonView setColorShadowButtons:[UIColor clearColor]];
    
    [self.SuggestedFiltersRibbonView initSlideButtonWithButtons:featuresNames andDelegate:self];
    
    [self.SuggestedFiltersRibbonView setBButtonsDistributed:YES];
    
    //Show the filter terms ribbon
    [self showSuggestedFiltersRibbonAnimated:YES];
}


#pragma mark - Slide button views delegates and management


// SlideButtonViewDelegate function
- (void)slideButtonView:(SlideButtonView *)slideButtonView btnClick:(int)buttonEntry
{
    if(![[self activityIndicator] isHidden])
        return;

    if (slideButtonView == self.SuggestedFiltersRibbonView)
    {
        if (!(_productFeaturesList == nil))
        {
            if (!(buttonEntry >= [_productFeaturesList count]))
            {
                if ([[[_productFeaturesList objectAtIndex:buttonEntry] name] isEqualToString:[self.productFeatureName text]])
                {
                    [self showProductFeatureTermsViewAnimated:YES];
                    
                    return;
                }
                
                [self.productFeatureName setText:[[_productFeaturesList objectAtIndex:buttonEntry] name]];
                
                [self getTermsForFeatureGroupId:[[_productFeaturesList objectAtIndex:buttonEntry] idFeatureGroup]];
            }
        }
    }
    else if (slideButtonView == self.searchTermsListView)
    {
        if(!(self.searchTermsListView == nil))
        {
            if(!(buttonEntry >= [self.searchTermsListView.arrayButtons count]))
            {
                // Remove button
                [self.searchTermsListView removeButton:buttonEntry];
                
                // Remove entry in array of selected terms
                [_selectedSearchTerms removeObjectAtIndex:buttonEntry];
                
                //        if([self.searchTermsListView.arrayButtons count] < 1)
                //        {
                //            if (!([self.searchTermsListView isHidden]))
                //            {
                //                [self hideSearchTermsListAnimated:YES];
                //            }
                //        }
                
                // Update Collection View
                [self updateCollectionViewWithCellType:@"FeatureCell" fromItem:0 toItem:-1 deleting:NO];
            }
        }
    }
}

// Method to remove a given button from the Search terms List View
-(void)removeFromSearchTermsListViewButton:(NSString*)removingButton
{
    // Look for the button within the searchTermsListView
    for (int i = 0; i < [self.searchTermsListView.arrayButtons count]; i++)
    {
        if ([[self.searchTermsListView.arrayButtons objectAtIndex:i] isEqualToString:removingButton])
        {
            // Remove button
            [self.searchTermsListView removeButton:i];
        }
    }

//    if([self.searchTermsListView.arrayButtons count] < 1)
//    {
//        if (!([self.searchTermsListView isHidden]))
//        {
//            [self hideSearchTermsListAnimated:YES];
//        }
//    }
}

// Method to add a given button from the Search terms List View
-(void)addToSearchTermsListViewButton:(NSString*)addingButton
{
    if (!([self.searchTermsListView.arrayButtons containsObject:addingButton]))
    {
        // Add button
        [self.searchTermsListView addButton:addingButton];
    }
    else
    {
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_TERM_ALREADY_IN_LIST_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
         */
    }

    if([self.searchTermsListView.arrayButtons count] > 0)
    {
        if ([self.searchTermsListView isHidden])
        {
            [self showSearchTermsListAnimated:YES];
        }
    }
}

// Clear terms action
- (void)clearTermsAction:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
        return;

    // Remove all search terms buttons
    [self.searchTermsListView removeAllButtons];
    
    // Remove all items in terms list
    [self.selectedSearchTerms removeAllObjects];

    // Update Collection View
    [self updateCollectionViewWithCellType:@"FeatureCell" fromItem:0 toItem:-1 deleting:NO];

    // Hide search terms list view
//    if (!([self.searchTermsListView isHidden]))
//    {
//        [self hideSearchTermsListAnimated:YES];
//    }
    
    // Hide product feature terms view
    [self hideProductFeatureTermsViewAnimated:YES];
}

// Reset terms action
- (void)resetTermsAction:(UIButton *)sender
{
    [_selectedSearchTerms removeAllObjects];
    
    [_selectedSearchTerms addObjectsFromArray:_shownProductFeatureTerms];
    
    // Init all interface elements

    [self initSearchTermsListView];
    
    [self updateCollectionViewWithCellType:@"FeatureCell" fromItem:0 toItem:-1 deleting:NO];
}


#pragma mark - Collection View

- (void)hideProductFeatureTermsViewAnimated:(BOOL) bAnimated
{
    if(!bExpandedProductFeatureTermsView)
        return;
    
    if (bAnimated)
    {
        [self.view layoutIfNeeded];

        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {

                             [self.productFeatureTermsView setAlpha:0.85];
                             self.productFeatureTermsViewBottomSpaceConstraint.constant -= 150;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                             //[self.productFeatureTermsView setHidden:YES];
                             bExpandedProductFeatureTermsView = NO;
                         }];
    }
    else
    {
        [self.productFeatureTermsView setHidden:YES];
        bExpandedProductFeatureTermsView = NO;
        [self.productFeatureTermsView setAlpha:0.85];
        self.productFeatureTermsViewBottomSpaceConstraint.constant -= 150;
    }
}

- (void)showProductFeatureTermsViewAnimated:(BOOL) bAnimated
{
    if(bExpandedProductFeatureTermsView)
        return;

    if (bAnimated)
    {
        [self.productFeatureTermsView setHidden:NO];
        bExpandedProductFeatureTermsView = YES;

        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {

                             [self.productFeatureTermsView setAlpha:1.00];
                             self.productFeatureTermsViewBottomSpaceConstraint.constant += 150;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    else
    {
        [self.productFeatureTermsView setAlpha:1.00];
        self.productFeatureTermsViewBottomSpaceConstraint.constant += 150;
        [self.productFeatureTermsView setHidden:NO];
        bExpandedProductFeatureTermsView = YES;
    }
}

// Initilize the Fetched Results Controller and the Collection View to manage and show the product feature terms
-(void)initProductFeatureTermsCollectionView
{
    [_productFeatureTermsView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.95]];
    
    // Init collection views cell types
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"FeatureCell", nil]];

    // Setup Fetched Results Controller
    [self initFetchedResultsControllerForCollectionViewWithCellType:@"FeatureCell" WithEntity:@"Feature" andPredicate:@"idFeature IN %@" inArray:_featureTermsList sortingWithKeys:[NSArray arrayWithObject:@"name"] ascending:YES andSectionWithKeyPath:nil];
    
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
    if ([cellType isEqualToString:@"FeatureCell"])
    {
        if(!([self getFetchedResultsControllerForCellType:cellType] == nil))
        {
            return [[[self getFetchedResultsControllerForCellType:cellType] fetchedObjects] count];
        }
        
        return 0;
    }
    
    return 0;
}

// OVERRIDE: Return the size of the image to be shown in a cell for a collection view
- (CGSize)getSizeForImageInCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(0, 0);
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"FeatureCell"])
    {
        Feature *tmpFeature = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
        
        NSString *image = @"no_image.png";
        
        if (tmpFeature.icon != nil)
        {
            if (![tmpFeature.icon isEqualToString:@""])
            {
                image = tmpFeature.icon;
            }
        }
        
        UIColor *featureLabelColor = [UIColor colorWithRed:(234/255.0) green:(234/255.0) blue:(234/255.0) alpha:1.0f];
        
        if([_selectedSearchTerms containsObject:tmpFeature.name])
        {
            featureLabelColor = [UIColor colorWithRed:(244/255.0) green:(206/255.0) blue:(118/255.0) alpha:1.0f];
        }
        else if([_shownProductFeatureTerms containsObject:tmpFeature.name])
        {
            featureLabelColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0f];
        }
        
        return [NSArray arrayWithObjects: image, tmpFeature.name, featureLabelColor, nil];
    }
    
    return nil;
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if(![[self activityIndicator] isHidden])
        return;

    if ([cellType isEqualToString:@"FeatureCell"])
    {
        Feature *tmpFeature = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];

        NSLog(@"Selected feature: %@", tmpFeature.name);
        
        // If feature is already selected, remove from the array
        if([_selectedSearchTerms containsObject:tmpFeature.name])
        {
            [_selectedSearchTerms removeObjectsInArray:[NSArray arrayWithObjects:tmpFeature.name, nil]];
            
            [self removeFromSearchTermsListViewButton:tmpFeature.name];

            [self updateCollectionViewWithCellType:cellType fromItem:0 toItem:-1 deleting:NO];
            
        }
        //Otherwise, insert into the array
        else
        {
            [_selectedSearchTerms addObject:tmpFeature.name];
            
            [self addToSearchTermsListViewButton:tmpFeature.name];
            
            [self updateCollectionViewWithCellType:cellType fromItem:0 toItem:-1 deleting:NO];
        }
    }
}


#pragma mark - Requests


// Get product features
- (void)getFeaturesForProductId:(Product *)product
{
    // Check that there's actually a product to search its features
    if (!(product == nil))
    {
        if (!(product.idProduct == nil))
        {
            if (!([product.idProduct isEqualToString:@""]))
            {
                [_selectedSearchTerms removeAllObjects];

                [_shownProductFeatureTerms removeAllObjects];
                
                [_productFeaturesList removeAllObjects];
                
                NSLog(@"Getting features for product: %@", product.idProduct);
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFEATURES_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:product, nil];
                
                [self performRestGet:GET_PRODUCT_FEATURES withParamaters:requestParameters];
            }
        }
    }
}

// Get terms for a given feature group
- (void)getTermsForFeatureGroupId:(NSString *)featureGroupId
{
    // Check that there's actually a product to search its features
    if (!(featureGroupId == nil))
    {
        if(!([featureGroupId isEqualToString:@""]))
        {
            NSLog(@"Getting terms for feature group: %@", featureGroupId);
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGPROPERTIES_ACTV_MSG_", nil)];
            
            // To indicate to the Rest Services Manager that in this GET_FEATUREGROUP_FEATURES request we want DO to message user about the result
            BOOL bVerbose = YES;
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:featureGroupId, [NSNumber numberWithBool:bVerbose], nil];
            
            [self performRestGet:GET_FEATUREGROUP_FEATURES withParamaters:requestParameters];
        }
    }
}

// Perform search
- (void)performSearch
{
    //Setup search string
    
    NSString * stringToSearch = [self composeStringhWithTermsOfArray:_selectedSearchTerms encoding:YES];
    
    // Check that the final string to search is valid
    if (((stringToSearch == nil) || ([stringToSearch isEqualToString:@""])))
    {
        /*
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_NO_SEARCH_KEYWORDS_", nil) message:NSLocalizedString(@"_NO_SEARCH_KEYWORDS_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
         */
        
        return;
    }
    else
    {
        NSLog(@"Performing search with terms: %@", stringToSearch);
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
        
        NSArray * requestParameters = [NSArray arrayWithObject:stringToSearch];
        
        [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS withParamaters:requestParameters];
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    __block SearchQuery *searchQuery;
    
    NSMutableArray *foundResults = [[NSMutableArray alloc] init];
    NSMutableArray *foundResultsGroups = [[NSMutableArray alloc] init];
    __block NSString * notSuccessfulTerms = @"";
    NSMutableArray *successfulTerms = nil;

    switch (connection)
    {
        case GET_FEATUREGROUP_FEATURES:
        {
            if (!([self getFetchedResultsControllerForCellType:@"FeatureCell"] == nil))
            {
                int feauresBeforeUpdate = (int) [[[self getFetchedResultsControllerForCellType:@"FeatureCell"] fetchedObjects] count];
                
                // Empty old features array
                [_featureTermsList removeAllObjects];
                
                // Update Fetched Results Controller
                [self performFetchForCollectionViewWithCellType:@"FeatureCell"];
                
                // Update collection view
                [self updateCollectionViewWithCellType:@"FeatureCell" fromItem:0 toItem:feauresBeforeUpdate deleting:TRUE];
                
                // Free fetched results controller and its request
                self.mainFetchedResultsController = nil;
                self.mainFetchRequest = nil;
            }
            
            [_featureTermsList removeAllObjects];
            
            // Get the list of properties that were provided
            for (Feature *feature in mappingResult)
            {
                if([feature isKindOfClass:[feature class]])
                {
                    if(!(feature.name == nil))
                    {
                        if (!([feature.name isEqualToString:@""]))
                        {
                            if (!([_featureTermsList containsObject:feature.idFeature]))
                            {
                                [_featureTermsList addObject:feature.idFeature];
                            }
                        }
                    }
                }
            }
            
            if([self initFetchedResultsControllerForCollectionViewWithCellType:@"FeatureCell" WithEntity:@"Feature" andPredicate:@"idFeature IN %@" inArray:_featureTermsList sortingWithKeys:[NSArray arrayWithObject:@"name"] ascending:YES andSectionWithKeyPath:nil])
            {
                // Update collection view
                [self updateCollectionViewWithCellType:@"FeatureCell" fromItem:0 toItem:(int)[[[self getFetchedResultsControllerForCellType:@"FeatureCell"] fetchedObjects] count] deleting:FALSE];
            }
            else
            {
                /*
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_PROPERTIES_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                 */
            }
            
            [self stopActivityFeedback];
            
            [self showProductFeatureTermsViewAnimated:YES];
            
            break;
        }
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            

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
            
            if (searchQuery.numresults > 0)
            {
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if (!([group.idResultsGroup isEqualToString:@""]))
                            {
                                if(!([foundResultsGroups containsObject:group]))
                                {
                                    [foundResultsGroups addObject:group];
                                }
                            }
                        }
                    }
                }

                // Get the list of results that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.idGSBaseElement == nil))
                        {
                            if (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([foundResults containsObject:result.idGSBaseElement]))
                                {
                                    [foundResults addObject:result.idGSBaseElement];
                                }
                            }
                        }
                    }
                }
                
                // Get the keywords that provided results
                for (Keyword *keyword in mappingResult)
                {
                    if([keyword isKindOfClass:[Keyword class]])
                    {
                        if (successfulTerms == nil)
                        {
                            successfulTerms = [[NSMutableArray alloc] init];
                        }
                        
                        if(!(keyword.name == nil))
                        {
                            if (!([keyword.name isEqualToString:@""]))
                            {
                                NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                                pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                                if (!([successfulTerms containsObject:pene]))
                                {
                                    // Add the term to the set of terms
                                    [successfulTerms addObject:pene];
                                }
                            }
                        }
                        
                    }
                }
                
                // Paramters for next VC (ResultsViewController)
                NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, successfulTerms, notSuccessfulTerms, nil];
                
                [self stopActivityFeedback];
                
                if ([foundResults count] > 0)
                {
                    [self transitionToViewController:SEARCH_VC withParameters:parametersForNextVC];
                }
                else
                {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    
                }
            }
            else
            {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
                
            }

            break;
        }
        case GET_PRODUCT_FEATURES:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Feature class]]))
                 {
                     if(!([(Feature*)(obj) name] == nil))
                     {
                         if (!([[(Feature*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_selectedSearchTerms containsObject:[(Feature*)(obj) name]]))
                             {
                                 [_selectedSearchTerms addObject:[(Feature*)(obj) name]];
                                 [_shownProductFeatureTerms addObject:[(Feature*)(obj) name]];
                             }
                         }
                     }
                 }
             }];

            // Now, request the product group
            if (!(mappingResult == nil))
            {
                if ([mappingResult count] > 0)
                {
                    Product * product = ((Product *)([mappingResult objectAtIndex:0]));
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:product, nil];
                    
                    [self performRestGet:GET_PRODUCT_GROUP withParamaters:requestParameters];
                    
                    return;
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT_GROUP:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[ProductGroup class]]))
                 {
                     if(!([(ProductGroup*)(obj) name] == nil))
                     {
                         if (!([[(ProductGroup*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_selectedSearchTerms containsObject:[(ProductGroup*)(obj) name]]))
                             {
                                 [_selectedSearchTerms addObject:[(ProductGroup*)(obj) name]];
                                 [_shownProductFeatureTerms addObject:[(ProductGroup*)(obj) name]];
                             }
                             
                             // Now, request the group features

                             NSMutableArray * requestParameters;
                             
                             if (!(mappingResult == nil))
                             {
                                 if ([mappingResult count] > 0)
                                 {
                                     Product * product = ((Product *)([mappingResult objectAtIndex:0]));
                                     
                                     requestParameters = [[NSMutableArray alloc] initWithObjects:product, nil];
                                 }
                             }
                             
                             if(requestParameters == nil)
                             {
                                 requestParameters = [[NSMutableArray alloc] init];
                             }
                             
                             [requestParameters addObject:(ProductGroup*)(obj)];
                             
                             [self performRestGet:GET_PRODUCTGROUP_FEATURES withParamaters:requestParameters];
                             
                             return;
                         }
                     }
                 }
             }];
            
            [self stopActivityFeedback];

            break;
        }
        case GET_PRODUCTGROUP_FEATURES:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[FeatureGroupOrderProductGroup class]]))
                 {
                     FeatureGroup * fg = ((FeatureGroupOrderProductGroup *)(obj)).featureGroup;
                     
                     if(!([fg name] == nil))
                     {
                         if (!([[fg name] isEqualToString:@""]))
                         {
                             if (!([_productFeaturesList containsObject:[fg name]]))
                             {
                                 [_productFeaturesList addObject:fg];
                             }
                         }
                     }
                 }
                 else if (([obj isKindOfClass:[FeatureGroup class]]))
                 {
                     if(!([(FeatureGroup*)(obj) name] == nil))
                     {
                         if (!([[(FeatureGroup*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_productFeaturesList containsObject:[(FeatureGroup*)(obj) name]]))
                             {
                                 [_productFeaturesList addObject:(FeatureGroup*)(obj)];
                             }
                         }
                     }
                 }
             }];
            
            //Set 'gender' at the begginning of the array
            for (int i = 0; i < [_productFeaturesList count]; i++)
            {
                FeatureGroup * fg = (FeatureGroup *)[_productFeaturesList objectAtIndex:i];
                
                if([[[fg.name lowercaseString] capitalizedString] isEqualToString:[[@"Gender" lowercaseString] capitalizedString]])
                {
                    [_productFeaturesList removeObjectAtIndex:i];
                    [_productFeaturesList insertObject:fg atIndex:0];
                    
                    [self stopActivityFeedback];

                    break;
                }
            }
            
            // Now, request the product brand
            
            if(!(mappingResult == nil))
            {
                if([mappingResult count] > 0)
                {
                    NSString * product = (NSString *)([(Product*)([mappingResult objectAtIndex:0]) idProduct]);
                    
                    [self performRestGet:GET_PRODUCT_BRAND withParamaters:[NSArray arrayWithObject:product]];
                    
                    break;
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT_BRAND:
        {
            // Get the list of features that were provided, as well as the brand and the product group
            // Then, check if the mapping contains the expected information
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Brand class]]))
                 {
                     if(!([(Brand*)(obj) name] == nil))
                     {
                         if (!([[(Brand*)(obj) name] isEqualToString:@""]))
                         {
                             if (!([_selectedSearchTerms containsObject:[(Brand*)(obj) name]]))
                             {
                                 [_selectedSearchTerms addObject:[(Brand*)(obj) name]];
                                 [_shownProductFeatureTerms addObject:[(Brand*)(obj) name]];
                             }
                         }
                     }
                 }
             }];
            
            // Init all interface elements
            
            // Check if there are results
            if(!([_shownProductFeatureTerms count] > 0))
            {
                // There were no results!
                [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_NO_TERMS_ERROR_MSG_", nil)];
            }
            else
            {
                // There were results!
                [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_SELECTTERMS_MSG_", nil)];
            }
            
            [self initSearchTermsListView];
            
            [self initSuggestedFiltersRibbonView];
            
            [self stopActivityFeedback];
            
//            if (!([_productFeaturesList count] > 0))
//            {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_GROUPFEATURES_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
//                
//                [alertView show];
//            }
            
            break;
        }
            
        default:
            
            break;
    }
}

// OVERRIDE: Rest answer not reached, to control if the answer fails when getting similar products
- (void)processRestConnection: (connectionType)connection WithErrorMessage:(NSArray*)errorMessage forOperation:(RKObjectRequestOperation *)operation
{
    switch (connection)
    {
        case GET_PRODUCT_FEATURES:
        {
            // Check that there's actually a product to search its features
            if (!(_shownProduct == nil))
            {
                if (!(_shownProduct.idProduct == nil))
                {
                    if (!([_shownProduct.idProduct isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownProduct, nil];
                        
                        [self performRestGet:GET_PRODUCT_GROUP withParamaters:requestParameters];
                        
                        return;
                    }
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT_GROUP:
        {
            // Check that there's actually a product to search its features
            if (!(_shownProduct == nil))
            {
                if (!(_shownProduct.idProduct == nil))
                {
                    if (!([_shownProduct.idProduct isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_shownProduct, nil];
                        
                        [self performRestGet:GET_PRODUCT_BRAND withParamaters:requestParameters];
                        
                        return;
                    }
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_PRODUCT_BRAND:
        {
            // Init all interface elements
            
            // Check if there are results
            if(!([_shownProductFeatureTerms count] > 0))
            {
                // There were no results!
                [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_NO_TERMS_ERROR_MSG_", nil)];
            }
            else
            {
                // There were results!
                [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_SELECTTERMS_MSG_", nil)];
            }
            
            [self initSearchTermsListView];
            
            [self initSuggestedFiltersRibbonView];
            
            [self stopActivityFeedback];
            
            if (!([_productFeaturesList count] > 0))
            {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_GROUPFEATURES_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
//                
//                [alertView show];
            }
            
            break;
        }
        default:
            
            [super processRestConnection:connection WithErrorMessage:errorMessage forOperation:operation];
            
            break;
    }
}


#pragma mark - User interaction
/*
// Right action
- (void)rightAction:(UIButton *)sender
{
    // If not overriden, default action is 'Search'
    
    [self performSearch];
}
*/
// Action to perform when user swipes down: hide the view
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
            if(widthPercentage > kMinPanGestureLenght)
            {
                [self swipeRightAction];
            }
        }
        
        // Perform the transition when swipe left
        if (velocity.x < 0)
        {
            if(widthPercentage > kMinPanGestureLenght)
            {
                [self swipeLeftAction];
            }
        }
        
        // Show the advanced search when swipe up
        if (velocity.y < 0)
        {
            if(heightPercentage > kMinPanGestureLenght)
            {
                [self showProductFeatureTermsViewAnimated:YES];
            }
        }
        
        // Hide the productFeatureTermsView search when swipe down
        if (velocity.y > 0)
        {
            if(heightPercentage > kMinPanGestureLenght)
            {
                [self hideProductFeatureTermsViewAnimated:YES];
            }
        }
    }
}

// Initialize gesture recognizer in productFeatureTermsView

- (void)initGestureRecognizer
{
    // Create the gesture recognizer and set its target method.
    UIPanGestureRecognizer * swipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    
    [self.view addGestureRecognizer:swipeRecognizer];
}


@end
