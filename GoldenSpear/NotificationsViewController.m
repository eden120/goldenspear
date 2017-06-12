//
//  NotificationsViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 17/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NotificationsViewController.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+MainMenuManagement.h"
#import "BaseViewController+UserManagement.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import "BaseViewController+FetchedResultsManagement.h"
#import "NSString+AttributtedNSString.h"

#import "NotificationsPostTableViewCell.h"


#define kFontInNotificationText "Avenir-Light"
#define kBoldFontInNotificationText "Avenir-Heavy"
#define kFontSizeInNotificationText 14
#define kCellHeight 50

@interface NotificationsViewController ()

@end

UIButton * buttonForHighlighting = nil;

@implementation NotificationsViewController

- (void)dealloc{
    self.imagesQueue = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNotificationsCollection];
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    //self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (BOOL)shouldCenterTitle{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.currentPresenterViewController){
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.topDistanceConstraint.constant = 0;
        self.bottomDistanceConstraint.constant = 0;
    }else{
        self.view.translatesAutoresizingMaskIntoConstraints = YES;
        self.topDistanceConstraint.constant = 60;
        self.bottomDistanceConstraint.constant = 60;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                
                [self performRestGet:GET_USER_NOTIFICATIONS withParamaters:requestParameters];
            }
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!((_numberOfNewNotifications * kCellHeight) > self.view.frame.size.height))
    {
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(resetNotificationsNumber) userInfo:nil repeats:NO];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resetNotificationsNumber];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.mainCollectionView)
    {
        if(_numberOfNewNotifications > 0)
        {
            if(scrollView.contentOffset.y >= (_numberOfNewNotifications * kCellHeight))
            {
                [self resetNotificationsNumber];
            }
        }
    }
}

- (void) resetNotificationsNumber
{
    _numberOfNewNotifications = 0;
    
    NSString *newNotificationSubtitle = NSLocalizedString(@"_NO_NEW_NOTIFICATIONS_", nil);
    
    [self setTopBarTitle:nil andSubtitle:newNotificationSubtitle];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate setUserNewNotifications:[NSNumber numberWithInt:_numberOfNewNotifications]];
    [self setupNotificationsLabel];
    [self initMainMenu];
}


