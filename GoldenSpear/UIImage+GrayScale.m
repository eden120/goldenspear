//
//  UIImage+GrayScale.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "UIImage+GrayScale.h"

@implementation UIImage (GrayScale)

+(UIImage *)convertImageToGrayScale:(UIImage *)image
{
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];

    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
    [filter setValue:@(0.0) forKey:kCIInputSaturationKey];
    
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef cgImageRef = [context createCGImage:outputImage fromRect:outputImage.extent];
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:cgImageRef];
    
    CGImageRelease(cgImageRef);
    
    return resultUIImage;
}

@end
