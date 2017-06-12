//
//  Notification+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 17/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Notification+Manage.h"
#import "AppDelegate.h"

@interface Notification (PrimitiveAccessors)
- (NSString *)primitivePreviewImage;
@end

@implementation Notification (Manage)

-(NSString *) previewImage
{
    [self willAccessValueForKey:@"previewImage"];
    NSString *preview_image = [self primitivePreviewImage];
    [self didAccessValueForKey:@"previewImage"];
    
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
    
    //    self.picturePath = preview_image;
    
    return preview_image;
}

@end
