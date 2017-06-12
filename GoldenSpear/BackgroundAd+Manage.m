//
//  BackgroundAd+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BackgroundAd+Manage.h"
#import "AppDelegate.h"

@interface BackgroundAd (PrimitiveAccessors)
- (NSString *)primitiveImageURL;
@end


@implementation BackgroundAd (Manage)

-(NSString *) imageURL
{
    [self willAccessValueForKey:@"imageURL"];
    NSString *preview_image = [self primitiveImageURL];
    [self didAccessValueForKey:@"imageURL"];
    
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

//-(NSString *) getImageURL
//{
//    NSString * imageURLToReturn = self.imageURL;
//    
//    if (self.imageURL != nil)
//    {
//        if(!([self.imageURL isEqualToString:@""]))
//        {
//            if(!([self.imageURL hasPrefix:IMAGESBASEURL]))
//            {
//                imageURLToReturn = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.imageURL];
//            }
//        }
//        
//        if(!NSEqualRanges( [self.imageURL rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
//        {
//            imageURLToReturn = [self.imageURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//        }
//    }
//    
//    return imageURLToReturn;
//}

@end
