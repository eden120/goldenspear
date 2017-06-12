//
//  WardrobeViewController.m
//  GoldenSpear
//
//  Created by JAVIER CASTAN SANCHEZ on 3/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "WardrobeViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "WardrobeContentViewController.h"
#import "UIButton+CustomCreation.h"


#define kWardrobeBinViewHeight 150
#define kWardrobeBinViewShadowOpacity 0.5
#define kWardrobeBinViewShadowRadius 4

@interface WardrobeViewController ()

@end

// To store items selected in the WardrobeBin
NSMutableArray * _selectedItemsInWardrobeBin;
NSMutableArray * _arrayWithUserId;
Wardrobe *_selectedWardrobeToDelete = nil;
Wardrobe *_selectedWardrobeToRename = nil;
Wardrobe *_selectedWardrobe = nil;
float fNewWardrobeNameOriginalConstraint = 10;

@implementation WardrobeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    fNewWardrobeNameOriginalConstraint = self.bottomConstraints.constant;

    // Init collection views cell types
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"WardrobeCell", @"WardrobeBinCell", nil]];

    
    /*AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil)];        
    }
    else
    {
        // Initialize array for items selection
        _selectedItemsInWardrobeBin = nil;
        
        // Show the WardrobeBin view
        _WardrobeBinViewHeightConstraint.constant = 0;

        [self getUserWardrobes];
    }*/
    
    // Set the delegate to the New Wardrobe Name text field
    [self.wardrobeNewName setDelegate:self];

    // Setup the New Wardrobe Name text field appearance
    [self.wardrobeNewName setValue:[UIFont fontWithName: @"Avenir-Medium" size: 18] forKeyPath:@"_placeholderLabel.font"];
    [self.wardrobeNewName setValue:[UIColor blackColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.wardrobeNewName setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [[self.wardrobeNewName layer] setCornerRadius:5.0];
    [[self.wardrobeNewName layer] setBorderWidth:0.5];
    [[self.wardrobeNewName layer] setBorderColor:[UIColor blackColor].CGColor];

//    [self.wardrobeNewName setClipsToBounds:NO];
//    [self.wardrobeNewName.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
//    [self.wardrobeNewName.layer setShadowRadius:5];
//    [self.wardrobeNewName.layer setShadowOpacity:0.7];
    [self.wardrobeNewName setHidden:YES];
    
    // Observe the notification for keyboard appearing/dissappearing in order to properly animate Add Terms text field
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    
    // Insert 'Hide' button at right side
    
    UIButton * hideButton = [UIButton createButtonWithOrigin:CGPointMake(0,4)
                                                     andSize:CGSizeMake(self.wardrobeNewName.frame.size.height-8, self.wardrobeNewName.frame.size.height-8)
                                              andBorderWidth:0.0
                                              andBorderColor:[UIColor clearColor]
                                                     andText:NSLocalizedString(@"_HIDE_BTN_", nil)
                                                     andFont:[UIFont fontWithName:@"Avenir-Light" size:9]
                                                andFontColor:[UIColor lightGrayColor]
                                              andUppercasing:YES
                                                andAlignment:UIControlContentHorizontalAlignmentCenter
                                                    andImage:[UIImage imageNamed:@"close.png"]
                                                andImageMode:UIViewContentModeScaleAspectFit
                                          andBackgroundImage:nil];
    
    // Button action
    [hideButton addTarget:self action:@selector(hideWardrobeNewName) forControlEvents:UIControlEventTouchUpInside];
    
    // Add button to view
    
    [self.wardrobeNewName setRightViewMode:UITextFieldViewModeAlways];
    
    self.wardrobeNewName.rightView = hideButton;
    
    // Setup Collection View
    [self initCollectionViewsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Check if the current view controller must show the bottom buttons
- (BOOL)shouldCreateBottomButtons
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self createBottomControls];
    
    // Observe the notification for keyboard appearing/dissappearing in order to properly animate Add Terms text field
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrameWithNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil)];
    }
    else
    {
        // Initialize array for items selection
        _selectedItemsInWardrobeBin = nil;
        
        // Show the WardrobeBin view
        _WardrobeBinViewHeightConstraint.constant = 0;
        
        [self getUserWardrobes];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - CollectionView overrides


// OVERRIDE: Number of sections for the given collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfSectionsForCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"WardrobeCell"])
    {
        return MAX([[[self getFetchedResultsControllerForCellType:cellType] sections] count], 1);
    }
    else if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
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

// OVERRIDE: Number of items in each section for the main collection view (to be overridden by each sub- view controller)
- (NSInteger)numberOfItemsInSection:(NSInteger)section forCollectionViewWithCellType:(NSString *)cellType
{
    if ([cellType isEqualToString:@"WardrobeCell"])
    {
        int iNum = (int)[[[self getFetchedResultsControllerForCellType:cellType] sections][section] numberOfObjects];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        return iNum+(_bEditionMode && !(appDelegate.currentUser == nil))/*IF wardrobe bin implemented, consider it:-(!(appDelegate.currentUser == nil))*/; // One extra item for "Add wardrobe" option, One less item for the "Wardrobe Bin"
    }
    else if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        return [[[self getFetchedResultsControllerForCellType:cellType] sections][section] numberOfObjects];
    }
    
    return 0;
}

