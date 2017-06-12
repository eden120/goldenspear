//
//  ImageCache.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

@synthesize imgCache;

#pragma mark - Methods

static ImageCache* sharedImageCache = nil;

+(ImageCache*)sharedImageCache
{
    @synchronized([ImageCache class])
    {
        if (!sharedImageCache)
            sharedImageCache= [[self alloc] init];
        
        return sharedImageCache;
    }
    
    return nil;
}

+(id)alloc
{
    @synchronized([ImageCache class])
    {
        //NSAssert(sharedImageCache == nil, @"Attempted to allocate a second instance of a singleton.");

        if(!(sharedImageCache == nil))
        {
            NSLog(@"XXXX Attempted to allocate a second instance of a singleton. XXXX");
            return sharedImageCache;
        }
        
        sharedImageCache = [super alloc];
        
        return sharedImageCache;
    }
    
    return nil;
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        imgCache = [[NSCache alloc] init];
        //[imgCache setTotalCostLimit:30000000];
    }
    
    return self;
}

- (void) addImage:(UIImage *)image withURL:(NSString *)imageURL;
{
    if (!(image == nil))
    {
        NSUInteger s3  = CGImageGetHeight(image.CGImage) * CGImageGetBytesPerRow(image.CGImage);

        [imgCache setObject:image forKey:imageURL cost:s3];
    }
}

- (void) deleteImageWithKey:(NSString *)imageURL
{
    [imgCache removeObjectForKey:imageURL];
}

- (NSString*) getImage:(NSString *)imageURL
{
    return [imgCache objectForKey:imageURL];
}

- (BOOL) doesExist:(NSString *)imageURL
{
    if ([imgCache objectForKey:imageURL] == nil)
    {
        return false;
    }
    
    return true;
}

@end
