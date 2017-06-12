//
//  AppDelegate.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import "AppDelegate.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import <SSZipArchive.h>
#import "GSAccountCreatorManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <linkedin-sdk/LISDK.h>
#import "GSPostCategoryOrderManager.h"
#import "GSFashionistaPostViewController.h"
#import "FullVideoViewController.h"
#import "FashionistaProfileViewController.h"
#import "GSNewsFeedViewController.h"
#import "StoryViewController.h"

#import <sys/utsname.h>

#define kNumRunningsWithOutSignIn 5

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    //return YES;
    self.splashScreen = YES;
    
    self.addingProductsToWardrobeID = nil;
    
    self.tmpVCQueue = [[NSMutableArray alloc] init];
    self.tmpParametersQueue = [[NSMutableArray alloc] init];
    self.lastDismissedVCQueue = [[NSMutableArray alloc] init];
    self.lastDismissedParametersQueue = [[NSMutableArray alloc] init];
    
    // Get Configuration Info from the server
    // self.activityIndicator =  [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(55, 67, 25, 25)];
    //[self.activityIndicator startAnimating];
    //[self.view addSubview:self.activityIndicator];
    UIDevice *device = [UIDevice currentDevice];
    //Tell it to start monitoring the accelerometer for orientation
    [device beginGeneratingDeviceOrientationNotifications];
    //Get the notification centre for the app
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(orientationChanged:)        name:UIDeviceOrientationDidChangeNotification
             object:device];

    
    [self resetMenuIndex];
    [self initTabIndex];
    [self performSelectorInBackground:@selector(getAccountTypes) withObject:nil];
    //[self performSelectorInBackground:@selector(getConfig) withObject:nil];
    //[self getConfig];
    
    self.finger = [[Fingerprint alloc] init];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [Fabric with:@[[Twitter class]]];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([LISDKCallbackHandler shouldHandleUrl:url]) {
        return [LISDKCallbackHandler application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (void)resetMenuIndex{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:-1] forKey:GSLastMenuEntry];
    [defaults synchronize];
}

- (void)resetTabIndex{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:-1] forKey:GSLastTabSelected];
    [defaults synchronize];
}

- (void)initTabIndex{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:GSLastTabSelected];
    [defaults synchronize];
}


- (void)initializeApp{
    [self performSelectorInBackground:@selector(getPostCategoriesAndOrdering) withObject:nil];
}

- (void)startApp
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Email validated Code : %@", _currentUser.emailvalidatedcode);
    // If user never signed in, set default values to iOS defaults system
    // check if th user is not logged in and whic is the run number of the app
    //if ([self bIsSignedOutWithAttemptsLessThan:kNumRunningsWithOutSignIn])
    if ([self bIsSignedOutWithAttemptsLessThan:0])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDefaults];
            
            UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:nil];
            
            [self.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(NEWSFEED_VC) stringValue]]];
            
//            UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
//            
//            [self.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]]];
        });
    }
    //    if (![defaults boolForKey:@"UserSignedIn"])
    //    {
    //        [self setDefaults];
    //
    //        UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
    //
    //        [self.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(SIGNIN_VC) stringValue]]];
    //    }
    else
    {
        if (![defaults boolForKey:@"UserSignedIn"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // show login view controller
                UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"UserAccount" bundle:nil];
                
                [self.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(SIGNIN_VC) stringValue]]];
            });
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // we need the root view controller, to be the delegate of the login function
//                UIStoryboard *initialStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
//                [self.window setRootViewController:[initialStoryboard instantiateViewControllerWithIdentifier:[@(SEARCH_VC) stringValue]]];
                // make autologin
                
                // Create User
                NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                //        User *logInUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:currentContext];
                User * logInUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
                
                if (!(logInUser == nil))
                {
                    self.bAutoLogin = YES;
                    
                    [logInUser setDelegate:(BaseViewController*)self.window.rootViewController];
                    
                    [(BaseViewController*)self.window.rootViewController stopActivityFeedback];
                    [(BaseViewController*)self.window.rootViewController startActivityFeedbackWithMessage:NSLocalizedString(@"_LOGIN_ACTV_MSG_", nil)];
                    [logInUser logInUserWithUsername:[defaults objectForKey:@"eMail"] andPassword:[defaults objectForKey:@"Password"] andVerbose:FALSE];
                }
                //            return YES;
            });
        }
    }
    
    // Load data from GS database
    [self loadDataFromServerDB];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Report user ending session
    [self closeCurrentServerSession];
    
    // Save data to GS database
    [self saveDataToServerDB];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if(!([RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext == nil))
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults boolForKey:@"UserSignedIn"])
        {
            User * logInUser = nil;
            
            if(!(self.currentUser == nil))
            {
                logInUser = self.currentUser;
            }
            else
            {
                // Create User
                NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                //        User *logInUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:currentContext];
                logInUser = [[User alloc] initWithEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext: currentContext] insertIntoManagedObjectContext:currentContext];
            }
            
            if (!(logInUser == nil))
            {
                self.bAutoLogin = YES;
                
                [logInUser setDelegate:(BaseViewController*)self.window.rootViewController];
                
                [(BaseViewController*)self.window.rootViewController stopActivityFeedback];
                [(BaseViewController*)self.window.rootViewController startActivityFeedbackWithMessage:NSLocalizedString(@"_LOGIN_ACTV_MSG_", nil)];
                [logInUser logInUserWithUsername:[defaults objectForKey:@"eMail"] andPassword:[defaults objectForKey:@"Password"] andVerbose:FALSE];
            }
            //            return YES;
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Call the 'activateApp' method to log an app event for use
    // in analytics and advertising reporting.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString*) appVersion
{
    //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    //return [NSString stringWithFormat:@"%@ build %@", version, build];
    return build;
}

