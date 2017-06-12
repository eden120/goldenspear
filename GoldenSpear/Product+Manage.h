//
//  Product+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Product.h"
#import "NSObject+ButtonSlideView.h"

@interface Product (Manage)

@end


@interface ProductView : NSObject

@property (nonatomic, retain) NSString * idProductView;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSString * origindetail;
@property (nonatomic, retain) NSDate * localtime;

@end

@interface ProductShared : NSObject

@property (nonatomic, retain) NSString * idProductShared;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSString * origindetail;
@property (nonatomic, retain) NSString * socialNetwork;
@property (nonatomic, retain) NSDate * localtime;


@end

@interface ProductPurchase : NSObject

@property (nonatomic, retain) NSString * idProductPurchase;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * statProductViewId;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSDate * localtime;

@end

@interface ProductReport : NSObject

@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * reportType;

@end

@interface ProductAvailability: NSObject

@property (nonatomic, retain) NSNumber * online;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * storename;
@property (nonatomic, retain) NSString * shoppingcenter;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * units;
@property (nonatomic, retain) NSSet * timetables;


@end

@interface ProductAvailabilityTimeTable: NSObject

@property (nonatomic, retain) NSNumber * dayweek;
@property (nonatomic, retain) NSSet * hours;

@end


@interface ProductAvailabilityTimeTableIntervalTime: NSObject

@property (nonatomic, retain) NSString * open;
@property (nonatomic, retain) NSString * close;

@end


