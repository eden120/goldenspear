//
//  BackgroundAd.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 25/09/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BackgroundAd : NSManagedObject

@property (nonatomic, retain) NSString * idBackgroundAd;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * mainInformation;
@property (nonatomic, retain) NSString * secondaryInformation;

@end
