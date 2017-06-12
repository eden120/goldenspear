//
//  GSSocialNetworkHandlerTwitter.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 27/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandlerTwitter.h"
#import <TwitterKit/TwitterKit.h>

@implementation GSSocialNetworkHandlerTwitter{
    NSInteger lastPageServed;
    NSMutableArray* friendsDownloaded;
}

- (void)loginUserToSocialNetwork{
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            [self.delegate loginSuccessfulWithData:@{kSNLoginToken:[NSString stringWithFormat:@"%@_--_%@",session.authToken,session.authTokenSecret],kSNLoginId:session.userID}];
            NSLog(@"signed in as %@", [session userName]);
        } else {
            [self.delegate loginDidFailedWithError:error];
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
}

- (void)downloadFriendsFromCursor:(NSInteger)cursor{
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSString *followingURL = @"https://api.twitter.com/1.1/friends/ids.json";
    NSDictionary *params = @{@"id" : userID,@"cursor":[NSString stringWithFormat:@"%ld",cursor]};
    
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:followingURL parameters:params error:&clientError];
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                [friendsDownloaded addObjectsFromArray:[json objectForKey:@"ids"]];
                NSNumber* nextCursor = [json objectForKey:@"next_cursor"];
                if ([nextCursor integerValue] > 0) {
                    [self downloadFriendsFromCursor:[nextCursor integerValue]];
                }else{
                    [self getTwitterUsersWithIds:friendsDownloaded];
                }
            }
            else {
                [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotConnected];
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotConnected];
    }
}

- (void)searchUserFriendsInNetwork:(NSString *)query{
    if([query isEqualToString:@""]){
        if([self.searchResults count]>0){
            [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:self.searchResults];
        }else{
            friendsDownloaded = [NSMutableArray new];
            lastPageServed = 0;
            self.searchResults = [NSMutableArray new];
            [self downloadFriendsFromCursor:-1];
        }
    }else{
        [self searchBetweenResultsWithName:[query lowercaseString]];
    }
}

- (void)getTwitterUsersWithIds:(NSArray*)usersIds{
    NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSString *followingURL = @"https://api.twitter.com/1.1/users/lookup.json";
    NSMutableString* userIDs = [NSMutableString new];
    NSInteger fetchVolume = 30;
    for (NSInteger i = fetchVolume*lastPageServed; i<[usersIds count]&&i<fetchVolume*(lastPageServed+1); i++) {
        if ([userIDs length]>0) {
            [userIDs appendString:@","];
        }
        [userIDs appendString:[[usersIds objectAtIndex:i]stringValue]];
    }
    lastPageServed++;
    NSDictionary *params = @{@"user_id" : userIDs};
    NSError *clientError;
    
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:followingURL parameters:params error:&clientError];
    
    if (request) {
        [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (data) {
                // handle the response data e.g.
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                //convertir en objetos de friends
                NSMutableArray* friendsArray = [NSMutableArray new];
                for (NSDictionary* user in json) {
                    GSSocialNetworkFriend* friend = [self getSocialNetworkFriendWithEntry:user];
                    [friendsArray addObject:friend];
                }
                [self.searchResults addObjectsFromArray:friendsArray];
                [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:friendsArray];
            }
            else {
                [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotConnected];
                NSLog(@"Error: %@", connectionError);
            }
        }];
    }
    else {
        NSLog(@"Error: %@", clientError);
        [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotConnected];
    }
}

- (void)getMoreFriends{
    if ([self.searchResults count]<[friendsDownloaded count]) {
        [self getTwitterUsersWithIds:friendsDownloaded];
    }else{
        [self.delegate searchSucceedWithStatus:GSSocialNetworkSearchStatusSuccess andResults:nil];
    }
    
}

- (GSSocialNetworkFriend*)getSocialNetworkFriendWithEntry:(NSDictionary*)result{
    GSSocialNetworkFriend* aFriend = [GSSocialNetworkFriend new];
    aFriend.socialNetwork = GSSocialNetworkOriginTwitter;
    aFriend.title = [result objectForKey:@"name"];
    aFriend.subtitle = [NSString stringWithFormat:@"@%@",[result objectForKey:@"screen_name"]];
    aFriend.imgUrl = [result objectForKey:@"profile_image_url"];
    aFriend.userId =[result objectForKey:@"id_str"];
    return aFriend;
}

- (void)sendMessageToFriendInNetworkAtIndex:(NSInteger)index{
    if(index<[self.searchResults count]){
        GSSocialNetworkFriend* friend = [self.searchResults objectAtIndex:index];
        
        NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
        NSString *followingURL = @"https://api.twitter.com/1.1/direct_messages/new.json";

        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                friend.userId,@"user_id",
                                NSLocalizedString(@"_INVITE_TWITTER_", nil),@"text",
                                nil];
        NSError *clientError;
        
        NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:followingURL parameters:params error:&clientError];
        if (request) {
            [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (data) {
                    [self.delegate succesfullyMessageSent];
                }
                else {
                    [self.delegate didFailSendingMessage:GSSocialNetworkSearchStatusNotConnected];
                }
            }];
        }
        else {
            [self.delegate didFailSendingMessage:GSSocialNetworkSearchStatusNotConnected];
        }
    }
}

@end
