//
//  keyboardCoreDataCollectionViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "keyboardCoreDataCollectionViewController.h"
#import "keyboardCoreDataManager.h"

@interface keyboardCoreDataCollectionViewController ()

@property (readwrite, nonatomic, strong) keyboardCoreDataFetchController *coreDataFetchController;

@end

@implementation keyboardCoreDataCollectionViewController

@synthesize coreDataFetchController = _coreDataFetchController;

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.coreDataFetchController viewDidAppear];
}

#pragma mark - Properties

- (NSManagedObjectContext *)managedObjectContext
{
    return [KeyboardCoreDataManager managerForModelName:self.modelName].managedObjectContext;
}

- (void)saveContext
{
    [KeyboardCoreDataManager saveContext:self.managedObjectContext];
}

#pragma mark - UICollectionViewDataSource

- (void)configureCell:(id)cell
         forIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"<Implementation missing! Please implement `configureCell:forIndexPath:` in your subclass of `keyboardCoreDataCollectionViewController`>");
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self cellIdentifierForItemAtIndexPath:indexPath];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                           forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.coreDataFetchController numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.coreDataFetchController numberOfRowsInSection:section];
}

#pragma mark - TKCoreDataViewDataSource

- (keyboardCoreDataFetchController *)coreDataFetchController
{
    @synchronized (self) {
        if (!_coreDataFetchController) {
            _coreDataFetchController = [[keyboardCoreDataFetchController alloc] initWithCollectionViewController:self];
        }
        return _coreDataFetchController;
    }
}

- (NSString *)modelName
{
    return nil;
}

- (NSString *)entityName
{
    return nil;
}

- (NSString *)cellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSArray *)defaultSortDescriptors
{
    return nil;
}

- (NSPredicate *)defaultPredicate
{
    return nil;
}

@end
