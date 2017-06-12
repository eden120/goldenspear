//
//  LiveStreamingEthnicity+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LiveStreamingEthnicity.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreamingEthnicity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *ethnicityId;
@property (nullable, nonatomic, retain) NSString *idLiveStreamingEthnicity;
@property (nullable, nonatomic, retain) NSString *livestreamingId;
@property (nullable, nonatomic, retain) NSString *other;

@end

NS_ASSUME_NONNULL_END
