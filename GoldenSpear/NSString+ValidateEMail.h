//
//  NSString+ValidateEMail.h
//  GoldenSpear
//
//  Created by Alberto Seco on 29/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ValidateEMail)

// Checks if a string fits into a regular expresion representing an email address
+ (BOOL)validateEmail:(NSString *)emailString;

@end
