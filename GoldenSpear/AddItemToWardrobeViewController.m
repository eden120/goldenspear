//
//  AddItemToWardrobeViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "AddItemToWardrobeViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+UserManagement.h"
#import "SearchBaseViewController.h"
#import "ProductSheetViewController.h"
#import "FashionistaPostViewController.h"
#import "WardrobeContentViewController.h"
#import "FashionistaProfileViewController.h"
#import "UIView+Shadow.h"
#import "GSNewsFeedViewController.h"
#import "GSFashionistaPostViewController.h"

@interface AddItemToWardrobeViewController ()

@end

@implementation AddItemToWardrobeViewController


- (void)viewDidLoad
{
    //[super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Check if user is already loged in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    else
    {
        // Check that there's actually an item to add
        if ((_itemToAdd == nil) && (_postToAdd == nil))
        {
            // Must indicate an item!
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_MUSTINDICATEITEM_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
        }
        else
        {
            // Setup fetched results controller
            [self setupFetchedResultsController];
            
            // Do not show separators between the table view cells
            [self.wardrobesTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            
            // Get user wardrobes
            [self getUserWardrobes];
            
            //  Operation queue initialization
            self.imagesQueue = [[NSOperationQueue alloc] init];
            
            // Set max number of concurrent operations it can perform at 3, which will make things load even faster
            self.imagesQueue.maxConcurrentOperationCount = 3;
            
            // Setup item image
            
            UIImage * image = nil;
            
            if (_itemToAdd != nil)
            {
                if (!(_itemToAdd.preview_image == nil))
                {
                    if(!([_itemToAdd.preview_image isEqualToString:@""]))
                    {
                        image = [UIImage cachedImageWithURL:_itemToAdd.preview_image];
                    }
                    
                }
            }
            else if (_postToAdd != nil)
            {
                if (!(_postToAdd.preview_image == nil))
                {
                    if(!([_postToAdd.preview_image isEqualToString:@""]))
                    {
                        image = [UIImage cachedImageWithURL:_postToAdd.preview_image];
                    }
                    
                }
            }
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            [_itemImage setImage:image];
            [_itemImage.layer setBorderWidth:0.5];
            [_itemImage.layer setBorderColor:[UIColor grayColor].CGColor];
            
            // Properly resize the image view
            
            double scale = _itemImage.frame.size.width / image.size.width;
            
            [_itemImage setFrame:CGRectMake(_itemImage.frame.origin.x, _itemImage.frame.origin.y, _itemImage.frame.size.width*scale, _itemImage.frame.size.height*scale)];
            
            // Setup item title
            
            [_itemName setAdjustsFontSizeToFitWidth:YES];
            if (_itemToAdd != nil)
                [_itemName setText:_itemToAdd.name];
            else if (_postToAdd != nil)
                [_itemName setText:_postToAdd.name];
            
            // Set the proper name to the 'Add/Move' button
            [_addToWardrobeButton setTitle: (([[self parentViewController] isKindOfClass:[WardrobeContentViewController class]] && !_isAddButton) ? NSLocalizedString(@"_MOVETOWARDROBE_", nil) : NSLocalizedString(@"_ADDTOWARDROBE_", nil) ) forState:UIControlStateNormal];
            
            // Set the inner shadow
            //[self.wardrobesTable makeInsetShadowWithRadius:4 Color:[UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.2] Directions:[NSArray arrayWithObjects:@"top", @"bottom", nil]];
            
            [self.wardrobeCollectionName setDelegate:self];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_wardrobesFetchedResultsController fetchedObjects] count]/*IF WardrobeBin Implementation, ignore it:-1*/;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *currentCell = [tableView dequeueReusableCellWithIdentifier:@"WardrobesListCell"];
    
    if (currentCell == nil)
    {
        currentCell = [[UITableViewCell alloc] init];
    }
    
    Wardrobe * tmpWardrobe = [_wardrobesFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item/*IF WardrobeBin implementation, ignore it:+1*/ inSection:0]];
    
    currentCell.textLabel.text = tmpWardrobe.name;
    
    currentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([UIImage isCached:tmpWardrobe.preview_image])
    {
        UIImage * image = [UIImage cachedImageWithURL:tmpWardrobe.preview_image];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        [currentCell.imageView setImage:image];
    }
    else
    {
        // Load image in the background
        
        __weak AddItemToWardrobeViewController *weakSelf = self;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:tmpWardrobe.preview_image];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Then set them via the main queue if the cell is still visible.
                UITableView *tmpTableView = weakSelf.wardrobesTable;
                
                if ([tmpTableView.indexPathsForVisibleRows containsObject:indexPath])
                {
                    UITableViewCell * currentCell = [[UITableViewCell alloc] init];
                    
                    [currentCell.imageView setImage:image];
                    
                    [tableView reloadData];
                }
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
    
    return currentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _wardrobeCollectionName.text = @"";
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Textedit management

- (IBAction)onStartEditing:(UITextField *)sender
{
    if (!(_wardrobesTable.indexPathForSelectedRow == nil))
    {
        UITableViewCell *cell = [_wardrobesTable cellForRowAtIndexPath:_wardrobesTable.indexPathForSelectedRow];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [_wardrobesTable deselectRowAtIndexPath:_wardrobesTable.indexPathForSelectedRow animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

- (IBAction)onEndEditing:(UITextField *)sender
{
    
}

#pragma mark - Wardrobes requests management

//Setup the Fetched Results Controller
-(BOOL) setupFetchedResultsController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    if (!(appDelegate.currentUser == nil))
    {
        //FETCH REQUEST
        
        _wardrobesFetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity to look for
        
        [_wardrobesFetchRequest setEntity:[NSEntityDescription entityForName:@"Wardrobe" inManagedObjectContext:currentContext]];
        
        // Filter results
        
        [_wardrobesFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userId IN %@", [NSArray arrayWithObject:appDelegate.currentUser.idUser]]];
        
        // Sort results
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"idWardrobe" ascending:YES];
        
        [_wardrobesFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        [_wardrobesFetchRequest setFetchBatchSize:20];
        
        // FETCHED RESULTS CONTROLLER
        
        _wardrobesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_wardrobesFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        _wardrobesFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        
        if (![_wardrobesFetchedResultsController performFetch:&error])
        {
            // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
            
            NSLog(@"Couldn't fetched items selected in wardrobe. Unresolved error: %@, %@", error, [error userInfo]);
            
            return YES;
        }
    }
    
    return NO;
}

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

// Add items to wardrobe
- (void)addItemToWardrobeWithID:(NSString *)wardrobeID
{
    if (_itemToAdd != nil)
    {
        NSLog(@"Adding item to wardrobe: %@", _itemToAdd.idGSBaseElement);
        
        // Perform request to save the item into the wardrobe
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGITEMTOWARDROBE_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeID, _itemToAdd, nil];
        
        [self performRestPost:ADD_ITEM_TO_WARDROBE withParamaters:requestParameters];
        
    }
    else if (_postToAdd != nil)
    {
        NSLog(@"Adding post to wardrobe: %@", wardrobeID);
        
        // Perform request to save the item into the wardrobe
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGITEMTOWARDROBE_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeID, _postToAdd, nil];
        
        [self performRestPost:ADD_POST_TO_WARDROBE withParamaters:requestParameters];
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSError *error = nil;
    
    switch (connection)
    {
        case GET_USER_WARDROBES:
        {
            if (![_wardrobesFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched items selected in wardrobe. Unresolved error: %@, %@", error, [error userInfo]);
                
                [self.controllerTitle setText: (([[self parentViewController] isKindOfClass:[WardrobeContentViewController class]]) ? NSLocalizedString(@"_CREATEWARDROBEMOVING_", nil) : NSLocalizedString(@"_CREATEWARDROBE_", nil) )];
                
                [self.wardrobesTable setHidden:YES];
                
                [self.noCollectionsLabel setHidden:NO];
            }
            else
            {
                if(!([[_wardrobesFetchedResultsController fetchedObjects] count] > 0/*IF WardrobeBin implementation, consider it: > 1*/))
                {
                    [self.controllerTitle setText: (([[self parentViewController] isKindOfClass:[WardrobeContentViewController class]]) ? NSLocalizedString(@"_CREATEWARDROBEMOVING_", nil) : NSLocalizedString(@"_CREATEWARDROBE_", nil) )];
                    
                    [self.wardrobesTable setHidden:YES];
                    
                    [self.noCollectionsLabel setHidden:NO];
                }
                else
                {
                    [_wardrobesTable reloadData];
                    
                    [self.controllerTitle setText: (([[self parentViewController] isKindOfClass:[WardrobeContentViewController class]]) ? NSLocalizedString(@"_CREATEORSELECTWARDROBEMOVING_", nil) : NSLocalizedString(@"_CREATEORSELECTWARDROBE_", nil) )];
                    
                    [self.wardrobesTable setHidden:NO];
                    
                    [self.noCollectionsLabel setHidden:YES];
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case ADD_WARDROBE:
        {
            if ((_itemToAdd != nil) || (_postToAdd != nil))
            {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if (!(appDelegate.currentUser == nil))
                {
                    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                    
                    NSFetchedResultsController * tmpFRC;
                    NSFetchRequest * tmpFRQ;
                    
                    //FETCH REQUEST
                    
                    tmpFRQ = [[NSFetchRequest alloc] init];
                    
                    // Entity to look for
                    
                    [tmpFRQ setEntity:[NSEntityDescription entityForName:@"Wardrobe" inManagedObjectContext:currentContext]];
                    
                    // Filter results
                    
                    [tmpFRQ setPredicate:[NSPredicate predicateWithFormat:@"userId IN %@", [NSArray arrayWithObject:appDelegate.currentUser.idUser]]];
                    
                    // Sort results
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"idWardrobe" ascending:YES];
                    
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
                    else
                    {
                        // Assume the new one is the last one (greater idWardrobe)
                        
                        Wardrobe * createdWardrobe = [tmpFRC objectAtIndexPath:[NSIndexPath indexPathForItem:((int)[[tmpFRC sections][[[_wardrobesFetchedResultsController sections] count] - 1] numberOfObjects]-1) inSection:([[_wardrobesFetchedResultsController sections] count] - 1)]];
                        
                        [self addItemToWardrobeWithID:createdWardrobe.idWardrobe];
                        
                        return;
                    }
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_WARDROBECREATION_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case ADD_ITEM_TO_WARDROBE:
        {
            _itemToAdd = nil;
            
            [self stopActivityFeedback];
            /*
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:(([[self parentViewController] isKindOfClass:[WardrobeContentViewController class]]) ? NSLocalizedString(@"_ITEMSUCCESSFULLYMOVEDTOWARDROBE_MSG_", nil): NSLocalizedString(@"_ITEMSUCCESSFULLYADDEDTOWARDROBE_MSG_", nil)) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
            */
            [self cancelAddingItemToWardrobe:nil];
            
            break;
        }
        case ADD_POST_TO_WARDROBE:
        {
            _postToAdd = nil;
            
            /*
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:(([[self parentViewController] isKindOfClass:[WardrobeContentViewController class]]) ? NSLocalizedString(@"_ITEMSUCCESSFULLYMOVEDTOWARDROBE_MSG_", nil): NSLocalizedString(@"_ITEMSUCCESSFULLYADDEDTOWARDROBE_MSG_", nil)) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
             
             [alertView show];
             */
            [self cancelAddingItemToWardrobe:nil];

            [self stopActivityFeedback];
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Actions


- (IBAction)cancelAddingItemToWardrobe:(UIButton *)sender
{
    if ([[self parentViewController] isKindOfClass:[SearchBaseViewController class]])
    {
        [((SearchBaseViewController *)[self parentViewController]) closeAddingItemToWardrobeHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
    }
    else if ([[self parentViewController] isKindOfClass: [ProductSheetViewController class]])
    {
        [((ProductSheetViewController *)[self parentViewController]) closeAddingItemToWardrobeHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
    }
    else if ([[self parentViewController] isKindOfClass: [FashionistaPostViewController class]])
    {
        [((FashionistaPostViewController *)[self parentViewController]) closeAddingItemToWardrobeHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
    }
    else if ([[self parentViewController] isKindOfClass: [FashionistaProfileViewController class]])
    {
        [((FashionistaProfileViewController *)[self parentViewController]) closeAddingItemToWardrobeHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
    }
    else if ([[self parentViewController] isKindOfClass:[WardrobeContentViewController class]])
    {
        if (_isAddButton) {
            [((WardrobeContentViewController *)[self parentViewController]) closeAddingItemToWardrobeHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
        }
        else {
            [((WardrobeContentViewController *)[self parentViewController]) closeMovingItemHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
        }
    }
    else if ([[self parentViewController] isKindOfClass:[GSNewsFeedViewController class]])
    {
        [((GSNewsFeedViewController *)[self parentViewController]) closeAddingItemToWardrobeHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
    }
    else if ([[self parentViewController] isKindOfClass: [GSFashionistaPostViewController class]])
    {
        [((GSFashionistaPostViewController *)[self parentViewController]) closeAddingItemToWardrobeHighlightingButton:_buttonToHighlight withSuccess:(sender == nil)];
    }
}

- (IBAction)addItemToWardrobe:(UIButton *)sender
{
    if(!(_wardrobeCollectionName.text == nil))
    {
        if(!([_wardrobeCollectionName.text isEqualToString:@""]))
        {
            [self createWardrobeWithName:_wardrobeCollectionName.text];
            
            return;
        }
    }
    
    if (!(_wardrobesTable.indexPathForSelectedRow == nil))
    {
        Wardrobe * tmpWardrobe = [_wardrobesFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:_wardrobesTable.indexPathForSelectedRow.item/*IF WardrobeBin implemented, consider it:+1*/ inSection:0]];
        
        for (NSString *itemId in tmpWardrobe.itemsId)
        {
            if (_itemToAdd != nil)
            {
                if([itemId isEqualToString:_itemToAdd.idGSBaseElement])
                {
                    // Item already in wardrobe!
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ITEMALREADYINWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    return;
                }
            }
            else if (_postToAdd != nil)
            {
                if([itemId isEqualToString:_postToAdd.idFashionistaPost])
                {
                    // Item already in wardrobe!
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_ITEMALREADYINWARDROBE_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                    return;
                }
            }
        }
        
        [self addItemToWardrobeWithID:tmpWardrobe.idWardrobe];
    }
}


#pragma mark - AlertViews Management


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    NSString *message = [alertView message];
    
    if([title isEqualToString:NSLocalizedString(@"_OK_", nil)])
    {
        if (([message isEqualToString:@"_MUSTINDICATEITEM_MSG_"]) || ([message isEqualToString:@"_MUSTBELOGGED_MSG_"]))
        {
            [self cancelAddingItemToWardrobe:nil];
        }
    }
}

#pragma mark - Logout
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    return;
    //    [self dismissViewController];
    
    [self transitionToViewController:SEARCH_VC withParameters:nil fromViewController:self.fromViewController];
}

@end
