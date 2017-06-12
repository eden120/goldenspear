//
//  Wardrobe+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 26/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Wardrobe.h"

NS_ASSUME_NONNULL_BEGIN

@interface Wardrobe (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *fashionistaContentId;
@property (nullable, nonatomic, retain) NSString *idWardrobe;
@property (nullable, nonatomic, retain) id itemsId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *preview_image;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSNumber *publicWardrobe;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
