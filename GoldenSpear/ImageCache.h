//
//  ImageCache.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 29/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

@property (nonatomic, retain) NSCache *imgCache;

+ (ImageCache*)sharedImageCache;
- (void) addImage:(UIImage *)image withURL:(NSString *)imageURL;
- (void) deleteImageWithKey:(NSString *)imageURL;
- (UIImage*) getImage:(NSString *)imageURL;
- (BOOL) doesExist:(NSString *)imageURL;

@end
