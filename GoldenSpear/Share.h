//
//  Share.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 06/10/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Share : NSManagedObject

@property (nonatomic, retain) NSString * idShare;
@property (nonatomic, retain) NSString * sharingUserId;
@property (nonatomic, retain) NSString * sharedPostId;
@property (nonatomic, retain) NSString * sharedProductId;

@end
