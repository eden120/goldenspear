//
//  SuggestedKeyword.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SuggestedKeyword : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * idSuggestedKeyword;
@property (nonatomic, retain) NSNumber * order;

@end
