//
//  VariantGroup+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/7/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VariantGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface VariantGroup (CoreDataProperties)

@property (nullable, nonatomic, retain) id coloursId;
@property (nullable, nonatomic, retain) NSString *idVariantGroup;
@property (nullable, nonatomic, retain) id materialsId;
@property (nullable, nonatomic, retain) id variantsId;
@property (nullable, nonatomic, retain) NSSet<VariantGroupElement *> *colours;
@property (nullable, nonatomic, retain) NSSet<VariantGroupElement *> *materials;
@property (nullable, nonatomic, retain) NSSet<VariantGroupElement *> *variants;

@end

@interface VariantGroup (CoreDataGeneratedAccessors)

- (void)addColoursObject:(VariantGroupElement *)value;
- (void)removeColoursObject:(VariantGroupElement *)value;
- (void)addColours:(NSSet<VariantGroupElement *> *)values;
- (void)removeColours:(NSSet<VariantGroupElement *> *)values;

- (void)addMaterialsObject:(VariantGroupElement *)value;
- (void)removeMaterialsObject:(VariantGroupElement *)value;
- (void)addMaterials:(NSSet<VariantGroupElement *> *)values;
- (void)removeMaterials:(NSSet<VariantGroupElement *> *)values;

- (void)addVariantsObject:(VariantGroupElement *)value;
- (void)removeVariantsObject:(VariantGroupElement *)value;
- (void)addVariants:(NSSet<VariantGroupElement *> *)values;
- (void)removeVariants:(NSSet<VariantGroupElement *> *)values;

@end

NS_ASSUME_NONNULL_END
