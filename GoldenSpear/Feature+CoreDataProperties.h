//
//  Feature+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 21/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Feature.h"

NS_ASSUME_NONNULL_BEGIN

@interface Feature (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *app_name;
@property (nullable, nonatomic, retain) NSString *featureGroupId;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *icons;
@property (nullable, nonatomic, retain) NSString *idFeature;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *priority;
@property (nullable, nonatomic, retain) id productGroupsId;
@property (nullable, nonatomic, retain) NSString *hidden;
@property (nullable, nonatomic, retain) FeatureGroup *featureGroup;
@property (nullable, nonatomic, retain) NSSet<ProductGroup *> *productGroups;

@end

@interface Feature (CoreDataGeneratedAccessors)

- (void)addProductGroupsObject:(ProductGroup *)value;
- (void)removeProductGroupsObject:(ProductGroup *)value;
- (void)addProductGroups:(NSSet<ProductGroup *> *)values;
- (void)removeProductGroups:(NSSet<ProductGroup *> *)values;

@end

NS_ASSUME_NONNULL_END
