//
//  NSString+CheckWhiteSpaces.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 17/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NSString+CheckWhiteSpaces.h"

@implementation NSString (CheckWhiteSpaces)

// Checks if a string contains white spaces
+ (BOOL)hasWhiteSpaces:(NSString *)string
{
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSRange whiteSpaceRange = [trimmedString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (whiteSpaceRange.location != NSNotFound)
    {
        return YES;
    }
    
    return NO;
}

@end
