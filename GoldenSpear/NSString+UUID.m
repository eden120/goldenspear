//
//  NSString+UUID.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 08/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)uuid
{
    NSString *uuidString = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    
    if (uuid)
    {
        uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        
        CFRelease(uuid);
    }
    
    return uuidString;
}

@end
