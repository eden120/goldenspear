//
//  GSSocialNetworkHandlerFacebook.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 25/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandlerFacebook.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface GSSocialNetworkHandlerFacebook ()

@end

@implementation GSSocialNetworkHandlerFacebook

- (void)loginUserToSocialNetwork{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile",@"user_friends"]
     fromViewController:(UIViewController*)self.delegate
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             [self.delegate loginDidFailedWithError:error];
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             [self.delegate loginDidFailedWithError:error];
             NSLog(@"Cancelled");
         } else {
             [self.delegate loginSuccessfulWithData:@{kSNLoginToken:result.token.tokenString,kSNLoginId:result.token.userID}];
         }
     }];
}

@end
