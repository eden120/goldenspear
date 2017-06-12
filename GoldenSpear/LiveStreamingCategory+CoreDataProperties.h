//
//  LiveStreamingCategory+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LiveStreamingCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreamingCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *idLiveStreamingCategory;
@property (nullable, nonatomic, retain) NSNumber *isNews;
@property (nullable, nonatomic, retain) NSNumber *isTrending;
@property (nullable, nonatomic, retain) id livestreamings;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *numActiveLiveStreams;
@property (nullable, nonatomic, retain) NSNumber *numLiveStreams;
@property (nullable, nonatomic, retain) NSNumber *order;

@end

NS_ASSUME_NONNULL_END
