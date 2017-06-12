//
//  keyboardIDGenerator.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface keyboardIDGenerator : NSObject

#pragma mark - Singleton
+ (instancetype)sharedInstance;

#pragma mark - ID Generation
@property (readonly, atomic, strong) NSString *UUID;
+ (NSString *)uniqueIdentifier;

@end
