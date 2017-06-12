//
//  ProductGroup+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "ProductGroup+Manage.h"
#import "FeatureGroup+Manage.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
@import Foundation;

static char ICONPATH_KEY;
static char ICONMENPATH_KEY;
static char ICONWOMENPATH_KEY;
static char ICONBOYPATH_KEY;
static char ICONGIRLPATH_KEY;
static char ICONUNISEXPATH_KEY;
static char ICONKIDPATH_KEY;
static char SELECTED_KEY;
static char INSUGGESTEDKEYWORD_KEY;
static char CHILDREN_KEY;

@interface ProductGroup (PrimitiveAccessors)
- (NSString *)primitiveIcon;
@end

@implementation ProductGroup (Manage)

//-(NSString *) icon
//{
//    [self willAccessValueForKey:@"icon"];
//    NSString *preview_image = [self primitiveIcon];
//    [self didAccessValueForKey:@"icon"];
//    
//    //    NSString * preview_image = self.preview_image;
//    if (preview_image != nil)
//    {
//        if(!([preview_image isEqualToString:@""]))
//        {
//            if(!([preview_image hasPrefix:IMAGESBASEURL]))
//            {
//                preview_image = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, preview_image];
//            }
//        }
//        
//        if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
//        {
//            preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//        }
//    }
//    
//    return preview_image;
//}

#pragma mark - Properties

// Getter and setter for picImage
- (NSString *)iconPath
{
    return objc_getAssociatedObject(self, &ICONPATH_KEY);
}