// OVERRIDE: Return the size of the image to be shown in a cell for a collection view
- (CGSize)getSizeForImageInCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        GSBaseElement *tmpItem = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];

        return CGSizeMake([tmpItem.preview_image_width intValue], [tmpItem.preview_image_height intValue]);
    }
    
    return CGSizeMake(0, 0);
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if ([cellType isEqualToString:@"WardrobeCell"])
    {
        int iNum = (int)[[[self getFetchedResultsControllerForCellType:cellType] fetchedObjects] count];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        iNum += (!(appDelegate.currentUser == nil))/*IF wardrobe bin implemented, consider it:-(!(appDelegate.currentUser == nil))*/; // One extra item for "Add wardrobe" option, One less item for the "Wardrobe Bin"
        
        int iIdx = (int)[indexPath indexAtPosition:1];
        
        if( iIdx == 0 && _bEditionMode)
        {
            NSArray * cellContent = [NSArray arrayWithObjects: [NSNumber numberWithInt:0], @"", @"", nil];
            return cellContent;
        }
        else
        {
            int iMode = 1;
            
            if(_selectedItemsInWardrobeBin)
            {
                if([_selectedItemsInWardrobeBin count] > 0)
                {
                    iMode = 2;
                }
            }
            
            if(!_bEditionMode)
                iMode = 3;
            
            int iOffset = 0;
            if(_bEditionMode)
                iOffset = -1;
            
            Wardrobe *tmpWardrobe = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item+iOffset/*IF WardrobeBin implemented, consider it: +1*/ inSection:indexPath.section]];
        
            NSArray * cellContent = [NSArray arrayWithObjects: [NSNumber numberWithInt:iMode], tmpWardrobe.preview_image, tmpWardrobe.name, nil];
        
            return cellContent;
        }
    }
    else if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        GSBaseElement *tmpItem = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
        
        NSArray * cellContent = [NSArray arrayWithObjects: tmpItem.preview_image, tmpItem.name, nil];
        
        return cellContent;
    }

    
    return nil;
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    [self hideWardrobeNewName];
    
    if ([cellType isEqualToString:@"WardrobeCell"])
    {
        //int iNum = (int)[[[self getFetchedResultsControllerForCellType:cellType] fetchedObjects] count];
        
        //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        //iNum += (!(appDelegate.currentUser == nil))/*IF wardrobe bin implemented, consider it:-(!(appDelegate.currentUser == nil))*/; // One extra item for "Add wardrobe" option, One less item for the "Wardrobe Bin"
        
        int iIdx = (int)[indexPath indexAtPosition:1];
        
        if( _bEditionMode && iIdx == 0)
        {
            return;
        }
        else
        {
            int iOffset = 0;
            if(_bEditionMode)
                iOffset = -1;
            
            _selectedWardrobe = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item+iOffset/*IF WardrobeBin implemented, consider it: +1*/ inSection:0]];
            
            // Perform request to get its properties from GS server
            [self getContentsForWardrobe:_selectedWardrobe];
        }
    }
    else if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        if (_selectedItemsInWardrobeBin == nil)
        {
            _selectedItemsInWardrobeBin = [[NSMutableArray alloc] init];
        }

        // Determine the selected items by using the indexPath
        GSBaseElement *tmpItem = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];

        // Add the selected item into the array (if not already there)
        if (!([_selectedItemsInWardrobeBin containsObject: tmpItem.idGSBaseElement]))
        {
            [_selectedItemsInWardrobeBin addObject:tmpItem.idGSBaseElement];
        }
        
        if([_selectedItemsInWardrobeBin count] > 0)
        {
            [self.removeWardrobeBinItemsButton setHidden:NO];
        }
        
        [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:-1 deleting:NO];
    }
}

