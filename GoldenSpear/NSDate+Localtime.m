//
//  NSDate+Localtime.m
//  GoldenSpear
//
//  Created by Alberto Seco on 19/8/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "NSDate+Localtime.h"

@implementation NSDate (Localtime)

+(NSDate *) getLocalTime
{
    NSDate* sourceDate = [NSDate date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] ;
    
    return destinationDate;
}

@end
