//
//  NSString+Morphing.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//


#import <Foundation/Foundation.h>

#define kKeyboardDictionaryKeyMergedString @"mergedString"
#define kKeyboardDictionaryKeyAdditionRanges @"additionRanges"
#define kKeyboardDictionaryKeyDeletionRanges @"deletionRanges"

@interface NSString (Morphing)

- (NSDictionary *)keyboardMergeIntoString:(NSString *)string;

- (NSDictionary *)keyboardMergeIntoString:(NSString *)string lookAheadRadius:(NSUInteger)lookAheadRadius;

@end
