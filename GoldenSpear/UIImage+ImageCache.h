//
//  UIImage+ImageCache.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageCache)

+ (BOOL) isCached:(NSString *)imageURL;
+ (UIImage *)cachedImageWithURL:(NSString*)imageURL;
+ (UIImage *)cachedImageWithURLForceReload:(NSString*)imageURL;
+ (UIImage *)cachedImageWithURL:(NSString*)imageURL withNoImageFileURL:(NSURL *)noImageFileURL;

@end
