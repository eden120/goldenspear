//
//  NSString+ValidateURL.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 12/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ValidateURL)

// Checks if a string fits into a regular expresion representing an URL
+ (BOOL)validateURL: (NSString *) urlString;

@end
