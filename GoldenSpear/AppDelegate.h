//
//  AppDelegate.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//  


// Frameworks
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@import MessageUI;

#ifndef DEBUG
    #define NSLog(...);
#endif

// Supporting files
#import "BaseViewController.h"
#import "NSString+UUID.h"
#import "RKObjectManager+EntitiesMapping.h"

// Core Data Classes
#import "User+Manage.h"
#import "SearchQuery+Manage.h"
#import "ResultsGroup+Manage.h"
#import "GSBaseElement+Manage.h"
#import "Brand+Manage.h"
#import "Product+Manage.h"
#import "ProductGroup+Manage.h"
#import "Price+Manage.h"
#import "Keyword+Manage.h"
#import "SuggestedKeyword+Manage.h"
#import "Feature+Manage.h"
#import "FeatureGroup+Manage.h"
#import "FeatureGroupOrderProductGroup+Manage.h"
#import "KeywordFashionistaContent+Manage.h"
#import "Content+Manage.h"
#import "Availability+Manage.h"
#import "Shop+Manage.h"
#import "Review+Manage.h"
#import "Wardrobe+Manage.h"
#import "FashionistaPage+Manage.h"
#import "FashionistaPost+Manage.h"
#import "FashionistaContent+Manage.h"
#import "Follow+Manage.h"
#import "Comment+Manage.h"
#import "PostLike+Manage.h"
#import "Notification+Manage.h"
#import "BackgroundAd+Manage.h"
#import "Share+Manage.h"
#import "Country+Manage.h"
#import "StateRegion+Manage.h"
#import "City+CoreDataProperties.h"
#import "LiveStreamingCategory+Manage.h"
#import "LiveStreamingEthnicity+Manage.h"
#import "LiveStreamingInvitation+Manage.h"
#import "LiveStreaming+Manage.h"
#import "LiveStreamingPrivacy+Manage.h"
#import "TypeLook.h"
#import "TypeLook+CoreDataProperties.h"

#import "Fingerprint.h"

// General defines
  // Working local or via internet
//#define LOCALNETWORK 0
#define RESTBASEURL @"https://app.goldenspear.com"  // @"https://app.goldenspear.com:8080" //(LOCALNETWORK) ? @"http://192.168.1.99:8080" : @"http://goldenspear.dyndns.org:8080"
#define IMAGESBASEURL @"http://app.goldenspear.com" //@"http://app.goldenspear.com" //(LOCALNETWORK) ? @"http://192.168.1.99:8081" : @"http://goldenspear.dyndns.org:8081"
#define PROFILESPICIMAGESBASEURL @"http://app.goldenspear.com/profile_pictures/" // @"http://app.goldenspear.com/profile_pictures/" //(LOCALNETWORK) ? @"http://192.168.1.99/profile_pictures/" : @"http://goldenspear.dyndns.org/profile_pictures/"

  // Detect device type
//#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
//#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 667.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

// View Controllers IDs
//Directory
#define NOTIFICATIONS_VC 0
#define TAGGEDHISTORY_VC 1
#define FRIENDS_VC 2
#define LIKES_VC 3
#define SALES_VC 4
//
#define HISTORY_VC 5
#define WARDROBECOLLECTIONS_VC 6
#define USERPROFILE_VC 7
//Settings
#define ACCOUNT_VC 8
#define LINKACCOUNTS_VC 9
#define CHANGEPASSWORD_VC 10
#define HELPSUPPORT_VC 11
#define EMAILVERIFY_VC  12

#define STYLIST_VC 5000
#define CART_VC 1000
#define BRAND_VC 1002
#define FASHIONISTAS_VC 1003
#define FASHIONISTAPOSTS_VC 1004
#define EDITPROFILE_VC 2500

#define SIGNIN_VC 50
#define FORGOTPWD_VC 51

#define IDENTIFY_VC 100

#define CREATEPOST_VC 3100

#define INSTRUCTIONS_VC 20
#define SEARCHFILTERS_VC 21
#define SEARCHBRANDFILTERS_VC 22
#define PRODUCTSHEET_VC 23
#define FEATURESSEARCH_VC 24
#define WARDROBECONTENT_VC 26
#define ADDITEMTOWARDROBE_VC 27
#define PRODUCTFEATURESEARCH_VC 28
#define VISUALSEARCH_VC 111

#define FASHIONISTAMAINPAGE_VC 30
#define FASHIONISTAPOST_VC 31
#define FASHIONISTACOVERPAGE_VC 32
#define MAGAGINETAPPEDVIEW_VC  321

#define ADDPOSTTOPAGE_VC 33

#define CUSTOMCAMERA_VC 34

#define STYLES_VC 35

#define SIGNUP_VC 36

#define REQUIREDPROFILESTYLIST_VC 37

#define ANALYTICS_VC 38

#define WHO_ARE_YOU_VC 39
#define ACCOUNT_DETAIL_VC 41

//TAGGING
#define TAGGING_VC 42
#define SEARCHPRODUCT_VC 43
#define NEWSFEED_VC 101
#define DISCOVER_VC 104
#define SEARCH_VC 105
//Discover Live
#define LIVEPLAYER_VC 107

