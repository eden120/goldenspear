//
//  Product+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Product+Manage.h"
#import "AppDelegate.h"

@interface Product (PrimitiveAccessors)
- (NSString *)primitivePreview_image;
- (NSString *)primitiveUrl;
- (NSString *)primitiveProfile_brand;
@end

@implementation Product (Manage)

-(NSString *) preview_image
{
    [self willAccessValueForKey:@"preview_image"];
    NSString *preview_image = [self primitivePreview_image];
    [self didAccessValueForKey:@"preview_image"];
    
    //    NSString * preview_image = self.preview_image;
    if (preview_image != nil)
    {
        if(!([preview_image isEqualToString:@""]))
        {
            if(!([preview_image hasPrefix:IMAGESBASEURL]))
            {
                preview_image = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, preview_image];
            }
        }
        
        if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return preview_image;
}

-(NSString *) profile_brand
{
	[self willAccessValueForKey:@"profile_brand"];
	NSString *profile_brand = [self primitiveProfile_brand];
	[self didAccessValueForKey:@"profile_brand"];
	
	return profile_brand;
}

-(NSString *) url
{
    [self willAccessValueForKey:@"url"];
    NSString *path = [self primitiveUrl];
    [self didAccessValueForKey:@"url"];
    
    //    NSString * preview_image = self.preview_image;
    if (path != nil)
    {
        if(!NSEqualRanges( [path rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return path;
}

-(NSString*)toStringButtonSlideView
{
    return self.name;
}

-(NSString*)toImageButtonSlideView
{
    return self.preview_image;
}

/*
-(void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"preview_image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"preview_image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"url" context:(__bridge void*)self];
    
    [self removeObserver:self forKeyPath:@"preview_image" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"url"])
        {
            if (self.url != nil)
            {
                if(!NSEqualRanges( [self.url rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.url = [self.url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                }
            }
        }
        else if([keyPath isEqualToString:@"preview_image"])
        {
            if (self.preview_image != nil)
            {
                if(!([self.preview_image isEqualToString:@""]))
                {
                    if(!([self.preview_image hasPrefix:IMAGESBASEURL]))
                    {
                        self.preview_image = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.preview_image];
                    }
                }

                if(!NSEqualRanges( [self.preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.preview_image = [self.preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                }
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

@implementation ProductView

@end

@implementation ProductShared

@end

@implementation ProductPurchase

@end

@implementation ProductReport

@end

@implementation ProductAvailability

@end

@implementation ProductAvailabilityTimeTable

@end

@implementation ProductAvailabilityTimeTableIntervalTime

@end