- (void)setIconPath:(NSString *)iconPath
{
    objc_setAssociatedObject(self, &ICONPATH_KEY, iconPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for picImage
- (NSString *)iconPathMen
{
    return objc_getAssociatedObject(self, &ICONMENPATH_KEY);
}

- (void)setIconPathMen:(NSString *)iconPathMen
{
    objc_setAssociatedObject(self, &ICONMENPATH_KEY, iconPathMen, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for picImage
- (NSString *)iconPathWomen
{
    return objc_getAssociatedObject(self, &ICONWOMENPATH_KEY);
}

- (void)setIconPathWomen:(NSString *)iconPathWomen
{
    objc_setAssociatedObject(self, &ICONWOMENPATH_KEY, iconPathWomen, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for picImage
- (NSString *)iconPathBoy
{
    return objc_getAssociatedObject(self, &ICONBOYPATH_KEY);
}

- (void)setIconPathBoy:(NSString *)iconPathBoy
{
    objc_setAssociatedObject(self, &ICONBOYPATH_KEY, iconPathBoy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for picImage
- (NSString *)iconPathGirl
{
    return objc_getAssociatedObject(self, &ICONGIRLPATH_KEY);
}

- (void)setIconPathGirl:(NSString *)iconPathGirl
{
    objc_setAssociatedObject(self, &ICONGIRLPATH_KEY, iconPathGirl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for iconunisex
- (NSString *)iconPathUnisex
{
    return objc_getAssociatedObject(self, &ICONUNISEXPATH_KEY);
}

- (void)setIconPathUnisex:(NSString *)iconPathUnisex
{
    objc_setAssociatedObject(self, &ICONUNISEXPATH_KEY, iconPathUnisex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for iconkid
- (NSString *)iconPathKid
{
    return objc_getAssociatedObject(self, &ICONKIDPATH_KEY);
}

- (void)setIconPathKid:(NSString *)iconPathKid
{
    objc_setAssociatedObject(self, &ICONKIDPATH_KEY, iconPathKid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


// Getter and setter for selected
- (BOOL)selected
{
    return [(NSNumber *)objc_getAssociatedObject(self, &SELECTED_KEY) boolValue];
}

- (void)setSelected:(BOOL)selected
{
    NSNumber * nsValue = [NSNumber numberWithBool:selected];
//    NSLog(@"setSelected %@", (nsValue.boolValue?@"YES":@"NO"));
    objc_setAssociatedObject(self, &SELECTED_KEY, nsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for selected
- (BOOL)isInSuggestedKeywords
{
    return [(NSNumber *)objc_getAssociatedObject(self, &INSUGGESTEDKEYWORD_KEY) boolValue];
}

- (void)setIsInSuggestedKeywords:(BOOL)selected
{
    NSNumber * nsValue = [NSNumber numberWithBool:selected];
    //    NSLog(@"setSelected %@", (nsValue.boolValue?@"YES":@"NO"));
    objc_setAssociatedObject(self, &INSUGGESTEDKEYWORD_KEY, nsValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// Getter and setter for children
- (NSMutableArray *)childrenProductGroup
{
    return objc_getAssociatedObject(self, &CHILDREN_KEY);
}

- (void)setChildrenProductGroup:(NSMutableArray *)children
{
    objc_setAssociatedObject(self, &CHILDREN_KEY, children, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Functions for slidebutton view

-(NSString*)toStringButtonSlideView
{
    return [self getNameForApp];
}

-(NSString*)toImageButtonSlideView
{
    return [self checkIcon:self.icon];
}

#pragma mark - Name for App

-(NSString *) getNameForApp
{
    if (self.app_name != nil)
    {
        if (![self.app_name isEqualToString: @""])
        {
            return self.app_name;
        }
    }
    
    return self.name;
}

#pragma mark - Icon by gender

- (NSString *) checkIcon:(NSString *) sPathIcon
{
    if (sPathIcon != nil)
    {
        if (![sPathIcon  isEqualToString: @""])
        {
            return sPathIcon;
        }
    }
    
    return self.icon;
}

-(NSString *) getIconForGender:(int) gender byDefault:(NSString *) sPathByDefault
{
    NSString * iconGender = self.icon;
    NSString * iconToShow = nil;
    
    if (gender == 1)
    {
        iconToShow = [self checkIcon:self.icon_m];
    }
    else if (gender == 2)
    {
        iconToShow =  [self checkIcon:self.icon_w];
    }
    else if (gender == 4)
    {
        iconToShow =  [self checkIcon:self.icon_b];
    }
    else if (gender == 8)
    {
        iconToShow =  [self checkIcon:self.icon_g];
    }
    else if (gender == 16)
    {
        iconToShow =  [self checkIcon:self.icon_u];
    }
    else if (gender == 32)
    {
        iconToShow =  [self checkIcon:self.icon_k];
    }
    
    if ((iconToShow != nil) && !([iconToShow isEqualToString:@""]))
    {
        iconGender = iconToShow;
    }
        
    
    if (iconGender != nil)
    {
        if (![iconGender  isEqualToString: @""])
        {
            return [self completeIconPath:iconGender];
        }
    }

    return sPathByDefault;
}

-(BOOL)checkGender:(int) gender
{
    int iGenders = [self.genders intValue];
    //    NSLog(@"checkGender for %@. Gender: %i. GenderToCheck: %i", [self getNameForApp], iGenders, gender);
    if ((gender > 0) && (iGenders > 0))
        return (iGenders & gender);
    
    return YES;
}

-(BOOL)checkExpandedForGender:(int) gender
{
    int iGenders = [self.expanded intValue];
    //    NSLog(@"checkGender for %@. Gender: %i. GenderToCheck: %i", [self getNameForApp], iGenders, gender);
    if ((gender > 0) && (iGenders > 0))
        return (iGenders & gender);
    
    return NO;
}

#pragma mark - FeaturesGroups

-(int) getNumFeaturesGroup
{
    return [self getNumFeaturesGroupOfProductCategory:self];
}

-(int) getNumFeaturesGroupOfProductCategory:(ProductGroup *) productCategory
{
    int iNumGroupFeatures = (int)productCategory.featuresGroupOrder.count;
    
    for(ProductGroup * pgChild in productCategory.productGroups)
    {
        iNumGroupFeatures += [self getNumFeaturesGroupOfProductCategory:pgChild];
    }
    return iNumGroupFeatures;
}

-(NSMutableArray *) getFeturesGroupExcept:(NSString *)sFeatureGroupToIgnore;
{
    NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"featureGroup.name" ascending:YES];
    
    NSMutableArray * featureGroups = [NSMutableArray arrayWithArray:[[self.featuresGroupOrder allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptorOrder, sortDescriptorName, nil]]];

    NSMutableArray * resFeaturesGroup = [[NSMutableArray alloc] init];
    NSString * sFeatureGroupToIgnoreTrimmed = [sFeatureGroupToIgnore stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // looping all product categories filtering the product ctagoeries withour featuregroup
    for(FeatureGroupOrderProductGroup * fgOrder in featureGroups)
    {
        if (fgOrder.order > 0)
        {
            FeatureGroup * fg = fgOrder.featureGroup;
            // check the num features for each featuregroup
            int iNumFeatures = [fg getNumTotalFeatures];
            if (iNumFeatures > 0)
            {
                // check the name of the featuregroup, if is equal to the parameter
                NSString *sFeatureGroupNameTrimmed = [fg.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (![sFeatureGroupToIgnoreTrimmed.lowercaseString isEqualToString:sFeatureGroupNameTrimmed.lowercaseString])
                {
                    if (![self existsFeatureGroupByName:sFeatureGroupNameTrimmed inArray:resFeaturesGroup])
                    {
                        [resFeaturesGroup addObject:fg];
                    }
                }
            }
        }
    }

    return resFeaturesGroup;
}

-(BOOL)existsFeatureGroupByName:(NSString *)sFeatureGroupNameToSearch inArray:(NSArray*)array
{
    for (FeatureGroup *fg in array)
    {
        NSString * sFeatureGroupName = [fg.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([sFeatureGroupName.lowercaseString isEqualToString:sFeatureGroupNameToSearch.lowercaseString])
        {
            return YES;
        }
        
    }
    
    return NO;
}



-(BOOL)existsFeatureGroupByName:(NSString *)sFeatureGroupName
{
    NSString * sFeatureGroupNameTrimmed = [sFeatureGroupName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [self existsFeatureGroupByNameRecursive:sFeatureGroupNameTrimmed] ;//] inProductCategory:self];
}

-(BOOL)existsFeatureGroupByNameRecursive:(NSString *)sFeatureGroupNameToSearch
{
    for (FeatureGroupOrderProductGroup *fgOrder in self.featuresGroupOrder)
    {
        FeatureGroup *fg = fgOrder.featureGroup;
        NSString * sFeatureGroupName = [fg.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([sFeatureGroupName.lowercaseString isEqualToString:sFeatureGroupNameToSearch.lowercaseString])
        {
            return YES;
        }
        
    }
    
    for(ProductGroup * pgChild in self.productGroups)
    {
        if ([pgChild existsFeatureGroupByNameRecursive:sFeatureGroupNameToSearch])
        {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Children

-(BOOL) isChild:(ProductGroup *) pg
{
    NSMutableArray * allChildren = [self getChildren];
    
    for(ProductGroup * pgChild in allChildren)
    {
        if ([pgChild.idProductGroup isEqualToString:pg.idProductGroup])
            return YES;
    }
    
    return NO;
}

-(BOOL) isDescendant:(ProductGroup *) pg
{
    NSMutableArray * allChildren = [self getAllDescendants];
    
    for(ProductGroup * pgChild in allChildren)
    {
        if ([pgChild.idProductGroup isEqualToString:pg.idProductGroup])
            return YES;
    }
    
    return NO;
}

-(NSMutableArray *) getChildren
{
    if (self.childrenProductGroup == nil)
    {

        self.childrenProductGroup = [NSMutableArray arrayWithArray:[[self.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO],
                                                                                                                                                          [NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES],nil]]];
    }
    
    return self.childrenProductGroup;
}

-(NSMutableArray *) getChildrenInFoundSuggestions:(NSMutableDictionary *)foundSuggestions forGender:(int)iGender
{
    if (self.childrenProductGroup == nil)
    {
        self.childrenProductGroup = [NSMutableArray arrayWithArray:[[self.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO],
                                                                                                                                                          [NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES],nil]]];
    }

    NSMutableArray * arrayRes = [[NSMutableArray alloc] init];
    for(ProductGroup *pgChild in self.childrenProductGroup)
    {
        if ([pgChild checkGender:iGender])
        {
            if(foundSuggestions.count == 0 || [foundSuggestions objectForKey:pgChild.idProductGroup])
            {
                [arrayRes addObject:pgChild];
            }
        }
    }

    
    return arrayRes;
}

-(NSMutableArray *) getAllDescendants
{
    if (self.childrenProductGroup == nil)
    {
        self.childrenProductGroup = [NSMutableArray arrayWithArray:[[self.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO],
                                                                                                                                 [NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES],nil]]];
    }
    
    NSMutableArray * arrayRest = [[NSMutableArray alloc] init];
    for(ProductGroup * pgChild in self.childrenProductGroup)
    {
        [arrayRest addObject:pgChild];
        NSMutableArray * temp = [pgChild getAllDescendants];
        [arrayRest addObjectsFromArray:temp];
        
    }
    
    return arrayRest;
}

-(NSMutableArray *) getAllDescendantsInFoundSuggestions:(NSMutableDictionary *)foundSuggestions forGender:(int)iGender
{
    NSMutableArray * allDescendants = [self getAllDescendants];
    
    NSMutableArray * arrayRest = [[NSMutableArray alloc] init];
    for(ProductGroup * pgChild in allDescendants)
    {
        if ([pgChild checkGender:iGender])
        {
            if(foundSuggestions.count == 0 || [foundSuggestions objectForKey:pgChild.idProductGroup])
            {
                [arrayRest addObject:pgChild];
            }
        }
    }
    
    return arrayRest;
}

-(NSMutableArray *) getAllParents
{
    NSMutableArray * arrayRest = [[NSMutableArray alloc] init];
    ProductGroup * pg = self;
    [arrayRest addObject:pg];
    while (pg.parent != nil)
    {
        pg = pg.parent;
        if (pg != nil)
        {
            [arrayRest addObject:pg];
        }
    }
    
    return arrayRest;
    
}

-(ProductGroup *) getChildAtPosition:(int) iIdx
{
    if (self.childrenProductGroup == nil)
    {
        self.childrenProductGroup = [NSMutableArray arrayWithArray:[[self.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO],
                                                                                                                                 [NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES],nil]]];
    }
    ProductGroup * child= nil;
    
    if ((iIdx >= 0) && (iIdx < self.childrenProductGroup.count))
    {
        child = [self.childrenProductGroup objectAtIndex:iIdx];
    }
    
    return child;
}

-(NSMutableArray *) getChildrenReloading
{
    if (self.childrenProductGroup != nil)
    {
        [self.childrenProductGroup removeAllObjects];
    }
    
//    self.childrenProductGroup = [NSMutableArray arrayWithArray:[[self.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES]]]];
    self.childrenProductGroup = [NSMutableArray arrayWithArray:[[self.productGroups allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO],
                                                                                                                             [NSSortDescriptor sortDescriptorWithKey:@"app_name" ascending:YES],nil]]];
    
    return self.childrenProductGroup;
}

-(ProductGroup  *)getTopParent
{
    if (self.parent == nil)
        return self;
    else
    {
        return [self.parent getTopParent];
    }
    
//    return [self getTopParentOf:self];
}

-(ProductGroup  *)getTopParentOf:(ProductGroup *)productGroup;
{
    
    if (productGroup.parent != nil)
        return [self getTopParentOf:productGroup.parent];
    else
        return productGroup;
}

- (NSString *) completeIconPath:(NSString *) sIconPath
{
    NSString * sIconFulPath = nil;
    if (sIconPath != nil)
    {
        if(!([sIconPath isEqualToString:@""]))
        {
            if(!([sIconPath hasPrefix:IMAGESBASEURL]))
            {
                sIconFulPath = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, sIconPath];
            }
        }
        
        if(!NSEqualRanges( [sIconPath rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            sIconFulPath = [sIconPath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return sIconFulPath;
    
}



#pragma mark - Image url manage

/*
-(void)awakeFromFetch
{
    self.childrenProductGroup = nil;
    
    [self addObserver:self forKeyPath:@"icon" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
//    [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    self.childrenProductGroup = nil;
    
    [self addObserver:self forKeyPath:@"icon" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
//    [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"icon" context:(__bridge void*)self];
//    [self removeObserver:self forKeyPath:@"name" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"icon"])
        {
            self.iconPath = [self completeIconPath:self.icon ];
            self.iconPathMen = [self completeIconPath:self.icon_m ];
            self.iconPathWomen = [self completeIconPath:self.icon_w ];
            self.iconPathBoy = [self completeIconPath:self.icon_b ];
            self.iconPathGirl = [self completeIconPath:self.icon_g ];
            self.iconPathUnisex = [self completeIconPath:self.icon_u ];
        }
        else if([keyPath isEqualToString:@"name"])
        {
            if (self.name != nil)
            {
                if(self.name != [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]])
                    self.name = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}
*/

@end
