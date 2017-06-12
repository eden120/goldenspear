//
//  PostOrdering+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 20/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PostOrdering.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostOrdering (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *field;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSNumber *visibleInLandingPage;
@property (nullable, nonatomic, retain) NSNumber *inUser;
@property (nullable, nonatomic, retain) NSNumber *inDiscover;
@property (nullable, nonatomic, retain) NSString *orderingId;

@end

NS_ASSUME_NONNULL_END
