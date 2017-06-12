//
//  ProductGroup.h
//  GoldenSpear
//
//  Created by Alberto Seco on 26/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Brand, Feature, FeatureGroup, FeatureGroupOrderProductGroup;

NS_ASSUME_NONNULL_BEGIN

@interface ProductGroup : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "ProductGroup+CoreDataProperties.h"
