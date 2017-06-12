//
//  TypeLook+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TypeLook.h"

NS_ASSUME_NONNULL_BEGIN

@interface TypeLook (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idTypeLook;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *picture;

@end

NS_ASSUME_NONNULL_END
