//
//  FashionistaPage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 03/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface FashionistaPage : NSManagedObject

@property (nonatomic, retain) NSString * idFashionistaPage;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * subcategory;
@property (nonatomic, retain) NSString * header_image;
@property (nonatomic, retain) NSNumber * header_image_width;
@property (nonatomic, retain) NSNumber * header_image_height;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * stat_viewnumber;
@property (nonatomic, retain) NSNumber * wardrobesPostNumber;
@property (nonatomic, retain) NSNumber * articlesPostNumber;
@property (nonatomic, retain) NSNumber * tutorialsPostNumber;
@property (nonatomic, retain) NSNumber * reviewsPostNumber;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * blogURL;
@property (nonatomic, retain) User *user;

@end
