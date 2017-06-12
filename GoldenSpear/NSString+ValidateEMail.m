//
//  NSString+ValidateEMail.m
//  GoldenSpear
//
//  Created by Alberto Seco on 29/4/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NSString+ValidateEMail.h"

@implementation NSString (ValidateEMail)

// Checks if a string fits into a regular expresion representing an email address
+ (BOOL)validateEmail:(NSString *)emailString
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

@end