// OVERRIDE: Action to perform if an item in a collection view is deselected
- (void)actionForDeselectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    [self hideWardrobeNewName];
    
    if ([cellType isEqualToString:@"WardrobeBinCell"])
    {
        if (_selectedItemsInWardrobeBin != nil)
        {
            // Determine the selected items by using the indexPath
            GSBaseElement *tmpItem = [[self getFetchedResultsControllerForCellType:cellType] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]];
            
            for(id itemID in _selectedItemsInWardrobeBin)
            {
                if([itemID isEqualToString:tmpItem.idGSBaseElement])
                {
                    [_selectedItemsInWardrobeBin removeObject:itemID];
                    break;
                }
            }
        }
        
        if(!([_selectedItemsInWardrobeBin count] > 0))
        {
            [self.removeWardrobeBinItemsButton setHidden:YES];
        }
    }
    
    [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:-1 deleting:NO];
}


#pragma mark - Wardrobe actions


- (void)onTapCreateNewElement:(UIButton *)sender
{
    [self hideWardrobeNewName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ADDWARDROBE_", nil) message:NSLocalizedString(@"_ADDWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_ADD_", nil), nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeDefault;
    
    [alertView textFieldAtIndex:0].placeholder = NSLocalizedString(@"_ADDWARDROBENAME_LBL_", nil);
    
    [alertView show];
}

- (void)onTapView:(UIButton *)sender
{
    [self hideWardrobeNewName];
    
    int iOffset = 0;
    if(_bEditionMode)
        iOffset = -1;
    
    _selectedWardrobe = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag+iOffset/*IF WardrobeBin implemented, consider it: +1*/ inSection:0]];
    
    // Perform request to get its properties from GS server
    [self getContentsForWardrobe:_selectedWardrobe];
}

- (void)onTapDelete:(UIButton *)sender
{
    [self hideWardrobeNewName];
    
    int iOffset = 0;
    if(_bEditionMode)
        iOffset = -1;
    
    _selectedWardrobeToDelete = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag+iOffset/*IF WardrobeBin implemented, consider it: +1*/ inSection:0]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEWARDROBE_", nil) message:NSLocalizedString(@"_REMOVEWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
    
    [alertView show];
}

- (void)onTapEditWardrobeTitle:(UIButton *)sender
{
    if(!_bEditionMode)
        return;
    
    if(!([_wardrobeNewName isHidden]))
    {
        return;
    }

    [self showMainMenu:nil];
    
    int iOffset = 0;
    if(_bEditionMode)
        iOffset = -1;
    
    _selectedWardrobeToRename = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag+iOffset/*IF WardrobeBin implemented, consider it: +1*/ inSection:0]];
    
    // Empty New Wardrobe Name text field
    [_wardrobeNewName setText:_selectedWardrobeToRename.name];
    
    if([_wardrobeNewName isHidden])
    {
        self.bottomConstraints.constant = fNewWardrobeNameOriginalConstraint;
    }
    
    // Show New Wardrobe Name text field and set the focus
    [_wardrobeNewName setHidden:NO];
    
    [_wardrobeNewName becomeFirstResponder];
}

