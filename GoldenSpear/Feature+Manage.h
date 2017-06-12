//
//  Feature+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Feature+CoreDataProperties.h"

@interface Feature (Manage)

@property (nonatomic) BOOL  isInSuggestedKeywords;

-(NSString *) getIconForGender:(int) gender andProductCategoryParent:(ProductGroup *) pgParent andProductCategoryChild:(ProductGroup *) pgChild byDefault:(NSString *) sPathByDefault;
-(NSString *) getIconForGender:(int) gender andProductCategoryParent:(ProductGroup *) pgParent andSubProductCategories:(NSMutableArray *) subProductCategories byDefault:(NSString *) sPathByDefault;

-(BOOL) isVisibleForGender:(int) gender andProductCategory:(ProductGroup *) productCategory andSubProductCategories:(NSMutableArray *) subProductCategories;

-(NSString *) getNameForApp;

@end
