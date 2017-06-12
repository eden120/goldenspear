//
//  GSTaggingLocationSearchViewController.h
//  GoldenSpear
//
//  Created by Crane on 8/19/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchBaseViewController.h"
@protocol LocationSearchtDelegate;

@interface GSTaggingLocationSearchViewController :SearchBaseViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *userDisplayList;
@property (nonatomic) followingRelationships userListMode;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic, weak) User* shownRelatedUser;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) NSString *postId;
@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UILabel *locationAddress;

@property (nonatomic, assign) id <LocationSearchtDelegate> locationDelegate;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;

- (void)operationAfterLoadingSearch:(BOOL)hasResults;
- (IBAction)doSearchPush:(id)sender;

@end
@protocol LocationSearchtDelegate <NSObject>
@optional
-(void) setLocation:(POI *)poi;
@end