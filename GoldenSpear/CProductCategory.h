//
//  CProductCategory.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CProductCategory, CTagCategory, CVariant;

@interface CProductCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * pcId;
@property (nonatomic, retain) NSString * pcName;
@property (nonatomic, retain) NSNumber * pcParentCategoryID;
@property (nonatomic, retain) NSMutableArray * pcProductsID;
//@property (nonatomic, retain) id pcProductsID;
@property (nonatomic, retain) NSMutableArray * pcSubCategoriesID;
//@property (nonatomic, retain) id pcSubCategoriesID;
@property (nonatomic, retain) NSMutableArray * pcTagCategoriesID;
//@property (nonatomic, retain) id pcTagCategoriesID;
@property (nonatomic, retain) NSSet *pcSubCategories;
@property (nonatomic, retain) CProductCategory *pcParentCategory;
@property (nonatomic, retain) NSSet *pcProducts;
@property (nonatomic, retain) NSSet *pcTagCategories;
@end

@interface CProductCategory (CoreDataGeneratedAccessors)

- (void)addPcSubCategoriesObject:(CProductCategory *)value;
- (void)removePcSubCategoriesObject:(CProductCategory *)value;
- (void)addPcSubCategories:(NSSet *)values;
- (void)removePcSubCategories:(NSSet *)values;

- (void)addPcProductsObject:(CVariant *)value;
- (void)removePcProductsObject:(CVariant *)value;
- (void)addPcProducts:(NSSet *)values;
- (void)removePcProducts:(NSSet *)values;

- (void)addPcTagCategoriesObject:(CTagCategory *)value;
- (void)removePcTagCategoriesObject:(CTagCategory *)value;
- (void)addPcTagCategories:(NSSet *)values;
- (void)removePcTagCategories:(NSSet *)values;

@end
