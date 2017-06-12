//
//  GSAccountModule.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 14/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSAccountModule.h"

#define GSAccountModuleCaption  @"caption"
#define GSAccountModuleId       @"id"
#define GSAccountModuleElems    @"numElements"
#define GSAccountModuleOrder    @"order"
#define GSAccountModuleValues   @"values"
#define GSAccountModuleUserKey  @"userkey"

#define GSAccountModuleIdSocial         @"Social"
#define GSAccountModuleIdText           @"Text"
#define GSAccountModuleIdSwitch         @"Switch"
#define GSAccountModuleIdImage          @"Image"
#define GSAccountModuleIdVerification   @"Verification"
#define GSAccountModuleIdAgency         @"Agency"
#define GSAccountModuleIdModel          @"Model"

@implementation GSAccountModule

- (void)setModuleWithDictionary:(NSDictionary*)json{
    self.caption = [json objectForKey:GSAccountModuleCaption];
    self.moduleId = [json objectForKey:GSAccountModuleId];
    self.numElements = [[json objectForKey:GSAccountModuleElems] integerValue];
    self.order = [[json objectForKey:GSAccountModuleOrder] integerValue];
    self.values = [json objectForKey:GSAccountModuleValues];
    self.moduleType = [self moduleIdToType:self.moduleId];
    NSString* userKey = [json objectForKey:GSAccountModuleUserKey];
    if([userKey isEqualToString:@"user_title"]){
        userKey = @"fashionistaTitle";
    }
    self.userkey = userKey;
}

- (GSAccountModuleType)moduleIdToType:(NSString*)moduleId{
    GSAccountModuleType theType = GSAccountModuleSocial;
    if([moduleId isEqualToString:GSAccountModuleIdText]){
        theType = GSAccountModuleText;
    }else if([moduleId isEqualToString:GSAccountModuleIdSwitch]){
        theType = GSAccountModuleSwitch;
    }else if([moduleId isEqualToString:GSAccountModuleIdImage]){
        theType = GSAccountModuleImage;
    }else if([moduleId isEqualToString:GSAccountModuleIdVerification]){
        theType = GSAccountModuleVerification;
    }else if([moduleId isEqualToString:GSAccountModuleIdAgency]){
        theType = GSAccountModuleAgency;
    }else if([moduleId isEqualToString:GSAccountModuleIdModel]){
        theType = GSAccountModuleModel;
    }
    return theType;
}

@end
