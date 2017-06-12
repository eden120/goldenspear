//
//  Comment+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 16/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *fashionistaPostId;
@property (nullable, nonatomic, retain) NSString *fashionistaPostName;
@property (nullable, nonatomic, retain) NSString *idComment;
@property (nullable, nonatomic, retain) NSNumber *likeIt;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *video;
@property (nullable, nonatomic, retain) User *user;
@property (nullable, nonatomic, retain) FashionistaPost *post;

@end

NS_ASSUME_NONNULL_END
