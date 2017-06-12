//
//  Content+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Content+Manage.h"
#import "AppDelegate.h"

@interface Content (PrimitiveAccessors)
- (NSString *)primitiveUrl;
@end

@implementation Content (Manage)

-(NSString *) url
{
    [self willAccessValueForKey:@"url"];
    NSString *preview_image = [self primitiveUrl];
    [self didAccessValueForKey:@"url"];
    
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
    [self addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"url" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"url"])
        {
            if (self.url != nil)
            {
                if(!([self.url isEqualToString:@""]))
                {
                    if(!([self.url hasPrefix:IMAGESBASEURL]))
                    {
                        self.url = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.url];
                    }
                }
                
                if(!NSEqualRanges( [self.url rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.url = [self.url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
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
