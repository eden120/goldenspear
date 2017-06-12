//
//  FeatureGroup+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FeatureGroup+CoreDataProperties.h"

@interface FeatureGroup (Manage)

-(int) getNumTotalFeatures;
-(FeatureGroup  *)getTopParent;
-(NSMutableArray *) getAllChildrenId;
-(NSMutableArray *) getAllChildren;

-(NSString *) getNameForApp;

@end
