//
//  LiveStreamingComment+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LiveStreamingComment.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreamingComment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *fashionista_name;
@property (nullable, nonatomic, retain) NSString *idLiveStreamingComment;
@property (nullable, nonatomic, retain) NSString *liveStreamingId;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *user_picture;
@property (nullable, nonatomic, retain) NSString *userId;

@end

NS_ASSUME_NONNULL_END
