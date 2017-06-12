//
//  SearchQuery.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SearchQuery : NSManagedObject

@property (nonatomic, retain) NSString * searchQuery;
@property (nonatomic, retain) NSNumber * numresults;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * idSearchQuery;

@end