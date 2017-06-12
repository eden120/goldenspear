//
//  GSAccountModule.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 14/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GSAccountModuleSocial = 0,
    GSAccountModuleText,
    GSAccountModuleSwitch,
    GSAccountModuleImage,
    GSAccountModuleVerification,
    GSAccountModuleAgency,
    GSAccountModuleModel
} GSAccountModuleType;

@interface GSAccountModule : NSObject

@property (nonatomic) GSAccountModuleType moduleType;
@property (nonatomic,retain) NSString* caption;
@property (nonatomic,retain) NSString* moduleId;
@property (nonatomic) NSInteger numElements;
@property (nonatomic) NSInteger order;
@property (nonatomic,retain) NSArray* values;
@property (nonatomic,retain) NSString* userkey;

- (void)setModuleWithDictionary:(NSDictionary*)json;

@end
