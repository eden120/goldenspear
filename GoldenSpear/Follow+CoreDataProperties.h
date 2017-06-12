//
//  Follow+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 17/8/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Follow.h"

NS_ASSUME_NONNULL_BEGIN

@interface Follow (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *followedId;
@property (nullable, nonatomic, retain) NSString *followingId;
@property (nullable, nonatomic, retain) NSString *idFollow;
@property (nullable, nonatomic, retain) NSNumber *verified;

@end

NS_ASSUME_NONNULL_END
