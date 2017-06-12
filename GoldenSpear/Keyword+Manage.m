//
//  Keyword+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 26/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Keyword+Manage.h"

@implementation Keyword (Manage)

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

#pragma mark - Functions for slidebutton view

-(NSString*)toStringButtonSlideView
{
    if ([self.forPostContent boolValue])
    {
        return [NSString stringWithFormat:@"#%@", self.name ];
    }
    
    return self.name;

}

-(NSString*)toImageButtonSlideView
{
    return self.name;
}

-(NSString *) getIdElement
{
    if ((self.productCategoryId != nil) && (![self.productCategoryId isEqualToString:@""]))
    {
        return self.productCategoryId;
    }
    if ((self.featureId != nil) && (![self.featureId isEqualToString:@""]))
    {
        return self.featureId;
    }
    if ((self.brandId != nil) && (![self.brandId isEqualToString:@""]))
    {
        return self.brandId;
    }
    
    return nil;
}


@end
