//
//  GSSocialNetworkHandler.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 25/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkHandler.h"

@implementation GSSocialNetworkHandler

- (void)dealloc{
    self.searchResults = nil;
}

- (void)loginUserToSocialNetwork{
    [self.delegate loginDidFailedWithError:nil];
}

- (void)searchUserFriendsInNetwork:(NSString*)query{
    [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusNotImplemented];
}

- (void)sendMessageToFriendInNetworkAtIndex:(NSInteger)index{
    [self.delegate didFailSendingMessage:GSSocialNetworkSearchStatusNotImplemented];
}

- (GSSocialNetworkFriend*)getSocialNetworkFriendWithEntry:(NSDictionary*)result{
    return nil;
}

- (void)getMoreFriends{
    [self.delegate searchFailedWithStatus:GSSocialNetworkSearchStatusSuccess];
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

@end