#pragma mark - Local iOS check number of app running


-(BOOL) bIsSignedOutWithAttemptsLessThan:(int) iNumAttempts
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL bRes = NO;
    
    if (![defaults boolForKey:@"UserSignedIn"])
    {
        int iCurrentNumAttempts = 0;
        // get num of attempts
        if ([defaults integerForKey:@"NumAttempts"])
        {
            iCurrentNumAttempts = (int)[defaults integerForKey:@"NumAttempts"];
        }
        NSLog(@"Num attempts: %i", iCurrentNumAttempts);
        if (iCurrentNumAttempts < iNumAttempts)
        {
            bRes = YES;
            [defaults setInteger:(iCurrentNumAttempts+1) forKey:@"NumAttempts"];
        }
        else
        {
            [defaults setInteger:0 forKey:@"NumAttempts"];
        }
        
        
        
        [self setDefaults];
    }
    return bRes;
}

#pragma mark - Local iOS defaults managememt


// Save default values to iOS defaults system
-(void)setDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Generate UUID if doesn't already exists
    if ([defaults objectForKey:@"UUID"] == nil)
    {
        [defaults setObject:[NSString uuid] forKey:@"UUID"];
        
        [defaults synchronize];
    }
    
    // To save user profile pic
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Female" ofType:@"png"];
    
    // Assign default values
    NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInteger:-1], @"UserID",
                                   [NSString stringWithFormat:NSLocalizedString(@"_NAME_", nil)], @"Name",
                                   [NSString stringWithFormat:NSLocalizedString(@"_SURNAME_", nil)], @"Surname",
//                                   [NSString stringWithFormat:NSLocalizedString(@"_EMAIL_", nil)], @"eMail",
//                                   [NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_1_", nil)], @"Password",
//                                   [NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_2_", nil)], @"Password2",
                                   [NSString stringWithFormat:NSLocalizedString(@"_PHONE_NUMBER_", nil)], @"Phonenumber",
                                   [NSString stringWithFormat:NSLocalizedString(@"_BIRTHDATE_", nil)], @"Birthdate",
                                   [NSNumber numberWithInteger:0], @"Gender",
                                   [NSNumber numberWithBool:YES], @"ProfilePicPermission",
                                   imagePath, @"ProfilePicPath",
                                   nil];
    
    // Save default values
    [defaults registerDefaults:defaultValues];
    
    // Make sure to overwrite the standard default values also
    
    // The following two lines reset ALL default values:
    //NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    
    // Since we ONLY want to reset 'User Account' default values (not, for example, if the instructions have been already shown), next lines only update those values
    // TO DO: Improve?
    
    [defaults setInteger:-1 forKey:@"UserID"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_NAME_", nil)] forKey:@"Name"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_SURNAME_", nil)] forKey:@"Surname"];
//    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_EMAIL_", nil)] forKey:@"eMail"];
//    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_1_", nil)] forKey:@"Password"];
//    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_PASSWORD_2_", nil)] forKey:@"Password2"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_PHONE_NUMBER_", nil)] forKey:@"Phonenumber"];
    [defaults setObject:[NSString stringWithFormat:NSLocalizedString(@"_BIRTHDATE_", nil)] forKey:@"Birthdate"];
    [defaults setInteger:0 forKey:@"Gender"];
    [defaults setBool:YES forKey:@"ProfilePicPermission"];
    [defaults setObject:imagePath forKey:@"ProfilePicPath"];
    [defaults setBool:FALSE forKey:@"UserSignedIn"];
    
    // Save to device defaults
    if (![defaults synchronize])
    {
        NSLog(@"Could not reset defaults!");
    }
    
    NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    if (_currentUser != nil)
    {
        [currentContext deleteObject:_currentUser];
    
        NSError * error = nil;
        if (![currentContext save:&error])
        {
            NSLog(@"Error saving context! %@", error);
        }
        
    }
    
    _currentUser = nil;
    
}

-(void)setCurrentUser:(User *)newUser
{
//    NSManagedObjectContext * currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
//    if (_currentUser != nil)
//        [currentContext deleteObject:_currentUser];
//    
//    NSError * error = nil;
//    if (![currentContext save:&error])
//    {
//        NSLog(@"Error saving context! %@", error);
//    }
    [self resetMenuIndex];
    _currentUser = newUser;
}


#pragma mark - RestKit & CoreData setup & managememt


// Reset Core Data
- (void) resetRKCoreData
{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite"];
    
    NSLog(@"Deleting: %@", storePath);
    
    [fileManager removeItemAtPath:storePath error:NULL];
    if (DOWNLOAD_3_FILES)
    {
        storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite-shm"];
        
        NSLog(@"Deleting: %@", storePath);
        
        [fileManager removeItemAtPath:storePath error:NULL];
        
        storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite-wal"];
        
        NSLog(@"Deleting: %@", storePath);
        
        [fileManager removeItemAtPath:storePath error:NULL];
    }
    
    [[RKManagedObjectStore defaultStore] resetPersistentStores:nil];
    
    [RKObjectManager setSharedManager:nil];
    
    [RKManagedObjectStore setDefaultStore:nil];
}

