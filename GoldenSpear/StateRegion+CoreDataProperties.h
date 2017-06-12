//
//  StateRegion+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 27/10/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StateRegion.h"

NS_ASSUME_NONNULL_BEGIN

@interface StateRegion (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idStateRegion;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) id statesId;
@property (nullable, nonatomic, retain) id citiesId;
@property (nullable, nonatomic, retain) NSString *parentId;
@property (nullable, nonatomic, retain) NSString *countryId;
@property (nullable, nonatomic, retain) StateRegion *parentstateregion;
@property (nullable, nonatomic, retain) NSSet<StateRegion *> *states;
@property (nullable, nonatomic, retain) NSSet<City *> *cities;
@property (nullable, nonatomic, retain) Country *country;

@end

@interface StateRegion (CoreDataGeneratedAccessors)

- (void)addStatesObject:(StateRegion *)value;
- (void)removeStatesObject:(StateRegion *)value;
- (void)addStates:(NSSet<StateRegion *> *)values;
- (void)removeStates:(NSSet<StateRegion *> *)values;

- (void)addCitiesObject:(City *)value;
- (void)removeCitiesObject:(City *)value;
- (void)addCities:(NSSet<City *> *)values;
- (void)removeCities:(NSSet<City *> *)values;

@end

NS_ASSUME_NONNULL_END
