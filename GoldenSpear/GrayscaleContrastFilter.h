//
//  GrayscaleContrastFilter.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 12/08/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//
//  BASED ON DLCImagePickerController: https://github.com/gobackspaces/DLCImagePickerController
//

#import "GPUImageFilter.h"

extern NSString *const kGrayscaleContrastFragmentShaderString;

/** Converts an image to grayscale (a slightly faster implementation of the saturation filter, without the ability to vary the color contribution)*/
@interface GrayscaleContrastFilter : GPUImageFilter
{
    GLint intensityUniform;
    GLint slopeUniform;
}

@property(readwrite, nonatomic) CGFloat intensity;

@end