-(void) removeCoreDateFiles
{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite"];
    
    NSLog(@"Deleting: %@", storePath);
    
    [fileManager removeItemAtPath:storePath error:NULL];
    
    if (DOWNLOAD_3_FILES)
    {
        storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite-shm"];
        
        NSLog(@"Deleting: %@", storePath);
        
        [fileManager removeItemAtPath:storePath error:NULL];
        
        storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite-wal"];
        
        NSLog(@"Deleting: %@", storePath);
        
        [fileManager removeItemAtPath:storePath error:NULL];
    }
    
    [RKObjectManager setSharedManager:nil];
    
    [RKManagedObjectStore setDefaultStore:nil];

}

// Reload Core Data
- (void) reloadLocalRKCoreData
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    // SQLITE
    
    NSString * initialPath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"initialDB_GoldenSpear.sqlite"];
    
    NSString * storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite"];
    
    NSLog(@"Deleting: %@", storePath);
    
    [fileManager removeItemAtPath:storePath error:NULL];
    
    NSError *error;
    
    [fileManager copyItemAtPath:initialPath toPath:storePath error:&error];
    
    if(!(error == nil))
    {
        NSLog(@"Failed storing %@ into %@ with error: %@", initialPath, storePath, error);
        
        [self resetRKCoreData];
        
        return;
    }
    else
    {
        NSLog(@"Successfully stored %@ into %@", initialPath, storePath);
    }
    
    
    //SQLITE-SHM
    if (DOWNLOAD_3_FILES)
    {
        initialPath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"initialDB_GoldenSpear.sqlite-shm"];
        
        storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite-shm"];
        
        NSLog(@"Deleting: %@", storePath);
        
        [fileManager removeItemAtPath:storePath error:NULL];
        
        error = nil;
        
        [fileManager copyItemAtPath:initialPath toPath:storePath error:&error];
        
        if(!(error == nil))
        {
            NSLog(@"Failed storing %@ into %@ with error: %@", initialPath, storePath, error);
            
            [self resetRKCoreData];
            
            return;
        }
        else
        {
            NSLog(@"Successfully stored %@ into %@", initialPath, storePath);
        }
        
        
        //SQLITE-WAL
        
        initialPath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"initialDB_GoldenSpear.sqlite-wal"];
        
        storePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite-wal"];
        
        NSLog(@"Deleting: %@", storePath);
        
        [fileManager removeItemAtPath:storePath error:NULL];
        
        error = nil;
        
        [fileManager copyItemAtPath:initialPath toPath:storePath error:&error];
        
        if(!(error == nil))
        {
            NSLog(@"Failed storing %@ into %@ with error: %@", initialPath, storePath, error);
            
            [self resetRKCoreData];
            
            return;
        }
        else
        {
            NSLog(@"Successfully stored %@ into %@", initialPath, storePath);
        }
    }
    
    self.bLoadedFilterInfo = YES;
}

