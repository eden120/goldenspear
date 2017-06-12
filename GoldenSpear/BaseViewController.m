//
//  BaseViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import "BaseViewController.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+CircleMenuManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "UILabel+CustomCreation.h"

#import "CoreDataQuery.h"

@interface BaseViewController () <CLLocationManagerDelegate>

@end

@implementation BaseViewController {
    CLLocationManager *locationManager;
    CLGeocoder *geoCoder;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNotificationsLabel) name:kFinishedUpdatingNotifications object:nil];
    
    // Do any additional setup after loading the view.
    
    // Create top bar controls
    [self createTopBar];
    
    // Create 'Slide to go back' label and bottom controls
    [self createBottomControls];
    
    // Init the Gesture Recognizer
    [self initGestureRecognizer];
    
    // Init the images operation queue (to load them in the background)
    [self initImagesQueue];
    
    // Initialize the filter terms ribbon
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.finger.delegate = self;
    
    appDelegate.finger.viewParent = self.view;
    
    [appDelegate.finger runFingerprint];
    
    self.preloadImagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.preloadImagesQueue.maxConcurrentOperationCount = 3;
    
    locationManager = [[CLLocationManager alloc] init];
    geoCoder = [[CLGeocoder alloc] init];
    if (_placeMark == nil) {
        [self getCurrentLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self cancelFadeArrow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishLoadingTask" object:nil];
    
    // to be redefined in child controller in order to send the time to the correct api call
    self.endTime = [NSDate date];
    
    [self postAnayliticsIntervalTimeBetween:self.startTime and:self.endTime];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Update the notifications icon
    [self updateBottomNotificationsIcon];
    
    // Init the Activity feedback
    [self initActivityFeedback];
    
    // Init Main Menu
    [self initMainMenu];
    
    // Init the circle menus
    [self setupMainCircleMenuDefaults];
    [self setupLeftCircleMenuDefaults];
    
    [self createArrows];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.startTime = [NSDate date];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.idUserViewing = nil;
    if (appDelegate.currentUser != nil)
        self.idUserViewing = appDelegate.currentUser.idUser;
    
    [self showHintsFirstTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)getCurrentLocation
{
    [locationManager requestWhenInUseAuthorization];
    
    locationManager.delegate = self;
    
    locationManager.pausesLocationUpdatesAutomatically = YES;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [locationManager startUpdatingLocation];
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
        [locationManager stopUpdatingLocation];
        
        // Reverse Geocoding
        NSLog(@"Resolving the address...");
        
        [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
            
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            
            if (error == nil && [placemarks count] > 0)
            {
                _placeMark = [placemarks lastObject];
                
                NSString *countryCode = _placeMark.ISOcountryCode;
                
                NSString *radius = @"100";
                NSString *lat = [NSString stringWithFormat:@"%.4F", _placeMark.location.coordinate.latitude];
                NSString *lon = [NSString stringWithFormat:@"%.4F", _placeMark.location.coordinate.longitude];
                
                //MKPlacemark *mark = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:nil];
                NSString *zipCode = _placeMark.postalCode;
                NSLog(@"Location Info : %@, %@, %@, %@", countryCode, radius, lat, lon);
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.currentLocationLat = [NSNumber numberWithFloat:_placeMark.location.coordinate.latitude];
                appDelegate.currentLocationLon = [NSNumber numberWithFloat:_placeMark.location.coordinate.longitude];
            }
        }];
    }
}


-(void)updateBottomNotificationsIcon
{
    [self setupNotificationsLabel];
    /*
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     
     if([appDelegate.userNewNotifications intValue] > 0)
     {
     //Prepare the notification image
     UIImage * baseImage = [UIImage imageNamed:@"_MENUENTRY_5_NEWS_BOTTOM.png"];
     
     UIImageView * notificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,baseImage.size.width, baseImage.size.height)];
     
     [notificationImageView setContentMode:UIViewContentModeScaleAspectFit];
     
     [notificationImageView setImage:baseImage];
     
     UILabel * numberLabel = [UILabel createLabelWithOrigin:CGPointMake(baseImage.size.width-(baseImage.size.width*0.6),0)
     andSize:CGSizeMake(baseImage.size.width*0.6, baseImage.size.height*0.55)
     andBackgroundColor:[UIColor clearColor]
     andAlpha:1.0
     andText:[appDelegate.userNewNotifications stringValue]
     andTextColor:[UIColor whiteColor]
     andFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]
     andUppercasing:YES
     andAligned:NSTextAlignmentCenter];
     
     UIView * notificationIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0,baseImage.size.width, baseImage.size.height)];
     
     // Add image and label to view
     [notificationIcon addSubview:notificationImageView];
     [notificationIcon addSubview:numberLabel];
     
     UIGraphicsBeginImageContextWithOptions(notificationIcon.bounds.size, NO, 0.0);
     
     [notificationIcon.layer renderInContext:UIGraphicsGetCurrentContext()];
     
     UIImage *notificationImage = UIGraphicsGetImageFromCurrentImageContext();
     
     UIGraphicsEndImageContext();
     
     [self.menuButton setImage:notificationImage forState:UIControlStateNormal];
     [self.menuButton setImage:notificationImage forState:UIControlStateHighlighted];
     }
     */
}