// Catch the notification when keyboard appears
- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification
{
    // Calculate vertical increase
    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
    
    // Properly animate Add Terms text box
    [self animateTextViewFrameForVerticalOffset:keyboardVerticalIncrease];
}

// Calculate the vertical increase when keyboard appears
- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification
{
    CGFloat keyboardBeginY = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    
    return keyboardVerticalIncrease;
}

// Animate the Add Terms text box when keyboard appears
- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset
{
    CGFloat constant = self.bottomConstraints.constant;
    
    CGFloat newConstant = constant + offset;// + 50;
    
    /*if (offset < 0)
     {
     newConstant = constant - offset;// - 50;
     }*/
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         
                         self.bottomConstraints.constant = newConstant;
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         //                         if (offset < 0)
                         //                             self.addTermTextBox.hidden = YES;
                     }];
}

// Perform search when user press 'Search'
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (!(self.wardrobeNewName.text == nil))
    {
        if (!([self.wardrobeNewName.text isEqualToString:@""]))
        {
            [self setName:self.wardrobeNewName.text toWardrobeWithId:_selectedWardrobeToRename];
        }
    }
    
    [textField resignFirstResponder];
    
    [textField setHidden:YES];
    
    return YES;
}


- (void)hideWardrobeNewName
{
    [_wardrobeNewName resignFirstResponder];
    
    [_wardrobeNewName setHidden:YES];
}



// OVERRIDE: To hide the New Wardrobe Name when Main Menu is shown
- (void)showMainMenu:(UIButton *)sender
{
    [self hideWardrobeNewName];
    
    [super showMainMenu:sender];
}

// Hide the New Wardrobe Name text field when user scrolls the collection view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Hide Add Terms text field
    [self.view endEditing:YES];
    
    [self hideWardrobeNewName];
}

- (void)onTapAddBinContentToWardrobe:(UIButton *)sender
{
    [self hideWardrobeNewName];
   
    Wardrobe * selectedWardrobe = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag/*IF WardrobeBin implemented, consider it: +1*/ inSection:0]];
    
    [self addItemsToWardrobeWithID:selectedWardrobe.idWardrobe];
}

- (void)onTapRemoveFromWardrobeBin:(UIButton *)sender
{
    [self hideWardrobeNewName];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_REMOVEITEMS_", nil) message:NSLocalizedString(@"_REMOVEITEMSFROMWARDROBEBIN_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_YES_", nil), nil];
    
    [alertView show];
}


#pragma mark - Alert views management


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *title = [alertView buttonTitleAtIndex:1];
    
    if([title isEqualToString:NSLocalizedString(@"_ADD_", nil)])
    {
        if(![[[alertView textFieldAtIndex:0] text] length] >= 1)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"_ADD_", nil)])
    {
        [self createWardrobeWithName: [alertView textFieldAtIndex:0].text];
    }
    else if ([title isEqualToString:NSLocalizedString(@"_CANCEL_", nil)])
    {
        if ([alertView.title isEqualToString:NSLocalizedString(@"_ADDWARDROBE_", nil)])
        {
            if (_selectedItemsInWardrobeBin != nil)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTSELECTWARDROBE_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_CANCEL_", nil) otherButtonTitles:NSLocalizedString(@"_OK_", nil),nil];
                
                [alertView show];
            }
        }
        else if ([alertView.title isEqualToString:NSLocalizedString(@"_INFO_", nil)])
        {
            if (_selectedItemsInWardrobeBin != nil)
            {
                _selectedItemsInWardrobeBin = nil;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ADDITIONTOWARDROBECANCELLED_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }
        }
        else if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEWARDROBE_", nil)])
        {
            if (_selectedWardrobeToDelete != nil)
            {
                _selectedWardrobeToDelete = nil;
            }
        }

    }
    else if ([title isEqualToString:NSLocalizedString(@"_YES_", nil)])
    {
        if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEITEMS_", nil)])
        {
            if (_selectedItemsInWardrobeBin != nil)
            {
                Wardrobe * wardrobeBin = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

                [self deleteSelectedItemsFromWardrobeWithID:wardrobeBin.idWardrobe];
            }
        }
        else if ([alertView.title isEqualToString:NSLocalizedString(@"_REMOVEWARDROBE_", nil)])
        {
            if (_selectedWardrobeToDelete != nil)
            {
                [self deleteWardrobe:_selectedWardrobeToDelete];
            }
        }

    }

}


