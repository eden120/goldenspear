//
//  Country+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 12/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Country.h"

NS_ASSUME_NONNULL_BEGIN

@interface Country (CoreDataProperties)

@property (nullable, nonatomic, retain) id citiesId;
@property (nullable, nonatomic, retain) NSString *countryCode;
@property (nullable, nonatomic, retain) NSString *currency;
@property (nullable, nonatomic, retain) NSString *currencyCode;
@property (nullable, nonatomic, retain) NSString *currencySymbol;
@property (nullable, nonatomic, retain) NSString *idCountry;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) id statesId;
@property (nullable, nonatomic, retain) NSString *callingCodes;
@property (nullable, nonatomic, retain) NSSet<City *> *cities;
@property (nullable, nonatomic, retain) NSSet<StateRegion *> *states;

@end

@interface Country (CoreDataGeneratedAccessors)

- (void)addCitiesObject:(City *)value;
- (void)removeCitiesObject:(City *)value;
- (void)addCities:(NSSet<City *> *)values;
- (void)removeCities:(NSSet<City *> *)values;

- (void)addStatesObject:(StateRegion *)value;
- (void)removeStatesObject:(StateRegion *)value;
- (void)addStates:(NSSet<StateRegion *> *)values;
- (void)removeStates:(NSSet<StateRegion *> *)values;

@end

NS_ASSUME_NONNULL_END
