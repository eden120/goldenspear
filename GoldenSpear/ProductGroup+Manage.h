//
//  ProductGroup+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "ProductGroup+CoreDataProperties.h"
#import "NSObject+ButtonSlideView.h"

@interface ProductGroup (Manage)

@property (nonatomic, retain) NSString * iconPath;
@property (nonatomic, retain) NSString * iconPathMen;
@property (nonatomic, retain) NSString * iconPathWomen;
@property (nonatomic, retain) NSString * iconPathBoy;
@property (nonatomic, retain) NSString * iconPathGirl;
@property (nonatomic, retain) NSString * iconPathUnisex;
@property (nonatomic, retain) NSString * iconPathKid;
@property (nonatomic, retain) NSMutableArray * childrenProductGroup;

@property (nonatomic) BOOL  selected;
@property (nonatomic) BOOL  isInSuggestedKeywords;

-(NSString *) getNameForApp;
-(NSString *) getIconForGender:(int) gender byDefault:(NSString *) sPathByDefault;

-(int) getNumFeaturesGroup;
-(NSMutableArray *) getFeturesGroupExcept:(NSString *)sFeatureGroupToIgnore;
-(NSMutableArray *) getChildren;
-(NSMutableArray *) getChildrenInFoundSuggestions:(NSMutableDictionary *)foundSuggestions forGender:(int)iGender;
-(NSMutableArray *) getChildrenReloading;
-(NSMutableArray *) getAllDescendants;
-(NSMutableArray *) getAllDescendantsInFoundSuggestions:(NSMutableDictionary *)foundSuggestions forGender:(int)iGender;
-(NSMutableArray *) getAllParents;
-(BOOL) isChild:(ProductGroup *) pg;
-(BOOL) isDescendant:(ProductGroup *) pg;
-(ProductGroup *) getChildAtPosition:(int) iIdx;

-(BOOL)existsFeatureGroupByName:(NSString *)sFeatureGroupName;

-(BOOL)checkGender:(int) gender;
-(BOOL)checkExpandedForGender:(int) gender;

-(ProductGroup  *)getTopParent;
-(ProductGroup  *)getTopParentOf:(ProductGroup *)productGroup;
@end