#pragma mark - Wardrobes requests management


// Request the user wardrobes from the GS server
- (void) getUserWardrobes
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                NSLog(@"Fetching user wardrobes...");
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                [self performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
            }
        }
    }
}

// Perform search to retrieve wardrobe content
- (void)getContentsForWardrobe:(Wardrobe *)wardrobe
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        
        NSLog(@"Getting contents for wardrobe: %@", wardrobe.name);
        
        // Check that the string to search is valid
        
        if (!(wardrobe == nil))
        {
            // Perform request to get the wardrobe contents
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobe.idWardrobe, nil];
            
            [self performRestGet:GET_WARDROBE_CONTENT withParamaters:requestParameters];
        }
    }
}

// Update the name for a wardrobe
-(void)setName:(NSString *)wardrobeName toWardrobeWithId:(Wardrobe *)wardrobe
{
    if ((!(wardrobeName == nil)) && (!(wardrobe == nil)))
    {
        if ((!([wardrobeName isEqualToString:@""])) && (!([wardrobe.idWardrobe isEqualToString:@""])))
        {
            // Perform request to get the wardrobe contents
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPDATINGWARDROBE_MSG_", nil)];
            
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
//            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
//            Wardrobe *newWardrobe = [[Wardrobe alloc] initWithEntity:[NSEntityDescription entityForName:@"Wardrobe" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
            
            [wardrobe setName:wardrobeName];
            
//            [newWardrobe setUserId:appDelegate.currentUser.idUser];
            
            // Encode the wardrobe name string to be used as an URL parameter
            //        wardrobeName = [wardrobeName urlEncodeUsingNSUTF8StringEncoding];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobe.idWardrobe, wardrobe, nil];
            
            [self performRestPost:UPDATE_WARDROBE_NAME withParamaters:requestParameters];
            
        }
    }
}

//Create new wardrobe
-(void)createWardrobeWithName:(NSString *)wardrobeName
{
    NSLog(@"Adding wardrobe: %@", wardrobeName);
    
    // Check that the name is valid
    
    if (!(wardrobeName == nil))
    {
        // Perform request to get the wardrobe contents
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGWARDROBE_MSG_", nil)];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        Wardrobe *newWardrobe = [[Wardrobe alloc] initWithEntity:[NSEntityDescription entityForName:@"Wardrobe" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
        
        [newWardrobe setName:wardrobeName];
        
        [newWardrobe setUserId:appDelegate.currentUser.idUser];
        
        // Encode the wardrobe name string to be used as an URL parameter
        //        wardrobeName = [wardrobeName urlEncodeUsingNSUTF8StringEncoding];
        
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newWardrobe, nil];
        
        [self performRestPost:ADD_WARDROBE withParamaters:requestParameters];
    }
}

// Delete Wardrobe with a given ID
- (void)deleteWardrobe:(Wardrobe *)wardrobe
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        NSLog(@"Deleting wardrobe: %@", wardrobe.name);
        
        // Check that the name is valid
        
        if (!(wardrobe == nil))
        {
            if (!(wardrobe.idWardrobe == nil))
            {
                if (!([wardrobe.idWardrobe isEqualToString:@""]))
                {
                    // Perform request to get the wardrobe contents
                    
                    // Provide feedback to user
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DELETINGWARDROBE_MSG_", nil)];
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobe, nil];
                    
                    [self performRestDelete:DELETE_WARDROBE withParamaters:requestParameters];
                    
                }
            }
        }
    }
}

