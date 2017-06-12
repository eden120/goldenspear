//
//  AddPostToPageViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 31/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "AddPostToPageViewController.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+UserManagement.h"
#import "FashionistaPostViewController.h"
#import "UIView+Shadow.h"


@interface AddPostToPageViewController ()

@end

@implementation AddPostToPageViewController

// Object to get location data
CLLocationManager *postLocationManager;
// Class providing services for converting between a GPS coordinate and a user-readable address
CLGeocoder *postGeocoder;
// Object containing the result returned by CLGeocoder
CLPlacemark *postPlacemark;

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
        if (_postToAdd == nil)
        {
            // Must indicate an item!
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_MUSTINDICATEITEM_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
            
            [alertView show];
        }
        else
        {
            // Setup the TextEdit border color
            self.stylistPostName.layer.borderColor = [UIColor grayColor].CGColor;
            self.stylistPostName.layer.borderWidth= 1.0f;
            self.stylistPageName.layer.borderColor = [UIColor grayColor].CGColor;
            self.stylistPageName.layer.borderWidth= 1.0f;

            // Setup fetched results controller
            [self setupFetchedResultsController];
            
            // Do not show separators between the table view cells
            [self.pagesTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            
            // Get user pages
            [self getUserPages];
            
            //  Operation queue initialization
            self.imagesQueue = [[NSOperationQueue alloc] init];
            
            // Set max number of concurrent operations it can perform at 3, which will make things load even faster
            self.imagesQueue.maxConcurrentOperationCount = 3;
            
            // Setup item image
            
            UIImage * image = nil;
            
            if (!(_postToAdd.preview_image == nil))
            {
                if(!([_postToAdd.preview_image isEqualToString:@""]))
                {
                    image = [UIImage cachedImageWithURL:_postToAdd.preview_image];
                }
                
            }
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            [_postPreviewImage setImage:image];
            [_postPreviewImage.layer setBorderWidth:1.0f];
            [_postPreviewImage.layer setBorderColor:[UIColor grayColor].CGColor];
            
            // Properly resize the image view
            
            double scale = _postPreviewImage.frame.size.width / image.size.width;
            
            [_postPreviewImage setFrame:CGRectMake(_postPreviewImage.frame.origin.x, _postPreviewImage.frame.origin.y, _postPreviewImage.frame.size.width*scale, _postPreviewImage.frame.size.height*scale)];
            
            // Setup item title
            
            [_postTitle setAdjustsFontSizeToFitWidth:YES];
            [_postTitle setText:_postToAdd.name];
            
            if(!(_postToAdd.name == nil))
            {
                if(!([_postToAdd.name isEqualToString:@""]))
                {
                    [self.stylistPostName setText:_postToAdd.name];
                }
            }
            
            // Initialize objects to get location data
            postLocationManager = [[CLLocationManager alloc] init];
            postGeocoder = [[CLGeocoder alloc] init];
            [self getCurrentLocation];

            [_saveDateSwitch setOnTintColor:[UIColor colorWithRed:0.95 green:0.80 blue:0.46 alpha:0.95] ];
            [_saveLocationSwitch setOnTintColor:[UIColor colorWithRed:0.95 green:0.80 blue:0.46 alpha:0.95] ];
            
            [_saveDateSwitch setOn:YES];
            [_saveLocationSwitch setOn:YES];

            if(!(_postToAdd.fashionistaPageId == nil))
            {
                if (!([_postToAdd.fashionistaPageId isEqualToString:@""]))
                {
                    // Setup save date
                    if(!(_postToAdd.date == nil))
                    {
                        [_saveDateSwitch setOn:YES];
                    }
                    else
                    {
                        [_saveDateSwitch setOn:NO];
                    }
                    
                    // Setup save location
                    if(!(_postToAdd.location == nil))
                    {
                        if(!([_postToAdd.location isEqualToString:@""]))
                        {
                            [_saveLocationSwitch setOn:YES];
                        }
                        else
                        {
                            [_saveLocationSwitch setOn:NO];
                        }
                    }
                    else
                    {
                        [_saveLocationSwitch setOn:NO];
                    }
                }
            }
            
            // Setup item type
            if(!(_postToAdd.type == nil))
            {
                if(!([_postToAdd.type isEqualToString:@""]))
                {
                    // Get the type
                    if([_postToAdd.type isEqualToString:@"article"])
                    {
                        [_postTypeSegmentedControl setSelectedSegmentIndex:0];
                    }
                    else if([_postToAdd.type isEqualToString:@"review"])
                    {
                        [_postTypeSegmentedControl setSelectedSegmentIndex:1];
                    }
                    else if([_postToAdd.type isEqualToString:@"tutorial"])
                    {
                        [_postTypeSegmentedControl setSelectedSegmentIndex:2];
                    }
                }
            }
            
            // Set the proper name to the 'Add/Move' button
            [_addToPageButton setTitle:NSLocalizedString(@"_ADDTOPAGE_", nil) forState:UIControlStateNormal];
            
            // Set the inner shadow
            //[self.wardrobesTable makeInsetShadowWithRadius:4 Color:[UIColor colorWithRed:(0.0) green:(0.0) blue:(0.0) alpha:0.2] Directions:[NSArray arrayWithObjects:@"top", @"bottom", nil]];
            
            [self.stylistPageName setDelegate:self];
            [self.stylistPostName setDelegate:self];
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
    return [[_pagesFetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *currentCell = [tableView dequeueReusableCellWithIdentifier:@"PagesListCell"];
    
    if (currentCell == nil)
    {
        currentCell = [[UITableViewCell alloc] init];
    }
    
    FashionistaPage * tmpPage = [_pagesFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
    
    currentCell.textLabel.text = tmpPage.title;
    
    currentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(!(_pagesFetchedResultsController == nil))
    {
        if(([[_pagesFetchedResultsController fetchedObjects] count] > indexPath.item))
        {
            if(!(_postToAdd.fashionistaPageId == nil))
            {
                if(!([_postToAdd.fashionistaPageId isEqualToString:@""]))
                {
                    if([_postToAdd.fashionistaPageId isEqualToString:((FashionistaPage*)[[_pagesFetchedResultsController fetchedObjects] objectAtIndex:indexPath.item]).idFashionistaPage])
                    {
                        [_pagesTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                        [self tableView:_pagesTable didSelectRowAtIndexPath:indexPath];
                        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        
                        return currentCell;
                    }
                }
                else if (indexPath == [NSIndexPath indexPathForItem:0 inSection:0])
                {
                    [_pagesTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    [self tableView:_pagesTable didSelectRowAtIndexPath:indexPath];
                    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
                    
                    return currentCell;
                }
            }
            else if (indexPath == [NSIndexPath indexPathForItem:0 inSection:0])
            {
                [_pagesTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self tableView:_pagesTable didSelectRowAtIndexPath:indexPath];
                currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                return currentCell;
            }

            return currentCell;
        }
    }

//    if ([UIImage isCached:tmpPage.header_image])
//    {
//        UIImage * image = [UIImage cachedImageWithURL:tmpPage.header_image];
//        
//        if(image == nil)
//        {
//            image = [UIImage imageNamed:@"no_image.png"];
//        }
//        
//        [currentCell.imageView setImage:image];
//    }
//    else
//    {
//        // Load image in the background
//        
//        __weak AddPostToPageViewController *weakSelf = self;
//        
//        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//            
//            UIImage * image = [UIImage cachedImageWithURL:tmpPage.header_image];
//            
//            if(image == nil)
//            {
//                image = [UIImage imageNamed:@"no_image.png"];
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                // Then set them via the main queue if the cell is still visible.
//                UITableView *tmpTableView = weakSelf.pagesTable;
//                
//                if ([tmpTableView.indexPathsForVisibleRows containsObject:indexPath])
//                {
//                    UITableViewCell * currentCell = [[UITableViewCell alloc] init];
//                    
//                    [currentCell.imageView setImage:image];
//                    
//                    [tableView reloadData];
//                }
//            });
//        }];
//        
//        operation.queuePriority = NSOperationQueuePriorityHigh;
//        
//        [self.imagesQueue addOperation:operation];
//    }
    
    return currentCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _stylistPageName.text = @"";
    
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
    if (!(_pagesTable.indexPathForSelectedRow == nil))
    {
        UITableViewCell *cell = [_pagesTable cellForRowAtIndexPath:_pagesTable.indexPathForSelectedRow];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [_pagesTable deselectRowAtIndexPath:_pagesTable.indexPathForSelectedRow animated:YES];
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


#pragma mark - Switches management

// Save Date switch changes
- (IBAction)saveDateChanged:(UISwitch *)sender
{
    
}

// Save Location switch changes
- (IBAction)saveLocationChanged:(UISwitch *)sender
{
    
}


#pragma mark - CLLocationManagerDelegate

- (void)getCurrentLocation
{
    [postLocationManager requestWhenInUseAuthorization];
    
    postLocationManager.delegate = self;
    
    postLocationManager.pausesLocationUpdatesAutomatically = NO;
    
    postLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [postLocationManager startUpdatingLocation];
    }
    else
    {
        NSLog(@"Location services is not enabled");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location failed with error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated to location: %@", newLocation);
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        // Stop Location Manager
        [postLocationManager stopUpdatingLocation];
        
        // Reverse Geocoding
        NSLog(@"Resolving the address...");
        
        [postGeocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
            
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            
            if (error == nil && [placemarks count] > 0)
            {
                postPlacemark = [placemarks lastObject];
                
                // For full address
                /*_detailedReviewUserLocation.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                 placemark.subThoroughfare, placemark.thoroughfare,
                 placemark.postalCode, placemark.locality,
                 placemark.administrativeArea,
                 placemark.country];*/
                
                _currentUserLocation = [NSString stringWithFormat:@"%@ (%@)", postPlacemark.locality, postPlacemark.country];
            }
            else
            {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
    }
}


#pragma mark - Segmented control management

// Segmented Control changes

- (IBAction)postTypeChanged:(UISegmentedControl *)sender
{
//    if(!(_postToAdd == nil))
//    {
//        [_postToAdd setType:[self postTypeForIndex:sender.selectedSegmentIndex]];
//        
//        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
//
//        [currentContext processPendingChanges];
//
//        [currentContext save:nil];
//    }
}

-(NSString *) postTypeForIndex:(NSInteger)index
{
    switch (index)
    {
        case 0: // Article

            return @"article";

            break;

        case 1: // Review

            return @"review";

            break;

        case 2: // Tutorial

            return @"tutorial";

            break;

        default:

            return nil;

            break;
    }
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
        
        _pagesFetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity to look for
        
        [_pagesFetchRequest setEntity:[NSEntityDescription entityForName:@"FashionistaPage" inManagedObjectContext:currentContext]];
        
        // Filter results
        
        [_pagesFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userId IN %@", [NSArray arrayWithObject:appDelegate.currentUser.idUser]]];
        
        // Sort results
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"idFashionistaPage" ascending:YES];
        
        [_pagesFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        [_pagesFetchRequest setFetchBatchSize:20];
        
        // FETCHED RESULTS CONTROLLER
        
        _pagesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_pagesFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
        
        _pagesFetchedResultsController.delegate = self;
        
        NSError *error = nil;
        
        if (![_pagesFetchedResultsController performFetch:&error])
        {
            // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
            
            NSLog(@"Couldn't fetched pages. Unresolved error: %@, %@", error, [error userInfo]);
            
            return YES;
        }
    }
    
    return NO;
}

// Request the user pages from the GS server
- (void) getUserPages
{
    // Check if user is signed in
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                NSLog(@"Fetching user pages...");
                
                // Provide feedback to user
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                [self performRestGet:GET_FASHIONISTAPAGES withParamaters:requestParameters];
            }
        }
    }
}


//Create new page
-(void)createPageWithName:(NSString *)pageName
{
    NSLog(@"Adding page: %@", pageName);
    
    // Check that the name is valid
    
    if (!(pageName == nil))
    {
        // Perform request to get the wardrobe contents
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_PREPARINGFASHIONISTAPAGE_MSG_", nil)];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        FashionistaPage *newPage = [[FashionistaPage alloc] initWithEntity:[NSEntityDescription entityForName:@"FashionistaPage" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
        
        [newPage setTitle:pageName];
        
        [newPage setUserId:appDelegate.currentUser.idUser];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPage, [NSNumber numberWithBool:NO], nil];
        
        [self performRestPost:UPLOAD_FASHIONISTAPAGE withParamaters:requestParameters];
    }
}

// Add post to page
- (void)addPostToPageWithID:(NSString *)pageID
{
    if (!(_postToAdd == nil))
    {
        _postToAdd.fashionistaPageId = pageID;
        
        NSLog(@"Adding post to page: %@", pageID);
        
        // Perform request to save the item into the wardrobe
        
        // Provide feedback to user
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_ADDINGPOSTTOPAGE_MSG_", nil)];
        
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:_postToAdd, [NSNumber numberWithBool:YES], nil];
        
        [self performRestPost:UPLOAD_FASHIONISTAPOST withParamaters:requestParameters];
    }
}

// Action to perform if the connection succeed
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult
{
    NSError *error = nil;
    FashionistaPost *mappedUploadedPost = nil;
    
    switch (connection)
    {
        case GET_FASHIONISTAPAGES:
        {
            if (![_pagesFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched pages. Unresolved error: %@, %@", error, [error userInfo]);
                
                [self.controllerTitle setText: NSLocalizedString(@"_CREATEPAGE_", nil)];
                
                [self.pagesTable setHidden:YES];
                
                [self.noCollectionsLabel setHidden:NO];
            }
            else
            {
                if(!([[_pagesFetchedResultsController fetchedObjects] count] > 0))
                {
                    [self.controllerTitle setText: NSLocalizedString(@"_CREATEPAGE_", nil)];
                    
                    [self.pagesTable setHidden:YES];
                    
                    [self.noCollectionsLabel setHidden:NO];
                }
                else
                {
                    [self.controllerTitle setText:NSLocalizedString(@"_CREATEORSELECTPAGE_", nil)];
                    
                    [self.pagesTable setHidden:NO];
                    
                    [self.noCollectionsLabel setHidden:YES];
                    
                    [self.pagesTable reloadData];
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case UPLOAD_FASHIONISTAPOST:
        {
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            mappedUploadedPost = (FashionistaPost *)post;
                            
                            break;
                        }
                    }
                }
            }
            
            if(!(mappedUploadedPost == nil))
            {
                if(!(mappedUploadedPost.idFashionistaPost == nil))
                {
                    if(!([mappedUploadedPost.idFashionistaPost isEqualToString:@""]))
                    {
                        _postToAdd = mappedUploadedPost;
                        
                        if (!(_postToAdd == nil))
                        {
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:_postToAdd.idFashionistaPost, nil];
                            
                            [self performRestGet:GET_POST withParamaters:requestParameters];
                            
                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            [currentContext deleteObject:_postToAdd];
                            
                            [currentContext processPendingChanges];
                            
                            if (![currentContext save:nil])
                            {
                                NSLog(@"Save did not complete successfully.");
                            }
                            
                            return;
                        }
                    }
                }
            }
            
            [self stopActivityFeedback];
            
            break;
        }
        case GET_POST:
        {
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            mappedUploadedPost = (FashionistaPost *)post;
                            
                            break;
                        }
                    }
                }
            }
            
            if(!(mappedUploadedPost == nil))
            {
                if(!(mappedUploadedPost.idFashionistaPost == nil))
                {
                    if(!([mappedUploadedPost.idFashionistaPost isEqualToString:@""]))
                    {
                        if (!(self.parentViewController == nil))
                        {
                            if([self.parentViewController isKindOfClass:[FashionistaPostViewController class]])
                            {
                                [((FashionistaPostViewController *)self.parentViewController) setShownPost:mappedUploadedPost];
                            }
                        }
                    }
                }
            }
            
            _postToAdd = nil;
            
//            [self stopActivityFeedback];
            
            [self cancelAddingPostToPage:nil];
            
            break;
        }

        case UPLOAD_FASHIONISTAPAGE:
        {
            if (_postToAdd != nil)
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
                    
                    [tmpFRQ setEntity:[NSEntityDescription entityForName:@"FashionistaPage" inManagedObjectContext:currentContext]];
                    
                    // Filter results
                    
                    [tmpFRQ setPredicate:[NSPredicate predicateWithFormat:@"userId IN %@", [NSArray arrayWithObject:appDelegate.currentUser.idUser]]];
                    
                    // Sort results
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"idFashionistaPage" ascending:YES];
                    
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
                        
                        FashionistaPage * createdPage = [tmpFRC objectAtIndexPath:[NSIndexPath indexPathForItem:((int)[[tmpFRC sections][[[_pagesFetchedResultsController sections] count] - 1] numberOfObjects]-1) inSection:([[_pagesFetchedResultsController sections] count] - 1)]];
                        
                        [self addPostToPageWithID:createdPage.idFashionistaPage];
                        
                        return;
                    }
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_NO_FASHIONISTAPAGEUPLOAD_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }
            
            [self stopActivityFeedback];
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Actions


