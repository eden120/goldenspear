//
//  FeatureGroupOrderProductGroup.h
//  GoldenSpear
//
//  Created by Alberto Seco on 13/8/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeatureGroup, ProductGroup;

@interface FeatureGroupOrderProductGroup : NSManagedObject

@property (nonatomic, retain) NSString * idFeatureGroupOrder;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * featureGroupId;
@property (nonatomic, retain) NSString * productGroupId;
@property (nonatomic, retain) FeatureGroup *featureGroup;
@property (nonatomic, retain) ProductGroup *productGroup;

@end
