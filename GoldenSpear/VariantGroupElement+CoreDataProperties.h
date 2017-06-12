//
//  VariantGroupElement+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/7/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VariantGroupElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface VariantGroupElement (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *color_name;
@property (nullable, nonatomic, retain) NSString *color_image;
@property (nullable, nonatomic, retain) NSString *material_image;
@property (nullable, nonatomic, retain) NSString *material_name;
@property (nullable, nonatomic, retain) NSString *product_id;
@property (nullable, nonatomic, retain) VariantGroup *variantGroup;

@end

NS_ASSUME_NONNULL_END
