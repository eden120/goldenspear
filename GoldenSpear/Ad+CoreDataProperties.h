//
//  Ad+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Jose Antonio on 06/09/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Ad.h"

NS_ASSUME_NONNULL_BEGIN

@interface Ad (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSString *video;
@property (nullable, nonatomic, retain) NSNumber *width;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, retain) NSString *website;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSString *profileId;
@property (nullable, nonatomic, retain) NSString *productId;
@property (nullable, nonatomic, retain) NSString *postId;
@property (nullable, nonatomic, retain) NSString *idAd;

@end

NS_ASSUME_NONNULL_END
