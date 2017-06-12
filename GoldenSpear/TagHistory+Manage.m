//
//  TagHistory+Manage.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 19/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "TagHistory+Manage.h"
#import "AppDelegate.h"

@interface TagHistory (PrimitiveAccessors)
- (NSString *)primitiveTaggerPicture;
- (NSString *)primitivePostPreview;
@end

@implementation TagHistory (Manage)

-(NSString *) taggerPicture
{
    [self willAccessValueForKey:@"taggerPicture"];
    NSString *preview_image = [self primitiveTaggerPicture];
    [self didAccessValueForKey:@"taggerPicture"];
    
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
    
    //    self.picturePath = preview_image;
    
    return preview_image;
}

-(NSString *) postPreview
{
    [self willAccessValueForKey:@"postPreview"];
    NSString *preview_image = [self primitivePostPreview];
    [self didAccessValueForKey:@"postPreview"];
    
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

@end