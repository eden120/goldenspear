//
//  City+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 27/10/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "City.h"

NS_ASSUME_NONNULL_BEGIN

@interface City (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idCity;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *countryId;
@property (nullable, nonatomic, retain) NSString *stateregionId;
@property (nullable, nonatomic, retain) Country *country;
@property (nullable, nonatomic, retain) StateRegion *stateregion;

@end

NS_ASSUME_NONNULL_END
