//
//  FeatureGroup+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 20/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FeatureGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface FeatureGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) id featureGroupsId;
@property (nullable, nonatomic, retain) id featuresId;
@property (nullable, nonatomic, retain) NSString *idFeatureGroup;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *parentId;
@property (nullable, nonatomic, retain) id productGroupsId;
@property (nullable, nonatomic, retain) id productGroupsOrderId;
@property (nullable, nonatomic, retain) NSString *app_name;
@property (nullable, nonatomic, retain) NSSet<FeatureGroup *> *featureGroups;
@property (nullable, nonatomic, retain) NSSet<Feature *> *features;
@property (nullable, nonatomic, retain) FeatureGroup *parent;
@property (nullable, nonatomic, retain) NSSet<ProductGroup *> *productGroups;
@property (nullable, nonatomic, retain) NSSet<FeatureGroupOrderProductGroup *> *productGroupsOrder;

@end

@interface FeatureGroup (CoreDataGeneratedAccessors)

- (void)addFeatureGroupsObject:(FeatureGroup *)value;
- (void)removeFeatureGroupsObject:(FeatureGroup *)value;
- (void)addFeatureGroups:(NSSet<FeatureGroup *> *)values;
- (void)removeFeatureGroups:(NSSet<FeatureGroup *> *)values;

- (void)addFeaturesObject:(Feature *)value;
- (void)removeFeaturesObject:(Feature *)value;
- (void)addFeatures:(NSSet<Feature *> *)values;
- (void)removeFeatures:(NSSet<Feature *> *)values;

- (void)addProductGroupsObject:(ProductGroup *)value;
- (void)removeProductGroupsObject:(ProductGroup *)value;
- (void)addProductGroups:(NSSet<ProductGroup *> *)values;
- (void)removeProductGroups:(NSSet<ProductGroup *> *)values;

- (void)addProductGroupsOrderObject:(FeatureGroupOrderProductGroup *)value;
- (void)removeProductGroupsOrderObject:(FeatureGroupOrderProductGroup *)value;
- (void)addProductGroupsOrder:(NSSet<FeatureGroupOrderProductGroup *> *)values;
- (void)removeProductGroupsOrder:(NSSet<FeatureGroupOrderProductGroup *> *)values;

@end

NS_ASSUME_NONNULL_END