// Setup RestKit and Core Data
- (void)setupRestKit
{
    // Set high log level
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelOff);
    RKLogConfigureByName("RestKit/Network", RKLogLevelOff);
    RKLogConfigureByName("RestKit/CoreData/Cache", RKLogLevelOff);
    
    // Setup MODEL
    
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GoldenSpear" ofType:@"momd"]];
    
    // NOTE: Due to an iOS bug, the managed object model returned is immutable.
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    
    // Setup STORE
    
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSError *error = nil;
    
    NSDictionary * dictOption = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSSQLiteManualVacuumOption];
    
    [managedObjectStore addSQLitePersistentStoreAtPath:[[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite"]
                                fromSeedDatabaseAtPath:nil
                                     withConfiguration:nil
                                               options:@{ NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" } }
                                                 error:&error];
    
    // error setting up the file for the coredata.
    if (error)
    {
        // trying to remove the existing one, and let Coredata to create new ones.
        NSLog(@"Whoops, couldn't create store. First attempt: %@", error);
        
        // remove the sqlite files
        [self removeCoreDateFiles];
        
        error = nil;
        
        // force to dowload the filter info from the database
        self.bLoadedFilterInfo = NO;
        self.bLoadingFilterInfo = NO;
        
        [managedObjectStore addSQLitePersistentStoreAtPath:[[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite"]
                                    fromSeedDatabaseAtPath:nil
                                         withConfiguration:nil
                                                   options:@{ NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" } }
                                                     error:&error];
        
        if (error)
        {
            // error setting up the coredata file.
            NSLog(@"Whoops, couldn't create store: %@", error);
//            initialDB_GoldenSpear.sqlite
            return;
        }
        
//        return;
    }
    
    [managedObjectStore createManagedObjectContexts];
    
    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    // Setup CACHE
    
    managedObjectStore.managedObjectCache = [[RKFetchRequestManagedObjectCache alloc] init];
                                             //initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    // Setup OBJECT MANAGER
    
    [RKObjectManager managerWithBaseURL:[NSURL URLWithString:RESTBASEURL]];
    
    [RKObjectManager sharedManager].managedObjectStore = managedObjectStore;
    
    //[[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext setRetainsRegisteredObjects:YES];
    
    // Setup objects mapping
    [[RKObjectManager sharedManager] defineMappings];
}

// Get the model name used by the current Managed Object
- (NSString *)currentManagedObjectModelName
{
    //Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd"
                                                            inDirectory:nil];
    for (NSString *momdPath in momdArray)
    {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                            inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom"
                                                              inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    
    if ([modelPaths count] > 0)
    {
        return [[[modelPaths lastObject] lastPathComponent] stringByDeletingPathExtension];
    }
    
    return nil;
}


#pragma mark - Data managememt: load and save standard data from/to server

// Request the user Stylit pages from the GS server
- (void) getCurrentUserPagesList
{
    BaseViewController * baseController = (BaseViewController*)self.window.rootViewController;
    
    if (!(_currentUser == nil))
    {
        if(!(_currentUser.idUser == nil))
        {
            if(!([_currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentUser.idUser, nil];
                
                [baseController performRestGet:GET_FASHIONISTAPAGES withParamaters:requestParameters];
            }
        }
    }
}

- (void)getFollowingsAndNoticesForCurrentUser{
    if (!(_currentUser == nil))
    {
        [_currentUser getUserPostUnfollows];
        [_currentUser getUserPostUnnoticed];
        [_currentUser getUserUserUnnoticed];
    }
}

// Request the user wardrobes from the GS server
- (void) getCurrentUserWardrobesList
{
    BaseViewController * baseController = (BaseViewController*)self.window.rootViewController;
    
    if (!(_currentUser == nil))
    {
        if(!(_currentUser.idUser == nil))
        {
            if(!([_currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentUser.idUser, nil];
                
                [baseController performRestGet:GET_USER_WARDROBES withParamaters:requestParameters];
            }
        }
    }
}

// Request the user follows from the GS server
- (void) getCurrentUserFollowsList
{
    BaseViewController * baseController = (BaseViewController*)self.window.rootViewController;
    
    if (!(_currentUser == nil))
    {
        if(!(_currentUser.idUser == nil))
        {
            if(!([_currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentUser.idUser, nil];
                
                [baseController performRestGet:GET_USER_FOLLOWS withParamaters:requestParameters];
            }
        }
    }
}

// Request the user notifications from the GS server
- (void) getCurrentUserNotificationsList
{
    BaseViewController * baseController = (BaseViewController*)self.window.rootViewController;
    
    if (!(_currentUser == nil))
    {
        if(!(_currentUser.idUser == nil))
        {
            if(!([_currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentUser.idUser, nil];
                
                [baseController performRestGet:GET_USER_NOTIFICATIONS withParamaters:requestParameters];
            }
        }
    }
}

// Request the BackgroundAd to be shown to the user
- (void) getBackgroundAdForCurrentUser
{
    BaseViewController * baseController = (BaseViewController*)self.window.rootViewController;
 
    if (!(_currentUser == nil))
    {
        if(!(_currentUser.idUser == nil))
        {
            if(!([_currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:_currentUser.idUser, nil];

                [baseController performRestGet:GET_FULLSCREENBACKGROUNDAD withParamaters:requestParameters];
                
                [baseController performRestGet:GET_SEARCHADAPTEDBACKGROUNDAD withParamaters:requestParameters];
                
                [baseController performRestGet:GET_POSTADAPTEDBACKGROUNDAD withParamaters:requestParameters];
                
                return;
            }
        }
    }
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:@"", nil];
    
    [baseController performRestGet:GET_FULLSCREENBACKGROUNDAD withParamaters:requestParameters];
    
    [baseController performRestGet:GET_SEARCHADAPTEDBACKGROUNDAD withParamaters:requestParameters];

    [baseController performRestGet:GET_POSTADAPTEDBACKGROUNDAD withParamaters:requestParameters];
}

- (void) getCurrentUserInitialData
{   
    
//return; // TO REGENERATE LAST COREDATA FILES!!!
        // ALSO SET DATA = NIL IN 'getInitialDB'
        // ALSO SET RETURN IN SearchBaseViewController::'viewWillAppear'
        // ALSO SET RETURN IN SearchBaseViewController::'actionAfterLogIn'
    
    [self getCurrentUserWardrobesList];
    [self getCurrentUserFollowsList];
    [self getCurrentUserNotificationsList];
    [NSTimer scheduledTimerWithTimeInterval:30
                                     target:self
                                   selector:@selector(getCurrentUserNotificationsList)
                                   userInfo:nil
                                    repeats:YES];
    //[self getCurrentUserNotificationsList];
    [self getBackgroundAdForCurrentUser];
    [self getFollowingsAndNoticesForCurrentUser];
    
//    [self getCurrentUserPagesList];
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
     }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         // There was some problem with the communication with the GS server
         NSLog(@"Ooops! Keywords List NOT fetched...");
     }];
    
    /*  NSError *err;
     
     NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", RESTBASEURL, @"/keyword?limit=-1"]];
     
     NSURLRequest *req=[NSURLRequest requestWithURL:url];
     
     NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:&err];
     
     NSDictionary *json=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
     
     NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
     
     for(NSDictionary *item in json)
     {
     Keyword *newKeyword = [[Keyword alloc] initWithEntity:[NSEntityDescription entityForName:@"Keyword" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
     
     [newKeyword setIdKeyword:(NSString *)([item valueForKey:@"id"])];
     
     [newKeyword setName:(NSString *)([item valueForKey:@"name"])];
     }
     
     NSDate *methodFinish = [NSDate date];
     
     NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
     
     NSLog(@"Keywords List fetched! It took: %f", executionTime);
     */}

- (void) getBrands
{
    NSLog(@"Fetching all brands...");
    
    NSDate *methodStart = [NSDate date];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/brand?limit=-1"
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
     {
         // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
         
         NSDate *methodFinish = [NSDate date];
         
         NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
         
         NSLog(@"Brands List fetched! It took: %f", executionTime);
     }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         // There was some problem with the communication with the GS server
         NSLog(@"Ooops! Brands List NOT fetched...");
     }];
}

// Load basic information from the database
-(BOOL)loadDataFromServerDB
{
    //    BaseViewController * baseController = (BaseViewController*)self.window.rootViewController;
    //    [baseController stopActivityFeedback];
    //    [baseController startActivityFeedbackWithMessage:NSLocalizedString(@"Loading...", nil)];
    
    //[self getCurrentUserInitialData];
    
    //    [self getSearchKeywords];
    
    //    [self getBrands];
    
    //[baseController stopActivityFeedback];
    
    return TRUE;
}

-(void) getInitialDB
{
    NSLog(@"Fetching initial Data Base...");
    
    NSURLResponse* urlResponse;
    NSError* error;
    
    
    NSString * appVersion = [self appVersion];
    
    NSDate *methodStart = [NSDate date];
    
    NSURL *requestURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/initialDB/GoldenSpear_%@.sqlite.zip", IMAGESBASEURL, appVersion]];
    
    //    NSData *data = [NSData dataWithContentsOfURL:requestURL];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];

    int statusCode = (int)[((NSHTTPURLResponse *)urlResponse) statusCode];

//    data = nil; // TO REGENERATE LAST COREDATA FILES!!!
    // ALSO SET RETURN IN 'getCurrentUserInitialData'
    // ALSO SET RETURN IN SearchBaseViewController::'viewWillAppear'
    // ALSO SET RETURN IN SearchBaseViewController::'actionAfterLogIn'

    if(!(data == nil) && statusCode != 404)
    {
        NSString* savePathZip = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"GoldenSpear.sqlite.zip"];
        NSString* unzipPath = [[self applicationDocumentsDirectory] path]/* stringByAppendingPathComponent:@"initialDB_GoldenSpear.sqlite"]*/;
        NSString* savePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"initialDB_GoldenSpear.sqlite"];
        
        // save the data received by the server as a zip files
        if ([data writeToFile:savePathZip atomically:YES])
        {
            NSError * error;
            // decompress the zip files
            self.bLoadedFilterInfo = [SSZipArchive unzipFileAtPath:savePathZip toDestination:unzipPath overwrite:YES password:@"" error:&error];
            if (self.bLoadedFilterInfo)
            {
                // copy the file results from the decompress process as the initialDB_GoldenSpear.sqlite
                NSFileManager * fileManager = [NSFileManager defaultManager];
                
                NSString * unzipedFile = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:[NSString stringWithFormat:@"GoldenSpear_%@.sqlite", appVersion]];
                
                NSError *error;
                
                [fileManager removeItemAtPath:savePath error:NULL];
                self.bLoadedFilterInfo = [fileManager copyItemAtPath:unzipedFile toPath:savePath error:&error];
                
                NSLog(@"Deleting zip files: %@\n%@", unzipedFile, savePathZip);

                [fileManager removeItemAtPath:unzipedFile error:NULL];
                [fileManager removeItemAtPath:savePathZip error:NULL];
                
            }
        }
        
//        self.bLoadedFilterInfo = [data writeToFile:savePath atomically:YES];
        
        if(self.bLoadedFilterInfo)
        {
            if (DOWNLOAD_3_FILES)
            {
                requestURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/initialDB/GoldenSpear_%@.sqlite-shm", IMAGESBASEURL, appVersion]];
                
                //           data = [NSData dataWithContentsOfURL:requestURL];
                urlRequest = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
                data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
                int statusCode = (int)[((NSHTTPURLResponse *)urlResponse) statusCode];
                
                if(!(data == nil) && statusCode != 404)
                {
                    NSString* savePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"initialDB_GoldenSpear.sqlite-shm"];
                    
                    self.bLoadedFilterInfo = self.bLoadedFilterInfo && [data writeToFile:savePath atomically:YES];
                    
                    if(self.bLoadedFilterInfo)
                    {
                        requestURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@/initialDB/GoldenSpear_%@.sqlite-wal", IMAGESBASEURL, appVersion]];
                        
                        //data = [NSData dataWithContentsOfURL:requestURL];
                        urlRequest = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
                        data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
                        int statusCode = (int)[((NSHTTPURLResponse *)urlResponse) statusCode];
                        
                        if(!(data == nil) && statusCode != 404)
                        {
                            NSString* savePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"initialDB_GoldenSpear.sqlite-wal"];
                            
                            self.bLoadedFilterInfo = self.bLoadedFilterInfo && [data writeToFile:savePath atomically:YES];
                            
                            NSDate *methodFinish = [NSDate date];
                            
                            NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                            
                            NSLog(@"Downloading initial DB succeed!! It took: %f", executionTime);
                            
                            //Save last update in UserDefaults
                            
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            
                            [defaults setObject:[self.config valueForKey:[NSString stringWithFormat:@"last_update_%@", appVersion]] forKey:@"lastLocalDBUpdate"];
                            
                            [defaults synchronize];
                        }
                        else
                        {
                            // Reset RestKit
                            [self resetRKCoreData];
                        }
                    }
                    else
                    {
                        // Reset RestKit
                        [self resetRKCoreData];
                    }
                }
                else
                {
                    // Reset RestKit
                    [self resetRKCoreData];
                }
            }
            else
            {
                //Save last update in UserDefaults
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                [defaults setObject:[self.config valueForKey:[NSString stringWithFormat:@"last_update_%@", appVersion]] forKey:@"lastLocalDBUpdate"];
                
                [defaults synchronize];
                
            }
        }
        else
        {
            // Reset RestKit
            [self resetRKCoreData];
        }
    }
    else
    {
        // Reset RestKit
        [self resetRKCoreData];
    }
    
    [self reloadLocalRKCoreData];
    
    // Setup RestKit
    [self setupRestKit];
    
    [self initializeApp];
}

