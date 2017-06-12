//
//  NSString+ValidateURL.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 12/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NSString+ValidateURL.h"

@implementation NSString (ValidateURL)

// Checks if a string fits into a regular expresion representing an URL
+ (BOOL)validateURL: (NSString *) urlString
{
//    NSString *urlRegex = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";

    NSString *urlRegex = @"((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";

    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    
    return [urlTest evaluateWithObject:urlString];

//    NSURL *checkURL = [NSURL URLWithString:urlString];
//
//    // checkURL is a well-formed url with:
//    //  - a scheme (like http://)
//    //  - a host (like stackoverflow.com)
//    return (checkURL /*&& checkURL.scheme*/ && checkURL.host);
}

@end
