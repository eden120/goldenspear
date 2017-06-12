//
//  Review+Manage.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Review+Manage.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

//static char VIDEOPOSTCONTENT_KEY;

@interface Review (PrimitiveAccessors)
- (NSString *)primitiveVideo;
@end



@implementation Review (Manage)


-(NSString *) video
{
    [self willAccessValueForKey:@"video"];
    NSString *video = [self primitiveVideo];
    [self didAccessValueForKey:@"video"];
    
    //    NSString * preview_image = self.preview_image;
    if (video != nil)
    {
        if(!([video isEqualToString:@""]))
        {
            if((!([video hasPrefix:IMAGESBASEURL])) && (!([video hasPrefix:@"file:///"])))
            {
                video = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, video];
                //                        self.video_path = [NSString stringWithFormat:@"%@%@",IMAGESBASEURL, self.video];
            }
        }
        
        if(!NSEqualRanges( [video rangeOfString:@" "], NSMakeRange(NSNotFound, 0) ) )
        {
            video = [video stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            //                    self.video_path = [self.video stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
    }
    
    return video;
}


@end

@implementation ReviewProductView

@end
