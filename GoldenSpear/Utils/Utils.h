//
//  Utils.h
//  VauntBroadcaster
//
//  Created by Master on 7/14/15.
//  Copyright (c) 2015 Vaunt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (BOOL)validateEmail: (NSString *)candidate;

+ (void)setObjectToUserDefaults:(id)object inUserDefaultsForKey:(NSString*)key;
+ (id)getObjectFromUserDefaultsForKey:(NSString *)key;

+ (UIImage*)imageFromColor:(UIColor*)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;


+(void)CustomiseView:(UIView *)view withColor:(UIColor*)color withWidth:(float)width withCorner:(float)corner;


+ (UIBezierPath*)createPath:(NSArray*)ary withView:(UIView*)view;
+ (CGRect)getFrameByInfo:(NSDictionary*)info withView:(UIView*)view;
+ (UIImage *)changeBlackColorTransparent: (UIImage *)image;
@end


@interface NSString (containsCategory)
- (BOOL) containsString:(NSString *)substring;

@end
