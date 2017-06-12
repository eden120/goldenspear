//
//  LiveStreamingPrivacy+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LiveStreamingPrivacy.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreamingPrivacy (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idLiveStreamingPrivacy;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *value;

@end

NS_ASSUME_NONNULL_END