// Add items to wardrobe
- (void)addItemsToWardrobeWithID:(NSString *)wardrobeID
{
    //Setup items Id string
    
    NSString *itemsIdString = @"";
    
    if (!((_selectedItemsInWardrobeBin == nil) || ([_selectedItemsInWardrobeBin count] < 1)))
    {
        for (NSNumber *idNumber in _selectedItemsInWardrobeBin)
        {
            if([itemsIdString  isEqualToString:@""])
            {
                itemsIdString = [itemsIdString stringByAppendingString:[NSString stringWithFormat:@"%@", [idNumber stringValue]]];
            }
            else
            {
                itemsIdString = [itemsIdString stringByAppendingString:[NSString stringWithFormat:@",%@", [idNumber stringValue]]];
            }
        }
    }
    
    // Check that the string is valid
    if (!((itemsIdString == nil) || ([itemsIdString isEqualToString:@""])))
    {
        // Encode the string
        
        itemsIdString = [itemsIdString urlEncodeUsingNSUTF8StringEncoding];
        
        NSLog(@"Adding items to wardrobe: %@", wardrobeID);
        
        // Perform request to save the item into the wardrobe
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGITEMTOWARDROBE_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeID, itemsIdString, nil];
        
        [self performRestPost:ADD_ITEM_TO_WARDROBE withParamaters:requestParameters];
    }
}


