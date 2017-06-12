//
//  Keyword+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 22/4/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Keyword.h"

NS_ASSUME_NONNULL_BEGIN

@interface Keyword (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *brandId;
@property (nullable, nonatomic, retain) NSString *featureId;
@property (nullable, nonatomic, retain) NSNumber *forPostContent;
@property (nullable, nonatomic, retain) NSString *idKeyword;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *productCategoryId;
@property (nullable, nonatomic, retain) NSNumber *userAdded;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSSet<ResultsGroup *> *resultsGroups;

@end

@interface Keyword (CoreDataGeneratedAccessors)

- (void)addResultsGroupsObject:(ResultsGroup *)value;
- (void)removeResultsGroupsObject:(ResultsGroup *)value;
- (void)addResultsGroups:(NSSet<ResultsGroup *> *)values;
- (void)removeResultsGroups:(NSSet<ResultsGroup *> *)values;

@end

NS_ASSUME_NONNULL_END
