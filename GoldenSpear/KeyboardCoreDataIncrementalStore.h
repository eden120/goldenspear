//
//  KeyboardCoreDataIncrementalStore.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "AFIncrementalStore.h"
#import "AFRESTClient.h"

@interface KeyboardCoreDataIncrementalStore : AFIncrementalStore

@property (strong, nonatomic) AFRESTClient<AFIncrementalStoreHTTPClient> *client;

@end