-(void) getAccountTypes{
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/typeprofession", RESTBASEURL]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [configRequest setHTTPMethod:@"GET"];
    
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        id json = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
        [[GSAccountCreatorManager sharedManager] setAccountTypes:json];
    }
    [self performSelectorInBackground:@selector(getConfig) withObject:nil];
}

- (void)getPostCategoriesAndOrdering{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueAfterGettingPostCategoriesAndOrdering) name:kGSPCOManagerFinishedDownloadingNotification object:nil];
    [GSPostCategoryOrderManager downloadData:YES];
}

- (void)continueAfterGettingPostCategoriesAndOrdering{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGSPCOManagerFinishedDownloadingNotification object:nil];
    [self performSelectorInBackground:@selector(startApp) withObject:nil];
}

-(void) getConfig
{
    // Setup and perform the request to get the config from the server
    
    NSString * appVersion = [self appVersion];
    
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/config", RESTBASEURL]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [configRequest setHTTPMethod:@"GET"];
    
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        self.config = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
        
        /// UNCOMMENT TO FORCE HAVING THE SPEAR-THE-PIC FEATURE! >
        [self.config setValue:@(YES) forKey:@"visual_search"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (FORCE_DOWNLOAD_DATA)
        {
            self.bForceDownloadData = YES;
            self.bLoadedFilterInfo = NO;
            self.bLoadingFilterInfo = NO;
            
            // reset coredata
            [self resetRKCoreData];
            
            // setup restkit
            [self setupRestKit];
            
            // inicializamos la app
            [self initializeApp];
        }
        else
        {
            self.bForceDownloadData = NO;
            if (![defaults objectForKey:@"lastLocalDBUpdate"])
            {
                [self getInitialDB];
            }
            else
            {
                NSDate * lastLocalDBUpdate = [defaults objectForKey:@"lastLocalDBUpdate"];
                
                NSDate * currentServerDBVersion = [self.config valueForKey:[NSString stringWithFormat:@"last_update_%@", appVersion]];
                
                if((lastLocalDBUpdate == nil) || (currentServerDBVersion == nil))
                {
                    [self getInitialDB];
                }
                else if (!([lastLocalDBUpdate compare:currentServerDBVersion] == NSOrderedSame))
                {
                    [self getInitialDB];
                }
                else
                {
                    // Copy core data files
                    [self reloadLocalRKCoreData];
                    
                    // Setup RestKit
                    [self setupRestKit];
                    
                    [self initializeApp];
                }
            }
        }

    }
    else
    {
        NSString * def = [NSString stringWithFormat:@""
                          "{"
                          "\"visual_search\": false,"
                          "\"tag_post_auto_swap\": false,"
                          "\"load_filters_from_server\": false,"
                          "\"order_filter_default\": [\"gender\", \"style\", \"brands\", \"color\", \"prices\", \"features\"],"
                          "\"order_filter_history\": [\"history\", \"gender\", \"style\", \"brands\", \"color\", \"prices\", \"features\"],"
                          "\"order_filter_products\": [\"gender\", \"style\", \"brands\", \"color\", \"prices\", \"features\"],"
                          "\"order_filter_fashionistas\": [\"gender\", \"stylestylist\", \"location\", \"follower\"],"
                          "\"order_filter_post\": [\"gender\", \"follower\", \"stylestylist\", \"location\"],"
                          "\"profession_stylist\": [\"\", \"Fan\", \"Model\", \"Photographer\", \"Filmaker\", \"Casting Director\", \"Makeup Artist\", \"Hair Stylist\", \"Wardrobe Stylist\", \"Retoucher\", \"Artist Painter\", \"Body painter\", \"Clothing designer\", \"Digital Artist\", \"Blogger (Individual)\", \"Event Planner (Individual)\", \"Advertiser (Individual)\", \"Fashion Brand\", \"Publication\", \"Event Planer (Group)\", \"Advertiser (Group)\", \"Blogger (Group)\"],"
                          "\"gender_types\": [\"\", \"Male\", \"Female\"],"
                          "\"haircolor_types\": [\"\", \"Auburn\", \"Black\", \"Blonde\", \"Dredlocks\", \"Grey\", \"Red\", \"Other\"],"
                          "\"hairlength_types\": [\"\", \"Bald\", \"Short\", \"Shoulder Length\", \"Medium\", \"Long\", \"Very Long\"],"
                          "\"eyecolor_types\": [\"\", \"Black\", \"Blue\", \"Brown\", \"Green\", \"Grey\", \"Hazel\", \"Other\"],"
                          "\"skincolor_types\": [\"\", \"Brown\", \"Olive\", \"Tanned\", \"White\", \"Other\"],"
                          "\"ethnicity_types\": [\"\", \"Asian\", \"Black\", \"Caucasian\", \"Eastern European\", \"Western European\", \"East Indian\", \"Pacific Islander\", \"No Answer\", \"Other\"],"
                          "\"shootnudes_types\": [\"\", \"No\", \"Yes\"],"
                          "\"tatoos_types\": [\"\", \"None\", \"Some\", \"Many\"],"
                          "\"piercings_types\": [\"\", \"None\", \"Some\", \"Many\"],"
                          "\"relationship_types\": [\"\", \"Single\", \"Married\", \"It is Complicated\", \"Engaged\"],"
                          "\"experience_types\": [\"\", \"No  Experience\", \"Some Experience\", \"Experienceed\", \"Very Experienceed\"],"
                          "\"compensation_types\": [\"\", \"Any\", \"Depends on project\", \"Paid projects only\", \"Time for print\"],"
                          "\"genre_types\": [\"\", \"Acting\", \"Bodypaint\", \"Cosplay\", \"Dance\", \"Editorial\", \"Erotic\", \"Fashion\", \"Fetish\", \"Fit Modeling\", \"Fitness\", \"Glamour\", \"Hair/Makeup\", \"Lifestyle\", \"Lingerie\", \"Parts Modeling\", \"Performance Artist\", \"Pinup\", \"Pregnancy\", \"Promotional Modeling\", \"Runaway\", \"Spokesperson/Host\", \"Sports\", \"Stunt\", \"Swimwear\", \"Underwear\"],"
                          "\"cup_types\": [\"\", \"A\", \"B\", \"C\", \"D\", \"DD\", \"DDD\", \"E\", \"EE\", \"EEE\", \"F\", \"FF\", \"FFF\", \"G\", \"GG\", \"GGG\"],"
                          "\"dress_types\": [\"\", \"XS\", \"S\", \"M\", \"L\", \"XL\", \"XXL\", \"XXXL\"],"
                          "\"shoe_types\": [\"\", \"1\", \"1,5\", \"2\", \"2,5\", \"3\", \"3,5\", \"4\", \"4,5\", \"5\", \"5,5\", \"6\", \"6,5\", \"7\", \"7,5\", \"8\", \"8,5\", \"9\", \"9,5\", \"10\", \"10,5\", \"11\", \"11,5\", \"12\", \"12,5\", \"13\", \"13,5\", \"14\", \"14,5\", \"15\", \"15,5\", \"16\", \"16,5\", \"17\", \"17,5\", \"18\", \"18,5\", \"19\", \"19,5\", \"20\", \"20,5\", \"21\", \"21,5\", \"22\", \"22,5\", \"23\", \"23,5\", \"24\", \"24,5\", \"25\", \"25,5\", \"26\", \"26,5\", \"27\", \"27,5\", \"28\", \"28,5\", \"29\", \"29,5\", \"30\", \"30,5\"],"
                          "\"measure_types\": [\"\", \"Metric (kg/cm)\", \"Imperial (lb/inches)\"]"
                          "}"];
        
        NSData * configDefaultData = [def dataUsingEncoding:NSUTF8StringEncoding];
        self.config = [NSJSONSerialization JSONObjectWithData:configDefaultData options: NSJSONReadingMutableContainers error: &requestError];
        // Reset RestKit
        [self getInitialDB];
    }
}

