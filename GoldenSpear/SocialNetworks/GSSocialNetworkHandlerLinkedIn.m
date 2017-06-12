//
//  GSSocialNetworkHandlerLinkedIn.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 27/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandlerLinkedIn.h"
#import <linkedin-sdk/LISDK.h>
#import "AppDelegate.h"

@implementation GSSocialNetworkHandlerLinkedIn

- (void)loginUserToSocialNetwork{
    [LISDKSessionManager
     createSessionWithAuth:[NSArray arrayWithObjects:LISDK_BASIC_PROFILE_PERMISSION, nil]
     state:nil
     showGoToAppStoreDialog:YES
     successBlock:^(NSString *returnState) {
         LISDKSession *session = [[LISDKSessionManager sharedInstance] session];
         [self.delegate loginSuccessfulWithData:@{kSNLoginToken:session.accessToken.accessTokenValue,kSNLoginId:@""}];
     }
     errorBlock:^(NSError *error) {
         [self.delegate loginDidFailedWithError:error];
         
     }
     ];
}

- (void)searchUserFriendsInNetwork:(NSString *)query{
    [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotImplemented];
    /*
    if([query isEqualToString:@""]){
        if([self.searchResults count]>0){
            [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:self.searchResults];
        }else{
            self.searchResults = [NSMutableArray new];
            [self downloadFriendsFromCursor:-1];
        }
    }else{
        [self searchBetweenResultsWithName:[query lowercaseString]];
    }
     */
}

- (void)downloadFriendsFromCursor:(NSInteger)cursor{
    NSString *friendsURL = @"http://api.linkedin.com/v1/people/~/connections?modified=new";
    
    [[LISDKAPIHelper sharedInstance] getRequest:friendsURL
                                        success:^(LISDKAPIResponse *response) {
                                            NSError *jsonError;
                                            NSData* data = [response.data dataUsingEncoding:NSUTF8StringEncoding];
                                            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                            [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:nil];
                                        }
                                          error:^(LISDKAPIError *error) {
                                              [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotConnected];
                                          }];
}

- (void)searchBetweenResultsWithName:(NSString*)query{
    NSMutableArray* queryResults = [NSMutableArray new];
    for(GSSocialNetworkFriend* f in self.searchResults){
        if([f.title rangeOfString:query].location!=NSNotFound ||
           [f.subtitle rangeOfString:query].location!=NSNotFound){
            [queryResults addObject:f];
        }
    }
    [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:queryResults];
}

- (GSSocialNetworkFriend*)getSocialNetworkFriendWithEntry:(NSDictionary*)result{
    GSSocialNetworkFriend* aFriend = [GSSocialNetworkFriend new];
    aFriend.socialNetwork = GSSocialNetworkOriginInstagram;
    aFriend.title = [result objectForKey:@"full_name"];
    aFriend.subtitle = [NSString stringWithFormat:@"@%@",[result objectForKey:@"username"]];
    aFriend.imgUrl = [result objectForKey:@"profile_picture"];
    aFriend.userId =[result objectForKey:@"id"];
    return aFriend;
}

@end
