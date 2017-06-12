//
//  FashionistaPost+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 03/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "FashionistaPost+CoreDataProperties.h"

@interface FashionistaPost (Manage)

//@property (nonatomic, retain) NSString * preview_image_path;

@end

@interface FashionistaPostView : NSObject

@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSDate * localtime;

@end

@interface FashionistaPostViewTime : NSObject

@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * fingerprint;

@end

@interface FashionistaPostShared : NSObject

@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSString * socialNetwork;
@property (nonatomic, retain) NSDate * localtime;

@end

@interface PostContentReport : NSObject

@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * reportType;

@end

@interface PostUserUnfollow : NSObject

@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * pufId;

@end
