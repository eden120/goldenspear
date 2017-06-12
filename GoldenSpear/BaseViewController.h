//
//  BaseViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


// Frameworks
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

// Supporting files
#import "AppDelegate.h"
#import "MainMenuView.h"
#import "CircleMenuView.h"
#import "MenuSection.h"
#import "MenuEntry.h"
#import "SlideButtonView.h"
#import "UIImage+ImageCache.h"
#import "UIView+Shadow.h"

#import "Fingerprint.h"

#import <CoreLocation/CoreLocation.h>

// General defines
  // Content types
#define IMAGE_TYPE 0
#define VIDEO_TYPE 1
#define AUDIO_TYPE 2

#define kFinishedUpdatingNotifications @"kFinishedUpdatingNotifications"

@protocol GSRelatedViewControllerDelegate <NSObject>

- (void)closeRelatedViewController:(UIViewController*)theViewController;

@end

@interface BaseViewController : UIViewController<FingerPrintDelegate>

// Preloaded images queue.
@property (nonatomic, strong) NSOperationQueue *preloadImagesQueue;
-(void) loadDataFromServer;
-(void) setupAllProductCategoriesWithMapping:(NSArray *)productCategoriesMapping;
-(void) loadBrandsPriority;
-(void) setupPriorityBrandsWithMapping:(NSArray *)featureGroupMapping;
-(void) setupAllBrandsWithMapping:(NSArray *)featureGroupMapping;
-(void) setupAllFeaturesWithMapping:(NSArray *)featureGroupMapping;
-(void) loadAllProductCategory;
-(void) setupAllFeatureGroupsWithMapping:(NSArray *)featureGroupMapping;
-(void) loadAllFeatures;
-(void) loadAllBrands;
- (void)preLoadImage:(NSString*) imageFile;

- (NSInteger)getADcount;

@property (retain, nonatomic) NSDate *startTime;
@property (retain, nonatomic) NSString *idUserViewing;
@property (retain, nonatomic) NSDate *endTime;
@property (nonatomic) CLPlacemark *placeMark;


-(void) getKeywordFromMapping:(NSArray *)mappingResult inSuccesfulTerms:(NSMutableArray *) successfulTerms andInSuccessfulObjects:(NSMutableArray *)successfulObjects;

-(void) postAnayliticsIntervalTimeBetween:(NSDate *) startTime and:(NSDate *) endTime;


@end
