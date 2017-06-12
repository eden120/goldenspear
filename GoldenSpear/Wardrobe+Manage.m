//
//  Wardrobe+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Wardrobe+Manage.h"
#import "AppDelegate.h"

@interface Wardrobe (PrimitiveAccessors)
- (NSString *)primitivePreview_image;
@end

@implementation Wardrobe (Manage)

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

/*
-(void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"preview_image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"preview_image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"preview_image" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"preview_image"])
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

@implementation WardrobeView

@end
