//
//  KeyboardCoreDataIncrementalStore.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "KeyboardCoreDataIncrementalStore.h"

@implementation KeyboardCoreDataIncrementalStore

+ (void)initialize
{
    [NSPersistentStoreCoordinator registerStoreClass:self
                                        forStoreType:[self type]];
}

+ (NSString *)type
{
    return NSStringFromClass(self);
}

- (id<AFIncrementalStoreHTTPClient>)HTTPClient
{
    return self.client;
}

@end
