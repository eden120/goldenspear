//
//  Review.h
//  GoldenSpear
//
//  Created by JAVIER CASTAN SANCHEZ on 12/8/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSNumber * comfort_rating;
@property (nonatomic, retain) NSString * idReview;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * overall_rating;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSNumber * quality_rating;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * video;
@property (nonatomic, retain) User *user;

@end