#define DOUBLEDISPLAY_VC 200
#define ADDCOMMENT_VC 201
#define USERLIST_VC 202
#define TEXTEDIT_VC 203
#define QUICKVIEW_VC 204
#define EDITINFO_VC 205
#define SHOWINFO_VC 206
#define COMMENTS_VC 207
#define SOCIALNETWORKLIST_VC 208
#define SOCIALNETWORKWEBVIEW_VC 209
#define USERVIDEOS_VC 210
#define TAGGINGUSERSEARCH_VC 211
#define TAGGINGPRODUCTSEARCH_VC 212
#define LIVELOCATIONSEARCH_VC 213
#define LIVEAGELANGESEARCH_VC 214
#define ETHNICITY_VC 215
#define TRENDING_VC 1104

//LiveStream
#define BROADCAST_VC 44
#define LIVEFILTER_VC 45
/* OLD MENU IDS
#define SEARCH_VC 0
#define TRENDING_VC 1
#define BRAND_VC 2
#define FASHIONISTAS_VC 3
#define FASHIONISTAPOSTS_VC 4
#define NOTIFICATIONS_VC 5
#define HISTORY_VC 6
#define WARDROBECOLLECTIONS_VC 7
#define STYLIST_VC 8
#define ACCOUNT_VC 9
#define CART_VC 10
#define SIGNIN_VC 50
#define FORGOTPWD_VC 51

#define IDENTIFY_VC 100

#define INSTRUCTIONS_VC 20
#define SEARCHFILTERS_VC 21
#define PRODUCTSHEET_VC 23
#define FEATURESSEARCH_VC 24
#define EDITPROFILE_VC 25
#define WARDROBECONTENT_VC 26
#define ADDITEMTOWARDROBE_VC 27
#define PRODUCTFEATURESEARCH_VC 28
#define VISUALSEARCH_VC 11

#define FASHIONISTAMAINPAGE_VC 30
#define FASHIONISTAPOST_VC 31

#define USERPROFILE_VC 32

#define ADDPOSTTOPAGE_VC 33

#define CUSTOMCAMERA_VC 34

#define STYLES_VC 35

#define SIGNUP_VC 36

#define REQUIREDPROFILESTYLIST_VC 37

#define ANALYTICS_VC 38
*/


//Availability type
#define ONLINE_INSTORE      0
#define ONLINE_ONLY         1
#define INSTORE_ONLY        2

// Share Button Index
#define MESSAGE			0
#define MMS				1
#define EMAIL			2
#define PINTEREST		3
#define LINKEDIN		4
#define INSTAGRAM		5
#define SNAPCHAT		6
#define FACEBOOK		7
#define TUMBLR			8
#define FLIKER			9
#define TWITTER			10

// Device Orientation
#define LANDSCAPE_LEFT  1
#define LANDSCAPE_RIGHT 2

// Number of menu sections
#define NUM_MENU_SECTIONS 3
#define NUM_MENU_ENTRIES_IN_SECTION_0 5
#define NUM_MENU_ENTRIES_IN_SECTION_1 3
#define NUM_MENU_ENTRIES_IN_SECTION_2 5
// In case to add new sections, please remember to add a case into the 'BaseViewController+MainMenuManagement > initMainMenuEntries' switch... :S

// Number of menu entries
#define NUM_MENU_ENTRIES 13

  // Assume that app home will be the Search ViewController
#define HOME_VC NEWSFEED_VC

#define DOWNLOAD_3_FILES NO
#define FORCE_DOWNLOAD_DATA NO

#define GOLDENSPEAR_COLOR [UIColor colorWithRed:0.69 green:0.56 blue:0.42 alpha:0.95]
#define GSLastMenuEntry @"lastMenuEntry"
#define GSLastTabSelected @"lastTabSelected"

enum PostContentType{
    PostContentTypeImage = 1,
    PostContentTypeVideo,
    PostContentTypeText
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) User * currentUser;
@property (nonatomic) BOOL completeUser;

@property (nonatomic) BackgroundAd * nextFullscreenBackgroundAd;
@property (nonatomic) BackgroundAd * nextSearchAdaptedBackgroundAd;
@property (nonatomic) BackgroundAd * nextPostAdaptedBackgroundAd;

@property NSMutableArray * tmpVCQueue;
@property NSMutableArray * tmpParametersQueue;
@property NSMutableArray * lastDismissedVCQueue;
@property NSMutableArray * lastDismissedParametersQueue;
@property UIImage *taggingCameraImage;
@property (nonatomic) Fingerprint * finger;

@property (nonatomic) NSNumber * userNewNotifications;
@property (nonatomic) NSNumber * currentLocationLat;
@property (nonatomic) NSNumber * currentLocationLon;

// If different to nil, user will add products directly to this wardrobe
@property (nonatomic) NSString * addingProductsToWardrobeID;


@property BOOL bAutoLogin;
// boolean to know if it is still downloading the product category info
@property BOOL bLoadingFilterInfo;
@property BOOL bLoadedFilterInfo;
@property BOOL bForceDownloadData;

@property NSMutableArray *productGroups;
@property BOOL splashScreen;

@property NSDictionary * config;

@property MFMailComposeViewController * globalMailComposer;

- (void)setCurrentUser:(User *) newUser;
- (void)setDefaults;
- (void)getCurrentUserInitialData;
- (void)cycleGlobalMailComposer;
- (NSString *)currentManagedObjectModelName;
- (BOOL) closeCurrentServerSession;

- (void) getSearchKeywords;

- (BOOL) isConfigSearchCpp;

- (void)resetMenuIndex;
- (void)resetTabIndex;

+ (NSString *) getDeviceName;
+ (NSString *) getOSVersion;

@end