// Initialize fetched Results Controller to fetch the current user wardrobes in order to properly show the hanger button
- (BOOL)initFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_usersFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_usersFetchRequest == nil)
        {
            if([arrayForPredicate count] > 0)
            {
                _usersFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [_usersFetchRequest setEntity:entity];
                
                // Filter results
                
                [_usersFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [_usersFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [_usersFetchRequest setFetchBatchSize:20];
            }
        }
        
        if(_usersFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_usersFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _usersFetchedResultsController = fetchedResultsController;
            
            _usersFetchedResultsController.delegate = self;
        }
        
        if(_usersFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_usersFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_usersFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}

// Initialize a specific Fetched Results Controller to fetch the current user follows in order to properly show the heart button
- (BOOL)initFollowsFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_followsFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_followsFetchRequest == nil)
        {
            if([arrayForPredicate count] > 0)
            {
                _followsFetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity to look for
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                
                [_followsFetchRequest setEntity:entity];
                
                // Filter results
                
                [_followsFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
                
                // Sort results
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                
                [_followsFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                [_followsFetchRequest setFetchBatchSize:20];
            }
        }
        
        if(_followsFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_followsFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_followsFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _followsFetchedResultsController = fetchedResultsController;
            
            _followsFetchedResultsController.delegate = self;
        }
        
        if(_followsFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_followsFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetched wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_followsFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}

// Check if the user is in the current user list of follows
- (BOOL) doesCurrentUserFollowsStylistWithId:(NSString *)stylistId
{
    _followsFetchedResultsController = nil;
    _followsFetchRequest = nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if(!(appDelegate.currentUser.idUser == nil))
        {
            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
            {
                if(!(stylistId == nil))
                {
                    if (!([stylistId isEqualToString:@""]))
                    {
                        [self initFollowsFetchedResultsControllerWithEntity:@"Follow" andPredicate:@"followingId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKey:@"idFollow" ascending:YES];
                        
                        if (!(_followsFetchedResultsController == nil))
                        {
                            if (!((int)[[_followsFetchedResultsController fetchedObjects] count] < 1))
                            {
                                for (Follow *tmpFollow in [_followsFetchedResultsController fetchedObjects])
                                {
                                    if([tmpFollow isKindOfClass:[Follow class]])
                                    {
                                        // Check that the follow is valid
                                        if (!(tmpFollow == nil))
                                        {
                                            if(!(tmpFollow.followedId == nil))
                                            {
                                                if(!([tmpFollow.followedId isEqualToString:@""]))
                                                {
                                                    if ([tmpFollow.followedId isEqualToString:stylistId])
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
                }
            }
        }
    }
    
    return NO;
}

-(void)setupNotificationsCollection
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Setup Collection View
    [self setupCollectionViewsWithCellTypes:[[NSMutableArray alloc] initWithObjects:@"NotificationCell", nil]];
    
    _numberOfNewNotifications = 0;
    
    // Check if there are notifications
    if([self initFetchedResultsControllerForCollectionViewWithCellType:@"NotificationCell" WithEntity:@"Notification" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil])
    {
        for(Notification * notification in self.mainFetchedResultsController.fetchedObjects)
        {
            if(notification.notificationIsNew && ([notification.notificationIsNew boolValue] == YES))
            {
                _numberOfNewNotifications ++;
            }
        }
    }
    
    NSString *newNotificationSubtitle = NSLocalizedString(@"_NO_NEW_NOTIFICATIONS_", nil);
    
    if(_numberOfNewNotifications > 0)
    {
        if(_numberOfNewNotifications == 1)
        {
            newNotificationSubtitle = NSLocalizedString(@"_NEW_NOTIFICATION_", nil);
        }
        else
        {
            newNotificationSubtitle = [NSString stringWithFormat:NSLocalizedString(@"_NEW_NOTIFICATIONS_", nil), _numberOfNewNotifications];
        }
    }
    
    [self setTopBarTitle:nil andSubtitle:newNotificationSubtitle];
    
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
    if([cellType isEqualToString:@"NotificationCell"])
    {
        return self.mainFetchedResultsController.fetchedObjects.count;
    }
    
    return 0;
}

// OVERRIDE: Return the content to be shown in a cell for a collection view
- (NSArray *)getContentForCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if([cellType isEqualToString:@"NotificationCell"])
    {
        Notification * notification = [self.mainFetchedResultsController objectAtIndexPath:indexPath];
        
        if(!notification.actionUser)
        {
            if(!(notification.actionUserId == nil))
            {
                if(!([notification.actionUserId isEqualToString:@""]))
                {
                    _usersFetchedResultsController = nil;
                    _usersFetchRequest = nil;
                    
                    [self initFetchedResultsControllerWithEntity:@"User" andPredicate:@"idUser IN %@" inArray:[NSArray arrayWithObject:notification.actionUserId] sortingWithKey:@"idUser" ascending:YES];
                    
                    if (!(_usersFetchedResultsController == nil))
                    {
                        for (int i = 0; i < [[_usersFetchedResultsController fetchedObjects] count]; i++)
                        {
                            User * tmpUser = [[_usersFetchedResultsController fetchedObjects] objectAtIndex:i];
                            notification.actionUser = tmpUser;
                        }
                        
                        _usersFetchedResultsController = nil;
                        _usersFetchRequest = nil;
                    }
                }
            }
        }
        
        return [NSArray arrayWithObjects:
//USER ICON
                (((notification.actionUser.picture == nil) || ([notification.actionUser.picture isEqualToString:@""])) ? (@"portrait.png") : (notification.actionUser.picture)),
// MESSAGE
//                [self typeTextForNotificationType:notification],
                (((notification.text == nil) || ([notification.text isEqualToString:@""])) ? ([self notificationTextForNotification:notification]) : (notification.text)),
//DATE
                [[self calculatePeriodForDate:notification.date] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[[self calculatePeriodForDate:notification.date] substringToIndex:1] capitalizedString]],
//                [NSDateFormatter localizedStringFromDate:notification.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle],
// TEXT (NOW NOT USED)
//                (((notification.text == nil) || ([notification.text isEqualToString:@""])) ? ([self notificationTextForNotification:notification]) : (notification.text)),
// FOLLOW
                (( (!(notification.type == nil)) && (!([notification.type isEqualToString:@""])) && ([notification.type isEqualToString:@"follower"])) ? ([NSNumber numberWithBool:[self doesCurrentUserFollowsStylistWithId:notification.actionUserId]]) : nil), nil];
    }
    
    return nil;
}

- (NSString*) calculatePeriodForDate:(NSDate *)date
{
    NSDate * today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComponents = [calendar components: (NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date toDate:today options:0];
    
    if (dateComponents.year > 0)
    {
        if (dateComponents.year > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_YEARS_AGO_", nil), (long)dateComponents.year];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_YEAR_AGO_", nil);
        }
    }
    else if (dateComponents.month > 0)
    {
        if (dateComponents.month > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_MONTHS_AGO_", nil), (long)dateComponents.month];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_MONTH_AGO_", nil);
        }
    }
    else if (dateComponents.weekOfYear > 0)
    {
        if (dateComponents.weekOfYear > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_WEEKS_AGO_", nil), (long)dateComponents.weekOfYear];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_WEEK_AGO_", nil);
        }
    }
    else if (dateComponents.day > 0)
    {
        if (dateComponents.day > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_DAYS_AGO_", nil), (long)dateComponents.day];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_YESTERDAY_", nil);
        }
    }
    else if (dateComponents.hour > 0)
    {
        if (dateComponents.hour > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_HOURS_AGO_", nil), (long)dateComponents.hour];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_HOUR_AGO_", nil);
        }
    }
    else if (dateComponents.minute > 0)
    {
        if (dateComponents.minute > 1)
        {
            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_MINUTES_AGO_", nil), (long)dateComponents.minute];
        }
        else
        {
            return NSLocalizedString(@"_POSTED_MINUTE_AGO_", nil);
        }
    }
    else if (dateComponents.second > 0)
    {
        //        if (dateComponents.second > 1)
        //        {
        //            return [NSString stringWithFormat:NSLocalizedString(@"_POSTED_SECONDS_AGO_", nil), (long)dateComponents.second];
        //        }
        //        else
        {
            return NSLocalizedString(@"_POSTED_RIGHTNOW_", nil);
        }
    }
    
    //    else
    //    {
    //        return NSLocalizedString(@"_POSTED_TODAY_", nil);
    //    }
    
    return NSLocalizedString(@"_POSTED_RIGHTNOW_", nil);
}

-(NSString *) typeTextForNotificationType:(Notification *)notification
{
    if(!(notification.type == nil))
    {
        if(!([notification.type isEqualToString:@""]))
        {
            if([notification.type isEqualToString:@"follower"])
            {
                return NSLocalizedString(@"_NOTIFICATION_FOLLOWER", nil);
            }
            else if([notification.type isEqualToString:@"like"])
            {
                return NSLocalizedString(@"_NOTIFICATION_LIKE", nil);
            }
            else if([notification.type isEqualToString:@"comment"])
            {
                return NSLocalizedString(@"_NOTIFICATION_COMMENT", nil);
            }
            else if([notification.type isEqualToString:@"wardrobe"])
            {
                return NSLocalizedString(@"_NOTIFICATION_WARDROBE", nil);
            }
        }
    }
    
    return @"     ";
}

- (NSString*)processDate:(NSDate*)theDate
{
    if(!theDate){
        return @"";
    }
    return [NSDateFormatter localizedStringFromDate:theDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    return [dateFormatter stringFromDate:theDate];
}

- (NSAttributedString *)attributedMessageWithName:(NSString *)name andText:(NSString*)text andDate:(NSString*)dateString
{
    UIFont* normalFont = [UIFont fontWithName:@kFontInNotificationText size:kFontSizeInNotificationText];
    UIFont* boldFont = [UIFont fontWithName:@kBoldFontInNotificationText size:kFontSizeInNotificationText];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSDictionary * attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                  NSFontAttributeName:boldFont};
    
    NSAttributedString * subString = [[NSAttributedString alloc]
                                      initWithString:[NSString stringWithFormat:@"%@ ",name]
                                      attributes:attributes];
    [attributedMessage appendAttributedString:subString];
    
    attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                   NSFontAttributeName:normalFont};
    
    subString = [[NSAttributedString alloc]
                                      initWithString:[NSString stringWithFormat:@"%@ ",text]
                                      attributes:attributes];
    [attributedMessage appendAttributedString:subString];

    attributes = @{NSForegroundColorAttributeName:GOLDENSPEAR_COLOR,
                   NSFontAttributeName:boldFont};
    
    subString = [[NSAttributedString alloc]
                 initWithString:dateString
                 attributes:attributes];
    [attributedMessage appendAttributedString:subString];
    return attributedMessage;
}

-(NSAttributedString *) notificationTextForNotification:(Notification *)notification
{
    NSString* notificationText = @"";
    
    if(!(notification.type == nil))
    {
        if(!([notification.type isEqualToString:@""]))
        {
            if([notification.type isEqualToString:@"follower"])
            {
                notificationText = NSLocalizedString(@"_NEWUSER_IS_FOLLOWING", nil);
            }
            else if([notification.type isEqualToString:@"like"])
            {
                notificationText = NSLocalizedString(@"_NEWUSER_MADE_LIKE", nil);
            }
            else if([notification.type isEqualToString:@"comment"])
            {
                notificationText = NSLocalizedString(@"_NEWUSER_MADE_COMMENT", nil);
            }
            else if([notification.type isEqualToString:@"wardrobe"])
            {
                notificationText = NSLocalizedString(@"_NEWUSER_ADDEDTOWARDROBE_", nil);
            }
            else if([notification.type isEqualToString:@"socialfriend"])
            {
                notificationText = NSLocalizedString(@"_NEWUSER_ADDEDNETWORK_", nil);
            }else if([notification.type isEqualToString:@"tag"])
            {
                notificationText = NSLocalizedString(@"_USER_TAGGED_PICTURE_", nil);
            }
            else if([notification.type isEqualToString:@"mention"])
            {
                notificationText = NSLocalizedString(@"_USER_TAGGED_COMMENT_", nil);
            }
        }
    }
    NSString* userName = notification.actionUser.fashionistaName;
    NSString* noticeDate = [self processDate:notification.date];

    return [self attributedMessageWithName:userName andText:notificationText andDate:noticeDate];
}

// OVERRIDE: Action to perform if an item in a collection view is selected
- (void)actionForSelectionOfCellWithType:(NSString *)cellType AtIndexPath:(NSIndexPath *)indexPath
{
    if([cellType isEqualToString:@"NotificationCell"])
    {
        Notification * notification = [self.mainFetchedResultsController objectAtIndexPath:indexPath];
        
        if(!(notification.type == nil))
        {
            if(!([notification.type isEqualToString:@""]))
            {
                if([notification.type isEqualToString:@"follower"] || [notification.type isEqualToString:@"socialfriend"] )
                {
                    return;
                }
                else if(([notification.type isEqualToString:@"like"])
                        || [notification.type isEqualToString:@"comment"]
                        || [notification.type isEqualToString:@"mention"]
                        || [notification.type isEqualToString:@"tag"])
                {
                    if(!(notification.fashionistaPostId == nil))
                    {
                        if(!([notification.fashionistaPostId isEqualToString:@""]))
                        {
                            // Perform request to get the result contents
                            NSLog(@"Getting contents for Fashionista post: %@", notification.postTitle);
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:notification.fashionistaPostId, [NSNumber numberWithBool:NO], nil];
                            
                            [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
                        }
                    }
                }
                else if([notification.type isEqualToString:@"wardrobe"])
                {
                }
            }
        }
    }
}

// Action to perform if the user press the 'Heart' button on a ResultsCell (STYLISTSLAYOUT)
- (void)onTapActionButton:(UIButton *)sender
{
    if(![[self activityIndicator] isHidden])
        return;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    Notification *selectedNotification = [[self getFetchedResultsControllerForCellType:@"NotificationCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    
    if(!(selectedNotification == nil))
    {
        if (!([self doesCurrentUserFollowsStylistWithId:selectedNotification.actionUserId]))
        {
            if (!(selectedNotification == nil))
            {
                if (!(selectedNotification.actionUserId == nil))
                {
                    if(!([selectedNotification.actionUserId isEqualToString:@""]))
                    {
                        if (!(appDelegate.currentUser.idUser == nil))
                        {
                            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                            {
                                NSLog(@"Following user: %@", selectedNotification.actionUserId);
                                
                                // Perform request to follow user
                                
                                // Provide feedback to user
                                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_FOLLOWING_USER_MSG_", nil)];
                                
                                // Post the setFollow object
                                
                                setFollow * newFollow = [[setFollow alloc] init];
                                
                                [newFollow setFollow:selectedNotification.actionUserId];
                                
                                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
                                
                                buttonForHighlighting = sender;
                                
                                [self performRestPost:FOLLOW_USER withParamaters:requestParameters];
                            }
                        }
                    }
                }
            }
        }
        else
        {
            if (!(selectedNotification.actionUserId == nil))
            {
                if(!([selectedNotification.actionUserId isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSLog(@"UNfollowing user: %@", selectedNotification.actionUserId);
                            
                            // Perform request to follow user
                            
                            // Provide feedback to user
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNFOLLOWING_USER_MSG_", nil)];
                            
                            // Post the unsetFollow object
                            
                            unsetFollow * newUnsetFollow = [[unsetFollow alloc] init];
                            
                            [newUnsetFollow setUnfollow:selectedNotification.actionUserId];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newUnsetFollow, nil];
                            
                            buttonForHighlighting = sender;
                            
                            [self performRestPost:UNFOLLOW_USER withParamaters:requestParameters];
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
    __block id selectedItem;
    NSMutableArray * resultContent = [[NSMutableArray alloc] init];
    NSMutableArray * resultComments = [[NSMutableArray alloc] init];
    __block NSNumber * postLikesNumber = [NSNumber numberWithInt:0];
    __block User * postAuthor = nil;

    switch (connection)
    {
        case GET_USER_NOTIFICATIONS:
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

            _numberOfNewNotifications = 0;
            
            if([self getFetchedResultsControllerForCellType:@"NotificationCell"] == nil)
            {
                [self initFetchedResultsControllerForCollectionViewWithCellType:@"NotificationCell" WithEntity:@"Notification" andPredicate:@"userId IN %@" inArray:[NSArray arrayWithObject:appDelegate.currentUser.idUser] sortingWithKeys:[NSArray arrayWithObject:@"date"] ascending:NO andSectionWithKeyPath:nil];
            }

            [[self getFetchedResultsControllerForCellType:@"NotificationCell"] performFetch:nil];
            
            for(Notification * notification in self.mainFetchedResultsController.fetchedObjects)
            {
                if(notification.notificationIsNew && ([notification.notificationIsNew boolValue] == YES))
                {
                    _numberOfNewNotifications ++;
                }
            }

            [appDelegate setUserNewNotifications:[NSNumber numberWithInt:_numberOfNewNotifications]];
            [self initMainMenu];
            [self setupNotificationsLabel];
            NSString *newNotificationSubtitle = NSLocalizedString(@"_NO_NEW_NOTIFICATIONS_", nil);
            
            if(_numberOfNewNotifications > 0)
            {
                if(_numberOfNewNotifications == 1)
                {
                    newNotificationSubtitle = NSLocalizedString(@"_NEW_NOTIFICATION_", nil);
                }
                else
                {
                    newNotificationSubtitle = [NSString stringWithFormat:NSLocalizedString(@"_NEW_NOTIFICATIONS_", nil), _numberOfNewNotifications];
                }
            }
            
            //[self setTopBarTitle:nil andSubtitle:newNotificationSubtitle];

            [self stopActivityFeedback];
            
            //[self.mainCollectionView reloadData];
            [self.noticesTable reloadData];
            break;
        }
        case UNFOLLOW_USER:
        case FOLLOW_USER:
        {
            [self stopActivityFeedback];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if(!(appDelegate.currentUser.idUser == nil))
                {
                    if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, nil];
                        
                        [self performRestGet:GET_USER_FOLLOWS withParamaters:requestParameters];
                    }
                }
            }
            
            break;
        }
        case GET_FASHIONISTA:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     selectedItem = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            // Paramters for next VC (ResultsViewController)
            NSArray *parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */selectedItem, [NSNumber numberWithBool:NO], nil];
            
            [self stopActivityFeedback];
            
            if(!self.currentPresenterViewController){
                [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            }else{
                [self.currentPresenterViewController transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
                [self.currentPresenterViewController dismissControllerModal];
            }
            
            break;
        }
        case GET_FULL_POST:
        {
            User* postUser = nil;
            FashionistaPost* selectedSpecificPost = nil;
            
            // Get the post that was provided
            for (FashionistaPost *post in mappingResult)
            {
                if([post isKindOfClass:[FashionistaPost class]])
                {
                    if(!(post.idFashionistaPost == nil))
                    {
                        if  (!([post.idFashionistaPost isEqualToString:@""]))
                        {
                            selectedSpecificPost = (FashionistaPost *)post;
                            break;
                        }
                    }
                }
            }
            
            NSNumber* postLikesNumber = selectedSpecificPost.likesNum;
            
            NSMutableArray* resultComments = [NSMutableArray arrayWithArray:[selectedSpecificPost.comments allObjects]];
            
            NSMutableArray* postContent = [NSMutableArray arrayWithArray:[selectedSpecificPost.contents allObjects]];
            // Get the list of contents that were provided
            for (FashionistaContent *content in postContent)
            {
                [self preLoadImage:content.image];
                //[UIImage cachedImageWithURL:content.image];
            }
            
            postUser = selectedSpecificPost.author;
            
            // Paramters for next VC (ResultsViewController)
            NSArray* parametersForNextVC = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES], selectedSpecificPost, postContent, resultComments, [NSNumber numberWithBool:NO], postLikesNumber, postUser, nil];
            
            [self stopActivityFeedback];
            
            if(!([parametersForNextVC count] < 2))
            {
                [self transitionToViewController:FASHIONISTAPOST_VC withParameters:parametersForNextVC];
            }
            
            break;
        }
            
        default:
            
            break;
    }
}

#pragma mark - FollowButton

- (IBAction)followButtonPushed:(UIButton *)sender {
    sender.selected = !sender.selected;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    Notification *selectedNotification = [[self getFetchedResultsControllerForCellType:@"NotificationCell"] objectAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
    
    if(!(selectedNotification == nil))
    {
        if (sender.selected)
        {
            if (!(selectedNotification == nil))
            {
                if (!(selectedNotification.actionUserId == nil))
                {
                    if(!([selectedNotification.actionUserId isEqualToString:@""]))
                    {
                        if (!(appDelegate.currentUser.idUser == nil))
                        {
                            if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                            {
                                NSLog(@"Following user: %@", selectedNotification.actionUserId);
                                
                                // Perform request to follow user
                                
                                // Provide feedback to user
                                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_FOLLOWING_USER_MSG_", nil)];
                                
                                // Post the setFollow object
                                
                                setFollow * newFollow = [[setFollow alloc] init];
                                
                                [newFollow setFollow:selectedNotification.actionUserId];
                                
                                NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newFollow, nil];
                                
                                
                                [self performRestPost:FOLLOW_USER withParamaters:requestParameters];
                            }
                        }
                    }
                }
            }
        }
        else
        {
            if (!(selectedNotification.actionUserId == nil))
            {
                if(!([selectedNotification.actionUserId isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            NSLog(@"UNfollowing user: %@", selectedNotification.actionUserId);
                            
                            // Perform request to follow user
                            
                            // Provide feedback to user
                            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNFOLLOWING_USER_MSG_", nil)];
                            
                            // Post the unsetFollow object
                            
                            unsetFollow * newUnsetFollow = [[unsetFollow alloc] init];
                            
                            [newUnsetFollow setUnfollow:selectedNotification.actionUserId];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, newUnsetFollow, nil];
                            
                            buttonForHighlighting = sender;
                            
                            [self performRestPost:UNFOLLOW_USER withParamaters:requestParameters];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.mainFetchedResultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Notification * notification = [self.mainFetchedResultsController objectAtIndexPath:indexPath];
    
    NSAttributedString* text = [self notificationTextForNotification:notification];
    NSString* identifier;
    BOOL userNotif = NO;
    if ([notification.type isEqualToString:@"follower"] || [notification.type isEqualToString:@"socialfriend"]) {
        identifier = @"userCell";
        userNotif = YES;
    }else{
        identifier = @"postNotifCell";
    }
    FashionistaUserListViewCell* theCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    theCell.userName.attributedText = text;
    NSString* previewImage = notification.actionUser.picture;
    theCell.imageURL = previewImage;
    if ([UIImage isCached:previewImage])
    {
        UIImage * image = [UIImage cachedImageWithURL:previewImage];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        theCell.theImage.image = image;
    }
    else
    {
        [theCell.theImage setImageWithURL:[NSURL URLWithString:previewImage] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
    }
    if(userNotif){
        AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if([appDelegate.currentUser.idUser isEqualToString:notification.actionUser.idUser]){
            theCell.followingButton.hidden = YES;
        }else{
            theCell.followingButton.hidden = NO;
            theCell.followingButton.tag = indexPath.row;
            theCell.followingButton.selected = [self doesCurrentUserFollowsStylistWithId:notification.actionUser.idUser];
        }
    }else{
        NotificationsPostTableViewCell* cell = (NotificationsPostTableViewCell*)theCell;
        NSString* previewImage = notification.previewImage;
        theCell.imageURL = previewImage;
        if ([UIImage isCached:previewImage])
        {
            UIImage * image = [UIImage cachedImageWithURL:previewImage];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            cell.postImage.image = image;
        }
        else
        {
            [cell.postImage setImageWithURL:[NSURL URLWithString:previewImage] placeholderImage:[UIImage imageNamed:@"no_image.png"]];
        }
    }
    return theCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Notification * notification = [self.mainFetchedResultsController objectAtIndexPath:indexPath];
    
    if(!(notification.type == nil))
    {
        if(!([notification.type isEqualToString:@""]))
        {
            if([notification.type isEqualToString:@"follower"]||[notification.type isEqualToString:@"socialfriend"])
            {
                [self stopActivityFeedback];
                [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:notification.actionUser.idUser, nil];
                
                [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
            }
            else if(([notification.type isEqualToString:@"like"])
                    || [notification.type isEqualToString:@"comment"]
                    || [notification.type isEqualToString:@"mention"]
                    || [notification.type isEqualToString:@"tag"])
            {
                if(!(notification.fashionistaPostId == nil))
                {
                    if(!([notification.fashionistaPostId isEqualToString:@""]))
                    {
                        // Perform request to get the result contents
                        NSLog(@"Getting contents for Fashionista post: %@", notification.postTitle);
                        
                        // Provide feedback to user
                        [self stopActivityFeedback];
                        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
                        
                        NSArray * requestParameters = [[NSArray alloc] initWithObjects:notification.fashionistaPostId, [NSNumber numberWithBool:NO], nil];
                        
                        [self performRestGet:GET_FULL_POST withParamaters:requestParameters];
                    }
                }
            }
        }
    }
}

@end
