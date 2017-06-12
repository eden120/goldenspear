//
//  ResultsGroup.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 30/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Keyword;

@interface ResultsGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * first_order;
@property (nonatomic, retain) NSNumber * last_order;
@property (nonatomic, retain) NSString * searchQueryId;
@property (nonatomic, retain) NSString * idResultsGroup;
@property (nonatomic, retain) NSSet *keywords;
@end

@interface ResultsGroup (CoreDataGeneratedAccessors)

- (void)addKeywordsObject:(Keyword *)value;
- (void)removeKeywordsObject:(Keyword *)value;
- (void)addKeywords:(NSSet *)values;
- (void)removeKeywords:(NSSet *)values;

@end
