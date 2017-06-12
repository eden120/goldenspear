//
//  KeyboardCoreDataManager.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "KeyboardCoreDataIncrementalStore.h"
#import "NSManagedObject+KeyboardHelper.h"
#import "KeyboardCoreDataCollectionViewController.h"
#import "KeyboardCoreDataTableViewController.h"

@interface KeyboardCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) AFRESTClient<AFIncrementalStoreHTTPClient> *client;

+ (instancetype)managerForModelName:(NSString *)dataModelName;
+ (instancetype)managerForModelName:(NSString *)dataModelName withBackingRESTClientClass:(Class)RestClientClass;

+ (instancetype)managerForContext:(NSManagedObjectContext *)context;
+ (void)saveContext:(NSManagedObjectContext *)context;
- (void)saveContext;

@end
