//
//  POI+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 17/8/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "POI.h"

NS_ASSUME_NONNULL_BEGIN

@interface POI (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idPOI;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *address;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *asciiname;
@property (nullable, nonatomic, retain) NSString *featureclass;
@property (nullable, nonatomic, retain) NSString *featurecode;

@end

NS_ASSUME_NONNULL_END
