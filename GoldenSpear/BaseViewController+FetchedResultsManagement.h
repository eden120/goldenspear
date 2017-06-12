//
//  BaseViewController+FetchedResultsManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 13/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController (FetchedResultsManagement) <NSFetchedResultsControllerDelegate>

// Fetch results management
@property NSFetchedResultsController * mainFetchedResultsController;
@property NSFetchRequest * mainFetchRequest;

@property NSFetchedResultsController * secondFetchedResultsController;
@property NSFetchRequest * secondFetchRequest;

@property NSFetchedResultsController * thirdFetchedResultsController;
@property NSFetchRequest * thirdFetchRequest;

// Arrays to cache the sections and objects updates until the fetched results controller is finished with the updates
@property NSMutableDictionary *objectChanges;
@property NSMutableDictionary *sectionChanges;

- (NSFetchedResultsController *)getFetchedResultsControllerForCellType:(NSString *)cellType;
- (BOOL)performFetchForCollectionViewWithCellType:(NSString *)cellType;
- (BOOL)initFetchedResultsControllerForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKeys:(NSArray *)sortKeys ascending:(BOOL)ascending andSectionWithKeyPath:(NSString *)sectionNameKeyPath;
- (BOOL)initFetchedResultsControllerForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSPredicate *)predicate sortingWithKeys:(NSArray *)sortKeys ascending:(BOOL)ascending andSectionWithKeyPath:(NSString *)sectionNameKeyPath;
- (BOOL)initFetchedResultsControllerForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSPredicate *)predicate sortingWithKeys:(NSArray *)sortKeys ascendingArray:(NSArray *)ascendingArray andSectionWithKeyPath:(NSString *)sectionNameKeyPath;

@end
