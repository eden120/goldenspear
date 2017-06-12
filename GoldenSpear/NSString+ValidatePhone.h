//
//  NSString+ValidatePhone.h
//  GoldenSpear
//
//  Created by Alberto Seco on 5/5/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ValidatePhone)

// Checks if a string fits into a regular expresion representing an email address
+ (BOOL)validatePhone:(NSString *)emailString;

@end
