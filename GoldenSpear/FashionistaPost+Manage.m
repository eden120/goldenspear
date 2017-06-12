//
//  FashionistaPost+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 03/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FashionistaPost+Manage.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

static char POSTIMAGEPREVIEW_KEY;

@interface FashionistaPost (PrimitiveAccessors)
- (NSString *)primitivePreview_image;
@end

@implementation FashionistaPost (Manage)

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

// Getter and setter for picImage
- (NSString *)preview_image_path
{
    return objc_getAssociatedObject(self, &POSTIMAGEPREVIEW_KEY);
}

- (void)setPreview_image_path:(NSString *)preview_image_path
{
    NSLog(@"setPreview_image_path %@", preview_image_path);
    objc_setAssociatedObject(self, &POSTIMAGEPREVIEW_KEY, preview_image_path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
//                        self.preview_image_path = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.preview_image];
                    }
                }
                
                if(!NSEqualRanges( [self.preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.preview_image = [self.preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//                    self.preview_image_path = [self.preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
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

@implementation FashionistaPostView

@end

@implementation FashionistaPostViewTime

@end

@implementation FashionistaPostShared

@end

@implementation PostContentReport

@end

@implementation PostUserUnfollow


@end
