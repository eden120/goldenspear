//
//  Product+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/7/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Product.h"

NS_ASSUME_NONNULL_BEGIN

@interface Product (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *brandId;
@property (nullable, nonatomic, retain) NSString *group;
@property (nullable, nonatomic, retain) NSString *idProduct;
@property (nullable, nonatomic, retain) NSString *information;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *preview_image;
@property (nullable, nonatomic, retain) NSNumber *preview_image_heigth;
@property (nullable, nonatomic, retain) NSNumber *preview_image_width;
@property (nullable, nonatomic, retain) NSString *profile_brand;
@property (nullable, nonatomic, retain) NSNumber *recommendedPrice;
@property (nullable, nonatomic, retain) NSString *size;
@property (nullable, nonatomic, retain) id size_array;
@property (nullable, nonatomic, retain) NSString *sku;
@property (nullable, nonatomic, retain) NSNumber *stat_viewnumber;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *variantGroupId;
@property (nullable, nonatomic, retain) NSString *color;
@property (nullable, nonatomic, retain) NSString *material;
@property (nullable, nonatomic, retain) Brand *brand;
@property (nullable, nonatomic, retain) VariantGroup *variantGroup;
@property (nullable, nonatomic, retain) NSString *color_curated;
@property (nullable, nonatomic, retain) NSString *material_curated;

@end

NS_ASSUME_NONNULL_END
