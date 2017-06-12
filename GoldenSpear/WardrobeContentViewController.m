//
//  WardrobeContentViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 04/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "WardrobeContentViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+UserManagement.h"
#import "ProductSheetViewController.h"
#import "AddItemToWardrobeViewController.h"
#import "NSDate+Localtime.h"

@interface WardrobeContentViewController ()

@end

NSMutableArray * wItemsID;
NSString * _selectedItemId = nil;


@implementation WardrobeContentViewController {
    NSMutableArray *userWardrobesElements;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    
    // Init collection views cell types
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"WardrobeContentCell", nil]];
    
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:nil];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    [backgroundImageView setAlpha:0.20];
    [backgroundImageView setImage:[UIImage imageNamed:@"Splash_Background.png"]];
    [self.mainCollectionView setBackgroundView:backgroundImageView];

    wItemsID = [[NSMutableArray alloc] initWithArray:_shownWardrobe.itemsId];
    
    // Check if there are results
    if(![self initFetchedResultsControllerForCollectionViewWithCellType:@"WardrobeContentCell" WithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:wItemsID sortingWithKeys:[NSArray arrayWithObject:@"idGSBaseElement"] ascending:YES andSectionWithKeyPath:nil])
    {
        // There were no results!
        [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_NO_ITEMS_MSG_", nil)];
        return;
    }
    else
    {
        if(!([[self.mainFetchedResultsController fetchedObjects] count] > 0))
        {
            // There were no results!
            [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_NO_ITEMS_MSG_", nil)];
            return;
        }
        else
        {
            if ([[self.mainFetchedResultsController fetchedObjects] count] > 1)
            {
                // There were results!
                [self setTopBarTitle:nil andSubtitle:[NSString stringWithFormat:NSLocalizedString(@"_NUM_ITEMS_", nil), _shownWardrobe.name, [[self.mainFetchedResultsController fetchedObjects] count]]];
            }
            else
            {
                // There were results!
                [self setTopBarTitle:nil andSubtitle:[NSString stringWithFormat:NSLocalizedString(@"_NUM_ITEM_", nil), _shownWardrobe.name, [[self.mainFetchedResultsController fetchedObjects] count]]];
            }
            
            [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];

            // Setup Collection View
            [self initCollectionViewsLayout];
        }
    }
    
    // Get the current user
    User * currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
    
    
    if (!(currentUser == nil))
    {
        if(!(currentUser.idUser == nil))
        {
            if(!([currentUser.idUser isEqualToString:@""]))
            {
                if (!(_shownWardrobe == nil))
                {
                    if(!(_shownWardrobe.userId == nil))
                    {
                        if(!([_shownWardrobe.userId isEqualToString:@""]))
                        {
                            if([currentUser.idUser isEqualToString:_shownWardrobe.userId])
                            {
                                if(_bEditionMode)
                                {
                                    
                                }
                                else
                                {
                                }
                            }
                            else
                            {
                            }
                        }
                    }
                }
            }
        }
    }
    
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

    if ([_shownWardrobe.userId isEqualToString:appDelegate.currentUser.idUser]) {
        
    }
    else {
        [self createWardrobeButton];
    }

    // statistics only if there is a wardrobe to load
    // send to backend that the wardrobe has been shown
    [self uploadWardrobeView];
}

- (BOOL)shouldCreateMenuButton {
    return NO;
}

// Check if the current view controller must show the bottom buttons
- (BOOL)shouldCreateBottomButtons
{
    User * currentUser = [((AppDelegate *)([[UIApplication sharedApplication] delegate])) currentUser];
    
    if (!(currentUser == nil))
    {
        if(!(currentUser.idUser == nil))
        {
            if(!([currentUser.idUser isEqualToString:@""]))
            {
                if (!(_shownWardrobe == nil))
                {
                    if(!(_shownWardrobe.userId == nil))
                    {
                        if(!([_shownWardrobe.userId isEqualToString:@""]))
                        {
                            if([currentUser.idUser isEqualToString:_shownWardrobe.userId])
                            {
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void)updateSubtitle
{
    if(!([[self.mainFetchedResultsController fetchedObjects] count] > 0))
    {
        // There were no results!
        [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_NO_ITEMS_MSG_", nil)];
        
        [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:[UIImage imageNamed:@"Splash_Background.png"]];
    }
    else
    {
        if ([[self.mainFetchedResultsController fetchedObjects] count] > 1)
        {
            // There were results!
            [self setTopBarTitle:nil andSubtitle:[NSString stringWithFormat:NSLocalizedString(@"_NUM_ITEMS_", nil), _shownWardrobe.name, [[self.mainFetchedResultsController fetchedObjects] count]]];
        }
        else
        {
            // There were results!
            [self setTopBarTitle:nil andSubtitle:[NSString stringWithFormat:NSLocalizedString(@"_NUM_ITEM_", nil), _shownWardrobe.name, [[self.mainFetchedResultsController fetchedObjects] count]]];
        }
        
        [((UIImageView *)([self.mainCollectionView backgroundView])) setImage:nil];
    }
}

// OVERRIDE: Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        return [[[self getFetchedResultsControllerForCellType:cellType] sections] count];
    }
    
    return 1;
}

// OVERRIDE: Return the layout to be shown in a cell for a collection view
- (resultCellLayout)getLayoutTypeForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        GSBaseElement *tmpResult = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
        
        // Check that the element to search is valid
        
        if (!(tmpResult == nil))
        {
            if(!(tmpResult.productId == nil))
            {
                if(!([tmpResult.productId isEqualToString:@""]))
                {
                    return PRODUCTLAYOUT;
                }
            }
//            else if(!(tmpResult.articleId == nil))
//            {
//                if(!([tmpResult.articleId isEqualToString:@""]))
//                {
//                    return ARTICLELAYOUT;
//                }
//            }
//            else if(!(tmpResult.tutorialId == nil))
//            {
//                if(!([tmpResult.tutorialId isEqualToString:@""]))
//                {
//                    return TUTORIALLAYOUT;
//                }
//            }
//            else if(!(tmpResult.reviewId == nil))
//            {
//                if(!([tmpResult.reviewId isEqualToString:@""]))
//                {
//                    return REVIEWLAYOUT;
//                }
//            }
            else if(!(tmpResult.fashionistaPostId == nil))
            {
                if(!([tmpResult.fashionistaPostId isEqualToString:@""]))
                {
                    return POSTLAYOUT;
                }
            }
            else if(!(tmpResult.fashionistaPageId == nil))
            {
                if(!([tmpResult.fashionistaPageId isEqualToString:@""]))
                {
                    return PAGELAYOUT;
                }
            }
            else if(!(tmpResult.wardrobeId == nil))
            {
                if(!([tmpResult.wardrobeId isEqualToString:@""]))
                {
                    return WARDROBELAYOUT;
                }
            }
            else if(!(tmpResult.wardrobeQueryId == nil))
            {
                if(!([tmpResult.wardrobeQueryId isEqualToString:@""]))
                {
                    return WARDROBELAYOUT;
                }
            }
            else if(!(tmpResult.fashionistaId == nil))
            {
                if(!([tmpResult.fashionistaId isEqualToString:@""]))
                {
                    return STYLISTLAYOUT;
                }
            }
        }
    }
    
    return PRODUCTLAYOUT;
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
    if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        return [[[self getFetchedResultsControllerForCellType:cellType] sections][section] numberOfObjects];
    }
    
    return 0;
}

// OVERRIDE: Return the size of the image to be shown in a cell for a collection view
- (CGSize)getSizeForImageInCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        GSBaseElement *tmpItem = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
        
        return CGSizeMake([tmpItem.preview_image_width intValue], [tmpItem.preview_image_height intValue]);
    }
    
    return CGSizeMake(0, 0);
}

// Get number of images from the codificated string
- (NSNumber *) getImagesNumFromString:(NSString*)infoString
{
    // infoString: "XX XX XX"
    
    NSArray* values = [[infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString: @" "];
    
    if(!(values == nil))
    {
        if([values count] > 0)
        {
            if(!([values objectAtIndex:0] == nil))
            {
                if([[values objectAtIndex:0] isKindOfClass:[NSString class]])
                {
                    if(!([[values objectAtIndex:0] isEqualToString:@""]))
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        
                        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSNumber *imagesNum = [numberFormatter numberFromString:[values objectAtIndex:0]];
                        
                        return ((imagesNum > 0) ? (imagesNum) : ([NSNumber numberWithInt:0]));
                    }
                }
            }
        }
    }
    
    return nil;
}

// Get number of likes from the codificated string
- (NSNumber *) getLikesNumFromString:(NSString*)infoString
{
    // infoString: "XX XX XX"
    
    NSArray* values = [[infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString: @" "];
    
    if(!(values == nil))
    {
        if([values count] > 1)
        {
            if(!([values objectAtIndex:1] == nil))
            {
                if([[values objectAtIndex:1] isKindOfClass:[NSString class]])
                {
                    if(!([[values objectAtIndex:1] isEqualToString:@""]))
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        
                        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSNumber *likesNum = [numberFormatter numberFromString:[values objectAtIndex:1]];
                        
                        return ((likesNum > 0) ? (likesNum) : ([NSNumber numberWithInt:0]));
                    }
                }
            }
        }
    }
    
    return nil;
}

// Get number of comments from the codificated string
- (NSNumber *) getCommentsNumFromString:(NSString*)infoString
{
    // infoString: "XX XX XX"
    
    NSArray* values = [[infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString: @" "];
    
    if(!(values == nil))
    {
        if([values count] > 2)
        {
            if(!([values objectAtIndex:2] == nil))
            {
                if([[values objectAtIndex:2] isKindOfClass:[NSString class]])
                {
                    if(!([[values objectAtIndex:2] isEqualToString:@""]))
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        
                        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                        
                        NSNumber *commentsNum = [numberFormatter numberFromString:[values objectAtIndex:2]];
                        
                        return ((commentsNum > 0) ? (commentsNum) : ([NSNumber numberWithInt:0]));
                    }
                }
            }
        }
    }
    
    return nil;
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        GSBaseElement *tmpItem = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
        
        NSString * cellTitle = [NSString stringWithFormat:@"%@", tmpItem.name];
        
        NSNumber * imagesNum = nil;
        NSNumber * likesNum = nil;
        NSNumber * commentsNum = nil;
        
        resultCellLayout layout = [self getLayoutTypeForCellWithType:cellType AtIndexPath:indexPath];
        
        if(!((layout == WARDROBELAYOUT) || (layout == STYLISTLAYOUT)))
        {
            if(!((tmpItem.mainInformation == nil) || ([tmpItem.mainInformation isEqualToString:@""])))
            {
                cellTitle = (((layout == PRODUCTLAYOUT)) ? ([NSString stringWithFormat:@"%@\n%@", tmpItem.mainInformation, tmpItem.name]) : ([NSString stringWithFormat:NSLocalizedString(@"_AUTHOR_AND_TITLE_", nil), tmpItem.mainInformation, ((tmpItem.name == nil) ? (@"") : (tmpItem.name))]));;
            }
        }
        
        if(layout == POSTLAYOUT)
        {
            imagesNum = [self getImagesNumFromString:tmpItem.name];
            likesNum = [self getLikesNumFromString:tmpItem.name];
            commentsNum = [self getCommentsNumFromString:tmpItem.name];
        }
        
        int iMode = 1;
        
        if(_bEditionMode)
            iMode = 0;
        
        NSArray * cellContent = [NSArray arrayWithObjects:tmpItem.preview_image,
                                 [NSNumber numberWithBool:NO],
                                [NSNumber numberWithBool:YES],
                                 cellTitle,
                                 ((!(layout == PRODUCTLAYOUT)) ? ((layout == WARDROBELAYOUT) ? (tmpItem.mainInformation) : (tmpItem.additionalInformation)) : (((tmpItem.additionalInformation == nil) || ([tmpItem.additionalInformation isEqualToString:@""])) ? (NSLocalizedString(@"_PASTCOLLECTIONPRODUCT_", nil)) : (([tmpItem.recommendedPrice floatValue] > 0) ? ([NSString stringWithFormat:@"$%.2f", [tmpItem.recommendedPrice floatValue]]) : (NSLocalizedString(@"_PRICE_NOT_AVAILABLE_", nil))))),
                                 [NSNumber numberWithInt:iMode],
                                 imagesNum,
                                 likesNum,
                                 commentsNum,
                                 nil];
        
        return cellContent;
    }
    
    return nil;
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if(!([_moveItemVCContainerView isHidden]))
    {
        return;
    }

    if ([cellType isEqualToString:@"WardrobeContentCell"])
    {
        _selectedItem = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
        
        // Perform request to get its properties from GS server
        [self getContentsForElement:_selectedItem];
    }
}

// Action to perform if the user press the 'View' button on a WardrobeContentCell
- (void)onTapView:(UIButton *)sender
{
    if(!([_moveItemVCContainerView isHidden]))
    {
        return;
    }

    _selectedItem = [[self getFetchedResultsControllerForCellType:@"WardrobeContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    
    // Perform request to get its properties from GS server
    [self getContentsForElement:_selectedItem];
}

// Action to perform if the user press the 'Delete' button on a WardrobeContentCell
- (void)onTapDelete:(UIButton *)sender
{
    if(!([_moveItemVCContainerView isHidden]))
    {
        return;
    }

    _selectedItem = [[self getFetchedResultsControllerForCellType:@"WardrobeContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    _selectedItemId = _selectedItem.idGSBaseElement;

    // TODO: Ojo! Cambio el alertview por la accion dura de la realidad
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEITEMS_", nil) message:NSLocalizedString(@"_REMOVEITEMSFROMWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
    
    [alertView show];
     */
    
    if (_selectedItem != nil)
    {
        [self deleteSelectedItemsFromWardrobeWithID:_shownWardrobe.idWardrobe];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
    {
        if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEITEMS_", nil)])
        {
            if (_selectedItem != nil)
            {
                [self deleteSelectedItemsFromWardrobeWithID:_shownWardrobe.idWardrobe];
            }
        }
    }
}

// Action to perform if the user press the 'Move' button on a WardrobeContentCell
- (void)onTapMoveWardrobeElement:(UIButton *)sender
{
    _selectedItem = [[self getFetchedResultsControllerForCellType:@"WardrobeContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];

    _selectedItemId = _selectedItem.idGSBaseElement;
    
    // Instantiate the 'AddItemToWardrobe' view controller within the container view
    
    if(!(_selectedItem == nil))
    {
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
                [addItemToWardrobeVC setItemToAdd:_selectedItem];
                
                [addItemToWardrobeVC setButtonToHighlight:nil];
                
                [self addChildViewController:addItemToWardrobeVC];
                
                //[addItemToWardrobeVC willMoveToParentViewController:self];
                
                addItemToWardrobeVC.view.frame = CGRectMake(0,0,_moveItemVCContainerView.frame.size.width, _moveItemVCContainerView.frame.size.height);
                
                [_moveItemVCContainerView addSubview:addItemToWardrobeVC.view];
                
                [addItemToWardrobeVC didMoveToParentViewController:self];
                
                [_moveItemVCContainerView setHidden:NO];
                
                [_moveItemBackgroundView setHidden:NO];
                
                [self.view bringSubviewToFront:_moveItemBackgroundView];
                
                [self.view bringSubviewToFront:_moveItemVCContainerView];
            }
        }
    }
}

- (void)closeMovingItemHighlightingButton:(UIButton *)button withSuccess:(BOOL)bSuccess
{
    if (bSuccess)
    {
        if (_selectedItem != nil)
        {
            [self deleteSelectedItemsFromWardrobeWithID:_shownWardrobe.idWardrobe];
        }
    }
    else
    {
        _selectedItem = nil;
        _selectedItemId = nil;
        
        int itemsBeforeUpdate = (int) [[self.mainFetchedResultsController fetchedObjects] count];
        
        // Empty old items array
        [wItemsID removeAllObjects];
        
        // Update Fetched Results Controller
        [self performFetchForCollectionViewWithCellType:@"WardrobeContentCell"];
        
        // Update collection view
        [self updateCollectionViewWithCellType:@"WardrobeContentCell" fromItem:0 toItem:itemsBeforeUpdate deleting:TRUE];

        wItemsID = [NSMutableArray arrayWithArray:_shownWardrobe.itemsId];
        
        self.mainFetchedResultsController = nil;
        self.mainFetchRequest = nil;
        
        [self initFetchedResultsControllerForCollectionViewWithCellType:@"WardrobeContentCell" WithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:wItemsID sortingWithKeys:[NSArray arrayWithObject:@"idGSBaseElement"] ascending:YES andSectionWithKeyPath:nil];
        
        // Update collection view
        [self updateCollectionViewWithCellType:@"WardrobeContentCell" fromItem:0 toItem:(int)[[self.mainFetchedResultsController fetchedObjects] count] deleting:FALSE];
        
        [self updateSubtitle];
        
        //[self stopActivityFeedback];
    }

    // Close the child view controller
    
    [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
    
    [[_moveItemVCContainerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [[self.childViewControllers lastObject] removeFromParentViewController];
    
    //[[self.childViewControllers lastObject] didMoveToParentViewController:nil];
    
    [_moveItemVCContainerView setHidden:YES];
    
    [_moveItemBackgroundView setHidden:YES];
}


// OVERRIDE: Just to prevent from being at the 'Add to Wardrobe' view
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([_moveItemVCContainerView isHidden]))
        return;
    
    [super touchesEnded:touches withEvent:event];
    
}

// Add items to wardrobe
- (void)deleteSelectedItemsFromWardrobeWithID:(NSString *)wardrobeID
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    if (!(_selectedItem == nil))
    if (!(_selectedItemId == nil))
    {
        // Check that the string is valid
//        if (!((_selectedItem.idGSBaseElement == nil) || ([_selectedItem.idGSBaseElement isEqualToString:@""])))
        if (!([_selectedItemId isEqualToString:@""]))
        {
            if (!(appDelegate.currentUser == nil))
            {
                NSLog(@"Deleting item %@ from wardrobe %@", _selectedItem.name, wardrobeID);
                
                // Check that the wardrobe is valid
                if (!(wardrobeID == nil))
                {
                    if (!([wardrobeID isEqualToString:@""]))
                    {
                        // Perform request to get the wardrobe contents
                        
                        // Provide feedback to user
                        [self stopActivityFeedback];
                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_REMOVINGITEMFROMWARDROBE_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects: wardrobeID, _selectedItemId, nil];
                        
                        [self performRestDelete:REMOVE_ITEM_FROM_WARDROBE withParamaters:requestParameters];
                    }
                }
            }
        }
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSMutableArray * resultContent = [[NSMutableArray alloc] init];
    NSMutableArray * resultReviews = [[NSMutableArray alloc] init];
    NSArray * parametersForNextVC = nil;
    int itemsBeforeUpdate = 0;
    __block id selectedSpecificResult;
    __block User * postAuthor;
    
    switch (connection)
    {
        case GET_PRODUCT:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Product class]]))
                 {
                     selectedSpecificResult = (Product *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Get the list of reviews that were provided
            for (Review *review in mappingResult)
            {
                if([review isKindOfClass:[Review class]])
                {
                    if(!(review.idReview == nil))
                    {
                        if  (!([review.idReview isEqualToString:@""]))
                        {
                            if(!([resultReviews containsObject:review.idReview]))
                            {
                                [resultReviews addObject:review.idReview];
                            }
                        }
                    }
                }
            }
            
            // Get the list of contents that were provided
            for (Content *content in mappingResult)
            {
                if([content isKindOfClass:[Content class]])
                {
                    if(!(content.idContent == nil))
                    {
                        if  (!([content.idContent isEqualToString:@""]))
                        {
                            if(!([resultContent containsObject:content.idContent]))
                            {
                                [resultContent addObject:content.idContent];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: _selectedItem, selectedSpecificResult, resultContent, resultReviews/*, _currentSearchQuery*/, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:PRODUCTSHEET_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_POST:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[FashionistaPost class]]))
                 {
                     selectedSpecificResult = (FashionistaPost *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Get the list of contents that were provided
            for (FashionistaContent *content in mappingResult)
            {
                if([content isKindOfClass:[FashionistaContent class]])
                {
                    if(!(content.idFashionistaContent == nil))
                    {
                        if  (!([content.idFashionistaContent isEqualToString:@""]))
                        {
//                            if(!([resultContent containsObject:content.idFashionistaContent]))
//                            {
//                                [resultContent addObject:content.idFashionistaContent];
//                            }
                            if(!([resultContent containsObject:content]))
                            {
                                [resultContent addObject:content];
                            }
                        }
                    }
                }
            }
            
            // Get the user who authored the Post
            for (User *user in mappingResult)
            {
                if([user isKindOfClass:[User class]])
                {
                    if(!(user.idUser == nil))
                    {
                        if  (!([user.idUser isEqualToString:@""]))
                        {
                            postAuthor = user;
                        }
                    }
                }
            }

            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: _selectedItem, selectedSpecificResult, resultContent/*, _currentSearchQuery*/, postAuthor, nil];
            
            [self stopActivityFeedback];
            
            
            if((!([parametersForNextVC count] < 2)) && ([resultContent count] > 0))
            {
                [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
            }
            
            break;
        }
        case GET_FASHIONISTA:
        {
            // Get the stylist that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     selectedSpecificResult = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */selectedSpecificResult, [NSNumber numberWithBool:NO]/*, _currentSearchQuery*/, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_PAGE:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[FashionistaPage class]]))
                 {
                     selectedSpecificResult = (FashionistaPage *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects:/* _selectedItem, */selectedSpecificResult/*, _currentSearchQuery*/, nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:FASHIONISTAMAINPAGE_VC withParameters:parametersForNextVC];
            
            break;
        }
        case GET_WARDROBE:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[Wardrobe class]]))
                 {
                     selectedSpecificResult = (Wardrobe *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (GSBaseElement *item in mappingResult)
            {
                if([item isKindOfClass:[GSBaseElement class]])
                {
                    if(!(item.idGSBaseElement== nil))
                    {
                        if(!([item.idGSBaseElement isEqualToString:@""]))
                        {
                            if(((Wardrobe*)selectedSpecificResult).itemsId == nil)
                            {
                                ((Wardrobe*)selectedSpecificResult).itemsId = [[NSMutableArray alloc] init];
                            }
                            
                            if(!([((Wardrobe*)selectedSpecificResult).itemsId containsObject:item.idGSBaseElement]))
                            {
                                [((Wardrobe*)selectedSpecificResult).itemsId addObject:item.idGSBaseElement];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects:((Wardrobe*)selectedSpecificResult), [NSNumber numberWithBool:_bEditionMode], nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:WARDROBECONTENT_VC withParameters:parametersForNextVC];
            
            break;
        }
        case REMOVE_ITEM_FROM_WARDROBE:
        {
            itemsBeforeUpdate = (int) [[self.mainFetchedResultsController fetchedObjects] count];
            
            // Empty old items array
            [wItemsID removeAllObjects];
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"WardrobeContentCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeContentCell" fromItem:0 toItem:itemsBeforeUpdate deleting:TRUE];
            
            if(!(_shownWardrobe.itemsId == nil))
            {
                if([_shownWardrobe.itemsId count] > 0)
                {
                    for (int i = 0; i < [_shownWardrobe.itemsId count]; i++)
                    {
                        NSString * tmpId = [_shownWardrobe.itemsId objectAtIndex:i];
                        
                        if ([_selectedItemId isEqualToString:tmpId])
                        {
                            [_shownWardrobe.itemsId removeObjectAtIndex:i];
                            
                            break;
                        }
                    }
                }
            }
            
            _selectedItem = nil;
            _selectedItemId = nil;
            
            wItemsID = [NSMutableArray arrayWithArray:_shownWardrobe.itemsId];
            
            self.mainFetchedResultsController = nil;
            self.mainFetchRequest = nil;
            
            [self initFetchedResultsControllerForCollectionViewWithCellType:@"WardrobeContentCell" WithEntity:@"GSBaseElement" andPredicate:@"idGSBaseElement IN %@" inArray:wItemsID sortingWithKeys:[NSArray arrayWithObject:@"idGSBaseElement"] ascending:YES andSectionWithKeyPath:nil];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeContentCell" fromItem:0 toItem:(int)[[self.mainFetchedResultsController fetchedObjects] count] deleting:FALSE];
            
            [self updateSubtitle];
            
            [self stopActivityFeedback];
            
            break;
        }
            
        default:
            break;
    }
}


// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Action to perform when user swipes to right: go to previous screen
- (void)swipeRightAction
{
    if(!([self.hintBackgroundView isHidden]))
    {
        [self hintPrevAction:nil];
        
        return;
    }

    if(!([_moveItemVCContainerView isHidden]))
    {
        [self  closeMovingItemHighlightingButton:nil withSuccess:NO];
    }
    else
    {
        [super swipeRightAction];
    }
}
/*
// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Left action
- (void)leftAction:(UIButton *)sender
{
    if(!([_moveItemVCContainerView isHidden]))
    {
        return;
    }
    
    [super leftAction:sender];
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Home action
- (void)homeAction:(UIButton *)sender
{
    if(!([_moveItemVCContainerView isHidden]))
    {
        return;
    }
    
    [super homeAction:sender];
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Long press gesture reconizer
- (void)homeLongPressGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if(!([_moveItemVCContainerView isHidden]))
    {
        return;
    }
    
    [super homeLongPressGestureRecognized:recognizer];
}

// OVERRIDE: (Just to prevent from being at 'AddToWardrobe' dialog) Right action
- (void)rightAction:(UIButton *)sender
{
    if(!([_moveItemVCContainerView isHidden]))
    {
        return;
    }
    
    // Go to edition mode
//    [self stopActivityFeedback];
    _bEditionMode = !_bEditionMode;
    self.mainFetchedResultsController = nil;
    self.mainFetchRequest = nil;
    [self viewDidLoad];
    [self viewWillAppear:NO];
    [self.mainCollectionView reloadData];
    return;
    
    //[super rightAction:sender];
}
*/
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
//    if(!([_moveItemVCContainerView isHidden]))
//    {
//        return;
//    }

    [super actionAfterLogOut];
    return;
}


#pragma mark - Statistics


-(void)uploadWardrobeView
{
    // Check that the name is valid
    
    if (!(self.shownWardrobe.idWardrobe == nil))
    {
        if(!([self.shownWardrobe.idWardrobe isEqualToString:@""]))
        {
            // Post the ProductView object
            
            WardrobeView * newWardrobeView = [[WardrobeView alloc] init];
            
            newWardrobeView.localtime = [NSDate date];
            
            [newWardrobeView setWardrobeId:self.shownWardrobe.idWardrobe];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newWardrobeView setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newWardrobeView setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newWardrobeView setFingerprint:appDelegate.finger.fingerprint];

            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newWardrobeView, nil];
            
            [self performRestPost:ADD_WARDROBEVIEW withParamaters:requestParameters];
        }
    }
}

- (void)onTapAddToWardrobeButton:(UIButton *)sender
{
    GSBaseElement *element;
    if(![[self activityIndicator] isHidden])
        return;
    
    NSInteger index = sender.tag;
    if (index > -1) {
        _selectedItem = [[self getFetchedResultsControllerForCellType:@"WardrobeContentCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        element = _selectedItem;
    }
    else {
        element = _shownElement;
    }
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
                    
                    [addItemToWardrobeVC setButtonToHighlight:sender];
                    
                    [addItemToWardrobeVC setIsAddButton:YES];
                    
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
        else if(!(item.wardrobeQueryId == nil))
        {
            if(!([item.wardrobeQueryId isEqualToString:@""]))
            {
                itemId = item.wardrobeQueryId;
            }
        }
        else if(!(item.styleId == nil))
        {
            if(!([item.styleId isEqualToString:@""]))
            {
                itemId = item.styleId;
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
                        }
                    }
                }
            }
        }
    }
    
    return NO;
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


@end
