//
//  Wardrobe+Manage.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 24/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "Wardrobe+CoreDataProperties.h"

@interface Wardrobe (Manage)

@end

@interface WardrobeView : NSObject

@property (nonatomic, retain) NSString * wardrobeId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * statProductQueryId;
@property (nonatomic, retain) NSString * fingerprint;
@property (nonatomic, retain) NSDate * localtime;

@end
