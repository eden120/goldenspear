//
//  PostCategory+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 20/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PostCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSNumber *inUser;
@property (nullable, nonatomic, retain) NSNumber *inDiscover;
@property (nullable, nonatomic, retain) NSString *categoryId;

@end

NS_ASSUME_NONNULL_END
