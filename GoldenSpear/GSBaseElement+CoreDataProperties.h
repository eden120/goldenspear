//
//  GSBaseElement+CoreDataProperties.h
//  GoldenSpear
//
//  Created by Alberto Seco on 6/9/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSBaseElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSBaseElement (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *additionalInformation;
@property (nullable, nonatomic, retain) NSString *brandId;
@property (nullable, nonatomic, retain) NSNumber *content_type;
@property (nullable, nonatomic, retain) NSString *content_url;
@property (nullable, nonatomic, retain) NSString *fashionistaId;
@property (nullable, nonatomic, retain) NSString *fashionistaPageId;
@property (nullable, nonatomic, retain) NSString *fashionistaPostId;
@property (nullable, nonatomic, retain) NSNumber *group;
@property (nullable, nonatomic, retain) NSString *idGSBaseElement;
@property (nullable, nonatomic, retain) NSNumber *isFollowingAuthor;
@property (nullable, nonatomic, retain) NSString *mainInformation;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSDate *post_createdAt;
@property (nullable, nonatomic, retain) NSNumber *post_likes;
@property (nullable, nonatomic, retain) NSString *post_location;
@property (nullable, nonatomic, retain) NSString *postowner_image;
@property (nullable, nonatomic, retain) NSString *posttype;
@property (nullable, nonatomic, retain) NSNumber *premium;
@property (nullable, nonatomic, retain) NSString *preview_image;
@property (nullable, nonatomic, retain) NSNumber *preview_image_height;
@property (nullable, nonatomic, retain) NSNumber *preview_image_width;
@property (nullable, nonatomic, retain) NSString *product_polygons;
@property (nullable, nonatomic, retain) NSString *productId;
@property (nullable, nonatomic, retain) NSNumber *recommendedPrice;
@property (nullable, nonatomic, retain) NSString *styleId;
@property (nullable, nonatomic, retain) NSString *wardrobeId;
@property (nullable, nonatomic, retain) NSString *wardrobeQueryId;
@property (nullable, nonatomic, retain) NSString *post_magazinecategory;
@property (nullable, nonatomic, retain) NSOrderedSet<Comment *> *post_comments;

@end

@interface GSBaseElement (CoreDataGeneratedAccessors)

- (void)insertObject:(Comment *)value inPost_commentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPost_commentsAtIndex:(NSUInteger)idx;
- (void)insertPost_comments:(NSArray<Comment *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePost_commentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPost_commentsAtIndex:(NSUInteger)idx withObject:(Comment *)value;
- (void)replacePost_commentsAtIndexes:(NSIndexSet *)indexes withPost_comments:(NSArray<Comment *> *)values;
- (void)addPost_commentsObject:(Comment *)value;
- (void)removePost_commentsObject:(Comment *)value;
- (void)addPost_comments:(NSOrderedSet<Comment *> *)values;
- (void)removePost_comments:(NSOrderedSet<Comment *> *)values;

@end

NS_ASSUME_NONNULL_END
