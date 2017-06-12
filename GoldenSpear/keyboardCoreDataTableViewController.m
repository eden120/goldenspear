//
//  keyboardCoreDataTableViewController.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "keyboardCoreDataTableViewController.h"
#import "keyboardCoreDataManager.h"

@interface keyboardCoreDataTableViewController ()

@property (readwrite, nonatomic, strong) keyboardCoreDataFetchController *coreDataFetchController;

@end

@implementation keyboardCoreDataTableViewController

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

#pragma mark - UITableViewDataSource

- (void)configureCell:(id)cell
         forIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"<Implementation missing! Please implement `configureCell:forIndexPath:` in your subclass of `KeyboardCoreDataTableViewController`>");
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self cellIdentifierForItemAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.coreDataFetchController numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.coreDataFetchController numberOfRowsInSection:section];
}

#pragma mark - TKCoreDataViewDataSource

- (keyboardCoreDataFetchController *)coreDataFetchController
{
    @synchronized (self) {
        if (!_coreDataFetchController) {
            _coreDataFetchController = [[keyboardCoreDataFetchController alloc] initWithTableViewController:self];
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
