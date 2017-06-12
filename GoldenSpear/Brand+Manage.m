//
//  Brand+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Brand+Manage.h"
#import "AppDelegate.h"
#import "NSObject+ButtonSlideView.h"

@interface Brand (PrimitiveAccessors)
- (NSString *)primitiveLogo;
- (NSString *)primitiveUrl;
@end


@implementation Brand (Manage)

-(NSString *) logo
{
    [self willAccessValueForKey:@"logo"];
    NSString *preview_image = [self primitiveLogo];
    [self didAccessValueForKey:@"logo"];
    
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

-(NSString *) url
{
    [self willAccessValueForKey:@"url"];
    NSString *url = [self primitiveUrl];
    [self didAccessValueForKey:@"url"];
    
    if (url != nil)
    {
        if(!NSEqualRanges( [url rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            url = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return url;
}


-(NSString*)toStringButtonSlideView
{
    return self.name;
}

-(NSString*)toImageButtonSlideView
{
    return self.logo;
}

-(NSString *) getLogo
{
    NSString * logoToReturn = self.logo;
    
    if (self.logo != nil)
    {
        if(!([self.logo isEqualToString:@""]))
        {
            if(!([self.logo hasPrefix:IMAGESBASEURL]))
            {
                logoToReturn = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.logo];
            }
        }
        
        if(!NSEqualRanges( [self.logo rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            logoToReturn = [self.logo stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return logoToReturn;
}

/*
-(void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"logo" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];

    [self addObserver:self forKeyPath:@"logo" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"url" context:(__bridge void*)self];

    [self removeObserver:self forKeyPath:@"logo" context:(__bridge void*)self];
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
        else if([keyPath isEqualToString:@"logo"])
        {
            if (self.logo != nil)
            {
                if(!([self.logo isEqualToString:@""]))
                {
                    if(!([self.logo hasPrefix:IMAGESBASEURL]))
                    {
                        self.logo = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.logo];
                    }
                }

                if(!NSEqualRanges( [self.logo rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.logo = [self.logo stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
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
