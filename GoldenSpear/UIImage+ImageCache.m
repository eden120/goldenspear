 //
//  UIImage+ImageCache.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UIImage+ImageCache.h"
#import "ImageCache.h"

@implementation UIImage (ImageCache)

+ (BOOL) isCached:(NSString *)imageURL
{
    return [[ImageCache sharedImageCache] doesExist:imageURL];
}

- (UIImage*)scaleDownToSizeKeepAspect:(CGSize)size
{
    if(size.width*size.height > self.size.height*self.size.width)
        return self;
    
    float fmax = size.height;
    
    if(self.size.width > self.size.height)
        fmax = size.width;
    
    float oldWidth = self.size.width;
    float scaleFactor = fmax / oldWidth;
    
    float newHeight = self.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [self drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)cachedImageWithURL:(NSString*)imageURL
{
    NSURL *noImageFileURL = [[NSBundle mainBundle]
                             URLForResource: @"no_image" withExtension:@"png"];
    
    return [self cachedImageWithURL:imageURL withNoImageFileURL:noImageFileURL];
}

+ (UIImage *)cachedImageWithURL:(NSString*)imageURL withNoImageFileURL:(NSURL *)noImageFileURL
{
    UIImage *image;
    
    // Check the image cache to see if the image already exists. If so, then use it. If not, then download it.
    
    if ([[ImageCache sharedImageCache] doesExist:imageURL] == true)
    {
        image = [[ImageCache sharedImageCache] getImage:imageURL];
    }
    else
    {
       // NSLog([NSString stringWithFormat:@"Cargamos imagen: %@",imageURL]);
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageURL]];
        
        if (imageData != nil)
        {
            image = [[UIImage alloc] initWithData:imageData];
            
            image = [image scaleDownToSizeKeepAspect:CGSizeMake(1280, 720)];
            // Add the image to the cache
            [[ImageCache sharedImageCache] addImage:image withURL:imageURL];
        }
        else
        {
            return nil;
        }
    }
    
    return image;
}

+ (UIImage *)cachedImageWithURLForceReload:(NSString*)imageURL
{
    if ([[ImageCache sharedImageCache] doesExist:imageURL] == true)
    {
        [[ImageCache sharedImageCache] deleteImageWithKey:imageURL];
    }
    
    return [UIImage cachedImageWithURL:imageURL];
}

@end
