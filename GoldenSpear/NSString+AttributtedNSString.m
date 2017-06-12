//
//  NSString+AttributtedNSString.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 21/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "NSString+AttributtedNSString.h"
@import AVKit;


@implementation NSString (AttributtedNSString)


NSString * const hashTagKey = @"HashTag";
NSString * const userNameKey = @"UserName";
NSString * const normalKey = @"NormalKey";
NSString * const wordType = @"WordType";

+ (NSAttributedString *)attributedMessageFromMessage:(NSString *)message withFont:(NSString *)textFont andSize:(NSNumber *)fontSize
{
    NSArray* messageWords = [message componentsSeparatedByString: @" "];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:@""];
    
    for (NSString *word in messageWords)
    {
        NSDictionary * attributes;
        
        if([word length] > 0)
        {
            if([word characterAtIndex:0] == '@')
            {
                attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.65 green:0.50 blue:0.16 alpha:1.0],
                               wordType: userNameKey,
                               userNameKey:[word substringFromIndex:1],
                               NSFontAttributeName:[UIFont fontWithName:textFont size:[fontSize intValue]]};
                
            }
            else if([word characterAtIndex:0] == '#')
            {
                attributes = @{NSForegroundColorAttributeName:[UIColor blueColor],
                               wordType: hashTagKey,
                               hashTagKey:[word substringFromIndex:1],
                               NSFontAttributeName:[UIFont fontWithName:textFont size:[fontSize intValue]]};
                
            }
            else
            {
                attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                               wordType: normalKey,
                               NSFontAttributeName:[UIFont fontWithName:textFont size:[fontSize intValue]]};
            }
        }
        else
        {
            attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                           wordType: normalKey,
                           NSFontAttributeName:[UIFont fontWithName:textFont size:[fontSize intValue]]};
        }
        
        NSAttributedString * subString = [[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@ ",word]
                                          attributes:attributes];
        
        [attributedMessage appendAttributedString:subString];
    }
    
    return attributedMessage;
}

@end
