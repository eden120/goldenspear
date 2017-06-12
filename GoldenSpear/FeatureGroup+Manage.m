//
//  FeatureGroup+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FeatureGroup+Manage.h"
#import "NSObject+ButtonSlideView.h"

@implementation FeatureGroup (Manage)

-(int) getNumTotalFeatures
{
    return [self getNumTotalFeatures:self];
}


-(int) getNumTotalFeatures:(FeatureGroup *)featureGroup
{
    int iNumFeatures = (int)featureGroup.features.count;
    
    for(FeatureGroup * fgChild in featureGroup.featureGroups)
    {
        iNumFeatures += [self getNumTotalFeatures:fgChild];
    }
    
    return iNumFeatures;
}

-(FeatureGroup  *)getTopParent
{
    if (self.parent == nil)
    {
        return self;
    }
    else
    {
        return [self.parent getTopParent];
    }
    
    //return [self getTopParentOf:self];
}

-(FeatureGroup  *)getTopParentOf:(FeatureGroup *)featureGroup;
{
    
    if (featureGroup.parent != nil)
        return [self getTopParentOf:featureGroup.parent];
    else
        return featureGroup;
}

-(NSMutableArray *) getAllChildrenId
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [array addObject:self.idFeatureGroup];
    for (FeatureGroup *fg in self.featureGroups)
    {
        NSMutableArray * arrayChildren = [fg getAllChildrenId];
        [array addObjectsFromArray:arrayChildren];
    }
    
    return array;
}

-(NSMutableArray *) getAllChildren
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [array addObject:self];
    for (FeatureGroup *fg in self.featureGroups)
    {
        NSMutableArray * arrayChildren = [fg getAllChildren];
        [array addObjectsFromArray:arrayChildren];
    }
    
    return array;
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


#pragma mark - Functions for slidebutton view

-(NSString*)toStringButtonSlideView
{
    return [self getNameForApp];
}

/*
 -(void)awakeFromFetch
 {
 [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
 }
 
 -(void)awakeFromInsert
 {
 [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
 }
 
 - (void) willTurnIntoFault
 {
 [super willTurnIntoFault];
 
 [self removeObserver:self forKeyPath:@"name" context:(__bridge void*)self];
 }
 
 - (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 {
 if ((__bridge id)context == self)
 {
 if([keyPath isEqualToString:@"name"])
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
