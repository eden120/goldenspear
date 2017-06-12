//
//  keyboardCoreDataViewDataSource.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "keyboardCoreDataFetchController.h"

@protocol keyboardCoreDataViewDataSource <NSObject>

@required

@property (readonly, nonatomic, strong) keyboardCoreDataFetchController *coreDataFetchController;

- (NSString *)modelName;

- (NSString *)entityName;

- (NSString *)cellIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)defaultSortDescriptors;

- (NSPredicate *)defaultPredicate;

- (void)configureCell:(id)cell
         forIndexPath:(NSIndexPath *)indexPath;

@optional

- (Class)backingRESTClientClass;

@end