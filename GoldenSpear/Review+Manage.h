//
//  Review+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Review.h"

@interface Review (Manage)

@end

@interface ReviewProductView : NSObject

@property (nonatomic, retain) NSString * reviewId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSDate * localtime;

@end
