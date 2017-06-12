//
//  NSString+AttributtedNSString.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 21/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AttributtedNSString)

+ (NSAttributedString *)attributedMessageFromMessage:(NSString *)message withFont:(NSString *)textFont andSize:(NSNumber *)fontSize;

@end
