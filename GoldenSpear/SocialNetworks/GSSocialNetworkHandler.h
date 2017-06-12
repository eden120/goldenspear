//
//  GSSocialNetworkHandler.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 25/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSSocialNetworkFriend.h"
#import <UIKit/UIKit.h>

#define kSNLoginToken   @"loginToken"
#define kSNLoginId      @"loginId"

typedef enum{
    GSSocialNetworkSearchStatusNotFound,
    GSSocialNetworkSearchStatusSuccess,
    GSSocialNetworkSearchStatusNotConnected,
    GSSocialNetworkSearchStatusNotImplemented
}GSSocialNetworkSearchStatus;

@protocol GSSocialNetworkHandlerDelegate <NSObject>

@optional
- (void)loginSuccessfulWithData:(NSDictionary*)loginData;
- (void)loginDidFailedWithError:(NSError*)error;
- (void)searchFailedWithStatus:(GSSocialNetworkSearchStatus)status;
- (void)searchSucceedWithStatus:(GSSocialNetworkSearchStatus)status andResults:(NSArray*)results;
- (void)succesfullyMessageSent;
- (void)didFailSendingMessage:(GSSocialNetworkSearchStatus)status;

@end

@interface GSSocialNetworkHandler : NSObject{
    NSString* lastQuery;
}

@property (nonatomic,weak) id<GSSocialNetworkHandlerDelegate> delegate;
@property (nonatomic,strong) NSMutableArray* searchResults;

- (void)loginUserToSocialNetwork;
- (void)searchUserFriendsInNetwork:(NSString*)query;
- (void)sendMessageToFriendInNetworkAtIndex:(NSInteger)index;
- (GSSocialNetworkFriend*)getSocialNetworkFriendWithEntry:(NSDictionary*)result;
- (void)getMoreFriends;
- (void)searchBetweenResultsWithName:(NSString*)query;

@end
