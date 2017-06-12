//
//  StateRegion+CoreDataProperties.m
//  GoldenSpear
//
//  Created by Alberto Seco on 27/10/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StateRegion+CoreDataProperties.h"

@implementation StateRegion (CoreDataProperties)

@dynamic idStateRegion;
@dynamic name;
@dynamic statesId;
@dynamic citiesId;
@dynamic parentId;
@dynamic countryId;
@dynamic parentstateregion;
@dynamic states;
@dynamic cities;
@dynamic country;

@end
