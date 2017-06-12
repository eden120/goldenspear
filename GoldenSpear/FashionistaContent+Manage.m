//
//  FashionistaContent+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 03/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FashionistaContent+Manage.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

static char IMAGEPOSTCONTENT_KEY;
static char VIDEOPOSTCONTENT_KEY;

@interface FashionistaContent (PrimitiveAccessors)
- (NSString *)primitiveImage;
- (NSString *)primitiveVideo;
@end

@implementation FashionistaContent (Manage)

-(NSString *) image
{
    [self willAccessValueForKey:@"image"];
    NSString *preview_image = [self primitiveImage];
    [self didAccessValueForKey:@"image"];
    
    if (preview_image != nil)
    {
        if(!([preview_image isEqualToString:@""]))
        {
            if((!([preview_image hasPrefix:IMAGESBASEURL])) && (!([preview_image hasPrefix:@"file:///"])))
            {
                preview_image = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, preview_image];
                //                        self.image_path = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.image];
            }
        }
        
        if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            //                    self.image_path = [self.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return preview_image;
}

-(NSString *) video
{
    [self willAccessValueForKey:@"video"];
    NSString *video = [self primitiveVideo];
    [self didAccessValueForKey:@"video"];
    
    //    NSString * preview_image = self.preview_image;
    if (video != nil)
    {
        if(!([video isEqualToString:@""]))
        {
            if((!([video hasPrefix:IMAGESBASEURL])) && (!([video hasPrefix:@"file:///"])))
            {
                video = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, video];
                //                        self.video_path = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.video];
            }
        }
        
        if(!NSEqualRanges( [video rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            video = [video stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            //                    self.video_path = [self.video stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return video;
}

// Getter and setter for image
- (NSString *)image_path
{
    return objc_getAssociatedObject(self, &IMAGEPOSTCONTENT_KEY);
}

- (void)setImage_path:(NSString *)image_path
{
    objc_setAssociatedObject(self, &IMAGEPOSTCONTENT_KEY, image_path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
// Getter and setter for video
- (NSString *)video_path
{
    return objc_getAssociatedObject(self, &VIDEOPOSTCONTENT_KEY);
}

- (void)setVideo_path:(NSString *)video_path
{
    objc_setAssociatedObject(self, &VIDEOPOSTCONTENT_KEY, video_path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/*
-(void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];

    [self addObserver:self forKeyPath:@"video" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

-(void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
    
    [self addObserver:self forKeyPath:@"video" options:NSKeyValueObservingOptionNew context:(__bridge void*)self];
}

- (void) willTurnIntoFault
{
    [super willTurnIntoFault];
    
    [self removeObserver:self forKeyPath:@"image" context:(__bridge void*)self];
    
    [self removeObserver:self forKeyPath:@"video" context:(__bridge void*)self];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((__bridge id)context == self)
    {
        if([keyPath isEqualToString:@"image"])
        {
            if (self.image != nil)
            {
                if(!([self.image isEqualToString:@""]))
                {
                    if((!([self.image hasPrefix:IMAGESBASEURL])) && (!([self.image hasPrefix:@"file:///"])))
                    {
                        self.image = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.image];
//                        self.image_path = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.image];
                    }
                }
                
                if(!NSEqualRanges( [self.image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.image = [self.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//                    self.image_path = [self.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                }
            }
        }
        else if([keyPath isEqualToString:@"video"])
        {
            if (self.video != nil)
            {
                if(!([self.video isEqualToString:@""]))
                {
                    if((!([self.video hasPrefix:IMAGESBASEURL])) && (!([self.video hasPrefix:@"file:///"])))
                    {
                        self.video = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.video];
//                        self.video_path = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.video];
                    }
                }
                
                if(!NSEqualRanges( [self.video rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
                {
                    self.video = [self.video stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//                    self.video_path = [self.video stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
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
