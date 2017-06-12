//
//  Comment+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 04/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Comment.h"

@interface Comment (Manage)

@end

@interface CommentView : NSObject

@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSDate * localtime;

@end

@interface PostCommentReport : NSObject

@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * reportType;

@end
