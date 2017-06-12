//
//  keyboardIDGenerator.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 02/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "keyboardIDGenerator.h"
#import <CommonCrypto/CommonDigest.h>

#define kKeyboardUUIDKey @"com.gs.kKeyboardUUIDKey"
#define kKeyboardTimeStamp [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000]


@interface keyboardIDGenerator ()

@property (readwrite, atomic, strong) NSString *UUID;

@end

@implementation keyboardIDGenerator

@synthesize UUID = _UUID;

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static keyboardIDGenerator *_sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - ID Generation

- (NSString *)UUID
{
    @synchronized([keyboardIDGenerator sharedInstance]) {
        if (!_UUID) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            _UUID = [userDefaults objectForKey:kKeyboardUUIDKey];
            
            if (!_UUID || !_UUID.length) {
                _UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                [userDefaults setObject:_UUID forKey:kKeyboardUUIDKey];
            }
        }
        
        return _UUID;
    }
}

+ (NSString *)uniqueIdentifier
{
    @synchronized([keyboardIDGenerator sharedInstance]) {
        return [self sha1RepresentationOfString:[NSString stringWithFormat:@"%@%@", [keyboardIDGenerator sharedInstance].UUID, kKeyboardTimeStamp]];
    }
}

#pragma mark - SHA1 Helper

+ (NSString *)sha1RepresentationOfString:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

#pragma mark - Atomic Setters

- (void)setUUID:(NSString *)UUID
{
    @synchronized([keyboardIDGenerator sharedInstance]) {
        _UUID = UUID;
    }
}

@end