// Add items to wardrobe
- (void)deleteSelectedItemsFromWardrobeWithID:(NSString *)wardrobeID
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!((_selectedItemsInWardrobeBin == nil) || ([_selectedItemsInWardrobeBin count] < 1)))
    {
        for (GSBaseElement * item in _selectedItemsInWardrobeBin)
        {
            // Check that the string is valid
            if (!((item.idGSBaseElement== nil) || ([item.idGSBaseElement isEqualToString:@""])))
            {
                if (!(appDelegate.currentUser == nil))
                {
                    NSLog(@"Deleting item %@ from wardrobe %@", item.name, wardrobeID);
                    
                    // Check that the wardrobe is valid
                    if (!(wardrobeID == nil))
                    {
                        if (!([wardrobeID isEqualToString:@""]))
                        {
                            // Perform request to get the wardrobe contents
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_REMOVINGITEMFROMWARDROBE_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects: wardrobeID, item.idGSBaseElement, nil];
                            
                            [self performRestDelete:REMOVE_ITEM_FROM_WARDROBE withParamaters:requestParameters];
                        }
                    }
                }
            }
        }
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int itemsInWardrobeBinBeforeUpdate = 0;
    
    int itemsInWardrobeBeforeUpdate = 0;
    
    NSArray * parametersForNextVC;
    
    NSManagedObjectContext *currentContext;

    switch (connection)
    {
        case GET_USER_WARDROBES:
        {
            if (![self getFetchedResultsControllerForCellType:@"WardrobeCell"])
            {
                _arrayWithUserId = [[NSMutableArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                if(![self initFetchedResultsControllerForCollectionViewWithCellType:@"WardrobeCell" WithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:_arrayWithUserId sortingWithKeys:[NSArray arrayWithObject:@"idWardrobe"] ascending:YES andSectionWithKeyPath:nil])
                {
                    // There were no results!
                    [self setTopBarTitle:nil andSubtitle:NSLocalizedString(@"_NO_WARDROBES_ERROR_MSG_", nil)];
                    
                    [self stopActivityFeedback];
                    
                    return;
                }
            }
            else
            {
                int itemsBeforeUpdate = (int) [[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] fetchedObjects] count];
                
                // Empty old items array
                [_arrayWithUserId removeAllObjects];
                
                // Update Fetched Results Controller
                [self performFetchForCollectionViewWithCellType:@"WardrobeCell"];
                
                // Update collection view
                [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:itemsBeforeUpdate deleting:TRUE];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                _arrayWithUserId = [NSMutableArray arrayWithObject:appDelegate.currentUser.idUser];
                
                self.mainFetchedResultsController = nil;
                self.mainFetchRequest = nil;
                
                [self initFetchedResultsControllerForCollectionViewWithCellType:@"WardrobeCell" WithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:_arrayWithUserId sortingWithKeys:[NSArray arrayWithObject:@"idWardrobe"] ascending:YES andSectionWithKeyPath:nil];
            }
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:(int)[[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] fetchedObjects] count] deleting:FALSE];
            
            // There were results!
            [self setTopBarTitle:nil andSubtitle: appDelegate.currentUser.name];
            
            // Check if there are object in the Wardrobe Bin
//            Wardrobe * tmpWardrobeBin = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//            
//            if(!(tmpWardrobeBin == nil))
//            {
//                [self getContentsOfWardrobe:tmpWardrobeBin];
//            }
//            else
//            {
                [self stopActivityFeedback];
//            }

            break;
        }
        case ADD_WARDROBE:
        {
            if (_selectedItemsInWardrobeBin != nil)
            {
                if([_selectedItemsInWardrobeBin count] > 0)
                {
                    Wardrobe * createdWardrobe = [[self getFetchedResultsControllerForCellType:@"WardrobeCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:((int)[[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] sections][[[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] sections] count] - 1] numberOfObjects]-1) inSection:0]];
                    
                    [self addItemsToWardrobeWithID:createdWardrobe.idWardrobe];
                    
                    return;
                }
            }
            
            int itemsBeforeUpdate = (int) [[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] fetchedObjects] count];
            
            // Empty old items array
            [_arrayWithUserId removeAllObjects];
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"WardrobeCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:itemsBeforeUpdate deleting:TRUE];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            _arrayWithUserId = [NSMutableArray arrayWithObject:appDelegate.currentUser.idUser];
            
            self.mainFetchedResultsController = nil;
            self.mainFetchRequest = nil;
            
            [self initFetchedResultsControllerForCollectionViewWithCellType:@"WardrobeCell" WithEntity:@"Wardrobe" andPredicate:@"userId IN %@" inArray:_arrayWithUserId sortingWithKeys:[NSArray arrayWithObject:@"idWardrobe"] ascending:YES andSectionWithKeyPath:nil];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:(int)[[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] fetchedObjects] count] deleting:FALSE];
            
            [self stopActivityFeedback];
            
            break;
        }
        case ADD_ITEM_TO_WARDROBE:
        {
            itemsInWardrobeBinBeforeUpdate = (int) [[[self getFetchedResultsControllerForCellType:@"WardrobeBinCell"] sections][[[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] sections] count] - 1] numberOfObjects];
            
            itemsInWardrobeBeforeUpdate = (int)[[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] sections][[[[self getFetchedResultsControllerForCellType:@"WardrobeCell"] sections] count] - 1] numberOfObjects];
            
            _selectedItemsInWardrobeBin = nil;
            _wardrobeBinItems = nil;
            
            self.mainFetchedResultsController = nil;
            self.mainFetchRequest = nil;
            self.secondFetchedResultsController = nil;
            self.secondFetchRequest = nil;
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"WardrobeCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:itemsInWardrobeBinBeforeUpdate deleting:TRUE];
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"WardrobeBinCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeBinCell" fromItem:0 toItem:itemsInWardrobeBinBeforeUpdate deleting:TRUE];
            
            [self getUserWardrobes];
            
            [self stopActivityFeedback];
            /*
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ITEMSUCCESSFULLYADDEDTOWARDROBE_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
*/
            break;
        }
        case UPDATE_WARDROBE_NAME:
        {
            _selectedWardrobeToRename = nil;
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"WardrobeCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:-1 deleting:FALSE];
            
            [self stopActivityFeedback];

            break;
        }
        case GET_WARDROBE_CONTENT:
        case GET_WARDROBE:
        {
            [_selectedWardrobe.itemsId removeAllObjects];
            
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (GSBaseElement *item in mappingResult)
            {
                if([item isKindOfClass:[GSBaseElement class]])
                {
                    if(!(item.idGSBaseElement== nil))
                    {
                        if(!([item.idGSBaseElement isEqualToString:@""]))
                        {
                            if(_selectedWardrobe.itemsId == nil)
                            {
                                _selectedWardrobe.itemsId = [[NSMutableArray alloc] init];
                            }
                            
                            if(!([_selectedWardrobe.itemsId containsObject:item.idGSBaseElement]))
                            {
                                [_selectedWardrobe.itemsId addObject:item.idGSBaseElement];
                            }
                        }
                    }
                }
            }

            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects:_selectedWardrobe, [NSNumber numberWithBool:_bEditionMode], nil];
            
            [self stopActivityFeedback];
            
            [self transitionToViewController:WARDROBECONTENT_VC withParameters:parametersForNextVC];
            
            _selectedWardrobe = nil;
            
            break;
        }
        case REMOVE_ITEM_FROM_WARDROBE:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            if (!(_selectedItemsInWardrobeBin == nil))
            {
                if([_selectedItemsInWardrobeBin count] > 0)
                {
                    NSFetchedResultsController * tmpFRC;
                    NSFetchRequest * tmpFRQ;
                    
                    //FETCH REQUEST
                    
                    tmpFRQ = [[NSFetchRequest alloc] init];
                    
                    // Entity to look for
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GSBaseElement" inManagedObjectContext:currentContext];
                    
                    [tmpFRQ setEntity:entity];
                    
                    // Filter results
                    
                    [tmpFRQ setPredicate:[NSPredicate predicateWithFormat:@"idGSBaseElement IN %@", _selectedItemsInWardrobeBin]];
                    
                    // Sort results
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"idGSBaseElement" ascending:YES];
                    
                    [tmpFRQ setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    
                    [tmpFRQ setFetchBatchSize:20];
                    
                    // FETCHED RESULTS CONTROLLER
                    
                    tmpFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:tmpFRQ managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
                    
                    tmpFRC.delegate = self;
                    
                    NSError *error = nil;
                    
                    if (![tmpFRC performFetch:&error])
                    {
                        // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                        
                        NSLog(@"Couldn't fetched items selected in wardrobe. Unresolved error: %@, %@", error, [error userInfo]);
                    }
                    
                    for (GSBaseElement *item in [tmpFRC fetchedObjects])
                    {
                        if([item isKindOfClass:[GSBaseElement class]])
                        {
                            [currentContext deleteObject:item];
                            
                            NSError * error = nil;
                            if (![currentContext save:&error])
                            {
                                NSLog(@"Error saving context! %@", error);
                            }
                            
                        }
                    }
                }
            }
            
            _selectedItemsInWardrobeBin = nil;
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"WardrobeBinCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeBinCell" fromItem:0 toItem:-1 deleting:FALSE];
            
            [self stopActivityFeedback];
            
            break;
        }
        case DELETE_WARDROBE:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            [currentContext deleteObject:_selectedWardrobeToDelete];
            
            NSError * error = nil;
            if (![currentContext save:&error])
            {
                NSLog(@"Error saving context! %@", error);
            }
            
            
            _selectedWardrobeToDelete = nil;
            
            // Update Fetched Results Controller
            [self performFetchForCollectionViewWithCellType:@"WardrobeCell"];
            
            // Update collection view
            [self updateCollectionViewWithCellType:@"WardrobeCell" fromItem:0 toItem:-1 deleting:FALSE];
            
            [self stopActivityFeedback];
            
            break;
        }
            
        default:
            break;
    }
}

// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    return;
}

/*
// OVERRIDE: Right action
- (void)rightAction:(UIButton *)sender
{
    // Go to edition mode
    //[self stopActivityFeedback];
    _bEditionMode = !_bEditionMode;
    [self viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];

    [self viewWillAppear:NO];
    return;
}
*/
@end