// Hide Menu view or close any open keyboard if the user touches anywhere on the screen
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIViewController * topMostController = (BaseViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topMostController.presentedViewController != nil)
    {
        topMostController = topMostController.presentedViewController;
    }
    
    
    if(self != topMostController)
        return;
    
    [super touchesEnded:touches withEvent:event];
    
    if(self.hintView.hidden)
    {
        [self showMainMenu:nil];
        [self.view endEditing:YES];
    }
    else
    {
        if ([self.updatingHint boolValue] == YES)
        {
            self.updatingHint = [NSNumber numberWithBool:NO];
        }
        else
        {
            if(([self.hintLabel.text isEqualToString:NSLocalizedString(@"_POSTANDBEVALIDATED_", nil)]) || ([self.hintLabel.text isEqualToString:NSLocalizedString(@"_SHARE_BTN_", nil)]))
            {
                [self hideMessage];
            }
            else
            {
                [self hideHints:nil];
            }
        }
    }
}

/*
 
 - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
 {
 return UIInterfaceOrientationPortrait;
 }
 
 
 -(NSUInteger)supportedInterfaceOrientations
 {
 
 return UIInterfaceOrientationMaskPortrait;
 }
 
 
 - (BOOL)shouldAutorotate
 {
 return NO;
 }
 */

#pragma mark - Fingerprint
-(void) fingerprintfinished:(NSString *)fingerprint
{
    NSLog(@"BaseViewController FingerPrint: %@", fingerprint);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.currentUser != nil)
    {
        [appDelegate.currentUser setFingerPrint:fingerprint];
    }
    
}

-(void) fingerprintfinishederror:(NSError *)error
{
    NSLog(@"BaseViewController FingerPrint Error %@", error.description);
}

// Pre-download image
- (void)preLoadImage:(NSString*) imageFile
{
    if (imageFile != nil)
    {
        //NSLog(@"Preloading Image");
        
        // Preload images in the background
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            [UIImage cachedImageWithURL:imageFile];
            
            //NSLog(@"Preloaded Image");
        }];
        
        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        
        [self.preloadImagesQueue addOperation:operation];
    }
}
#pragma mark - Downloading info for filter search

-(void) loadDataFromServer
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSplashView:) name:@"finishLoadingTask" object:nil];
    
    [self startLoadingInfoFilterFromServer];
}

-(void) startLoadingInfoFilterFromServer
{
    timingDate = [NSDate date];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.bForceDownloadData) || ((appDelegate.bLoadedFilterInfo == NO) && (appDelegate.bLoadingFilterInfo == NO)))
    {
        appDelegate.bLoadingFilterInfo = YES;
        
        [self loadAllBrands];
        
        [self loadAllFeaturesGroup];
        
        [self getSearchKeywords];
        
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGFILTERS_ACTV_MSG_", nil)];
        
        appDelegate.bForceDownloadData = NO;
    }
    else if (appDelegate.bLoadedFilterInfo == YES)
    {
        appDelegate.splashScreen = NO;
        
        [self finishedLoadingFilterInfo];
        
        
        NSLog(@"SplashScreen Time taken: %f", [[NSDate date] timeIntervalSinceDate:timingDate]);
    }
    
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
        NSLog(@"Num product group order: %ld", (unsigned long)pg.featuresGroupOrder.count);
        NSLog(@"----------------------------------------");
    }
    
}


