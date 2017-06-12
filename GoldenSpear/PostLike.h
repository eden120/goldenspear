//
//  PostLike.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 05/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostLike : NSManagedObject

@property (nonatomic, retain) NSString * idPostLike;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * userId;

@end
