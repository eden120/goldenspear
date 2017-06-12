//
//  NSString+stringBetweenStrings.m
//  GoldenSpear
//
//  Created by Alberto Seco on 3/11/15.
//  Copyright © 2015 GoldenSpear. All rights reserved.
//

#import "NSString+stringBetweenStrings.h"

@implementation NSString (stringBetweenStrings)
- (NSString*) stringBetweenString:(NSString*)start andString:(NSString*)end {
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [self length] - targetRange.location;
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}
@end
