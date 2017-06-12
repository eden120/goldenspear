//
//  keyboardCoreDataCollectionViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "keyboardCoreDataViewDataSource.h"

@interface keyboardCoreDataCollectionViewController : UICollectionViewController <keyboardCoreDataViewDataSource>

@property (readonly) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

@end
