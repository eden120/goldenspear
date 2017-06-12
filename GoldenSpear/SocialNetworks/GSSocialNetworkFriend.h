//
//  GSSocialNetworkFriend.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 25/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
        GSSocialNetworkOriginFacebook,
    GSSocialNetworkOriginTwitter,
    GSSocialNetworkOriginInstagram,
    GSSocialNetworkOriginPinterest,
    GSSocialNetworkOriginTumblr,
    GSSocialNetworkOriginFlicker,
    GSSocialNetworkOriginLinkedIn,
    GSSocialNetworkOriginSnapChat,
    GSSocialNetworkOriginEmail
}GSSocialNetworkOrigin;

@interface GSSocialNetworkFriend : NSObject

@property (nonatomic,strong) NSString* userId;
@property (nonatomic,strong) NSString* imgUrl;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* subtitle;
@property (nonatomic) GSSocialNetworkOrigin socialNetwork;

@end
