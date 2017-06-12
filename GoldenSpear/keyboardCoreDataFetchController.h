//
//  keyboardCoreDataFetchController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class keyboardCoreDataTableViewController;
@class keyboardCoreDataCollectionViewController;

@interface keyboardCoreDataFetchController : NSObject

@property (atomic, strong) NSPredicate *predicate;
@property (atomic, strong) NSArray *sortDescriptors;
@property (readonly, atomic, strong) NSString *modelName;

@property (nonatomic) UITableViewRowAnimation tableViewRowAnimation;

- (void)setPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors;

- (id)initWithTableViewController:(keyboardCoreDataTableViewController *)tableViewController;
- (id)initWithCollectionViewController:(keyboardCoreDataCollectionViewController *)collectionViewController;
- (void)viewDidAppear;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSections;

@end
