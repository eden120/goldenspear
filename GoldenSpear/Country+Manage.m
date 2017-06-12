//
//  Country+Manage.m
//  GoldenSpear
//
//  Created by Alberto Seco on 27/10/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//

#import "Country+Manage.h"

@implementation Country (Manage)

-(NSArray *)getCallingCodes
{
    NSArray * arCallingCodes = [self.callingCodes componentsSeparatedByString:@"#"];
    
    return arCallingCodes;
}

@end
