//
//  Follow+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 28/08/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Follow+CoreDataProperties.h"

@interface Follow (Manage)

@end

@interface setFollow : NSObject 

@property (nonatomic, retain) NSString * follow;

@end

@interface unsetFollow : NSObject 

@property (nonatomic, retain) NSString * unfollow;

@end

