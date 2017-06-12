//
//  GSAccountCreatorManager.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 14/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountCreatorManager.h"

@interface GSAccountCreatorManager (){
    NSMutableDictionary* accountDictionary;
    NSMutableArray* accountArray;
}

@end

@implementation GSAccountCreatorManager

+ (id)sharedManager {
    static GSAccountCreatorManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)setAccountTypes:(NSArray*)json{
    accountDictionary = [NSMutableDictionary new];
    accountArray = [NSMutableArray new];
    for (NSDictionary* account in json) {
        GSAccountType* aType = [GSAccountType new];
        [aType setAccountWithDictionary:account];
        [accountDictionary setObject:aType forKey:aType.typeId];
        [accountArray addObject:aType];
    }
}

- (NSArray*)getUserTypes{
    return accountArray;
}

- (GSAccountType *)getAccountTypeWithId:(NSString *)accountId{
    return [accountDictionary objectForKey:accountId];
}

@end
