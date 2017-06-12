//
//  FashionistaPost+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 26/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FashionistaPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface FashionistaPost (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *commentsNum;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *fashionistaPageId;
@property (nullable, nonatomic, retain) NSString *group;
@property (nullable, nonatomic, retain) NSString *idFashionistaPost;
@property (nullable, nonatomic, retain) NSNumber *imagesNum;
@property (nullable, nonatomic, retain) NSNumber *isFollowingAuthor;
@property (nullable, nonatomic, retain) NSNumber *likesNum;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *location_poi;
@property (nullable, nonatomic, retain) NSString *magazineAuthor;
@property (nullable, nonatomic, retain) NSString *magazineCategory;
@property (nullable, nonatomic, retain) NSString *magazinePhotographer;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *preview_image;
@property (nullable, nonatomic, retain) NSNumber *preview_image_height;
@property (nullable, nonatomic, retain) NSNumber *preview_image_width;
@property (nullable, nonatomic, retain) NSNumber *stat_viewnumber;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSNumber *publicPost;
@property (nullable, nonatomic, retain) User *author;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;
@property (nullable, nonatomic, retain) NSSet<FashionistaContent *> *contents;

@end

@interface FashionistaPost (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

- (void)addContentsObject:(FashionistaContent *)value;
- (void)removeContentsObject:(FashionistaContent *)value;
- (void)addContents:(NSSet<FashionistaContent *> *)values;
- (void)removeContents:(NSSet<FashionistaContent *> *)values;

@end

NS_ASSUME_NONNULL_END
