//
//  GSBaseElement+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 27/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import "GSBaseElement+Manage.h"
#import "AppDelegate.h"

@interface GSBaseElement (PrimitiveAccessors)
- (NSString *)primitivePreview_image;
- (NSString *)primitivePostowner_image;
- (NSString *)primitiveContent_url;
@end

@implementation GSBaseElement (Manage)

-(NSString *) preview_image
{
    [self willAccessValueForKey:@"preview_image"];
    NSString *preview_image = [self primitivePreview_image];
    [self didAccessValueForKey:@"preview_image"];
    
//    NSString * preview_image = self.preview_image;
    if (preview_image != nil)
    {
        if(!(self.fashionistaId == nil))
        {
            if(!([preview_image isEqualToString:@""]))
            {
                if(!([preview_image hasPrefix:PROFILESPICIMAGESBASEURL]))
                {
                    preview_image = [NSString stringWithFormat:@"%@%@",PROFILESPICIMAGESBASEURL, preview_image];
                }
            }
            
            if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
            {
                preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            }
        }
        else
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
    }
    
    return preview_image;
}

-(NSString *) postowner_image
{
    [self willAccessValueForKey:@"postowner_image"];
    NSString *preview_image = [self primitivePostowner_image];
    [self didAccessValueForKey:@"postowner_image"];
    
    //    NSString * preview_image = self.preview_image;
    if (preview_image != nil)
    {
        
            if(!([preview_image isEqualToString:@""]))
            {
                if(!([preview_image hasPrefix:PROFILESPICIMAGESBASEURL]))
                {
                    preview_image = [NSString stringWithFormat:@"%@%@",PROFILESPICIMAGESBASEURL, preview_image];
                }
            }
            
            if(!NSEqualRanges( [preview_image rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
            {
                preview_image = [preview_image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            }
    }
    
    return preview_image;
}

-(NSString *) content_url
{
    [self willAccessValueForKey:@"content_url"];
    NSString *video = [self primitiveContent_url];
    [self didAccessValueForKey:@"content_url"];
    
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

//- (NSNumber *) group:(NSArray *)groups
//{
//    if(!(groups == nil))
//    {
//        if([groups count] > 0)
//        {
//            if([groups count] > 1)
//            {
//                for (int i = 1; i < [groups count]; i++)
//                {
//                    if([self.group intValue] < [[groups objectAtIndex:i] intValue])
//                    {
//                        return [groups objectAtIndex:(i-1)];
//                    }
//                }
//            }
//            else
//            {
//                return [groups objectAtIndex:0];
//            }
//        }
//        else
//        {
//            return [NSNumber numberWithInt:0];
//        }
//        
//        return [groups objectAtIndex:([groups count]-1)];
//    }
//    
//    return [NSNumber numberWithInt:0];
//}

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

- (NSArray*)postParamsFromBaseElement{
    NSArray* parametersForPost = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO],
                                  (self.fashionistaPostId?self.fashionistaPostId:@""),
                                    (self.preview_image?self.preview_image:@""),
                                    [self.post_comments array],
                                    (self.post_location?self.post_location:@""),
                                    (self.post_likes?self.post_likes:[NSNumber numberWithInteger:0]),
                                    (self.postowner_image?self.postowner_image:@""),
                                    /*post owner name*/(self.mainInformation?self.mainInformation:@""),
                                    (self.content_url?self.content_url:@""),
                                    (self.content_type?self.content_type:@""),
                                    (self.preview_image_width?self.preview_image_width:[NSNumber numberWithInteger:0]),
                                    (self.preview_image_height?self.preview_image_height:[NSNumber numberWithInteger:0]),
                                    (self.post_createdAt?self.post_createdAt:@""),
                                    (self.isFollowingAuthor?self.isFollowingAuthor:[NSNumber numberWithBool:NO]),
                                    (self.additionalInformation?self.additionalInformation:@""),
                                  (self.posttype?self.posttype:@""),
                                  (self.post_magazinecategory?self.post_magazinecategory:@""),
                                    (self.wardrobeQueryId?self.wardrobeQueryId:@""),
                                    nil];
    return parametersForPost;
}

@end