- (IBAction)cancelAddingPostToPage:(UIButton *)sender
{
    if ([[self parentViewController] isKindOfClass: [FashionistaPostViewController class]])
    {
        [((FashionistaPostViewController *)[self parentViewController]) closeAddingPostToPageWithSuccess:(sender == nil)];
    }
}

- (IBAction)addPostToPage:(UIButton *)sender
{
    if((_stylistPostName.text == nil) || ([_stylistPostName.text isEqualToString:@""]))
    {
        _stylistPostName.text = @"";
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_SHOULDSETPOSTTITLE_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles: nil];
//        
//        [alertView show];
//        
//        return;
    }
    
    [_postToAdd setName:_stylistPostName.text];
    [_postToAdd setType:[self postTypeForIndex:self.postTypeSegmentedControl.selectedSegmentIndex]];
    
    if([_saveDateSwitch isOn])
    {
        [_postToAdd setDate:[NSDate date]];
    }
    else
    {
        [_postToAdd setDate:nil];
    }
        
    
    if([_saveLocationSwitch isOn])
    {
        // TO DO: Get real location
        [_postToAdd setLocation:(((_currentUserLocation == nil) || ([_currentUserLocation isEqualToString:@""])) ? nil : (_currentUserLocation))];
    }
    else
    {
        [_postToAdd setLocation:nil];
    }

    if(!(_stylistPageName.text == nil))
    {
        if(!([_stylistPageName.text isEqualToString:@""]))
        {
            [self createPageWithName:_stylistPageName.text];
            
            return;
        }
    }
    
    if (!(_pagesTable.indexPathForSelectedRow == nil))
    {
        FashionistaPage * tmpPage = [_pagesFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:_pagesTable.indexPathForSelectedRow.item inSection:0]];
        
        [self addPostToPageWithID:tmpPage.idFashionistaPage];
    }
    else if([_pagesTable numberOfRowsInSection:0] > 0)
    {
        FashionistaPage * tmpPage = [_pagesFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        [self addPostToPageWithID:tmpPage.idFashionistaPage];
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
            [self cancelAddingPostToPage:nil];
        }
    }
}

#pragma mark - Logout
// Peform an action once the user logs out
- (void)actionAfterLogOut
{
    [super actionAfterLogOut];
    return;
}


@end
