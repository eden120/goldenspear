//
//  ProductGroup+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 2/12/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ProductGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *app_name;
@property (nullable, nonatomic, retain) id brandsId;
@property (nullable, nonatomic, retain) NSString *descriptionProductGroup;
@property (nullable, nonatomic, retain) id featuresGroupId;
@property (nullable, nonatomic, retain) id featuresGroupOrderId;
@property (nullable, nonatomic, retain) id featuresId;
@property (nullable, nonatomic, retain) NSNumber *genders;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *icon_b;
@property (nullable, nonatomic, retain) NSString *icon_g;
@property (nullable, nonatomic, retain) NSString *icon_k;
@property (nullable, nonatomic, retain) NSString *icon_m;
@property (nullable, nonatomic, retain) NSString *icon_u;
@property (nullable, nonatomic, retain) NSString *icon_w;
@property (nullable, nonatomic, retain) NSString *idProductGroup;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *parentId;
@property (nullable, nonatomic, retain) id productGroupsId;
@property (nullable, nonatomic, retain) NSNumber *visible;
@property (nullable, nonatomic, retain) NSNumber *expanded;
@property (nullable, nonatomic, retain) NSSet<Brand *> *brands;
@property (nullable, nonatomic, retain) NSSet<Feature *> *features;
@property (nullable, nonatomic, retain) NSSet<FeatureGroup *> *featuresGroup;
@property (nullable, nonatomic, retain) NSSet<FeatureGroupOrderProductGroup *> *featuresGroupOrder;
@property (nullable, nonatomic, retain) ProductGroup *parent;
@property (nullable, nonatomic, retain) NSSet<ProductGroup *> *productGroups;

@end

@interface ProductGroup (CoreDataGeneratedAccessors)

- (void)addBrandsObject:(Brand *)value;
- (void)removeBrandsObject:(Brand *)value;
- (void)addBrands:(NSSet<Brand *> *)values;
- (void)removeBrands:(NSSet<Brand *> *)values;

- (void)addFeaturesObject:(Feature *)value;
- (void)removeFeaturesObject:(Feature *)value;
- (void)addFeatures:(NSSet<Feature *> *)values;
- (void)removeFeatures:(NSSet<Feature *> *)values;

- (void)addFeaturesGroupObject:(FeatureGroup *)value;
- (void)removeFeaturesGroupObject:(FeatureGroup *)value;
- (void)addFeaturesGroup:(NSSet<FeatureGroup *> *)values;
- (void)removeFeaturesGroup:(NSSet<FeatureGroup *> *)values;

- (void)addFeaturesGroupOrderObject:(FeatureGroupOrderProductGroup *)value;
- (void)removeFeaturesGroupOrderObject:(FeatureGroupOrderProductGroup *)value;
- (void)addFeaturesGroupOrder:(NSSet<FeatureGroupOrderProductGroup *> *)values;
- (void)removeFeaturesGroupOrder:(NSSet<FeatureGroupOrderProductGroup *> *)values;

- (void)addProductGroupsObject:(ProductGroup *)value;
- (void)removeProductGroupsObject:(ProductGroup *)value;
- (void)addProductGroups:(NSSet<ProductGroup *> *)values;
- (void)removeProductGroups:(NSSet<ProductGroup *> *)values;

@end

NS_ASSUME_NONNULL_END
