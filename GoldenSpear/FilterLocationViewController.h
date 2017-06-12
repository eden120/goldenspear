//
//  FilterLocationViewController.h
//  GoldenSpear
//
//  Created by Crane on 9/20/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
#import "SearchBaseViewController.h"
@protocol FilterLocationSearchtDelegate;

@interface FilterLocationViewController :SearchBaseViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;

@property (nonatomic) followingRelationships userListMode;

@property (nonatomic, assign) id <FilterLocationSearchtDelegate> filterLocationDelegate;
@property (nonatomic, strong) NSOperationQueue *imagesQueue;
@property int searchType;
@property NSMutableArray *countries;
@property NSMutableArray *states;
@property NSMutableArray *cities;

- (void)operationAfterLoadingSearch:(BOOL)hasResults;
- (IBAction)doSearchPush:(id)sender;

@end
@protocol FilterLocationSearchtDelegate <NSObject>
@optional
-(void) setLocations:(NSMutableArray*)locations type:(int)type;
@end