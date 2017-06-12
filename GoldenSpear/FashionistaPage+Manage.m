//
//  FashionistaPage+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 03/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import "FashionistaPage+Manage.h"
#import "AppDelegate.h"
#import <objc/runtime.h>
#import "NSObject+ButtonSlideView.h"

static char IMAGEHEADER_KEY;

@interface FashionistaPage (PrimitiveAccessors)
- (NSString *)primitiveHeader_image;
- (NSString *)primitiveBlogURL;
@end







@implementation FashionistaPage (Manage)
/*
-(NSString *) header_image
{
    [self willAccessValueForKey:@"header_image"];
    NSString *preview_image = [self primitiveHeader_image];
    [self didAccessValueForKey:@"header_image"];
    
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

-(NSString *) blogURL
{
    [self willAccessValueForKey:@"blogURL"];
    NSString *path = [self primitiveBlogURL];
    [self didAccessValueForKey:@"blogURL"];
    
    if (path != nil)
    {
        if(!NSEqualRanges( [path rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    else
    {
        path = @"";
    }
    
    return path;
}
*/

-(NSString*)toStringButtonSlideView
{
    return self.title;
}


// Getter and setter for picImage
- (NSString *)header_image_path
{
    return objc_getAssociatedObject(self, &IMAGEHEADER_KEY);
}

- (void)setHeader_image_path:(NSString *)header_image_path
{
    objc_setAssociatedObject(self, &IMAGEHEADER_KEY, header_image_path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"blogURL" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"header_image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"blogURL" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"header_image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"blogURL" context:(__bridge void*)self];
    
    [self removeObserver:self forKeyPath:@"header_image" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"blogURL"])
        {
            if (self.blogURL != nil)
            {
                if(!NSEqualRanges( [self.blogURL rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.blogURL = [self.blogURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                }
            }
        }
        else if([keyPath isEqualToString:@"header_image"])
        {
            if (self.header_image != nil)
            {
                if(!([self.header_image isEqualToString:@""]))
                {
                    if(!([self.header_image hasPrefix:IMAGESBASEURL]))
                    {
//                        self.header_image_path = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.header_image];
                        self.header_image = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.header_image];
                    }
                }
                
                if(!NSEqualRanges( [self.header_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.header_image = [self.header_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//                    self.header_image_path = [self.header_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                }
            }
        }
    }
    else
    {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

@end
