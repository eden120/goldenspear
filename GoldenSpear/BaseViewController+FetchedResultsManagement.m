//
//  BaseViewController+FetchedResultsManagement.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 13/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController+FetchedResultsManagement.h"
#import "BaseViewController+CustomCollectionViewManagement.h"
#import <objc/runtime.h>


static char MAINFETCHEDRESULTSCONTROLLER_KEY;
static char MAINFETCHREQUEST_KEY;
static char SECONDFETCHEDRESULTSCONTROLLER_KEY;
static char SECONDFETCHREQUEST_KEY;
static char THIRDFETCHEDRESULTSCONTROLLER_KEY;
static char THIRDFETCHREQUEST_KEY;
static char OBJECTCHANGES_KEY;
static char SECTIONCHANGES_KEY;


@implementation BaseViewController (FetchedResultsManagement)


#pragma mark - Fetched results management

// Getter and setter for mainFetchedResultsController
- (NSFetchedResultsController *)mainFetchedResultsController
{
    return objc_getAssociatedObject(self, &MAINFETCHEDRESULTSCONTROLLER_KEY);
}

- (void)setMainFetchedResultsController:(NSFetchedResultsController *)mainFetchedResultsController
{
    objc_setAssociatedObject(self, &MAINFETCHEDRESULTSCONTROLLER_KEY, mainFetchedResultsController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for mainFetchRequest
- (NSFetchRequest *)mainFetchRequest
{
    return objc_getAssociatedObject(self, &MAINFETCHREQUEST_KEY);
}

- (void)setMainFetchRequest:(NSFetchRequest *)mainFetchRequest
{
    objc_setAssociatedObject(self, &MAINFETCHREQUEST_KEY, mainFetchRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for secondFetchedResultsController
- (NSFetchedResultsController *)secondFetchedResultsController
{
    return objc_getAssociatedObject(self, &SECONDFETCHEDRESULTSCONTROLLER_KEY);
}

- (void)setSecondFetchedResultsController:(NSFetchedResultsController *)secondFetchedResultsController
{
    objc_setAssociatedObject(self, &SECONDFETCHEDRESULTSCONTROLLER_KEY, secondFetchedResultsController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for secondFetchRequest
- (NSFetchRequest *)secondFetchRequest
{
    return objc_getAssociatedObject(self, &SECONDFETCHREQUEST_KEY);
}

- (void)setSecondFetchRequest:(NSFetchRequest *)secondFetchRequest
{
    objc_setAssociatedObject(self, &SECONDFETCHREQUEST_KEY, secondFetchRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for thirdFetchedResultsController
- (NSFetchedResultsController *)thirdFetchedResultsController
{
    return objc_getAssociatedObject(self, &THIRDFETCHEDRESULTSCONTROLLER_KEY);
}

- (void)setThirdFetchedResultsController:(NSFetchedResultsController *)thirdFetchedResultsController
{
    objc_setAssociatedObject(self, &THIRDFETCHEDRESULTSCONTROLLER_KEY, thirdFetchedResultsController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for thirdFetchRequest
- (NSFetchRequest *)thirdFetchRequest
{
    return objc_getAssociatedObject(self, &THIRDFETCHREQUEST_KEY);
}

- (void)setThirdFetchRequest:(NSFetchRequest *)thirdFetchRequest
{
    objc_setAssociatedObject(self, &THIRDFETCHREQUEST_KEY, thirdFetchRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for objectChanges
- (NSMutableDictionary *)objectChanges
{
    return objc_getAssociatedObject(self, &OBJECTCHANGES_KEY);
}

- (void)setObjectChanges:(NSMutableDictionary *)objectChanges
{
    objc_setAssociatedObject(self, &OBJECTCHANGES_KEY, objectChanges, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for sectionChanges
- (NSMutableDictionary *)sectionChanges
{
    return objc_getAssociatedObject(self, &SECTIONCHANGES_KEY);
}

- (void)setSectionChanges:(NSMutableDictionary *)sectionChanges
{
    objc_setAssociatedObject(self, &SECTIONCHANGES_KEY, sectionChanges, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Get fetchedResultsController for a given Cell Type
- (NSFetchedResultsController *)getFetchedResultsControllerForCellType:(NSString *)cellType
{
    if(cellType == self.mainCollectionCellType)
    {
        return self.mainFetchedResultsController;
    }
    else if(cellType == self.secondCollectionCellType)
    {
        return self.secondFetchedResultsController;
    }
    else if(cellType == self.thirdCollectionCellType)
    {
        return self.thirdFetchedResultsController;
    }
    
    return nil;
}

// Get fetchedRequest for a given Cell Type
- (NSFetchRequest *)getFetchRequestForCellType:(NSString *)cellType
{
    if(cellType == self.mainCollectionCellType)
    {
        return self.mainFetchRequest;
    }
    else if(cellType == self.secondCollectionCellType)
    {
        return self.secondFetchRequest;
    }
    else if(cellType == self.thirdCollectionCellType)
    {
        return self.thirdFetchRequest;
    }
    
    return nil;
}


// Set fetchedResultsController for a given Cell Type
- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController ForCellType:(NSString *)cellType
{
    NSFetchedResultsController * fetchedController = [self getFetchedResultsControllerForCellType:cellType];
    if (fetchedController != nil)
    {
        if (fetchedController == self.mainFetchedResultsController)
        {
            self.mainFetchedResultsController = fetchedResultsController;
            
            self.mainFetchedResultsController.delegate = self;
        }
        else if (fetchedController == self.secondFetchedResultsController)
        {
            self.secondFetchedResultsController = fetchedResultsController;
            
            self.secondFetchedResultsController.delegate = self;
        }
        else if (fetchedController == self.thirdFetchedResultsController)
        {
            self.thirdFetchedResultsController = fetchedResultsController;
            
            self.thirdFetchedResultsController.delegate = self;
        }
    }
    else
    {
        if(cellType == self.mainCollectionCellType)
        {
            self.mainFetchedResultsController = fetchedResultsController;
            
            self.mainFetchedResultsController.delegate = self;
        }
        else if(cellType == self.secondCollectionCellType)
        {
            self.secondFetchedResultsController = fetchedResultsController;
            
            self.secondFetchedResultsController.delegate = self;
        }
        else if(cellType == self.thirdCollectionCellType)
        {
            self.thirdFetchedResultsController = fetchedResultsController;
            
            self.thirdFetchedResultsController.delegate = self;
        }
    }
}

// Set fetchedRequest for a given Cell Type
- (void)setFetchRequest:(NSFetchRequest *)fetchRequest ForCellType:(NSString *)cellType
{
    NSFetchRequest * fetchedObject = [self getFetchRequestForCellType:cellType];
    if (fetchedObject != nil)
    {
        if (fetchedObject == self.mainFetchRequest)
        {
            self.mainFetchRequest =fetchRequest;
        }
        else if (fetchedObject == self.secondFetchRequest)
        {
            self.secondFetchRequest =fetchRequest;
        }
        if (fetchedObject == self.thirdFetchRequest)
        {
            self.thirdFetchRequest =fetchRequest;
        }
    }
    else
    {
        if(cellType == self.mainCollectionCellType)
        {
            self.mainFetchRequest =fetchRequest;
        }
        else if(cellType == self.secondCollectionCellType)
        {
            self.secondFetchRequest =fetchRequest;
        }
        else if(cellType == self.thirdCollectionCellType)
        {
            self.thirdFetchRequest =fetchRequest;
        }
    }
    
}


// Perform initial fetch for a given fetchedResultsController
- (BOOL)performFetchForCollectionViewWithCellType:(NSString *)cellType
{
    // Perform fetch
    
    NSError *error = nil;
    
    if (![[self getFetchedResultsControllerForCellType:cellType] performFetch:&error])
    {
        // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        return FALSE;
    }
    
    return ([[self getFetchedResultsControllerForCellType:cellType] fetchedObjects].count > 0);
}

// Init fetch request for mainFetchedResultsController
- (BOOL)initFetchRequestForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSPredicate *)predicate sortingWithKeys:(NSArray *)sortKeys ascending:(BOOL)ascending
{
    if ([self getFetchRequestForCellType:cellType] == nil)
    {
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        // Entity to look for
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
        
        [fetchRequest setEntity:entity];
        
        // Filter results
        [fetchRequest setPredicate:predicate];
        
        // Sort results
        
        if(!(sortKeys == nil))
        {
            if([sortKeys count] > 0)
            {
                NSMutableArray * sortDescriptors = [[NSMutableArray alloc] init];
                
                for (NSString *sortKey in sortKeys)
                {
                    if([sortKey isKindOfClass:[NSString class]])
                    {
                        if(!(sortKey == nil))
                        {
                            if(!([sortKey isEqualToString:@""]))
                            {
                                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                                
                                [sortDescriptors addObject:sortDescriptor];
                            }
                        }
                    }
                }
                
                if (!(sortDescriptors == nil))
                {
                    if([sortDescriptors count] > 0)
                    {
                        [fetchRequest setSortDescriptors:sortDescriptors];
                    }
                }
            }
        }
        
        [fetchRequest setFetchBatchSize:20];
        
        [self setFetchRequest:fetchRequest ForCellType:cellType];
    }
    
    return (!([self getFetchRequestForCellType:cellType] == nil));
}

// Init fetch request for mainFetchedResultsController
- (BOOL)initFetchRequestForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSPredicate *)predicate sortingWithKeys:(NSArray *)sortKeys ascendingArray:(NSArray *)ascendingArray
{
    if ([self getFetchRequestForCellType:cellType] == nil)
    {
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        // Entity to look for
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
        
        [fetchRequest setEntity:entity];
        
        // Filter results
        [fetchRequest setPredicate:predicate];
        
        // Sort results
        
        if(!(sortKeys == nil))
        {
            if([sortKeys count] > 0)
            {
                NSMutableArray * sortDescriptors = [[NSMutableArray alloc] init];
                int iIdxSortKey = 0;
                for (NSString *sortKey in sortKeys)
                {
                    if([sortKey isKindOfClass:[NSString class]])
                    {
                        if(!(sortKey == nil))
                        {
                            if(!([sortKey isEqualToString:@""]))
                            {
                                NSNumber * numberAscending = ascendingArray[iIdxSortKey];
                                BOOL ascending = [numberAscending boolValue];
                                
                                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                                
                                [sortDescriptors addObject:sortDescriptor];
                            }
                        }
                    }
                    iIdxSortKey++;
                }
                
                if (!(sortDescriptors == nil))
                {
                    if([sortDescriptors count] > 0)
                    {
                        [fetchRequest setSortDescriptors:sortDescriptors];
                    }
                }
            }
        }
        
        [fetchRequest setFetchBatchSize:20];
        
        [self setFetchRequest:fetchRequest ForCellType:cellType];
    }
    
    return (!([self getFetchRequestForCellType:cellType] == nil));
}

// Init fetch request for mainFetchedResultsController
- (BOOL)initFetchRequestForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKeys:(NSArray *)sortKeys ascending:(BOOL)ascending
{
    if ([self getFetchRequestForCellType:cellType] == nil)
    {
        if([arrayForPredicate count] > 0)
        {
            NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
            
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            // Entity to look for
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
            
            [fetchRequest setEntity:entity];
            
            // Filter results
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, arrayForPredicate]];
            
            // Sort results
            
            if(!(sortKeys == nil))
            {
                if([sortKeys count] > 0)
                {
                    NSMutableArray * sortDescriptors = [[NSMutableArray alloc] init];
                    
                    for (NSString *sortKey in sortKeys)
                    {
                        if([sortKey isKindOfClass:[NSString class]])
                        {
                            if(!(sortKey == nil))
                            {
                                if(!([sortKey isEqualToString:@""]))
                                {
                                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                                    
                                    [sortDescriptors addObject:sortDescriptor];
                                }
                            }
                        }
                    }

                    if (!(sortDescriptors == nil))
                    {
                        if([sortDescriptors count] > 0)
                        {
                            [fetchRequest setSortDescriptors:sortDescriptors];
                        }
                    }
                }
            }

            [fetchRequest setFetchBatchSize:20];
            
            [self setFetchRequest:fetchRequest ForCellType:cellType];
        }
    }
    
    return (!([self getFetchRequestForCellType:cellType] == nil));
}

// Create the mainFetchedResultsController
- (BOOL)initFetchedResultsControllerForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSString *)predicate inArray:(NSArray *)arrayForPredicate sortingWithKeys:(NSArray *)sortKeys ascending:(BOOL)ascending andSectionWithKeyPath:(NSString *)sectionNameKeyPath
{
    BOOL bReturn = FALSE;
    
    if([self getFetchedResultsControllerForCellType:cellType] == nil)
    {
        if([self initFetchRequestForCollectionViewWithCellType:cellType WithEntity:entityName andPredicate:predicate inArray:arrayForPredicate sortingWithKeys:sortKeys ascending:ascending])
        {
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[[self getFetchRequestForCellType:cellType] sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self getFetchRequestForCellType:cellType] managedObjectContext:currentContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
            
            [self setFetchedResultsController: fetchedResultsController ForCellType:cellType];
            
            if ([self performFetchForCollectionViewWithCellType:cellType])
            {
                bReturn = TRUE;
            }
        }
    }
    
    return bReturn;
}
- (BOOL)initFetchedResultsControllerForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSPredicate *)predicate sortingWithKeys:(NSArray *)sortKeys ascending:(BOOL)ascending andSectionWithKeyPath:(NSString *)sectionNameKeyPath
{
    BOOL bReturn = FALSE;
    
    if([self getFetchedResultsControllerForCellType:cellType] == nil)
    {
        if([self initFetchRequestForCollectionViewWithCellType:cellType WithEntity:entityName andPredicate:predicate sortingWithKeys:sortKeys ascending:ascending])
        {
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[[self getFetchRequestForCellType:cellType] sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self getFetchRequestForCellType:cellType] managedObjectContext:currentContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
            
            [self setFetchedResultsController: fetchedResultsController ForCellType:cellType];
            
            if ([self performFetchForCollectionViewWithCellType:cellType])
            {
                bReturn = TRUE;
            }
        }
    }
    
    return bReturn;
}

- (BOOL)initFetchedResultsControllerForCollectionViewWithCellType:(NSString *)cellType WithEntity:(NSString *)entityName andPredicate:(NSPredicate *)predicate sortingWithKeys:(NSArray *)sortKeys ascendingArray:(NSArray *)ascendingArray andSectionWithKeyPath:(NSString *)sectionNameKeyPath
{
    BOOL bReturn = FALSE;
    
    if([self getFetchedResultsControllerForCellType:cellType] == nil)
    {
        if([self initFetchRequestForCollectionViewWithCellType:cellType WithEntity:entityName andPredicate:predicate sortingWithKeys:sortKeys ascendingArray:ascendingArray])
        {
            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[[self getFetchRequestForCellType:cellType] sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self getFetchRequestForCellType:cellType] managedObjectContext:currentContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
            
            [self setFetchedResultsController: fetchedResultsController ForCellType:cellType];
            
            if ([self performFetchForCollectionViewWithCellType:cellType])
            {
                bReturn = TRUE;
            }
        }
    }
    
    return bReturn;
}

// Manage fetched results controller object updates
/*- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.objectChanges = [NSMutableDictionary dictionary];
    self.sectionChanges = [NSMutableDictionary dictionary];
}*/

// Manage fetched results controller object updates
/*- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{*/
   /* NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            
            change[@(type)] = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeUpdate:
            
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeMove:
            
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [self.objectChanges addObject:change];*/
    
/*    NSMutableArray *changeSet = self.objectChanges[@(type)];
    if (changeSet == nil) {
        changeSet = [[NSMutableArray alloc] init];
        self.objectChanges[@(type)] = changeSet;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [changeSet addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [changeSet addObject:@[indexPath, newIndexPath]];
            break;
    }
}*/

// Manage fetched results controller section updates
/*- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{*/
   /* NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            
            change[@(type)] = @(sectionIndex);
            break;
            
        case NSFetchedResultsChangeDelete:
            
            change[@(type)] = @(sectionIndex);
            break;
            
        case NSFetchedResultsChangeMove:
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            
            break;
    }
    
    [self.sectionChanges addObject:change];*/
/*    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete) {
        NSMutableIndexSet *changeSet = self.sectionChanges[@(type)];
        if (changeSet != nil) {
            [changeSet addIndex:sectionIndex];
        } else {
            self.sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
        }
    }
}*/

// Manage fetched results controller content updates
/*- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{*/
   /* if ([self.sectionChanges count] > 0)
    {
        [self.mainCollectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            
                            [self.mainCollectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                            
                        case NSFetchedResultsChangeDelete:
                            
                            [self.mainCollectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                            
                        case NSFetchedResultsChangeUpdate:
                            
                            [self.mainCollectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                            
                        case NSFetchedResultsChangeMove:
                            
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.mainCollectionView.window == nil)
        {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view ( http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure )
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar ( http://openradar.appspot.com/12954582 )
            
            [self.mainCollectionView reloadData];
        }
        else
        {
            [self.mainCollectionView performBatchUpdates:^{
                
                for (NSDictionary *change in self.objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.mainCollectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.mainCollectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.mainCollectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.mainCollectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [self.sectionChanges removeAllObjects];
    
    [self.objectChanges removeAllObjects];
    */
    
    
    /*NSMutableArray *moves = self.objectChanges[@(NSFetchedResultsChangeMove)];
    if (moves.count > 0) {
        NSMutableArray *updatedMoves = [[NSMutableArray alloc] initWithCapacity:moves.count];
        
        NSMutableIndexSet *insertSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        NSMutableIndexSet *deleteSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        for (NSArray *move in moves) {
            NSIndexPath *fromIP = move[0];
            NSIndexPath *toIP = move[1];
            
            if ([deleteSections containsIndex:fromIP.section]) {
                if (![insertSections containsIndex:toIP.section]) {
                    NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeInsert)];
                    if (changeSet == nil) {
                        changeSet = [[NSMutableArray alloc] initWithObjects:toIP, nil];
                        self.objectChanges[@(NSFetchedResultsChangeInsert)] = changeSet;
                    } else {
                        [changeSet addObject:toIP];
                    }
                }
            } else if ([insertSections containsIndex:toIP.section]) {
                NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeDelete)];
                if (changeSet == nil) {
                    changeSet = [[NSMutableArray alloc] initWithObjects:fromIP, nil];
                    self.objectChanges[@(NSFetchedResultsChangeDelete)] = changeSet;
                } else {
                    [changeSet addObject:fromIP];
                }
            } else {
                [updatedMoves addObject:move];
            }
        }
        
        if (updatedMoves.count > 0) {
            self.objectChanges[@(NSFetchedResultsChangeMove)] = updatedMoves;
        } else {
            [self.objectChanges removeObjectForKey:@(NSFetchedResultsChangeMove)];
        }
    }
    
    NSMutableArray *deletes = self.objectChanges[@(NSFetchedResultsChangeDelete)];
    if (deletes.count > 0) {
        NSMutableIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        [deletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![deletedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    NSMutableArray *inserts = self.objectChanges[@(NSFetchedResultsChangeInsert)];
    if (inserts.count > 0) {
        NSMutableIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        [inserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![insertedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    UICollectionView *collectionView = self.mainCollectionView;
    
    [collectionView performBatchUpdates:^{
        NSIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedSections.count > 0) {
            [collectionView deleteSections:deletedSections];
        }
        
        NSIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedSections.count > 0) {
            [collectionView insertSections:insertedSections];
        }
        
        NSArray *deletedItems = self.objectChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedItems.count > 0) {
            [collectionView deleteItemsAtIndexPaths:deletedItems];
        }
        
        NSArray *insertedItems = self.objectChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedItems.count > 0) {
            [collectionView insertItemsAtIndexPaths:insertedItems];
        }
        
        NSArray *reloadItems = self.objectChanges[@(NSFetchedResultsChangeUpdate)];
        if (reloadItems.count > 0) {
            [collectionView reloadItemsAtIndexPaths:reloadItems];
        }
        
        NSArray *moveItems = self.objectChanges[@(NSFetchedResultsChangeMove)];
        for (NSArray *paths in moveItems) {
            [collectionView moveItemAtIndexPath:paths[0] toIndexPath:paths[1]];
        }
    } completion:nil];
    
    self.objectChanges = nil;
    self.sectionChanges = nil;*/
/*
    
}

// Reload collection view after fetched results controller updates
- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL shouldReload = NO;
    
    for (NSDictionary *change in self.objectChanges)
    {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            
            NSIndexPath *indexPath = obj;
            
            switch (type)
            {
                case NSFetchedResultsChangeInsert:
                    
                    if ([self.mainCollectionView numberOfItemsInSection:indexPath.section] == 0)
                    {
                        shouldReload = YES;
                    }
                    else
                    {
                        shouldReload = NO;
                    }
                    break;
                    
                case NSFetchedResultsChangeDelete:
                    
                    if ([self.mainCollectionView numberOfItemsInSection:indexPath.section] == 1)
                    {
                        shouldReload = YES;
                    }
                    else
                    {
                        shouldReload = NO;
                    }
                    break;
                    
                case NSFetchedResultsChangeUpdate:
                    
                    shouldReload = NO;
                    break;
                    
                case NSFetchedResultsChangeMove:
                    
                    shouldReload = NO;
                    break;
            }
        }];
    }
    return shouldReload;
}*/

// Free all the data in memory when the view is offscreen
- (void)viewDidUnload
{
    self.mainFetchedResultsController = nil;
    self.secondFetchedResultsController = nil;
    self.thirdFetchedResultsController = nil;
}

@end
