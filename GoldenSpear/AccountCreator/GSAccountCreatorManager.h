//
//  GSAccountCreatorManager.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 14/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAccountType.h"

@interface GSAccountCreatorManager : NSObject

+ (id)sharedManager;
- (void)setAccountTypes:(NSArray*)json;

- (NSArray*)getUserTypes;
- (GSAccountType*)getAccountTypeWithId:(NSString*)accountId;

@end
