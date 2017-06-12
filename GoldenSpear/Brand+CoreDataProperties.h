//
//  Brand+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 2/12/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Brand.h"

NS_ASSUME_NONNULL_BEGIN

@interface Brand (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *gbin;
@property (nullable, nonatomic, retain) NSString *idBrand;
@property (nullable, nonatomic, retain) NSString *information;
@property (nullable, nonatomic, retain) NSString *logo;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *priority;
@property (nullable, nonatomic, retain) id productGroupsId;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSSet<ProductGroup *> *productGroups;
@property (nullable, nonatomic, retain) NSSet<Product *> *products;

@end

@interface Brand (CoreDataGeneratedAccessors)

- (void)addProductGroupsObject:(ProductGroup *)value;
- (void)removeProductGroupsObject:(ProductGroup *)value;
- (void)addProductGroups:(NSSet<ProductGroup *> *)values;
- (void)removeProductGroups:(NSSet<ProductGroup *> *)values;

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet<Product *> *)values;
- (void)removeProducts:(NSSet<Product *> *)values;

@end

NS_ASSUME_NONNULL_END