-(BOOL) isConfigSearchCpp
{
    BOOL bSearchCpp = NO;
    
    // Setup and perform the request to get the config from the server
    
    NSMutableURLRequest *configRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/configserchcpp", RESTBASEURL]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    [configRequest setHTTPMethod:@"GET"];
    
    [configRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    
    NSError *requestError;
    
    NSURLResponse *requestResponse;
    
    NSData *configResponseData = [NSURLConnection sendSynchronousRequest:configRequest returningResponse:&requestResponse error:&requestError];
    int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
    
    if(!(configResponseData == nil) && statusCode != 404)
    {
        NSDictionary * config = [NSJSONSerialization JSONObjectWithData:configResponseData options: NSJSONReadingMutableContainers error: &requestError];
        bSearchCpp = [[config valueForKey:@"searchcpp"] boolValue];
    }
    
    return bSearchCpp;
}


// Report user ending session
- (BOOL) closeCurrentServerSession
{
    if(!(self.currentUser == nil))
    {
        if(!(self.currentUser.idUser == nil))
        {
            if(!([self.currentUser.idUser isEqualToString:@""]))
            {
                // Setup and perform the request to put the 'endsession' on the server
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

                NSMutableURLRequest *endSessionRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/endsession?updatedAtLocal=%@", RESTBASEURL, [dateFormatter stringFromDate:[NSDate date]]]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
                
                [endSessionRequest setHTTPMethod:@"POST"];
                
                [endSessionRequest setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
                
                NSError *requestError;
                
                NSURLResponse *requestResponse;
                
                NSData *endSessionResponseData = [NSURLConnection sendSynchronousRequest:endSessionRequest returningResponse:&requestResponse error:&requestError];
                
                int statusCode = (int)[((NSHTTPURLResponse *)requestResponse) statusCode];
                
                if(!(endSessionResponseData == nil) && statusCode != 404)
                {
                    NSLog(@"Reported end session!");
                    
                    return YES;
                }
                else
                {
                    NSLog(@"Didn't work reporting end session!");
                    
                    return NO;
                }
            }
        }
    }
    
    return NO;
}

// Save information to the database
-(BOOL)saveDataToServerDB
{
    return TRUE;
}

-(void) cycleGlobalMailComposer
{
    // To solve an issue with iOS 8 (see http://stackoverflow.com/questions/25604552/i-have-real-misunderstanding-with-mfmailcomposeviewcontroller-in-swift-ios8-in/25864182#25864182)
    self.globalMailComposer = nil;
    self.globalMailComposer = [[MFMailComposeViewController alloc] init];
}


-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController * topMostController = window.rootViewController;
    while (topMostController.presentedViewController != nil)
    {
        topMostController = topMostController.presentedViewController;
    }
    NSString * controllerName = NSStringFromClass([topMostController class]);
    
    if([controllerName isEqualToString:@"NYTPhotosViewController"])
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    if([controllerName isEqualToString:@"FullVideoViewController"]) {
        FullVideoViewController *videoVC = (FullVideoViewController*)topMostController;
        if (videoVC.isPresented) {
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
        }
        else
            return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)orientationChanged:(NSNotification *)note
{
    //    if ([[note object] orientation] == UIDeviceOrientationIsPortrait(<#UIDeviceOrientation orientation#>))
    
    UIViewController * topMostController = self.window.rootViewController;
    while (topMostController.presentedViewController != nil)
    {
        topMostController = topMostController.presentedViewController;
    }
    NSString * controllerName = NSStringFromClass([topMostController class]);
    
    
    UIDevice *device = [note object];
    if ([device orientation] == UIDeviceOrientationPortrait) {
        NSLog(@"Portrait Mode");
        if ([controllerName isEqualToString:@"FullVideoViewController"]) {
            [((FullVideoViewController*)topMostController) closeView];
        }
    }
    else if ([device orientation] == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"LandscapeLeft Mode");
        if([controllerName isEqualToString:@"GSFashionistaPostViewController"])
        {
            [((GSFashionistaPostViewController*)topMostController) showFullVideo:LANDSCAPE_LEFT];
        }
        else if ([controllerName isEqualToString:@"FashionistaProfileViewController"]) {
            [((FashionistaProfileViewController*)topMostController) showFullVideo:LANDSCAPE_LEFT];
        }
        else if ([controllerName isEqualToString:@"GSNewsFeedViewController"]) {
            [((GSNewsFeedViewController*)topMostController) showFullVideo:LANDSCAPE_LEFT];
        }
        else if ([controllerName isEqualToString:@"StoryViewController"]) {
            
        }
    }
    else if ([device orientation] == UIDeviceOrientationLandscapeRight) {
        NSLog(@"LandscapeRight Mode");
        if([controllerName isEqualToString:@"GSFashionistaPostViewController"])
        {
            [((GSFashionistaPostViewController*)topMostController) showFullVideo:LANDSCAPE_RIGHT];
        }
        else if ([controllerName isEqualToString:@"FashionistaProfileViewController"]) {
            [((FashionistaProfileViewController*)topMostController) showFullVideo:LANDSCAPE_RIGHT];
        }
        else if ([controllerName isEqualToString:@"GSNewsFeedViewController"]) {
            [((GSNewsFeedViewController*)topMostController) showFullVideo:LANDSCAPE_RIGHT];
        }
    }
}

+ (NSString *) getDeviceName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"x86_64"    :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",        // (Original)
                              @"iPod2,1"   :@"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   :@"iPod Touch",        // (6th Generation)
                              @"iPhone1,1" :@"iPhone",            // (Original)
                              @"iPhone1,2" :@"iPhone",            // (3G)
                              @"iPhone2,1" :@"iPhone",            // (3GS)
                              @"iPad1,1"   :@"iPad",              // (Original)
                              @"iPad2,1"   :@"iPad 2",            //
                              @"iPad3,1"   :@"iPad",              // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",          // (GSM)
                              @"iPhone3,3" :@"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",         //
                              @"iPhone5,1" :@"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",              // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",         // (Original)
                              @"iPhone5,3" :@"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",     //
                              @"iPhone7,2" :@"iPhone 6",          //
                              @"iPhone8,1" :@"iPhone 6S",         //
                              @"iPhone8,2" :@"iPhone 6S Plus",    //
                              @"iPhone8,4" :@"iPhone SE",         //
                              @"iPhone9,1" :@"iPhone 7",          //
                              @"iPhone9,3" :@"iPhone 7",          //
                              @"iPhone9,2" :@"iPhone 7 Plus",     //
                              @"iPhone9,4" :@"iPhone 7 Plus",     //
                              
                              @"iPad4,1"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   :@"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
                              @"iPad6,8"   :@"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
                              @"iPad6,3"   :@"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   :@"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
        else {
            deviceName = @"Unknown";
        }
    }
    
    return deviceName;
    
}

+ (NSString *) getOSVersion
{
    UIDevice * device = [UIDevice currentDevice];
    
    return device.systemVersion;
}


@end
