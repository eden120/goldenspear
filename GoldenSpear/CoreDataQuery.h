//
//  CoreDataQuery.h
//  GoldenSpear
//
//  Created by Alberto Seco on 15/2/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

#import "ProductGroup+Manage.h"
#import "Feature+Manage.h"
#import "FeatureGroup+Manage.h"
#import "Keyword+Manage.h"
#import "Brand+Manage.h"

@interface CoreDataQuery : NSObject

+ (CoreDataQuery *)sharedCoreDataQuery;

-(void) initDataFromLocalDatabase;

-(ProductGroup *) getProductGroupFromId:(NSString *) idProductGroup;
-(ProductGroup *) getProductGroupFromName:(NSString *) name;
-(ProductGroup *) getProductGroupParentFromId:(NSString *) idProductGroup;

-(Feature *)getFeatureFromId:(NSString *)idFeature;
-(Feature *)getFeatureFromName:(NSString *)sName;
-(NSMutableArray *) getFeaturesOfFeatureGroupByName: (NSString *)sNameFeatureGroup;

-(FeatureGroup *)getFeatureGroupFromId:(NSString *)idFeatureGroup;
-(FeatureGroup *)getFeatureGroupFromName:(NSString *)name;
-(FeatureGroup *) getFeatureGroupFromFeatureName:(NSString *) name;

-(Brand *) getBrandFromId:(NSString *)idBrand;
-(Brand *) getBrandFromName:(NSString *)name;
-(NSMutableArray *) getAllBrands;
-(NSMutableArray *) getAllProductGroup;

-(Keyword *) getKeywordFromId:(NSString *)idKeyword;
-(NSObject *) getKeywordElementForName:(NSString *) sNameKeyword;

@end
