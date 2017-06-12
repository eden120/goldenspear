//
//  GSPostCategoryOrderManager.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 20/6/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostCategory.h"
#import "PostOrdering.h"

#define kGSPCOManagerFinishedDownloadingNotification @"kGSPCOManagerFinishedDownloadingNotification"

@interface GSPostCategoryOrderManager : NSObject

+ (NSArray*)getPostOrderingForSection:(NSInteger)section;
+ (NSArray*)getPostCategoriesForSection:(NSInteger)section;
+ (void)downloadData:(BOOL)force;

@end