-(void) setupAllProductCategoriesWithMapping:(NSArray *)productCategoriesMapping
{
    //    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    // remove all features group with gender
    //    appDelegate.productGroups = [NSMutableArray arrayWithArray:[self fetchProductCategories]];
    //
    //    [self filterProductCategoryByFeatureGroupAndGender: appDelegate.productGroups];
    //
    //[self checkDebugProductGroup];
    
    NSDictionary* userInfo = @{@"total": @"setupAllProductCategoriesWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
    
}

-(void) loadAllFeatures
{
    NSLog(@"Loading features info");
    // get all product categories
    [self performRestGet:GET_ALLFEATURES withParamaters:nil];
}

-(void) setupAllFeaturesWithMapping:(NSArray *)featureGroupMapping
{
    
    NSDictionary* userInfo = @{@"total": @"setupAllFeaturesWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) loadAllFeaturesGroup
{
    NSLog(@"Loading feature groups info");
    // get all product categories
    [self performRestGet:GET_ALLFEATUREGROUPS withParamaters:nil];
}

-(void) setupAllFeatureGroupsWithMapping:(NSArray *)featureGroupMapping
{
    NSDictionary* userInfo = @{@"total": @"setupAllFeatureGroupsWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) loadBrandsPriority
{
    
    // make two requests to the server,
    
    // Get all brands "http://209.133.201.250:8080/brand?where={"priority":{"$gt":0}}&sort=priority desc&limit=-1"
    
    NSLog(@"Loading brands info");
    
    // get all product categories
    [self performRestGet:GET_PRIORITYBRANDS withParamaters:nil];
}

-(void) loadAllBrands
{
    
    // make two requests to the server,
    
    // Get all brands "http://209.133.201.250:8080/brand?where={"priority":{"$gt":0}}&sort=priority desc&limit=-1"
    
    NSLog(@"Loading all brands info");
    
    // get all product categories
    [self performRestGet:GET_ALLBRANDS withParamaters:nil];
}

-(void) setupPriorityBrandsWithMapping:(NSArray *)featureGroupMapping
{
    NSDictionary* userInfo = @{@"total": @"setupPriorityBrandsWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) setupAllBrandsWithMapping:(NSArray *)featureGroupMapping
{
    NSDictionary* userInfo = @{@"total": @"setupAllBrandsWithMapping"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
}

-(void) finishedLoadingFilterInfo
{
    //[self checkDebugProductGroup];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.bLoadingFilterInfo = NO;
    appDelegate.bLoadedFilterInfo = YES;
    
    
    appDelegate.productGroups = [NSMutableArray arrayWithArray:[self fetchProductCategories]];
    
    [self filterProductCategoryByFeatureGroupAndGender: appDelegate.productGroups];
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
                [productCategories addObject:pg];
            }
            else if (iNumFeatures == 1)
            {
                // only one featureGRoup, check if is gender
                if (![pg existsFeatureGroupByName:@"gender"])
                {
                    [productCategories addObject:pg];
                }
                else
                {
                    NSLog(@"Product category con un solo feature group y es gender. %@", pg.name);
                }
                
            }
        }
    }
}

int iNumDownloadingTask = 0;
int iNumMaxMessage = 4;
NSDate * timingDate;

-(void) closeSplashView:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    
    NSLog(@"*************************************** %@ %i %i", userInfo[@"total"], iNumDownloadingTask, iNumMaxMessage);
    
    if (![userInfo[@"total"] isEqualToString:@"getSearchKeywords"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([userInfo[@"total"] isEqualToString:@"ErrorConnection"])
        {
            if (appDelegate.bLoadingFilterInfo)
            {
                NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[errorMessage objectAtIndex:0]message:[errorMessage objectAtIndex:1] delegate:nil cancelButtonTitle:[errorMessage objectAtIndex:2] otherButtonTitles:nil];
                
                [alertView show];
            }
            
            appDelegate.splashScreen = NO;
            
            appDelegate.bLoadingFilterInfo = NO;
            appDelegate.bLoadedFilterInfo = NO;
            
            [self stopActivityFeedback];
            
            iNumDownloadingTask++;
            
            if((iNumDownloadingTask < iNumMaxMessage)&& (!appDelegate.bLoadedFilterInfo))
            {
                appDelegate.splashScreen = YES;
            }
        }
        else
        {
            iNumDownloadingTask++;
            if (iNumDownloadingTask > iNumMaxMessage)
            {
                
                appDelegate.splashScreen = NO;
                
                [self finishedLoadingFilterInfo];
                
                [self stopActivityFeedback];
                
                NSLog(@"SplashScreen Time taken: %f", [[NSDate date] timeIntervalSinceDate:timingDate]);
                
            }
        }
    }
}

- (void) getSearchKeywords
{
    NSLog(@"Fetching all keywords...");
    
    NSDate *methodStart = [NSDate date];
    NSString * requestString = [NSString stringWithFormat:@"/keyword?where={\"$or\":[{\"feature\":{\"$exists\":1}},{\"productcategory\":{\"$exists\":1}},{\"brand\":{\"$exists\":1}}]}&limit=-1"];
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:requestString
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
         
         NSDate *methodFinish = [NSDate date];
         
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         
         NSLog(@"Keywords List fetched! It took: %f", executionTime);
         
         NSDictionary* userInfo = @{@"total": @"getSearchKeywords"};
         [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingTask" object:nil userInfo:userInfo];
     }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         NSDate *methodFinish = [NSDate date];
         
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         
         // There was some problem with the communication with the GS server
         NSLog(@"Ooops! Keywords List NOT fetched...%f", executionTime);
     }];
}
#pragma mark - KeywordFromSearch

-(void) getKeywordFromMapping:(NSArray *)mappingResult inSuccesfulTerms:(NSMutableArray *) successfulTerms andInSuccessfulObjects:(NSMutableArray *)successfulObjects
{
    for (Keyword *keyword in mappingResult)
    {
        if([keyword isKindOfClass:[Keyword class]])
        {
            if(!(keyword.name == nil))
            {
                if (!([keyword.name isEqualToString:@""]))
                {
                    NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                    pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    if (!([successfulTerms containsObject:pene]))
                    {
                        
                        NSString *idElementKeyword = [keyword getIdElement];
                        
                        if (idElementKeyword != nil)
                        {
                            CoreDataQuery * objCoreDataQuery = [CoreDataQuery sharedCoreDataQuery];
                            ProductGroup *pg = [objCoreDataQuery getProductGroupFromId:idElementKeyword];
                            Feature *feat = [objCoreDataQuery getFeatureFromId:idElementKeyword];
                            Brand * brand = [objCoreDataQuery getBrandFromId:idElementKeyword];
                            
                            if (pg != nil)
                            {
                                if(pg.name != nil)
                                {
                                    if (successfulObjects != nil)
                                    {
                                        if ([successfulObjects containsObject:pg] == NO)
                                        {
                                            [successfulObjects addObject:pg];
                                        }
                                    }
                                    // Add the term to the set of terms
                                    //                                    if ([successfulTerms containsObject:[pg getNameForApp]] == NO)
                                    if ([successfulTerms containsObject:pg.name] == NO)
                                        //                                                    [_successfulTerms addObject:[pg getNameForApp]];
                                        [successfulTerms addObject:pg.name];
                                }
                            }
                            else if (feat != nil)
                            {
                                if(feat.name != nil)
                                {
                                    if (successfulObjects != nil)
                                    {
                                        if ([successfulObjects containsObject:feat] == NO)
                                        {
                                            [successfulObjects addObject:feat];
                                        }
                                    }
                                    // Add the term to the set of terms
                                    if ([successfulTerms containsObject:feat.name] == NO)
                                        [successfulTerms addObject:feat.name];
                                }
                            }
                            else if (brand != nil)
                            {
                                if(brand.name != nil)
                                {
                                    if (successfulObjects != nil)
                                    {
                                        if ([successfulObjects containsObject:brand] == NO)
                                        {
                                            [successfulObjects addObject:brand];
                                        }
                                    }
                                    // Add the term to the set of terms
                                    if ([successfulTerms containsObject:brand.name] == NO)
                                        [successfulTerms addObject:brand.name];
                                }
                            }
                            else
                            {
                                NSLog(@"keyword without element %@ - %@",keyword.name, idElementKeyword );
                            }
                        }
                        else
                        {
                            if ([keyword.userAdded boolValue])
                            {
                                if(keyword.name != nil)
                                {
                                    if (successfulObjects != nil)
                                    {
                                        if ([successfulObjects containsObject:keyword] == NO)
                                        {
                                            [successfulObjects addObject:keyword];
                                        }
                                    }
                                    if ([successfulTerms containsObject:keyword.name] == NO)
                                    {
                                        [successfulTerms addObject:keyword.name];
                                    }
                                }
                            }
                            else
                            {
                                NSLog(@"keyword with element is nil %@",keyword.name );
                            }
                        }
                        
                    }
                    
                }
            }
        }
    }
    
}

#pragma mark - Statistics
-(void) postAnayliticsIntervalTimeBetween:(NSDate *) startTime and:(NSDate *) endTime
{
    // need to be override in children
}

- (NSInteger)getADcount {
    return 3;
}

@end
