//
//  LiveStreaming+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 22/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LiveStreaming.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveStreaming (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *ageRange;
@property (nullable, nonatomic, retain) id brands;
@property (nullable, nonatomic, retain) id categories;
@property (nullable, nonatomic, retain) id cities;
@property (nullable, nonatomic, retain) id countries;
@property (nullable, nonatomic, retain) id ethnicities;
@property (nullable, nonatomic, retain) NSDate *expiration_date;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) id hashtags;
@property (nullable, nonatomic, retain) NSString *idLiveStreaming;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSNumber *longitud;
@property (nullable, nonatomic, retain) NSNumber *numActiveViews;
@property (nullable, nonatomic, retain) NSNumber *numComments;
@property (nullable, nonatomic, retain) NSNumber *numLikes;
@property (nullable, nonatomic, retain) NSNumber *numShares;
@property (nullable, nonatomic, retain) NSNumber *numViews;
@property (nullable, nonatomic, retain) NSString *owner_picture;
@property (nullable, nonatomic, retain) NSString *owner_username;
@property (nullable, nonatomic, retain) NSString *ownerId;
@property (nullable, nonatomic, retain) NSString *path_video;
@property (nullable, nonatomic, retain) NSString *postId;
@property (nullable, nonatomic, retain) NSString *preview_image;
@property (nullable, nonatomic, retain) NSNumber *preview_image_height;
@property (nullable, nonatomic, retain) NSNumber *preview_image_width;
@property (nullable, nonatomic, retain) NSString *preview_video;
@property (nullable, nonatomic, retain) NSString *privacyId;
@property (nullable, nonatomic, retain) id productcategories;
@property (nullable, nonatomic, retain) id stateregions;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) id typelooks;

@end

NS_ASSUME_NONNULL_END
