//
//  NSString+ValidatePhone.m
//  GoldenSpear
//
//  Created by Alberto Seco on 5/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NSString+ValidatePhone.h"

@implementation NSString (ValidatePhone)

// Checks if a string fits into a regular expresion representing an email address
+ (BOOL)validatePhone:(NSString *)emailString
{
    NSString *emailRegex = @"^([+]{0,1})([0-9()\\s-.]+)$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

@end
